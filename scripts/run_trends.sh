#!/bin/bash
# Lanzar el Trends Research Agent
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔍 Lanzando Trends Research Agent..."
echo "   Buscará trending topics y creará tareas en Notion."
echo ""

cd "$PROJECT_DIR"

# Verificar que existe .env
if [ ! -f ".env" ]; then
    echo "❌ No se encuentra .env. Ejecuta ./install.sh primero."
    exit 1
fi

# Cargar variables de entorno
set -a; source .env; set +a

# Lanzar con OpenClaw
python3 scripts/agent_runner.py agents/trends-research.md
