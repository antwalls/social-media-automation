#!/bin/bash
# Lanzar el TikTok Creator Agent
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🎵 Lanzando TikTok Creator Agent..."
echo "   Leerá tareas de Notion (Canal: TikTok, Status: Pendiente) y generará scripts."
echo ""

cd "$PROJECT_DIR"

if [ ! -f ".env" ]; then
    echo "❌ No se encuentra .env. Ejecuta ./install.sh primero."
    exit 1
fi

# Cargar variables de entorno
set -a; source .env; set +a

python3 scripts/agent_runner.py agents/tiktok-creator.md
