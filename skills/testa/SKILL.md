---
name: testa
description: Autonomously E2E-test iOS apps in the Simulator — read the screen (accessibility tree OR on-device OCR), tap/type/swipe/drag-drop/pinch/rotate, manage apps, and assert results. Use when asked to test, QA, drive, or reproduce a flow in an iOS app/simulator (React Native, Expo, native SwiftUI, or any app). Token-efficient: reads structured text, not screenshots. Works even with NO accessibility setup via Vision OCR.
---

# Testa — iOS Simulator E2E for agents

Testa drives a **booted iOS Simulator** with real HID touches and reads the
screen two ways: the **accessibility tree** (precise, semantic) and **on-device
Vision OCR** (works on any app, even with zero accessibility setup). A warm
daemon keeps it fast (~60 ms snapshots). No third-party dependencies.

## The loop

1. **Observe** — `testa ui`. One line per element:
   `e5 Button "Tap me" #tapButton @102,171`
   - `e5` ref · role · `"label"` · `#id` (RN `testID` / SwiftUI `accessibilityIdentifier`)
     · `=value` · `@x,y` **tap-ready center**.
   - If the tree is sparse (canvas/games/webviews, or an app with no testIDs),
     use **`testa see`** — OCR of every visible text + tap coordinates.
2. **Act** — by `ref`, `#id`, `"label"`, raw `x y`, or **visible text**:
   - `testa tap "#tapButton"` · `testa tap e5` · `testa tap 102 171`
   - `testa tapocr "Continue"` — taps visible text via OCR (no a11y needed)
   - `testa tap "Continue"` — tries the tree, then **falls back to OCR**
   - `testa typein "#email" "me@x.com"` · `testa setvalue "#email" "me@x.com"`
     (setvalue writes any unicode/emoji directly; great for long/odd strings)
3. **Verify** — `testa assert "#status" label=done` → `PASS`/`FAIL` (exit 0/1).

After acting, `testa ui` again. Off-screen elements report scrolled positions —
scroll first, then re-snapshot.

## Works without app changes (important for vibe-coded apps)

You do **not** need the app to add `testID`s. Visible text is enough:
- Native SwiftUI and RN `Text`/`Pressable`/`TextInput` already expose their text
  as labels — tap them by `"label"`.
- For anything else, `testa see` + `testa tapocr "<text>"` reads pixels via Apple
  Vision (on-device, no network). This covers buttons/labels/fields in almost any
  app. Only icon-only targets with no text/label are ambiguous — use coordinates.

## Commands

```
ui [diff|full]       see              find <q>         screenshot [path]
scrollto <sel>       assert <sel> [exists|gone|value=..|label=..]   wait <sel> [ms]
tap <sel|x y>        tapocr <text>    longpress <sel|x y>
typein <sel> <text>  type <text>      setvalue <sel> <text>
clear <sel>          key <hidUsage>
swipe <x1 y1 x2 y2>  drag <x1 y1 x2 y2 | fromSel toSel>   dragdrop <…>
pinch <sel|x y> <scale>     rotate <sel|x y> <radians>
devices  boot <udid|name>  shutdown <udid|all>
install <app>  launch <bundle>  terminate <bundle>  apps  open <url>
permission <grant|revoke|reset> <service> <bundle>   record <start [path]|stop>
info  status  start  stop          (target a sim with --udid <udid>)
```
`<sel>` = `eN` · `#identifier` · `"label"`.

- `ui` shows **on-screen** elements only (token-lean). Use `ui full` for the whole
  tree (incl. off-screen), `ui diff` for just what changed.
- To act on something below the fold: `testa scrollto "<sel>"` first, then tap.
  When a label matches several elements, `ui`/`find` lists each with its own ref —
  tap the exact `eN`.

## Complex gestures

Use `@x,y` from `ui`, or a selector directly:
- `testa dragdrop "#card" "#trash"`   (drag-and-drop by element)
- `testa pinch "#map" 2.0`            (zoom in; <1 zooms out)
- `testa rotate "#photo" 1.57`        (≈90°)

## A full flow

```
testa boot "iPhone 17 Pro"
testa install ./MyApp.app && testa launch com.example.myapp
testa wait "#welcome" 8000
testa tap "Continue"            # by visible text — works without testIDs
testa typein "#email" "a@b.co"
testa assert "#error" gone
```

## Tips

- First call boots the daemon + warms accessibility (a few seconds, once); then ~60 ms.
- Prefer `ui`/`see`/`assert` over `screenshot` to save tokens.
- React Native: a plain `View`'s `testID` only shows in the tree if the view is
  `accessible={true}`; `Pressable`/`TextInput` are fine. When in doubt, tap by
  visible text (OCR) instead.
