-- Telescope picker over every Spryker core file, for extending on project level.

local paths = require("tron.pyz.paths")

local M = {}

-- Types most often extended on project level float to the top of the list;
-- everything else keeps rg's order behind them.
local PRIORITY = {
	Facade = 1,
	FacadeInterface = 1,
	DependencyProvider = 2,
	Config = 3,
	Factory = 4,
	Repository = 5,
	EntityManager = 6,
}

local function priority_of(class_name)
	for suffix, rank in pairs(PRIORITY) do
		if class_name:sub(-#suffix) == suffix then
			return rank
		end
	end
	return 50
end

--- Layer (Zed/Yves/Client/Shared/Glue) and module, pulled from the relative dir.
local function layer_and_module(relative_dir)
	local layer, module = relative_dir:match("^([^/]+)/([^/]+)")
	return layer or relative_dir, module or ""
end

--- Column widths sized to the 90th-percentile entry rather than the longest, so a
--- handful of very long names do not pad every row. Overflow just wraps to the
--- next column, which is far cheaper than dead space on 24k rows.
local function build_display(entries)
	local function percentile(lengths)
		table.sort(lengths)
		return lengths[math.ceil(#lengths * 0.9)] or 20
	end

	local class_lengths, context_lengths = {}, {}
	for _, entry in ipairs(entries) do
		table.insert(class_lengths, #entry.class_name)
		table.insert(context_lengths, #entry.context)
	end

	return math.min(percentile(class_lengths), 44), math.min(percentile(context_lengths), 26)
end

function M.extend_picker()
	local ok, pickers = pcall(require, "telescope.pickers")
	if not ok then
		vim.notify("telescope.nvim is required for this picker", vim.log.levels.ERROR, { title = "PYZ" })
		return
	end

	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")

	local root_dir = paths.project_root(vim.api.nvim_buf_get_name(0))
	if not root_dir then
		vim.notify("Could not locate the project root", vim.log.levels.WARN, { title = "PYZ" })
		return
	end

	local core_files, err = paths.scan_core_files(root_dir)
	if err then
		vim.notify(err, vim.log.levels.ERROR, { title = "PYZ" })
		return
	end
	if #core_files == 0 then
		vim.notify("No Spryker core files found under vendor/", vim.log.levels.WARN, { title = "PYZ" })
		return
	end

	local extended = paths.extended_set(root_dir)

	local entries = {}
	for _, parts in ipairs(core_files) do
		local layer, module = layer_and_module(parts.relative_dir)
		local target = paths.target_for(parts, root_dir)
		table.insert(entries, {
			parts = parts,
			class_name = parts.class_name,
			context = module ~= "" and ("%s/%s"):format(layer, module) or layer,
			package = parts.package,
			relative_dir = parts.relative_dir,
			path = parts.path,
			is_extended = extended[target.path:sub(#root_dir + 2)] == true,
			priority = priority_of(parts.class_name),
		})
	end

	table.sort(entries, function(a, b)
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end
		if a.class_name ~= b.class_name then
			return a.class_name < b.class_name
		end
		return a.package < b.package
	end)

	local class_width, context_width = build_display(entries)
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 2 }, -- extended marker
			{ width = class_width },
			{ width = context_width },
			{ remaining = true },
		},
	})

	local finder = finders.new_table({
		results = entries,
		entry_maker = function(entry)
			return {
				value = entry,
				path = entry.path,
				-- Searchable text: class name, module context and package.
				ordinal = ("%s %s %s"):format(entry.class_name, entry.relative_dir, entry.package),
				display = function(item)
					local marker = item.value.is_extended and "●" or ""
					return displayer({
						{ marker, "DiagnosticOk" },
						{ item.value.class_name, item.value.is_extended and "Comment" or "TelescopeResultsIdentifier" },
						{ item.value.context, "TelescopeResultsComment" },
						{ item.value.package, "Comment" },
					})
				end,
			}
		end,
	})

	local extended_count = 0
	for _, entry in ipairs(entries) do
		if entry.is_extended then
			extended_count = extended_count + 1
		end
	end

	local opts = {
		prompt_title = ("Extend in Pyz  ·  %d core files  ·  ● %d extended"):format(#entries, extended_count),
		results_title = false,
		preview_title = "Core source",
		previewer = conf.file_previewer({}),
		-- Side-by-side: the list stays narrow and readable, the source sits alongside.
		-- The global config uses vertical/descending, so both are overridden here.
		layout_strategy = "horizontal",
		layout_config = {
			width = 0.9,
			height = 0.85,
			prompt_position = "top",
			preview_width = 0.5,
		},
		-- The list is pre-sorted by usefulness, so show it top-down.
		sorting_strategy = "ascending",
	}

	pickers
		.new(opts, {
			finder = finder,
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						require("tron.pyz").extend({ path = selection.value.path })
					end
				end)
				return true
			end,
		})
		:find()
end

return M
