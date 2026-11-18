#!/bin/zsh
# Valida que un APK de Xuper (u otra app) sirva para los TV Box RK3229 con Android 7.1.
# Uso: ./validar-apk.sh <archivo.apk>
set -e
BT=~/android-build/sdk/build-tools/34.0.0
command -v "$BT/aapt2" >/dev/null || BT=""
AAPT="${BT:+$BT/}aapt2"
F="$1"
[[ -f "$F" ]] || { echo "No existe: $F"; exit 2; }

echo "== $F"
"$AAPT" dump badging "$F" 2>/dev/null | grep -E "^package:|^sdkVersion:|native-code:"
ABIS=$("$AAPT" dump badging "$F" 2>/dev/null | grep -m1 native-code: || true)
SDK=$("$AAPT" dump badging "$F" 2>/dev/null | grep -m1 "^sdkVersion:" | grep -oE "[0-9]+")
ok=1

echo "$ABIS" | grep -q "armeabi-v7a" || { echo "✗ No trae armeabi-v7a: no corre en estos boxes."; ok=0; }
[[ -n "$SDK" && "$SDK" -le 25 ]] || echo "⚠ minSdk=$SDK (estos boxes son SDK 25 / Android 7.1)."

# Las apps que verifican su firma con la API de Android 9 se cierran al abrir (caso Xuper Ar).
D=$(mktemp -d); unzip -q -o "$F" 'classes*.dex' -d "$D" 2>/dev/null || true
if strings "$D"/classes*.dex 2>/dev/null | grep -qE "signingInfo|GET_SIGNING_CERTIFICATES"; then
  echo "✗ Usa signingInfo / GET_SIGNING_CERTIFICATES: probablemente se cierre en Android 7.1."
  ok=0
fi
rm -rf "$D"

[[ $ok -eq 1 ]] && echo "✓ Apto para estos boxes." || { echo "NO publicar este APK."; exit 1; }
