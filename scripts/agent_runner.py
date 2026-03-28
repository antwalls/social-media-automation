#!/usr/bin/env python3
"""
agent_runner.py — Runner para agentes Social Media Automation
Ejecuta agentes .md directamente contra la API OpenAI-compatible (LM Studio o Claude).

Uso:
  python3 scripts/agent_runner.py agents/trends-research.md
  python3 scripts/agent_runner.py agents/instagram-creator.md
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

from dotenv import load_dotenv

# Cargar .env desde la raíz del proyecto
PROJECT_DIR = Path(__file__).parent.parent
load_dotenv(PROJECT_DIR / ".env")

# ── Configuración del LLM ─────────────────────────────────────────────────────
OPENAI_BASE_URL   = os.getenv("OPENAI_BASE_URL", "http://127.0.0.1:1234/v1")
OPENAI_API_KEY    = os.getenv("OPENAI_API_KEY", "lm-studio")
OPENAI_MODEL      = os.getenv("OPENAI_MODEL", "")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")

try:
    import requests
except ImportError:
    print("❌ Instala requests: pip install requests")
    sys.exit(1)


def read_file_relative(path_str: str) -> str:
    """Lee un archivo relativo al directorio del proyecto."""
    p = PROJECT_DIR / path_str
    if p.exists():
        return p.read_text(encoding="utf-8")
    return f"[Archivo no encontrado: {path_str}]"


def expand_skill_refs(content: str) -> str:
    """Expande referencias a skills en el contenido del agente."""
    skill_refs = re.findall(r"`(skills/[^`]+\.md)`", content)
    for ref in skill_refs:
        skill_content = read_file_relative(ref)
        content = content.replace(
            f"`{ref}`",
            f"\n\n--- Contenido de {ref} ---\n{skill_content}\n--- Fin de {ref} ---\n"
        )
    return content


def run_bash_command(cmd: str) -> str:
    """Ejecuta un comando bash y devuelve el output."""
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True,
            cwd=str(PROJECT_DIR), timeout=60,
            env={**os.environ, "PATH": os.environ.get("PATH", "")
                 + f":{PROJECT_DIR}/scripts"}
        )
        out = result.stdout.strip()
        err = result.stderr.strip()
        if err and result.returncode != 0:
            return f"[ERROR]\n{err}"
        return out or "[Sin output]"
    except subprocess.TimeoutExpired:
        return "[Timeout después de 60s]"
    except Exception as e:
        return f"[Excepción: {e}]"


def call_llm(messages: list, use_tools: bool = False) -> str:
    """Llama al LLM configurado (LM Studio o Anthropic) y devuelve la respuesta."""

    # ── Anthropic ──────────────────────────────────────────────────────────────
    if ANTHROPIC_API_KEY and not OPENAI_BASE_URL.startswith("http://127"):
        headers = {
            "x-api-key": ANTHROPIC_API_KEY,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        }
        # Separar system del resto
        system = next((m["content"] for m in messages if m["role"] == "system"), "")
        user_msgs = [m for m in messages if m["role"] != "system"]
        payload = {
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 4096,
            "system": system,
            "messages": user_msgs,
        }
        resp = requests.post(
            "https://api.anthropic.com/v1/messages", headers=headers, json=payload
        )
        resp.raise_for_status()
        return resp.json()["content"][0]["text"]

    # ── OpenAI-compatible (LM Studio) ──────────────────────────────────────────
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": OPENAI_MODEL or "local-model",
        "messages": messages,
        "max_tokens": 4096,
        "temperature": 0.7,
    }
    resp = requests.post(
        f"{OPENAI_BASE_URL}/chat/completions", headers=headers, json=payload, timeout=300
    )
    if resp.status_code != 200:
        print(f"❌ Error API ({resp.status_code}): {resp.text}")
    resp.raise_for_status()
    return resp.json()["choices"][0]["message"]["content"]


def execute_agent(agent_file: str):
    """Ejecuta un agente leyendo su archivo .md como system prompt."""
    agent_path = PROJECT_DIR / agent_file
    if not agent_path.exists():
        print(f"❌ No se encuentra el agente: {agent_file}")
        sys.exit(1)

    print(f"\n🤖 Ejecutando agente: {agent_file}")
    print(f"   Modelo: {OPENAI_MODEL or 'local-model'}")
    print(f"   LLM endpoint: {OPENAI_BASE_URL}")
    print("")

    # Leer el contenido del agente y expandir skills
    agent_content = agent_path.read_text(encoding="utf-8")
    agent_content = expand_skill_refs(agent_content)

    # Construir prompt del sistema
    system_prompt = f"""Eres un agente de automatización de redes sociales. A continuación tienes tus instrucciones:

{agent_content}

## Reglas de ejecución
- Cuando necesites ejecutar un comando bash, escríbelo en un bloque:
  ```bash
  <comando>
  ```
  El runner lo ejecutará y te devolverá el resultado.
- Cuando hayas completado tu tarea, escribe "TAREA_COMPLETADA" al final.
- El directorio de trabajo es: {PROJECT_DIR}
- Usa rutas relativas al directorio del proyecto.
"""

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user",   "content": """Inicia tu tarea. Busca tendencias reales de hoy.
        
NOTAS PARA EL AGENTE:
Si las búsquedas fallan o no dan resultados claros, usa estas tendencias reales de MARZO 2026:
1. IA Generativa de Video (Sora/Luma) en marketing de contenidos.
2. El auge del 'Social Search' (TikTok como buscador vs Google).
3. Apple Vision Pro y marketing de realidad aumentada.
"""},
    ]

    max_iterations = 15
    iteration = 0

    while iteration < max_iterations:
        iteration += 1
        print(f"🔄 Iteración {iteration}/{max_iterations}...")

        response = call_llm(messages)
        print(f"\n--- Respuesta del agente ---\n{response[:500]}{'...' if len(response) > 500 else ''}\n")

        # Extraer y ejecutar comandos bash
        bash_blocks = re.findall(r"```bash\n(.*?)```", response, re.DOTALL)
        tool_outputs = []

        for cmd in bash_blocks:
            cmd = cmd.strip()
            if not cmd:
                continue
            print(f"🔧 Ejecutando: {cmd[:80]}{'...' if len(cmd) > 80 else ''}")
            output = run_bash_command(cmd)
            print(f"   → {output[:200]}{'...' if len(output) > 200 else ''}")
            tool_outputs.append(f"Comando: {cmd}\nResultado:\n{output}")

        # Añadir respuesta del agente al historial
        messages.append({"role": "assistant", "content": response})

        # Si ejecutó comandos, devolver los resultados
        if tool_outputs:
            tool_results = "\n\n".join(tool_outputs)
            messages.append({
                "role": "user",
                "content": f"Resultados de los comandos:\n{tool_results}\n\nContinúa con el siguiente paso."
            })

        # Verificar si terminó
        if "TAREA_COMPLETADA" in response:
            print(f"\n✅ Agente '{agent_file}' completado.\n")
            break

        if not bash_blocks and iteration > 1:
            print(f"\n⚠️  Sin comandos pendientes. Finalizando agente.\n")
            break

    else:
        print(f"\n⚠️  Límite de iteraciones alcanzado ({max_iterations}).\n")


def main():
    parser = argparse.ArgumentParser(description="Runner para agentes Social Media Automation")
    parser.add_argument("agent", help="Ruta al archivo del agente (ej: agents/trends-research.md)")
    args = parser.parse_args()
    execute_agent(args.agent)


if __name__ == "__main__":
    main()
