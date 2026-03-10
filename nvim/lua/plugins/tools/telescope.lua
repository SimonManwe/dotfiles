return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},

		config = function()
			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			local function custom_entry_maker(entry)
				local file_name = entry.filename or "[No Name]"
				local line_number = entry.lnum or "0"
				return {
					value = entry,
					display = function()
						return string.format("%s:%d", file_name, line_number)
					end,
					ordinal = file_name .. ":" .. line_number,
					filename = file_name,
					lnum = line_number,
				}
			end

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
					layout_strategy = "vertical",
					layout_config = {
						width = 0.9,
						mirror = true,
						prompt_position = "top",
					},
					sorting_strategy = "descending",
				},
				pickers = {
					lsp_references = {
						entry_maker = custom_entry_maker,
					},
					lsp_definitions = {
						entry_maker = custom_entry_maker,
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")

			-- Git root helpers
			local function find_git_root()
				local current_file = vim.api.nvim_buf_get_name(0)
				local current_dir
				local cwd = vim.fn.getcwd()

				if current_file == "" then
					current_dir = cwd
				else
					current_dir = vim.fn.fnamemodify(current_file, ":h")
				end

				local git_root =
					vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]

				if vim.v.shell_error ~= 0 then
					print("Not a git repository. Searching on current working directory")
					return cwd
				end

				return git_root
			end

			local function live_grep_git_root()
				local git_root = find_git_root()
				if git_root then
					require("telescope.builtin").live_grep({
						search_dirs = { git_root },
					})
				end
			end

			vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

			-- Keymaps
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Recently opened files" })
			vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find buffers" })
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "Fuzzy search current buffer" })

			local function telescope_live_grep_open_files()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end

			local function telescope_find_hidden_and_ignored()
				builtin.find_files({
					hidden = true,
					no_ignore = true,
					no_ignore_parent = true,
				})
			end

			vim.keymap.set("n", "<leader>s/", telescope_live_grep_open_files, { desc = "[S]earch [/] Open Files" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]elect Telescope" })
			vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "[G]it [F]iles" })
			vim.keymap.set("n", "<leader>sf", telescope_find_hidden_and_ignored, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[G]rep Git Root" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })

			-- ============================================
			-- SPRYKER PYZ GENERATOR
			-- ============================================
			local Job = require("plenary.job")

			-- Helper functions
			local function get_spryker_modules()
				local modules = {}
				local vendor_path = vim.fn.getcwd() .. "/vendor/spryker"

				if vim.fn.isdirectory(vendor_path) == 1 then
					local handle = vim.loop.fs_scandir(vendor_path)
					if handle then
						while true do
							local name, type = vim.loop.fs_scandir_next(handle)
							if not name then
								break
							end
							if type == "directory" then
								local module_name = name:gsub("%-(%w)", function(c)
									return c:upper()
								end):gsub("^%l", string.upper)
								table.insert(modules, { name = module_name, path = name })
							end
						end
					end
				end

				table.sort(modules, function(a, b)
					return a.name < b.name
				end)
				return modules
			end

			local function to_kebab_case(str)
				return str:gsub("(%u)", "-%1"):gsub("^%-", ""):lower()
			end

			local function get_available_applications(module_name)
				local kebab_name = to_kebab_case(module_name)
				local vendor_base = string.format("vendor/spryker/%s/src/Spryker", kebab_name)
				local apps = {}
				local possible_apps = { "Zed", "Glue", "Client", "Yves", "Service", "Shared" }

				for _, app in ipairs(possible_apps) do
					local app_path = string.format("%s/%s/%s", vendor_base, app, module_name)
					if vim.fn.isdirectory(app_path) == 1 then
						table.insert(apps, app)
					end
				end

				return apps
			end

			local function get_available_layers(module_name, application)
				local kebab_name = to_kebab_case(module_name)
				local base_path =
					string.format("vendor/spryker/%s/src/Spryker/%s/%s", kebab_name, application, module_name)
				local layers = {}

				local possible_layers = {
					Zed = { "Business", "Communication", "Persistence", "Dependency" },
					Glue = { "Processor", "Controller", "Plugin", "Dependency" },
					Client = { "Zed", "Storage", "Session", "Dependency" },
					Yves = { "Controller", "Plugin", "Dependency" },
					Service = { "Dependency" },
					Shared = {},
				}

				local layers_to_check = possible_layers[application] or {}

				for _, layer in ipairs(layers_to_check) do
					local layer_path = string.format("%s/%s", base_path, layer)
					if vim.fn.isdirectory(layer_path) == 1 then
						table.insert(layers, layer)
					end
				end

				table.insert(layers, "(Root)")
				return layers
			end

			local function get_vendor_namespace(module_name, application, layer, file_type)
				local kebab_name = to_kebab_case(module_name)
				local path_parts = { "vendor/spryker", kebab_name, "src/Spryker", application, module_name }

				if layer ~= "(Root)" then
					table.insert(path_parts, layer)
				end

				table.insert(path_parts, module_name .. file_type .. ".php")
				local vendor_file = table.concat(path_parts, "/")

				if vim.fn.filereadable(vendor_file) == 1 then
					local content = vim.fn.readfile(vendor_file)
					for _, line in ipairs(content) do
						if line:match("^namespace") then
							return line:match("namespace%s+(.+);")
						end
					end
				end

				if layer == "(Root)" then
					return string.format("Spryker\\%s\\%s", application, module_name)
				else
					return string.format("Spryker\\%s\\%s\\%s", application, module_name, layer)
				end
			end

			local function get_available_types(application, layer)
				local types = {}

				if layer == "(Root)" then
					table.insert(types, { name = "Config", suffix = "Config" })
					table.insert(types, { name = "DependencyProvider", suffix = "DependencyProvider" })
				end

				if application == "Zed" then
					if layer == "Business" then
						table.insert(types, { name = "Facade", suffix = "Facade" })
						table.insert(types, { name = "Factory", suffix = "BusinessFactory" })
					elseif layer == "Communication" then
						table.insert(types, { name = "Factory", suffix = "CommunicationFactory" })
					elseif layer == "Persistence" then
						table.insert(types, { name = "Factory", suffix = "PersistenceFactory" })
						table.insert(types, { name = "Repository", suffix = "Repository" })
						table.insert(types, { name = "EntityManager", suffix = "EntityManager" })
					end
				elseif application == "Glue" then
					if layer == "Processor" or layer == "(Root)" then
						table.insert(types, { name = "Factory", suffix = "Factory" })
					end
					if layer == "Controller" then
						table.insert(types, { name = "ResourceController", suffix = "ResourceController" })
					end
				elseif application == "Client" then
					table.insert(types, { name = "Client", suffix = "Client" })
					table.insert(types, { name = "Factory", suffix = "Factory" })
				elseif application == "Yves" then
					if layer == "Controller" then
						table.insert(types, { name = "Controller", suffix = "Controller" })
					end
					table.insert(types, { name = "Factory", suffix = "Factory" })
				elseif application == "Service" then
					table.insert(types, { name = "Service", suffix = "Service" })
					table.insert(types, { name = "Factory", suffix = "Factory" })
				end

				return types
			end

			-- Spryker Commands
			vim.api.nvim_create_user_command("SprykerExtend", function()
				local modules = get_spryker_modules()

				vim.ui.select(modules, {
					prompt = "Select Spryker module to extend:",
					format_item = function(item)
						return item.name
					end,
				}, function(choice)
					if not choice then
						return
					end

					local applications = get_available_applications(choice.name)
					if #applications == 0 then
						vim.notify("No applications found", vim.log.levels.WARN)
						return
					end

					vim.ui.select(applications, {
						prompt = "Select application:",
					}, function(application)
						if not application then
							return
						end

						local layers = get_available_layers(choice.name, application)
						if #layers == 0 then
							vim.notify("No layers found", vim.log.levels.WARN)
							return
						end

						vim.ui.select(layers, {
							prompt = "Select layer:",
						}, function(layer)
							if not layer then
								return
							end

							local types = get_available_types(application, layer)
							if #types == 0 then
								vim.notify("No types available", vim.log.levels.WARN)
								return
							end

							vim.ui.select(types, {
								prompt = "Select type:",
								format_item = function(item)
									return item.name
								end,
							}, function(type_choice)
								if not type_choice then
									return
								end

								local pyz_dir = string.format("src/Pyz/%s/%s", application, choice.name)
								if layer ~= "(Root)" then
									pyz_dir = pyz_dir .. "/" .. layer
								end

								vim.fn.mkdir(pyz_dir, "p")

								local file_name = string.format("%s/%s%s.php", pyz_dir, choice.name, type_choice.suffix)
								local vendor_namespace =
									get_vendor_namespace(choice.name, application, layer, type_choice.suffix)
								local pyz_namespace = vendor_namespace:gsub("^Spryker", "Pyz")

								local content = {
									"<?php",
									"",
									"namespace " .. pyz_namespace .. ";",
									"",
									"use "
										.. vendor_namespace
										.. "\\"
										.. choice.name
										.. type_choice.suffix
										.. " as Spryker"
										.. choice.name
										.. type_choice.suffix
										.. ";",
									"",
									"class "
										.. choice.name
										.. type_choice.suffix
										.. " extends Spryker"
										.. choice.name
										.. type_choice.suffix,
									"{",
									"    // Override methods here",
									"}",
								}

								vim.fn.writefile(content, file_name)
								vim.cmd("edit " .. file_name)
								vim.notify("Created " .. file_name, vim.log.levels.INFO)

								vim.defer_fn(function()
									Job
										:new({
											command = "docker/sdk",
											args = { "cli", "vendor/bin/console", "dev:ide-auto-completion:generate" },
											on_exit = function(_, exit_code)
												if exit_code == 0 then
													vim.schedule(function()
														vim.cmd("LspRestart")
														vim.notify("IDE helpers regenerated", vim.log.levels.INFO)
													end)
												end
											end,
										})
										:start()
								end, 100)
							end)
						end)
					end)
				end)
			end, {})

			-- Keymaps for Spryker
			vim.keymap.set("n", "<leader>se", "<cmd>SprykerExtend<cr>", { desc = "Spryker: Extend Module" })
		end,
	},
}
