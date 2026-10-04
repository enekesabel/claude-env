#!/bin/bash
# Setup for Claude Code cloud environments.
# Load it from an environment's setup script with:
#   curl -fsSL https://raw.githubusercontent.com/enekesabel/claude-env/main/setup.sh | bash
#
# Each step is independent: a failing step prints a warning and the rest still run.
set -uo pipefail

warn() { echo "claude-env: $*" >&2; }

settings="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$settings")"
[ -s "$settings" ] || echo '{}' > "$settings"

# Deep-merge a JSON object into the user settings, keeping everything else.
merge_settings() {
  jq --argjson patch "$1" '. * $patch' "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
}

# Advisor
merge_settings '{"advisorModel": "fable"}' || warn "advisor setting failed"

# DevFlow plugin, with the Coordinator as the default output style
if claude plugin marketplace add enekesabel/dev-flow && claude plugin install dev-flow@dev-flow; then
  merge_settings '{"outputStyle": "dev-flow:devflow"}' || warn "DevFlow output style failed"
else
  warn "DevFlow install failed"
fi

# Built-in plugins
claude plugin enable cc-plugin-you-should-know@builtin --scope user || warn "you-should-know enable failed"

exit 0
