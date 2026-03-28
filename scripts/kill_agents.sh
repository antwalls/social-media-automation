#!/bin/bash
# =============================================================
# kill_agents.sh — Mata todos los agentes OpenClaw en ejecución
# =============================================================
# Uso:
#   ./scripts/kill_agents.sh           # mata todos los agentes
#   ./scripts/kill_agents.sh --status  # solo muestra cuáles están corriendo

set -e

STATUS_ONLY=false
if [[ "$1" == "--status" ]]; then
    STATUS_ONLY=true
fi

echo ""
echo "🔍 Buscando procesos de agentes activos..."
echo ""

# Buscar por nombre de proceso de OpenClaw y por los agentes md
PATTERNS=(
    "openclaw"
    "trends-research"
    "newsletter-writer"
    "instagram-creator"
    "tiktok-creator"
    "blog-writer"
    "notion_client"
)

PIDS_FOUND=()

for PATTERN in "${PATTERNS[@]}"; do
    # pgrep -f busca en la línea de comando completa
    MATCHED=$(pgrep -f "$PATTERN" 2>/dev/null || true)
    if [ -n "$MATCHED" ]; then
        while IFS= read -r pid; do
            # Excluir este mismo script
            if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
                CMD=$(ps -p "$pid" -o comm= 2>/dev/null || echo "unknown")
                ARGS=$(ps -p "$pid" -o args= 2>/dev/null || echo "")
                echo "  [PID $pid] $CMD — $ARGS"
                PIDS_FOUND+=("$pid")
            fi
        done <<< "$MATCHED"
    fi
done

# Eliminar duplicados
UNIQUE_PIDS=($(printf '%s\n' "${PIDS_FOUND[@]}" | sort -u))

if [ ${#UNIQUE_PIDS[@]} -eq 0 ]; then
    echo "  ✅ No hay agentes corriendo."
    echo ""
    exit 0
fi

echo ""
echo "  Encontrados ${#UNIQUE_PIDS[@]} proceso(s)."
echo ""

if $STATUS_ONLY; then
    echo "ℹ️  Modo --status: no se ha matado ningún proceso."
    echo ""
    exit 0
fi

# Matar primero con SIGTERM (graceful)
echo "⏹️  Enviando SIGTERM (apagado ordenado)..."
for pid in "${UNIQUE_PIDS[@]}"; do
    kill -TERM "$pid" 2>/dev/null && echo "  → SIGTERM enviado a PID $pid" || true
done

# Esperar 5 segundos para que terminen limpiamente
sleep 5

# Verificar si siguen vivos y matar con SIGKILL si procede
STILL_ALIVE=()
for pid in "${UNIQUE_PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
        STILL_ALIVE+=("$pid")
    fi
done

if [ ${#STILL_ALIVE[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  ${#STILL_ALIVE[@]} proceso(s) siguen activos. Enviando SIGKILL..."
    for pid in "${STILL_ALIVE[@]}"; do
        kill -KILL "$pid" 2>/dev/null && echo "  → SIGKILL enviado a PID $pid" || true
    done
    sleep 1
fi

# Verificación final
STILL_RUNNING=0
for pid in "${UNIQUE_PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
        echo "  ⚠️  PID $pid sigue corriendo (puede requerir sudo)"
        STILL_RUNNING=$((STILL_RUNNING + 1))
    fi
done

echo ""
if [ $STILL_RUNNING -eq 0 ]; then
    echo "✅ Todos los agentes han sido detenidos."
else
    echo "⚠️  $STILL_RUNNING proceso(s) no pudieron detenerse. Prueba con: sudo ./scripts/kill_agents.sh"
fi
echo ""
