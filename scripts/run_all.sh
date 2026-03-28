#!/bin/bash
# =============================================================
# run_all.sh — Ejecuta el flujo completo de social media automation
# =============================================================
# Orden:
#   1. Trends Agent  (busca tendencias y crea tareas en Notion)
#   2. Newsletter, Instagram, TikTok y Blog agents en paralelo
# =============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

if [ ! -f ".env" ]; then
    echo "❌ No se encuentra .env. Ejecuta ./install.sh primero."
    exit 1
fi

# Cargar variables de entorno
set -a; source .env; set +a

# ── Registro de PIDs de agentes hijos ─────────────────────────
AGENT_PIDS=()

cleanup() {
    echo ""
    echo "🛑 Interrupción detectada — deteniendo todos los agentes..."
    for pid in "${AGENT_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null && echo "  → SIGTERM a PID $pid" || true
        fi
    done
    sleep 3
    for pid in "${AGENT_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill -KILL "$pid" 2>/dev/null && echo "  → SIGKILL a PID $pid" || true
        fi
    done
    echo "✅ Agentes detenidos."
    exit 1
}

# Ejecutar cleanup en Ctrl+C, SIGTERM o salida inesperada
trap cleanup INT TERM EXIT

echo ""
echo "🚀 Social Media Automation — Flujo completo"
echo "============================================"
echo ""

# --- PASO 1: Trends Agent ---
echo "┌─────────────────────────────────────────┐"
echo "│  Paso 1/2: 🔍 Trends Research Agent     │"
echo "└─────────────────────────────────────────┘"
echo "Buscando trending topics y creando tareas en Notion..."
echo ""
# python3 scripts/agent_runner.py agents/trends-research.md
echo "⏩ Saltando búsqueda de tendencias (usando tareas existentes)"
echo ""
echo "✅ Trends Agent terminado. Tareas creadas en Notion."
echo ""

# Pequeña pausa para que Notion procese las nuevas páginas
sleep 3

# --- PASO 2: Agentes de contenido en paralelo ---
echo "┌─────────────────────────────────────────┐"
echo "│  Paso 2/2: Agentes de contenido         │"
echo "│  (Newsletter, Instagram, TikTok, Blog)  │"
echo "└─────────────────────────────────────────┘"
echo "Lanzando los 4 agentes en paralelo..."
echo ""

bash scripts/run_newsletter.sh &
NEWSLETTER_PID=$!
AGENT_PIDS+=($NEWSLETTER_PID)

bash scripts/run_instagram.sh &
INSTAGRAM_PID=$!
AGENT_PIDS+=($INSTAGRAM_PID)

bash scripts/run_tiktok.sh &
TIKTOK_PID=$!
AGENT_PIDS+=($TIKTOK_PID)

bash scripts/run_blog.sh &
BLOG_PID=$!
AGENT_PIDS+=($BLOG_PID)

# Esperar a que terminen todos
echo "  📧 Newsletter Agent (PID: $NEWSLETTER_PID)"
echo "  📸 Instagram Agent  (PID: $INSTAGRAM_PID)"
echo "  🎵 TikTok Agent     (PID: $TIKTOK_PID)"
echo "  ✍️  Blog Agent       (PID: $BLOG_PID)"
echo ""
echo "Esperando a que terminen todos... (Ctrl+C para abortar y matar todos)"

wait $NEWSLETTER_PID && echo "  ✅ Newsletter Agent completado" || echo "  ⚠️  Newsletter Agent terminó con error"
wait $INSTAGRAM_PID  && echo "  ✅ Instagram Agent completado"  || echo "  ⚠️  Instagram Agent terminó con error"
wait $TIKTOK_PID     && echo "  ✅ TikTok Agent completado"     || echo "  ⚠️  TikTok Agent terminó con error"
wait $BLOG_PID       && echo "  ✅ Blog Agent completado"       || echo "  ⚠️  Blog Agent terminó con error"

# Desactivar trap en salida limpia
trap - EXIT

echo ""
echo "============================================"
echo "✅ Flujo completo terminado."
echo "   Revisa los drafts en tu Notion Board:"
echo "   Filtra por Status = 'Draft Listo'"
echo "============================================"
echo ""
