#!/bin/sh
# Review report paths for the current git checkout, used by /review and /fix-review.
# Key = directory name (readable) + hash of the full path (unique per checkout and worktree).
set -eu

dir=/tmp/opencode/reviews
top=$(git rev-parse --show-toplevel)
key="$(basename "$top")-$(printf '%s' "$top" | sha256sum | cut -c1-8)"

case "${1:-}" in
new)
	mkdir -p "$dir"
	printf '%s/%s-%s.md\n' "$dir" "$key" "$(date +%Y%m%d-%H%M%S)"
	;;
show)
	latest=$(find "$dir" -maxdepth 1 -name "$key-*.md" 2>/dev/null | sort | tail -n 1)
	if [ -z "$latest" ]; then
		echo "No review report found for $top."
		exit 0
	fi
	echo "Report file: $latest"
	echo
	cat "$latest"
	;;
*)
	echo "usage: review-report.sh new|show" >&2
	exit 2
	;;
esac
