#!/bin/bash
# Testa end-to-end regression suite against the native SwiftUI showcase.
# Every complex gesture is verified purely through the accessibility tree
# (the app mirrors the recognized gesture into its #status element).
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TESTA="${TESTA:-$ROOT/.build/debug/testa}"
BUNDLE="com.testa.showcase.native"

xcrun simctl terminate booted "$BUNDLE" >/dev/null 2>&1 || true
xcrun simctl launch booted "$BUNDLE" >/dev/null 2>&1
sleep 2

pass=0; fail=0
status() { "$TESTA" ui 2>/dev/null | sed -n 's/.*"\(.*\)" #status.*/\1/p'; }
check() {
  local name="$1" expect="$2"; shift 2
  "$@" >/dev/null 2>&1; sleep 0.2
  local got; got="$(status)"
  if [[ "$got" == *"$expect"* ]]; then
    echo "  PASS  $name  ->  $got"; pass=$((pass+1))
  else
    echo "  FAIL  $name  ->  '$got' (wanted *$expect*)"; fail=$((fail+1))
  fi
}

echo "Testa E2E — native showcase"
check "tap"        "tap:"        "$TESTA" tap "#tapButton"
check "long-press" "longpress"   "$TESTA" longpress "#longPressBox"
check "pinch"      "pinch"       "$TESTA" pinch "#pinchBox" 1.8
check "rotate"     "rotat"       "$TESTA" rotate "#rotateBox" 0.9
check "drag-drop"  "drop:zoneB"  "$TESTA" dragdrop "#dragHandle" "#zoneB"
check "type"       "typed:"      "$TESTA" typein "#textInput" hello

echo ""
echo "  $pass passed, $fail failed"
[ "$fail" -eq 0 ]
