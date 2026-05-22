<div align="center">

# Testa

**Drive the iOS Simulator like a human — from an AI agent.**

Real HID touches (every gesture), screen reading via the accessibility tree
**or on-device OCR**, token-efficient, fast, and **zero third-party dependencies**.
Test React Native / Expo and native SwiftUI apps end-to-end — **without adding a
single `testID`**.

[![CI](https://github.com/seizeddev/testa/actions/workflows/ci.yml/badge.svg)](https://github.com/seizeddev/testa/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20·%20iOS%2026-lightgrey)
![Swift](https://img.shields.io/badge/swift-6-orange.svg)
![Runtime deps](https://img.shields.io/badge/runtime%20deps-zero-success)
![MCP](https://img.shields.io/badge/MCP-ready-8A2BE2)

<img src="assets/demo.gif" alt="Testa driving the iOS Simulator — tap, pinch, rotate, drag-and-drop, type" width="280">

<sub>An agent tapping, pinching, rotating, dragging-and-dropping, and typing — all verified through the accessibility tree, no screenshots.</sub>

</div>

---

## Why Testa

Agents are great at writing iOS apps and clumsy at the part that comes next:
**actually exercising them in the simulator.** Testa is built for that — and two
things set it apart from the rest of the field: it drives screens that expose
**zero accessibility** (via on-device OCR), and it's a **single, fully-open,
dependency-free binary**.

- 🧠 **No app setup required.** Reads the accessibility tree, and falls back to
  **Apple Vision OCR** to tap any *visible text* — so it drives canvas, games,
  WebViews and vibe-coded apps that never added a `testID`.
- 🪙 **Token-efficient.** One compact line per element (`e5 Button "Save" #save @120,300`)
  with `find` / `assert` / `ui diff` — not screenshots.
- ⚡ **Fast.** A warm daemon keeps the connection, accessibility translator and HID
  client hot: **~60 ms** per snapshot.
- 👆 **Every gesture, for real.** Tap, long-press, swipe, **drag-and-drop**,
  **pinch/zoom**, **rotate**, multi-touch, unicode/emoji text — genuine HID events.
- 🔌 **Agent-native.** Ships an **MCP server** (`testa mcp`) and a Claude Code skill.
- 🔒 **Local & private.** A `0600` per-user Unix socket. No network, no telemetry.
- 📦 **Zero third-party runtime deps.** Talks straight to Apple's `CoreSimulator`,
  `SimulatorKit`, `AccessibilityPlatformTranslation`, Vision and `simctl`.

|  | **Testa** | Argent | idb | Appium | Maestro |
|---|:--:|:--:|:--:|:--:|:--:|
| Agent-native (MCP + token-efficient snapshots) | ✅ | ✅ | ❌ | ❌ | ⚠️ |
| Drives screens with **zero accessibility** (on-device OCR) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Pinch · rotate · drag-and-drop · multi-touch | ✅ | ⚠️ | ✅ | ✅ | ⚠️ |
| Self-contained: one native binary, no Node/SDK runtime | ✅ | ❌ | ❌ | ❌ | ❌ |
| Fully open source, no proprietary parts | ✅&nbsp;MIT | ⚠️ | ✅ | ✅ | ✅ |
| Platforms | iOS | iOS · Android | iOS | iOS · Android · web | iOS · Android |
| Live debugging & profiling (logs · network · RN tree · Instruments) | ❌ | ✅ | ⚠️ | ❌ | ❌ |

<sub>High-level summary, verified against each project's docs as of 2026. These are all good tools. The closest is <a href="https://github.com/software-mansion/argent">Argent</a> (Software Mansion): broader than Testa (cross-platform, deep debugging & profiling), but accessibility-only (no OCR), Node-based, and Apache-2.0 source <em>plus proprietary binaries</em>. Testa's niche: fully-open, dependency-free, OCR-driven, iOS-focused.</sub>

## Quick start

```bash
# Install (one line) — builds, installs the skill, registers the MCP server
brew install https://raw.githubusercontent.com/seizeddev/testa/main/Formula/testa.rb
testa setup

# …or from source
git clone https://github.com/seizeddev/testa && cd testa && ./install.sh
```

```bash
testa boot "iPhone 17 Pro"
testa install ./MyApp.app && testa launch com.example.myapp

testa ui                       # what's on screen (token-efficient)
testa tap "Continue"           # by visible text — falls back to OCR
testa typein "#email" "a@b.co"
testa assert "#welcome" exists # → PASS / FAIL (exit 0/1)
```

> First call boots a background daemon and warms accessibility (a few seconds,
> once). Every call after is ~60 ms. Requires macOS + Xcode 26 (iOS 26 sims), Swift 6.

## The loop

1. **Observe** — `testa ui` (on-screen elements) · `testa see` (OCR every visible
   text) · `testa find <q>` · `testa scrollto <sel>`.
2. **Act** — `tap · typein · setvalue · clear · swipe · drag · dragdrop · pinch ·
   rotate`. Address things by `eN` ref, `#identifier`, `"label"`, or `x y`.
3. **Verify** — `testa assert <sel> [exists|gone|value=…|label=…]` (exit 0/1).

```text
$ testa ui
25 elements (on screen)
e1 Application "Testa Native" @201,437
e5 Button "Tap me" #tapButton @102,171
e16 TextField #textInput =type here @201,673
…

$ testa pinch "#map" 2.0      →  pinched
$ testa dragdrop "#card" "#trash"  →  drag-and-dropped
$ testa assert "#status" label=done  →  PASS exists e2 …
```

<details>
<summary><b>Full command reference</b></summary>

```
Observe
  ui [diff|full]            on-screen snapshot (diff = changes, full = incl. off-screen)
  see                       OCR every visible text + tap coords (any app)
  find <query>              elements matching label/id/value/role
  scrollto <sel>            scroll until an element is visible
  assert <sel> [exists|gone|value=..|label=..]
  wait <sel> [timeoutMs]
  screenshot [path]

Act   (sel = eN ref · #identifier · "label")
  tap <sel> | tap <x> <y> | tapocr <text>
  typein <sel> <text> | type <text> | setvalue <sel> <text> | clear <sel>
  key <hidUsage>
  swipe <x1 y1 x2 y2>
  drag <x1 y1 x2 y2 | fromSel toSel>
  dragdrop <x1 y1 x2 y2 | fromSel toSel>
  longpress <sel | x y> | pinch <sel | x y> <scale> | rotate <sel | x y> <radians>

App / device
  devices | boot <udid|name> | shutdown <udid|all>
  install <app> | launch <bundle> | terminate <bundle> | apps | open <url>
  logs [bundle] [seconds] | crashes [bundle]
  permission <grant|revoke|reset> <service> <bundle>
  record <start [path] | stop>

Setup / daemon
  setup | start | stop | status | info | mcp        (target a sim: --udid <udid>)
```

</details>

## Works without app setup

You do **not** need the app to add `testID`s. Visible text is enough:

- Native SwiftUI and RN `Text` / `Pressable` / `TextInput` already expose their
  text as labels — `testa tap "Continue"`.
- For anything else, `testa see` + `testa tapocr "<text>"` reads pixels via
  **on-device Apple Vision** (no key, no network). This even drives a HealthKit
  permission sheet or a canvas-rendered screen that exposes *zero* accessibility.

Adding `testID` / `accessibilityIdentifier` just makes targeting more precise.

<div align="center"><img src="assets/ocr-demo.gif" alt="Testa driving a Canvas-rendered screen that has zero accessibility, via OCR" width="240"></div>

The bottom row above is drawn with `Canvas` — it exposes **zero accessibility**.
Most tools (and accessibility-only agents) are blind to it. Testa isn't:

```console
$ testa ui            # accessibility tree
… no "Start" / "Settings" / "Profile" — they aren't accessibility elements

$ testa see           # on-device OCR
"Start" @79,702    "Settings" @200,703    "Profile" @322,702

$ testa tapocr "Settings"
tapped (ocr) "Settings" @200,703     →  #status = canvas:Settings
```

## For AI agents

- **Claude Code** — `testa setup` installs the skill (`skills/testa/SKILL.md`).
- **Any MCP client** (Codex, Cursor, …) — `claude mcp add testa -- testa mcp`.
  Tools: `ui, see, find, scrollTo, tap, tapText, type, setValue, clear, key,
  swipe, drag, dragdrop, longpress, pinch, rotate, screenshot, assert, wait,
  install, launch, terminate, apps, logs, crashes, open, info`.

## How it works

```
agent ──► testa (CLI)            ──┐
agent ──► testa mcp (MCP server) ──┤ Unix socket (~/.testa/daemon-<udid>.sock, 0600)
                                   ▼
                              testad (warm daemon)
                                   │  Obj-C engine, dlopen'd private frameworks
                    ┌──────────────┼───────────────┐
                    ▼              ▼                ▼
              SimulatorKit    CoreSimulator   AccessibilityPlatformTranslation
              (Indigo HID)    (SimDevice)     (AXPTranslator → a11y tree)  + Vision (OCR)
                    └──────────────┴────────────────┘
                          booted iOS Simulator
```

- **HID injection** reimplements the Indigo touch wire-format
  (`SimDeviceLegacyHIDClient`) — taps/drags/multitouch are byte-for-byte what the
  simulator's guest HID service expects.
- **Accessibility** drives `AXPTranslator` with a token delegate that bridges each
  attribute read to an async `SimDevice` XPC request, yielding the element tree in
  **point coordinates that match the tap space**.
- **OCR** runs Apple Vision over an in-process framebuffer capture (IOSurface).

## Showcase / tests

Two example apps with complex gestures double as the regression suite. Each mirrors
the last recognized gesture into a `#status` element, so gestures are verified
through the accessibility tree alone:

- `examples/native` — SwiftUI · `examples/native/build.sh`, then `examples/native/e2e.sh`.
- `examples/rnshowcase` — Expo / React Native · see `TESTA_README.md` there.

```bash
make build   # debug build
make test    # unit tests
make e2e     # gesture regression vs the native showcase (needs a booted sim)
```

## Limitations (honest)

- **Icon-only controls with no text and no accessibility label** are ambiguous to
  *any* automation — use coordinates, or add an `accessibilityLabel`.
- iOS Simulator only, by design. Real devices and Android are out of scope.
- The prebuilt binary isn't notarized unless built with your own Apple Developer
  ID (`release.sh`); the `clone` and Homebrew paths build from source.
- `testa record` produces H.264 MP4; live FPS streaming isn't implemented.

## Project

- [CONTRIBUTING](CONTRIBUTING.md) · [CHANGELOG](CHANGELOG.md) · [Onboarding](ONBOARDING.md)
- License: [MIT](LICENSE)

<div align="center"><sub>Verified on Xcode 26.4 / iOS 26.4 (iPhone 17 Pro), against SwiftUI + Expo/React Native showcases and a real production app.</sub></div>
