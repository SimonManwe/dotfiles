# Yazi shell wrapper - allows cd on quit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
# run docker/sdk from anywhere inside the spryker repo
function sdk() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not in a repo" >&2; return 1; }
  [[ -x $root/docker/sdk ]] || { echo "no docker/sdk in $root" >&2; return 1; }
  (cd "$root" && docker/sdk "$@")
}
# sniff only changed PHP files vs. a base branch (default: development)
function sniff-diff() {
  local base=${1:-development}
  git diff -z --diff-filter=ACM --name-only "$base"...HEAD -- src \
    | xargs -0 -r sdk cli vendor/bin/phpcs
}
