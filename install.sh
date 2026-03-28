#!/bin/bash
# =============================================================
# Social Media Automation — Instalador
# =============================================================

set -e

echo ""
echo "🤖 Social Media Automation — Setup"
echo "===================================="
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Python deps ---
echo "📦 Instalando dependencias Python..."
if command -v pip3 &>/dev/null; then
    pip3 install requests python-dotenv 2>/dev/null || true
elif command -v pip &>/dev/null; then
    pip install requests python-dotenv 2>/dev/null || true
else
    echo "  ⚠️  pip no encontrado. Instala Python 3.9+ primero."
fi

# --- .env ---
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo ""
    echo "⚙️  Creando .env a partir de .env.example..."
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo "  ✅ .env creado. Edítalo con tus API keys antes de continuar."
else
    echo "  ✅ .env ya existe."
fi

# --- Permisos scripts ---
echo ""
echo "🔑 Dando permisos de ejecución a los scripts..."
chmod +x "$PROJECT_DIR/scripts/"*.sh

echo ""
echo "✅ Setup completado."
echo ""
echo "Próximos pasos:"
echo ""
echo "  [LLM] Elige tu proveedor en .env (sólo uno activo a la vez):"
echo "    → LM Studio (local):  activa OPENAI_BASE_URL / OPENAI_API_KEY / OPENAI_MODEL"
echo "       Asegúrate de tener LM Studio corriendo en http://127.0.0.1:1234"
echo "    → Claude (cloud):     activa ANTHROPIC_API_KEY=sk-ant-..."
echo ""
echo "  1. Edita .env y activa el bloque LLM que vayas a usar"
echo "  2. Rellena NOTION_API_KEY y NOTION_DATABASE_ID en .env"
echo "  3. Sigue las instrucciones en notion/database-setup.md"
echo "  4. Ejecuta: ./scripts/run_trends.sh   (para buscar tendencias)"
echo "  5. Ejecuta: ./scripts/run_all.sh      (para el flujo completo)"
echo ""
