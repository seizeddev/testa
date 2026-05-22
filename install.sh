#!/bin/bash
# Testa installer. Builds a release binary, puts it on PATH, installs the Claude
# Code skill, and registers the MCP server. Re-runnable.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

PREFIX="${PREFIX:-$HOME/.local/bin}"

echo "==> Building release binary..."
swift build -c release
BIN="$DIR/.build/release/testa"

echo "==> Installing to $PREFIX/testa"
mkdir -p "$PREFIX"
install "$BIN" "$PREFIX/testa"

echo "==> Installing Claude Code skill"
mkdir -p "$HOME/.claude/skills/testa"
cp "$DIR/skills/testa/SKILL.md" "$HOME/.claude/skills/testa/SKILL.md"

if command -v claude >/dev/null 2>&1; then
  echo "==> Registering MCP server with Claude Code"
  claude mcp add testa -- "$PREFIX/testa" mcp 2>/dev/null \
    && echo "    registered: claude mcp 'testa'" \
    || echo "    (already registered or skipped)"
fi

case ":$PATH:" in
  *":$PREFIX:"*) : ;;
  *) echo "==> NOTE: add $PREFIX to your PATH:  export PATH=\"$PREFIX:\$PATH\"" ;;
esac

echo ""
echo "Done. Boot a simulator, then try:"
echo "  testa info"
echo "  testa ui"
