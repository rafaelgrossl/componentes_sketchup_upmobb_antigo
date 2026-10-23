#!/bin/bash
# Roda um modelo do Blender do plugin direto (sem a ponte) e mostra o resumo do resultado.json.
# Uso: bash scripts/blender.sh <pasta em banco/blender> [...]   ex.: bash scripts/blender.sh carro_inferior_ro27
# (pela ponte, blender(...) foi interrompido no meio das previas: ^C no blender.log)
B=$(ls -d "/c/Program Files/Blender Foundation/"*/blender.exe | tail -1)
PL="$APPDATA/SketchUp/SketchUp 2026/SketchUp/Plugins/componentes_upmobb"
for N in "$@"; do
  D="$PL/banco/blender/$N"; rm -f "$D/resultado.json"
  cat > "$TEMP/rodar_blender.py" <<PY
import sys, traceback
sys.path.insert(0, r"$(cygpath -m "$PL/ponte/blender")")
import upmobb
upmobb.TRABALHO = {'pasta': r"$(cygpath -m "$D")", 'resultado': r"$(cygpath -m "$D")/resultado.json"}
try:
    f = r"$(cygpath -m "$D")/modelo.py"
    exec(compile(open(f, encoding='utf-8').read(), f, 'exec'), {'__file__': f, '__name__': '__main__'})
except BaseException:
    upmobb.falha(traceback.format_exc())
PY
  "$B" --background --factory-startup --python "$(cygpath -m "$TEMP/rodar_blender.py")" > "$D/blender.log" 2>&1
  echo "== $N"; grep -o '"ok[^,]*\|"medidas_mm[^]]*]\|"min_mm[^]]*]\|"triangulos[^,]*\|"arestas_abertas[^,]*\|"avisos[^]]*]\|"erro[^\n]*' "$D/resultado.json" | tr -d '\n'; echo
done
