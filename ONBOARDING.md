# Onboarding — Testa

Testa lets AI agents (and you) drive a booted iOS Simulator end-to-end: read the
screen (accessibility tree **or** on-device OCR), tap/type/swipe/drag-drop/pinch/
rotate, manage apps, and assert results — **no app changes required**.

## Get going (3 steps)

```bash
# 1. Install (builds a release binary, installs the skill, registers MCP)
./install.sh              # or: brew tap YOURNAME/testa && brew install testa

# 2. Boot a simulator + your app
testa boot "iPhone 17 Pro"
testa install ./MyApp.app && testa launch com.example.myapp

# 3. Drive it
testa ui                  # what's on screen (token-efficient)
testa tap "Continue"      # by visible text — falls back to OCR if needed
testa typein "#email" "me@x.co"
testa assert "#welcome" exists
```

First call boots a background daemon and warms accessibility (a few seconds,
once). After that, each command is ~60 ms.

## Mental model

- **Observe** → `testa ui` (on-screen elements) · `testa see` (OCR every visible
  text) · `testa find <q>` · `testa scrollto <sel>`.
- **Act** → `tap / typein / setvalue / clear / swipe / drag / dragdrop / pinch /
  rotate`. Address things by `eN` ref, `#identifier`, `"label"`, or `x y`.
- **Verify** → `testa assert <sel> [exists|gone|value=…|label=…]` (exit 0/1).

You do **not** need to add `testID`s — visible text is enough (Testa uses Apple
Vision OCR as a fallback). Adding `testID`/`accessibilityIdentifier` just makes
targeting more precise.

## For agents

- Claude Code: the **skill** at `skills/testa/SKILL.md` is installed to
  `~/.claude/skills/testa/` and documents the loop.
- Any MCP client: `testa mcp` (stdio). Register with
  `claude mcp add testa -- testa mcp`.

## Develop / test

```bash
make build      # debug build
make test       # unit tests (swift test)
make e2e        # gesture regression vs the native showcase
make showcase   # build + launch the SwiftUI showcase
```

Architecture and internals: see `README.md`. Two runnable example apps live in
`examples/` (SwiftUI + Expo/React Native) and double as the regression suite.

## Requirements

macOS with Xcode (Xcode 26 / iOS 26 simulators), Swift 6.
