#!/usr/bin/env bash
# Envia um .rb (ou codigo com -e) pela ponte e imprime so a saida e o erro (sem o JSON).
# Funciona sem Ruby (usa o enviar.ps1). Uso:
#   bash scripts/ponte.sh arquivo.rb [segundos]
#   bash scripts/ponte.sh -e "puts model.title"
#   bash scripts/ponte.sh --estado
# Usa a ponte do SketchUp (2026, 2027...) cujo estado.json diz "ativa": true e e o mais recente.
P=""
for e in $(ls -t "$APPDATA"/SketchUp/SketchUp\ */SketchUp/Plugins/componentes_upmobb/ponte/saida/estado.json 2>/dev/null | tr ' ' '|'); do
  e="${e//|/ }"
  if grep -q '"ativa": true' "$e"; then P="$(dirname "$(dirname "$e")")/enviar.ps1"; break; fi
done
[ -z "$P" ] && P="$(ls -d "$APPDATA"/SketchUp/SketchUp\ */SketchUp/Plugins/componentes_upmobb/ponte | tail -1)/enviar.ps1"
O="$TEMP/ponte_saida.json"
case "$1" in
  --estado) powershell -NoProfile -ExecutionPolicy Bypass -File "$P" -Estado; exit $? ;;
  -e) powershell -NoProfile -ExecutionPolicy Bypass -File "$P" -Codigo "$2" -Segundos "${3:-60}" > "$O" ;;
  *) powershell -NoProfile -ExecutionPolicy Bypass -File "$P" "$(cygpath -w "$1")" -Segundos "${2:-60}" > "$O" ;;
esac
cod=$?
powershell -NoProfile -Command "\$j=(Get-Content -Raw -Encoding UTF8 '$(cygpath -w "$O")' | ConvertFrom-Json); if (\$j.saida) { \$j.saida }; if (\$j.erro) { 'ERRO: ' + \$j.erro; \$j.linhas_erro | Select-Object -First 3 }"
exit $cod
