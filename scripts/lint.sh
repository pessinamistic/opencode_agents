#!/usr/bin/env bash
# Single owner of the ShellCheck lint definition for this repo: the tracked
# shell-script file set AND the pinned ShellCheck version. Both live only
# here so CI and a local run can never silently diverge -- if CI installed
# a different ShellCheck version than a contributor has on PATH, the same
# script could pass locally and fail in CI (or vice versa) on nothing but a
# version skew, not a real bug. Pinning removes that class of flake.
#
# The file set is discovered dynamically via `git ls-files -- '*.sh'` (not
# a hardcoded array), so a future new .sh file is picked up automatically
# with zero maintenance here.
#
# Two usage modes:
#   scripts/lint.sh                    Check that shellcheck is on PATH and
#                                       reports exactly REQUIRED_SHELLCHECK;
#                                       if not, print the pinned version and
#                                       an install hint and exit non-zero
#                                       without running anything. Otherwise
#                                       run shellcheck (default severity, no
#                                       downgrades, no blanket excludes)
#                                       against the discovered file set and
#                                       exit with ShellCheck's own exit code.
#   scripts/lint.sh --required-version Print just the pinned version string
#                                       and exit 0. No shellcheck-on-PATH
#                                       check is performed in this mode --
#                                       it lets CI read the pinned version
#                                       (to install a matching build) before
#                                       any shellcheck binary exists on the
#                                       runner.
set -eu

REQUIRED_SHELLCHECK="0.11.0"

if [ "${1:-}" = "--required-version" ]; then
  printf '%s\n' "$REQUIRED_SHELLCHECK"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "lint.sh: shellcheck not found on PATH." >&2
  echo "lint.sh: this repo pins shellcheck $REQUIRED_SHELLCHECK." >&2
  echo "lint.sh: install it (e.g. \`brew install shellcheck\`) and re-run." >&2
  exit 1
fi

found_version="$(shellcheck --version | awk '/^version:/ { print $2 }')"
if [ "$found_version" != "$REQUIRED_SHELLCHECK" ]; then
  echo "lint.sh: shellcheck version mismatch: found $found_version, this repo pins $REQUIRED_SHELLCHECK." >&2
  echo "lint.sh: install the pinned version (e.g. \`brew install shellcheck\`) and re-run." >&2
  exit 1
fi

cd "$REPO_ROOT"
files=()
while IFS= read -r f; do
  files+=("$f")
done < <(git ls-files -- '*.sh')

shellcheck "${files[@]}"
