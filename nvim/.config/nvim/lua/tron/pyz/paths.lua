-- Path/namespace math for mapping Spryker core files <-> project (Pyz) files.
--
-- A core file always looks like:
--   vendor/<org>/<package>/<src|tests>/<CoreNamespace>/<relative...>/<Class>.php
--   e.g. vendor/spryker/oms/src/Spryker/Zed/Oms/Business/OmsFacade.php
-- The project counterpart keeps <relative...> verbatim and swaps the two prefixes:
--   src/Pyz/Zed/Oms/Business/OmsFacade.php   +   namespace Pyz\Zed\Oms\Business

local M = {}

M.config = {
	-- Where core files land on project level. Keyed by the vendor root dir.
	targets = {
		src = { dir = "src/Pyz", namespace = "Pyz" },
		tests = { dir = "tests/PyzTest", namespace = "PyzTest" },
	},
	-- Any vendor namespace root with this prefix counts as "Spryker core";
	-- this covers Spryker, SprykerShop, SprykerEco, SprykerSdk, SprykerTest, ...
	core_namespace_prefix = "Spryker",
}

--- The root of the project owning `path`.
---
--- Searching upward for composer.json is wrong inside vendor/: every package ships
--- its own, so the nearest match is the package, not the project. For a path under
--- vendor/ the root is simply whatever precedes it.
function M.project_root(path)
	path = path or vim.fn.getcwd()

	-- Non-greedy: with a nested vendor/ the outermost one wins, which is the real project.
	local before_vendor = path:match("^(.-)/vendor/[^/]+/[^/]+/")
	if before_vendor then
		return before_vendor
	end

	return vim.fs.root(path, { "composer.json", ".git" })
end

local function is_core_namespace(name)
	return name:sub(1, #M.config.core_namespace_prefix) == M.config.core_namespace_prefix
end

--- Split a core file path into its meaningful parts.
--- @return table|nil parts, string|nil err
function M.parse_core_path(path)
	local package, root, core_ns, rest =
		path:match("/vendor/([%w%-%._]+/[%w%-%._]+)/(%a+)/(%a+)/(.+)$")

	if not package then
		return nil, "not a vendor package path"
	end
	if not M.config.targets[root] then
		return nil, ("unsupported vendor root %q (expected src/ or tests/)"):format(root)
	end
	if not is_core_namespace(core_ns) then
		return nil, ("%q is not a known Spryker core namespace"):format(core_ns)
	end

	local relative_dir = vim.fn.fnamemodify(rest, ":h")
	if relative_dir == "." then
		relative_dir = ""
	end

	return {
		package = package, -- "spryker/oms"
		root = root, -- "src" | "tests"
		core_namespace = core_ns, -- "Spryker"
		relative_dir = relative_dir, -- "Zed/Oms/Business"
		class_name = vim.fn.fnamemodify(rest, ":t:r"),
		file_name = vim.fn.fnamemodify(rest, ":t"),
	}
end

function M.is_core_path(path)
	return M.parse_core_path(path) ~= nil
end

--- Project-level destination for a parsed core file.
function M.target_for(parts, root_dir)
	local target = M.config.targets[parts.root]

	-- `_support` is a Codeception layout artefact in the path, never in the namespace.
	local namespace_path = parts.relative_dir:gsub("_support/?", ""):gsub("/$", "")

	local segments = { target.namespace }
	for segment in namespace_path:gmatch("[^/]+") do
		table.insert(segments, segment)
	end

	local dir = table.concat({ root_dir, target.dir, parts.relative_dir }, "/"):gsub("//+", "/"):gsub("/$", "")

	return {
		dir = dir,
		path = dir .. "/" .. parts.file_name,
		namespace = table.concat(segments, "\\"),
	}
end

--- Every Spryker core file in vendor/, as parsed entries.
--- Uses `rg --files`, which is named the same on Arch and Debian-based systems
--- (unlike fd/fdfind) and is already a dependency of the telescope config.
--- @return table[] entries, string|nil err
function M.scan_core_files(root_dir)
	if vim.fn.executable("rg") ~= 1 then
		return {}, "ripgrep (rg) not found in PATH"
	end

	local result = vim.system({
		"rg",
		"--files",
		"--no-ignore",
		-- Anchored at the package root so rg filters instead of listing all of vendor/.
		-- A leading slash would make these absolute and match nothing.
		"--glob=vendor/*/*/src/Spryker*/**/*.php",
		"--glob=vendor/*/*/tests/Spryker*/**/*.php",
		"vendor",
	}, { cwd = root_dir, text = true }):wait()

	-- rg exits 1 when nothing matched, which is not an error here.
	if result.code > 1 then
		return {}, (result.stderr or "rg failed"):gsub("%s+$", "")
	end

	local entries = {}
	for line in (result.stdout or ""):gmatch("[^\n]+") do
		local absolute = root_dir .. "/" .. line
		local parts = M.parse_core_path(absolute)
		if parts then
			parts.path = absolute
			parts.relative_path = line
			table.insert(entries, parts)
		end
	end

	return entries, nil
end

--- Relative paths of everything already extended on project level, as a lookup set.
function M.extended_set(root_dir)
	local set = {}
	if vim.fn.executable("rg") ~= 1 then
		return set
	end

	local result = vim.system({
		"rg",
		"--files",
		"--no-ignore",
		"--glob=*.php",
		"src/Pyz",
		"tests/PyzTest",
	}, { cwd = root_dir, text = true }):wait()

	for line in (result.stdout or ""):gmatch("[^\n]+") do
		set[line] = true
	end
	return set
end

--- Locate the core file backing a fully qualified class name, e.g.
--- "Spryker\Zed\Oms\Business\OmsFacade" -> vendor/spryker/oms/src/Spryker/.../OmsFacade.php
function M.find_core_file(fqn, root_dir)
	local relative = fqn:gsub("^\\", ""):gsub("\\", "/")
	for _, root in ipairs({ "src", "tests" }) do
		local pattern = ("%s/vendor/*/*/%s/%s.php"):format(root_dir, root, relative)
		local hits = vim.fn.glob(pattern, false, true)
		if #hits > 0 then
			return hits[1]
		end
	end
	return nil
end

return M
