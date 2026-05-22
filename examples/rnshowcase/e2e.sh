#!/bin/bash
# Testa end-to-end regression suite against the React Native / Expo showcase.
# Requires the app installed + Metro running (npx expo run:ios). Every complex
# gesture is verified through the accessibility tree via the #status element.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TESTA="${TESTA:-$ROOT/.build/debug/testa}"
BUNDLE="com.testa.showcase.rn"

pass=0; fail=0
status() { "$TESTA" ui 2>/dev/null | sed -n 's/.*"\(.*\)" #status.*/\1/p'; }
check() {
  local name="$1" expect="$2"; shift 2
  "$@" >/dev/null 2>&1; sleep 0.3
  local got; got="$(status)"
  if [[ "$got" == *"$expect"* ]]; then
    echo "  PASS  $name  ->  $got"; pass=$((pass+1))
  else
    echo "  FAIL  $name  ->  '$got' (wanted *$expect*)"; fail=$((fail+1))
  fi
}

echo "Testa E2E — React Native showcase"
check "tap"        "tap:"        "$TESTA" tap "#tapButton"
check "long-press" "longpress"   "$TESTA" longpress "#longPressBox"
check "pinch"      "pinch"       "$TESTA" pinch "#pinchBox" 2.0
check "rotate"     "rotat"       "$TESTA" rotate "#rotateBox" 0.8
check "drag-drop"  "drop:zoneB"  "$TESTA" dragdrop "#dragHandle" "#zoneB"
check "type"       "typed:"      "$TESTA" typein "#textInput" rn99

echo ""
echo "  $pass passed, $fail failed"
[ "$fail" -eq 0 ]
