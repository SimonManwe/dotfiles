-- Treesitter-backed reading of PHP buffers: what kind of declaration is this,
-- what namespace is it in, and which method is under the cursor.

local M = {}

-- Spryker follows PSR-12: four spaces, never tabs.
local INDENT = "    "

local DECLARATIONS = {
	class_declaration = "class",
	interface_declaration = "interface",
	trait_declaration = "trait",
	enum_declaration = "enum",
}

local function root_node(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "php")
	if not ok or not parser then
		return nil
	end
	local tree = parser:parse()[1]
	return tree and tree:root() or nil
end

local function text(node, bufnr)
	return node and vim.treesitter.get_node_text(node, bufnr) or nil
end

--- The declared namespace of the buffer, or nil for a namespace-less file.
function M.namespace(bufnr)
	local root = root_node(bufnr)
	if not root then
		return nil
	end
	for child in root:iter_children() do
		if child:type() == "namespace_definition" then
			local name = child:field("name")[1]
			return text(name, bufnr)
		end
	end
	return nil
end

--- The name this type extends, or the trait it composes — the thing a project-level
--- file inherits from. Returns the name as written (possibly an alias), not an FQN.
function M.parent_name(bufnr)
	local root = root_node(bufnr)
	if not root then
		return nil
	end

	local found

	local function walk(node, depth)
		if found or depth > 4 then
			return
		end
		local kind = node:type()
		-- `extends X` on a class, or `extends X, Y` on an interface.
		if kind == "base_clause" then
			for child in node:iter_children() do
				if child:named() and child:type() ~= "extends" then
					found = text(child, bufnr)
					return
				end
			end
		-- A trait composes its parent via `use X;` inside the body.
		elseif kind == "use_declaration" then
			for child in node:iter_children() do
				if child:named() then
					found = text(child, bufnr)
					return
				end
			end
		end
		for child in node:iter_children() do
			walk(child, depth + 1)
		end
	end

	walk(root, 0)
	return found
end

--- Every `use Foo\Bar;` import in the buffer, keyed by the short name it binds.
--- Grouped and function/const imports are out of scope; signatures never use them.
function M.imports(bufnr)
	local root = root_node(bufnr)
	if not root then
		return {}
	end

	local found = {}
	for child in root:iter_children() do
		if child:type() == "namespace_use_declaration" then
			local statement = text(child, bufnr) or ""
			-- Skip `use function ...` / `use const ...` and grouped `use A\{B, C};`.
			if not statement:match("^use%s+function") and not statement:match("^use%s+const") and not statement:match("{") then
				local fqn, alias = statement:match("use%s+([%w_\\]+)%s+as%s+([%w_]+)%s*;")
				if fqn then
					found[alias] = ("%s as %s"):format(fqn, alias)
				else
					local plain = statement:match("use%s+([%w_\\]+)%s*;")
					if plain then
						found[plain:match("([%w_]+)$")] = plain
					end
				end
			end
		end
	end
	return found
end

--- Type names referenced by a signature, so only relevant imports get copied over.
function M.referenced_types(signature)
	local seen, names = {}, {}
	-- Strip parameter names and default values, leaving type positions.
	local types = signature:gsub("%$[%w_]+", ""):gsub("=%s*[^,%)]+", "")
	for name in types:gmatch("[%a_][%w_\\]*") do
		local short = name:match("^([%w_]+)")
		if short and not seen[short] then
			seen[short] = true
			table.insert(names, short)
		end
	end
	return names
end

--- The top-level type declared in the buffer.
--- @return table|nil { kind = "class"|"interface"|..., name = string, abstract = boolean }
function M.declaration(bufnr)
	local root = root_node(bufnr)
	if not root then
		return nil
	end

	local function search(node)
		for child in node:iter_children() do
			local kind = DECLARATIONS[child:type()]
			if kind then
				local abstract = false
				for modifier in child:iter_children() do
					if modifier:type() == "abstract_modifier" then
						abstract = true
					end
				end
				return {
					kind = kind,
					name = text(child:field("name")[1], bufnr),
					abstract = abstract,
				}
			end
			-- Declarations may sit inside a braced `namespace Foo { ... }` block.
			if child:type() == "namespace_definition" or child:type() == "declaration_list" then
				local found = search(child)
				if found then
					return found
				end
			end
		end
		return nil
	end

	return search(root)
end

--- The method declaration surrounding the cursor, with its leading docblock.
--- @return table|nil { name = string, signature = string, docblock = string|nil, abstract = boolean }
function M.method_at_cursor(bufnr, winnr)
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = (function()
		local cursor = vim.api.nvim_win_get_cursor(winnr or 0)
		return { cursor[1] - 1, cursor[2] }
	end)() })

	while node and node:type() ~= "method_declaration" do
		node = node:parent()
	end
	if not node then
		return nil
	end

	local name = text(node:field("name")[1], bufnr)
	if not name then
		return nil
	end

	-- Rebuild the signature from parts so the body and any trailing whitespace
	-- are dropped, keeping modifiers/params/return type intact.
	local modifiers, abstract = {}, false
	for child in node:iter_children() do
		local kind = child:type()
		if kind == "visibility_modifier" or kind == "static_modifier" or kind == "final_modifier" then
			table.insert(modifiers, text(child, bufnr))
		elseif kind == "abstract_modifier" then
			abstract = true
		end
	end
	if #modifiers == 0 then
		modifiers = { "public" }
	end

	local params = text(node:field("parameters")[1], bufnr) or "()"
	local return_type = text(node:field("return_type")[1], bufnr)

	local signature = ("%s function %s%s"):format(table.concat(modifiers, " "), name, params)
	if return_type then
		signature = signature .. ": " .. return_type
	end

	local docblock
	local previous = node:prev_named_sibling()
	if previous and previous:type() == "comment" then
		local comment = text(previous, bufnr)
		if comment and comment:match("^/%*%*") then
			docblock = comment
		end
	end

	return {
		name = name,
		signature = signature,
		docblock = docblock,
		abstract = abstract,
		-- `return parent::foo();` is illegal when the parent returns void.
		returns_void = return_type == "void" or return_type == "never",
	}
end

--- Render the body of a method that simply delegates upward.
local function delegating_body(method, kind)
	if kind == "interface" then
		return nil -- interfaces carry no body
	end
	if method.abstract then
		return { INDENT:rep(2) .. "// TODO: implement " .. method.name }
	end

	local arguments = {}
	-- Forward the parameter names, ignoring types/defaults/variadics.
	for parameter in method.signature:gmatch("%$([%w_]+)") do
		table.insert(arguments, "$" .. parameter)
	end

	local keyword = method.returns_void and "" or "return "
	local call = ("%s%sparent::%s(%s);"):format(INDENT:rep(2), keyword, method.name, table.concat(arguments, ", "))
	return { call }
end

--- Render a method stub for the child class.
--- @return string[] lines
function M.render_method(method, kind)
	local lines = {}

	table.insert(lines, INDENT .. "/**")
	table.insert(lines, INDENT .. " * {@inheritDoc}")
	table.insert(lines, INDENT .. " *")
	table.insert(lines, INDENT .. " * @api")
	table.insert(lines, INDENT .. " */")

	local signature = method.signature
	if kind == "interface" then
		table.insert(lines, INDENT .. signature .. ";")
		return lines
	end

	-- An abstract parent method becomes concrete in the child.
	table.insert(lines, INDENT .. signature)
	table.insert(lines, INDENT .. "{")
	vim.list_extend(lines, delegating_body(method, kind) or {})
	table.insert(lines, INDENT .. "}")

	return lines
end

--- Build the full contents of a new project-level file extending a core one.
function M.render_class(opts)
	local alias = "Spryker" .. opts.class_name
	local fqn = opts.core_namespace .. "\\" .. opts.class_name

	-- The parent alias plus any type the copied signature depends on, sorted for stability.
	local use_statements = { ("%s as %s"):format(fqn, alias) }
	for _, statement in ipairs(opts.extra_imports or {}) do
		table.insert(use_statements, statement)
	end
	table.sort(use_statements)

	local lines = {
		"<?php",
		"",
		"declare(strict_types=1);",
		"",
		"namespace " .. opts.namespace .. ";",
		"",
	}
	for _, statement in ipairs(use_statements) do
		table.insert(lines, ("use %s;"):format(statement))
	end
	table.insert(lines, "")

	if opts.kind == "trait" then
		-- Traits cannot extend; composing the parent trait is the equivalent.
		table.insert(lines, ("trait %s"):format(opts.class_name))
		table.insert(lines, "{")
		table.insert(lines, ("%suse %s;"):format(INDENT, alias))
		if opts.method_lines and #opts.method_lines > 0 then
			table.insert(lines, "")
			vim.list_extend(lines, opts.method_lines)
		end
		table.insert(lines, "}")
		table.insert(lines, "")
		return lines
	end

	local keyword = opts.kind == "interface" and "interface" or "class"
	if opts.abstract then
		keyword = "abstract class"
	end
	local relation = opts.kind == "interface" and "extends" or "extends"

	table.insert(lines, ("%s %s %s %s"):format(keyword, opts.class_name, relation, alias))
	table.insert(lines, "{")
	if opts.method_lines and #opts.method_lines > 0 then
		vim.list_extend(lines, opts.method_lines)
	end
	table.insert(lines, "}")
	table.insert(lines, "")

	return lines
end

return M
