-- "Extend in PYZ" and core<->project navigation, after the PhpStorm PYZ plugin.
-- https://plugins.jetbrains.com/plugin/18215-pyz

local paths = require("tron.pyz.paths")
local php = require("tron.pyz.php")

local M = {}

local function warn(message)
	vim.notify(message, vim.log.levels.WARN, { title = "PYZ" })
end

local function info(message)
	vim.notify(message, vim.log.levels.INFO, { title = "PYZ" })
end

--- Imports from the core file that the copied signature actually needs.
local function required_imports(source_bufnr, method)
	if not method then
		return {}
	end

	local available = php.imports(source_bufnr)
	local needed = {}
	for _, short_name in ipairs(php.referenced_types(method.signature)) do
		if available[short_name] then
			table.insert(needed, available[short_name])
		end
	end
	return needed
end

--- Insert `use` statements that the file is missing, after the last existing import.
local function ensure_imports(bufnr, statements)
	if #statements == 0 then
		return 0
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local last_use, namespace_line = nil, nil
	for index, line in ipairs(lines) do
		if line:match("^use%s") then
			last_use = index
		elseif line:match("^namespace%s") then
			namespace_line = index
		end
	end

	local missing = {}
	for _, statement in ipairs(statements) do
		local short_name = statement:match("([%w_]+)$")
		local already_present = false
		for _, line in ipairs(lines) do
			if line:match("^use%s") and line:match("[\\%s]" .. vim.pesc(short_name) .. "%s*;") then
				already_present = true
				break
			end
		end
		if not already_present then
			table.insert(missing, ("use %s;"):format(statement))
		end
	end
	if #missing == 0 then
		return 0
	end

	local insert_at = last_use or namespace_line
	if not insert_at then
		return 0
	end
	if not last_use then
		table.insert(missing, 1, "")
	end

	vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, missing)
	return #missing
end

--- Append a method stub into an existing project-level file, before its closing brace.
local function append_method(target_path, method, extra_imports)
	local bufnr = vim.fn.bufadd(target_path)
	vim.fn.bufload(bufnr)

	local declaration = php.declaration(bufnr)
	if not declaration then
		warn("Could not find a declaration in " .. vim.fn.fnamemodify(target_path, ":~:."))
		return
	end

	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		if line:match("function%s+" .. vim.pesc(method.name) .. "%s*%(") then
			info(("%s() already exists in %s"):format(method.name, declaration.name))
			vim.cmd.edit(vim.fn.fnameescape(target_path))
			return
		end
	end

	-- Add imports first; this shifts the line numbers used below.
	ensure_imports(bufnr, extra_imports or {})
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Insert above the final closing brace.
	local insert_at = #lines
	for index = #lines, 1, -1 do
		if lines[index]:match("^%s*}%s*$") then
			insert_at = index - 1
			break
		end
	end

	local stub = php.render_method(method, declaration.kind)
	-- Keep one blank line between members.
	if insert_at > 0 and lines[insert_at] and lines[insert_at]:match("%S") then
		table.insert(stub, 1, "")
	end

	vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, stub)
	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd.write()
	end)

	vim.cmd.edit(vim.fn.fnameescape(target_path))
	vim.api.nvim_win_set_cursor(0, { math.min(insert_at + #stub, vim.api.nvim_buf_line_count(0)), 0 })
	info(("Added %s() to %s"):format(method.name, declaration.name))
end

--- Extend a Spryker core file on project level.
--- @param opts table|nil
---   method: boolean - also stub the method under the cursor (current buffer only)
---   path:   string  - extend this file instead of the current buffer
function M.extend(opts)
	opts = opts or {}

	local bufnr, source
	if opts.path then
		source = vim.fn.fnamemodify(opts.path, ":p")
		if not vim.uv.fs_stat(source) then
			warn("No such file: " .. source)
			return
		end
		-- Load without displaying; php.lua parses with an explicit language, so the
		-- buffer needs no filetype for treesitter to work.
		bufnr = vim.fn.bufadd(source)
		vim.fn.bufload(bufnr)
	else
		bufnr = vim.api.nvim_get_current_buf()
		source = vim.api.nvim_buf_get_name(bufnr)
		if vim.bo[bufnr].filetype ~= "php" then
			warn("Not a PHP buffer")
			return
		end
	end

	local parts, err = paths.parse_core_path(source)
	if not parts then
		warn("Not a Spryker core file: " .. err)
		return
	end

	local root_dir = paths.project_root(source)
	if not root_dir then
		warn("Could not locate the project root (no composer.json or .git found)")
		return
	end

	local declaration = php.declaration(bufnr)
	if not declaration then
		warn("No class, interface, trait or enum found in this file")
		return
	end

	local core_namespace = php.namespace(bufnr)
	if not core_namespace then
		warn("Core file declares no namespace")
		return
	end

	local method
	if opts.method then
		method = php.method_at_cursor(bufnr)
		if not method then
			warn("No method under the cursor")
			return
		end
	end

	local extra_imports = required_imports(bufnr, method)
	local target = paths.target_for(parts, root_dir)
	local relative_target = vim.fn.fnamemodify(target.path, ":~:.")

	if vim.uv.fs_stat(target.path) then
		if method then
			append_method(target.path, method, extra_imports)
		else
			info("Already extended: " .. relative_target)
			vim.cmd.edit(vim.fn.fnameescape(target.path))
		end
		return
	end

	local method_lines = method and php.render_method(method, declaration.kind) or nil
	local contents = php.render_class({
		namespace = target.namespace,
		core_namespace = core_namespace,
		class_name = declaration.name,
		kind = declaration.kind,
		abstract = declaration.abstract,
		method_lines = method_lines,
		extra_imports = extra_imports,
	})

	vim.fn.mkdir(target.dir, "p")
	vim.fn.writefile(contents, target.path)

	vim.cmd.edit(vim.fn.fnameescape(target.path))
	-- Land the cursor inside the body, ready to type.
	local body_line = #contents - (method_lines and #method_lines or 0) - 1
	vim.api.nvim_win_set_cursor(0, { math.max(body_line, 1), 0 })

	info(("Created %s (%s)"):format(relative_target, declaration.kind))
end

--- Jump between a project-level file and the core file it extends.
function M.goto_counterpart()
	local bufnr = vim.api.nvim_get_current_buf()
	local current = vim.api.nvim_buf_get_name(bufnr)

	local root_dir = paths.project_root(current)
	if not root_dir then
		warn("Could not locate the project root")
		return
	end

	-- Core file -> project counterpart.
	local parts = paths.parse_core_path(current)
	if parts then
		local target = paths.target_for(parts, root_dir)
		if vim.uv.fs_stat(target.path) then
			vim.cmd.edit(vim.fn.fnameescape(target.path))
		else
			warn("Not extended on project level yet: " .. vim.fn.fnamemodify(target.path, ":~:."))
		end
		return
	end

	local function open(fqn)
		local found = paths.find_core_file(fqn, root_dir)
		if found then
			vim.cmd.edit(vim.fn.fnameescape(found))
		else
			warn("Could not find a core file for " .. fqn)
		end
	end

	local imports = php.imports(bufnr)

	-- Project file -> the core type it inherits from. The extends/use clause names the
	-- parent unambiguously, so resolve that rather than guessing among the imports.
	local parent = php.parent_name(bufnr)
	if parent then
		local short_name = parent:match("([%w_]+)$")
		local statement = imports[short_name]
		-- `use Core\Thing as SprykerThing;` -> the FQN before the alias.
		local fqn = statement and statement:match("^([%w_\\]+)") or parent
		if fqn:match("^\\?Spryker") then
			open(fqn)
			return
		end
	end

	-- No inherited parent (or it is not core): offer the core imports instead.
	local candidates = {}
	for _, statement in pairs(imports) do
		local fqn = statement:match("^([%w_\\]+)")
		if fqn and fqn:match("^Spryker") then
			table.insert(candidates, fqn)
		end
	end
	table.sort(candidates)

	if #candidates == 0 then
		warn("No Spryker core parent or import found in this file")
		return
	end

	if #candidates == 1 then
		open(candidates[1])
		return
	end

	vim.ui.select(candidates, { prompt = "Jump to core class:" }, function(choice)
		if choice then
			open(choice)
		end
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("PyzExtend", function()
		M.extend()
	end, { desc = "PYZ: extend this Spryker core file on project level" })

	vim.api.nvim_create_user_command("PyzExtendMethod", function()
		M.extend({ method = true })
	end, { desc = "PYZ: extend this core file and stub the method under the cursor" })

	vim.api.nvim_create_user_command("PyzGotoCounterpart", function()
		M.goto_counterpart()
	end, { desc = "PYZ: jump between core and project-level file" })

	vim.api.nvim_create_user_command("PyzFind", function()
		require("tron.pyz.picker").extend_picker()
	end, { desc = "PYZ: browse Spryker core files and extend one" })

	-- The picker needs no PHP buffer, so it is bound globally.
	vim.keymap.set("n", "<leader>pf", function()
		require("tron.pyz.picker").extend_picker()
	end, { desc = "PYZ: Find core file to extend" })

	-- The rest act on the current file, so they only exist in PHP buffers.
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "php",
		desc = "PYZ keymaps",
		callback = function(event)
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
			end

			map("<leader>pe", M.extend, "PYZ: Extend in Pyz")
			map("<leader>pE", function()
				M.extend({ method = true })
			end, "PYZ: Extend method in Pyz")
			map("<leader>pg", M.goto_counterpart, "PYZ: Go to core/project counterpart")
		end,
	})
end

return M
