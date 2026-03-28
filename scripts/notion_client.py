#!/usr/bin/env python3
"""
notion_client.py — Cliente Notion API compartido para todos los agentes
Social Media Automation System

Uso:
  python3 notion_client.py read --canal "Newsletter" --status "Pendiente"
  python3 notion_client.py create --titulo "Tema" --canal "Newsletter" --angulo "Ángulo" --fuente "URL"
  python3 notion_client.py update --page-id "PAGE_ID" --draft "Contenido" --status "Draft Listo"
  python3 notion_client.py update --page-id "PAGE_ID" --draft-file "/tmp/draft.md" --status "Draft Listo"
"""

import argparse
import json
import os
import sys
from datetime import date

import requests
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

NOTION_API_KEY = os.getenv('NOTION_API_KEY')
NOTION_DATABASE_ID = os.getenv('NOTION_DATABASE_ID')
NOTION_VERSION = '2022-06-28'

if not NOTION_API_KEY:
    print("❌ ERROR: NOTION_API_KEY no está configurada en .env", file=sys.stderr)
    sys.exit(1)

if not NOTION_DATABASE_ID:
    print("❌ ERROR: NOTION_DATABASE_ID no está configurada en .env", file=sys.stderr)
    sys.exit(1)

HEADERS = {
    'Authorization': f'Bearer {NOTION_API_KEY}',
    'Content-Type': 'application/json',
    'Notion-Version': NOTION_VERSION,
}


def rich_text(text: str) -> list:
    """Convierte texto plano a formato rich_text de Notion."""
    # Notion tiene límite de 2000 chars por bloque de rich_text
    chunks = [text[i:i+2000] for i in range(0, len(text), 2000)]
    return [{"type": "text", "text": {"content": chunk}} for chunk in chunks]


def read_tasks(canal: str, status: str) -> list:
    """Lee tareas de la base de datos Notion filtradas por canal y status."""
    url = f'https://api.notion.com/v1/databases/{NOTION_DATABASE_ID}/query'
    payload = {
        "filter": {
            "and": [
                {
                    "property": "Canal",
                    "select": {"equals": canal}
                },
                {
                    "property": "Status",
                    "select": {"equals": status}
                }
            ]
        },
        "sorts": [
            {"property": "Fecha Creación", "direction": "descending"}
        ]
    }

    response = requests.post(url, headers=HEADERS, json=payload)

    if response.status_code != 200:
        print(f"❌ Error al leer de Notion: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)

    data = response.json()
    tasks = []

    for page in data.get('results', []):
        props = page.get('properties', {})

        def get_select(prop_name):
            prop = props.get(prop_name, {})
            sel = prop.get('select')
            return sel.get('name') if sel else None

        def get_title(prop_name):
            prop = props.get(prop_name, {})
            rt = prop.get('title', [])
            return ''.join([t.get('plain_text', '') for t in rt])

        def get_rich_text(prop_name):
            prop = props.get(prop_name, {})
            rt = prop.get('rich_text', [])
            return ''.join([t.get('plain_text', '') for t in rt])

        def get_url(prop_name):
            prop = props.get(prop_name, {})
            return prop.get('url', '')

        def get_date(prop_name):
            prop = props.get(prop_name, {})
            d = prop.get('date')
            return d.get('start') if d else None

        tasks.append({
            'id': page['id'],
            'titulo': get_title('Titulo'),
            'canal': get_select('Canal'),
            'status': get_select('Status'),
            'angulo': get_rich_text('Ángulo'),
            'fuente': get_url('Fuente Tendencia'),
            'fecha_creacion': get_date('Fecha Creación'),
        })

    return tasks


def create_task(titulo: str, canal: str, angulo: str, fuente: str) -> dict:
    """Crea una nueva tarea en la base de datos Notion."""
    url = 'https://api.notion.com/v1/pages'
    today = date.today().isoformat()

    payload = {
        "parent": {"database_id": NOTION_DATABASE_ID},
        "properties": {
            "Titulo": {"title": rich_text(titulo)},
            "Canal": {"select": {"name": canal}},
            "Status": {"select": {"name": "Pendiente"}},
            "Ángulo": {"rich_text": rich_text(angulo)},
            "Fuente Tendencia": {"url": fuente if fuente else None},
            "Fecha Creación": {"date": {"start": today}},
        }
    }

    # Limpiar fuente si está vacía (Notion no acepta url vacía)
    if not fuente:
        del payload['properties']['Fuente Tendencia']

    response = requests.post(url, headers=HEADERS, json=payload)

    if response.status_code != 200:
        print(f"❌ Error al crear tarea en Notion: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)

    data = response.json()
    return {
        'success': True,
        'page_id': data['id'],
        'titulo': titulo,
        'canal': canal,
        'status': 'Pendiente'
    }


def update_draft(page_id: str, draft: str, status: str) -> dict:
    """Actualiza el draft y el status de una tarea en Notion."""
    url = f'https://api.notion.com/v1/pages/{page_id}'
    today = date.today().isoformat()

    # Notion rich_text tiene límite de 2000 chars por bloque
    draft_blocks = rich_text(draft)

    payload = {
        "properties": {
            "Status": {"select": {"name": status}},
            "Draft Contenido": {"rich_text": draft_blocks},
            "Fecha Draft": {"date": {"start": today}},
        }
    }

    response = requests.patch(url, headers=HEADERS, json=payload)

    if response.status_code != 200:
        print(f"❌ Error al actualizar Notion: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)

    return {
        'success': True,
        'page_id': page_id,
        'status_updated': status,
        'fecha_draft': today
    }


def main():
    parser = argparse.ArgumentParser(description='Cliente Notion para Social Media Automation')
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Subcomando: read
    read_parser = subparsers.add_parser('read', help='Leer tareas pendientes')
    read_parser.add_argument('--canal', required=True, choices=['Newsletter', 'Instagram', 'TikTok', 'Blog'])
    read_parser.add_argument('--status', default='Pendiente')

    # Subcomando: create
    create_parser = subparsers.add_parser('create', help='Crear una nueva tarea')
    create_parser.add_argument('--titulo', required=True)
    create_parser.add_argument('--canal', required=True, choices=['Newsletter', 'Instagram', 'TikTok', 'Blog'])
    create_parser.add_argument('--angulo', required=True)
    create_parser.add_argument('--fuente', default='')

    # Subcomando: update
    update_parser = subparsers.add_parser('update', help='Guardar draft en una tarea')
    update_parser.add_argument('--page-id', required=True)
    update_parser.add_argument('--draft', default=None, help='Contenido del draft como string')
    update_parser.add_argument('--draft-file', default=None, help='Ruta a fichero con el draft')
    update_parser.add_argument('--status', default='Draft Listo')

    args = parser.parse_args()

    if args.command == 'read':
        tasks = read_tasks(args.canal, args.status)
        print(json.dumps(tasks, ensure_ascii=False, indent=2))

    elif args.command == 'create':
        result = create_task(args.titulo, args.canal, args.angulo, args.fuente)
        print(json.dumps(result, ensure_ascii=False, indent=2))

    elif args.command == 'update':
        if args.draft_file:
            with open(args.draft_file, 'r', encoding='utf-8') as f:
                draft_content = f.read()
        elif args.draft:
            draft_content = args.draft
        else:
            print("❌ ERROR: Debes proporcionar --draft o --draft-file", file=sys.stderr)
            sys.exit(1)

        result = update_draft(args.page_id, draft_content, args.status)
        print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
