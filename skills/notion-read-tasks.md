# Skill: Leer Tareas Pendientes de Notion

Esta skill te permite leer tareas pendientes de la base de datos Notion **Social Media Content Board**, filtrando por canal y status.

## Cuándo usar esta skill

Usa esta skill al inicio de tu sesión para saber qué tareas tienes asignadas en Notion según tu canal.

## Instrucciones

### Paso 1: Cargar variables de entorno

Lee el fichero `.env` del directorio raíz del proyecto y extrae:
- `NOTION_API_KEY`
- `NOTION_DATABASE_ID`

### Paso 2: Ejecutar el script de consulta

Ejecuta el siguiente comando sustituyendo los valores:

```bash
python3 scripts/notion_client.py read --canal "CANAL_AQUI" --status "Pendiente"
```

Donde `CANAL_AQUI` es uno de: `Newsletter`, `Instagram`, `TikTok`, `Blog`

### Paso 3: Interpretar el resultado

El script devuelve una lista de tareas en JSON con esta estructura:

```json
[
  {
    "id": "page-id-de-notion",
    "titulo": "Título del tema",
    "canal": "Newsletter",
    "status": "Pendiente",
    "angulo": "Descripción del ángulo sugerido por el Trends Agent",
    "fuente": "https://fuente-de-la-tendencia.com",
    "fecha_creacion": "2026-03-10"
  }
]
```

### Paso 4: Si no hay tareas

Si la lista está vacía, no hay tareas pendientes para tu canal en este momento. Informa al usuario y espera a que el Trends Agent cree nuevas tareas.

## Variables necesarias

| Variable | Descripción |
|----------|-------------|
| `NOTION_API_KEY` | Token de integración Notion (empieza con `secret_`) |
| `NOTION_DATABASE_ID` | ID de la base de datos en Notion |
