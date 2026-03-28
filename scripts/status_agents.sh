#!/bin/bash
# =============================================================
# status_agents.sh — Muestra el estado actual de los agentes
# =============================================================
# Muestra:
#   1. Procesos en ejecución (PID)
#   2. Resumen de tareas en Notion (Pendiente vs Draft Listo)
#   3. Últimas líneas de logs (si existen)
# =============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Cargar variables de entorno
if [ -f ".env" ]; then
    set -a; source .env; set +a
else
    echo "⚠️  No se encuentra el archivo .env"
fi

echo ""
echo "🦞 OpenClaw: Social Media Automation — STATUS"
echo "=============================================="
echo ""

# 1. BUSCAR PROCESOS
echo "🔍 PROCESOS ACTIVOS:"
PATTERNS=(
    "agent_runner.py"
    "trends-research"
    "newsletter-writer"
    "instagram-creator"
    "tiktok-creator"
    "blog-writer"
)

FOUND=0
for PATTERN in "${PATTERNS[@]}"; do
    MATCHED=$(pgrep -f "$PATTERN" 2>/dev/null || true)
    if [ -n "$MATCHED" ]; then
        while IFS= read -r pid; do
            if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
                CMD=$(ps -p "$pid" -o comm= 2>/dev/null || echo "unknown")
                ARGS=$(ps -p "$pid" -o args= 2>/dev/null || echo "")
                echo "  [PID $pid] $CMD — $ARGS"
                FOUND=$((FOUND + 1))
            fi
        done <<< "$MATCHED"
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "  ✅ No hay procesos de agentes activos en el sistema."
else
    echo "  → $FOUND procesos encontrados."
fi

echo ""

# 2. CONSULTAR NOTION
echo "📓 RESUMEN NOTION (Social Media Board):"
if [ -z "$NOTION_API_KEY" ] || [ -z "$NOTION_DATABASE_ID" ]; then
    echo "  ⚠️  Faltan credenciales de Notion en .env para consultar el estado."
else
    # Ejecutar notion_client para ver el conteo
    GET_COUNT() {
        # $1: canal, $2: status
        # Obtenemos la respuesta, filtramos por "id", contamos líneas y nos aseguramos de que sea un solo número sin espacios
        python3 "$SCRIPT_DIR/notion_client.py" read --canal "$1" --status "$2" 2>/dev/null | grep -c "\"id\":" | head -n 1 | tr -d ' ' || echo "0"
    }

    P_BLOG=$(GET_COUNT "Blog" "Pendiente")
    P_NEWS=$(GET_COUNT "Newsletter" "Pendiente")
    P_INST=$(GET_COUNT "Instagram" "Pendiente")
    P_TIK=$(GET_COUNT "TikTok" "Pendiente")
    
    # Asegurar que no estén vacíos antes de la aritmética
    P_BLOG=${P_BLOG:-0}; P_NEWS=${P_NEWS:-0}; P_INST=${P_INST:-0}; P_TIK=${P_TIK:-0}
    PENDING=$((P_BLOG + P_NEWS + P_INST + P_TIK))

    R_BLOG=$(GET_COUNT "Blog" "Draft Listo")
    R_NEWS=$(GET_COUNT "Newsletter" "Draft Listo")
    R_INST=$(GET_COUNT "Instagram" "Draft Listo")
    R_TIK=$(GET_COUNT "TikTok" "Draft Listo")
    
    R_BLOG=${R_BLOG:-0}; R_NEWS=${R_NEWS:-0}; R_INST=${R_INST:-0}; R_TIK=${R_TIK:-0}
    READY=$((R_BLOG + R_NEWS + R_INST + R_TIK))

    echo "  ⏳ Pendientes: $PENDING (Blog:$P_BLOG, News:$P_NEWS, Inst:$P_INST, TikTok:$P_TIK)"
    echo "  ✅ Drafts Listos: $READY (Blog:$R_BLOG, News:$R_NEWS, Inst:$R_INST, TikTok:$R_TIK)"
    
    if [ "$READY" -gt 0 ]; then
        echo "  → Revisa tus drafts aquí: https://www.notion.so/$NOTION_DATABASE_ID"
    fi
fi

echo ""

# 3. ÚLTIMOS LOGS (SI EXISTEN)
if [ -d "logs" ]; then
    echo "📝 ÚLTIMAS LÍNEAS DE LOGS:"
    for logfile in logs/*.log; do
        if [ -f "$logfile" ]; then
            echo "  --- $(basename "$logfile") ---"
            tail -n 2 "$logfile" | sed 's/^/    /'
        fi
    done
fi

echo "=============================================="
echo "💡 Tip: Usa ./scripts/kill_agents.sh para detener todo."
echo ""
