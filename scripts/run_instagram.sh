#!/bin/bash
# Lanzar el Instagram Creator Agent
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "📸 Lanzando Instagram Creator Agent..."
echo "   Leerá tareas de Notion (Canal: Instagram, Status: Pendiente) y generará drafts."
echo ""

cd "$PROJECT_DIR"

if [ ! -f ".env" ]; then
    echo "❌ No se encuentra .env. Ejecuta ./install.sh primero."
    exit 1
fi

# Cargar variables de entorno
set -a; source .env; set +a

python3 scripts/agent_runner.py agents/instagram-creator.md
