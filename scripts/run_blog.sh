#!/bin/bash
# Lanzar el Blog Writer Agent
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "✍️  Lanzando Blog Writer Agent..."
echo "   Leerá tareas de Notion (Canal: Blog, Status: Pendiente) y generará artículos."
echo ""

cd "$PROJECT_DIR"

if [ ! -f ".env" ]; then
    echo "❌ No se encuentra .env. Ejecuta ./install.sh primero."
    exit 1
fi

# Cargar variables de entorno
set -a; source .env; set +a

python3 scripts/agent_runner.py agents/blog-writer.md
