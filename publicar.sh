#!/bin/zsh
# Publica una nueva versión al repo para que los boxes se actualicen solos.
# Uso:  ./publicar.sh xuper  <archivo.apk>
#       ./publicar.sh inicio <archivo.apk>
set -e
cd "${0:A:h}"
BT=~/android-build/sdk/build-tools/34.0.0
command -v "$BT/aapt2" >/dev/null || BT=""
AAPT="${BT:+$BT/}aapt2"
COMP="$1"; F="$2"
[[ "$COMP" == "xuper" || "$COMP" == "inicio" ]] || { echo "Uso: ./publicar.sh <xuper|inicio> <apk>"; exit 2; }
[[ -f "$F" ]] || { echo "No existe: $F"; exit 2; }

# Xuper es de terceros: se valida que corra en estos boxes antes de publicar.
[[ "$COMP" == "xuper" ]] && ./validar-apk.sh "$F"

CODE=$("$AAPT" dump badging "$F" 2>/dev/null | grep -m1 "^package:" | grep -oE "versionCode='[0-9]+'" | grep -oE "[0-9]+")
NAME=$("$AAPT" dump badging "$F" 2>/dev/null | grep -m1 "^package:" | grep -oE "versionName='[^']+'" | sed "s/versionName='//;s/'//")
[[ -n "$CODE" ]] || { echo "No pude leer el versionCode."; exit 1; }
DEST="apks/$([[ $COMP == xuper ]] && echo XuperTV.apk || echo Inicio.apk)"
cp "$F" "$DEST"

# Actualiza el versionCode del componente en version.json.
python3 -I - "$COMP" "$CODE" <<'PY'
import json, sys
comp, code = sys.argv[1], int(sys.argv[2])
d = json.load(open("version.json"))
d[comp]["versionCode"] = code
json.dump(d, open("version.json", "w"), indent=2, ensure_ascii=False)
PY

git add -A
git commit -q -m "Publicar $COMP v$NAME ($CODE)" -m "Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
git push -q origin main
echo "✓ Publicado $COMP v$NAME (code $CODE). Los boxes lo tomarán al encender o dentro de 6 h."
