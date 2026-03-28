# Skill: Actualizar Draft en Notion

Esta skill te permite escribir el contenido generado (draft) en la tarea correspondiente de Notion y actualizar su status a `Draft Listo`.

## Cuándo usar esta skill

Úsala cuando hayas terminado de generar el contenido para una tarea y quieras guardarlo en Notion.

## Instrucciones

### Paso 1: Preparar el draft

Ten listo el contenido en texto plano o Markdown. Asegúrate de tener el `page_id` de la tarea (obtenido al leer las tareas con `notion-read-tasks`).

### Paso 2: Ejecutar el script

```bash
python3 scripts/notion_client.py update \
  --page-id "PAGE_ID" \
  --draft "CONTENIDO_DEL_DRAFT" \
  --status "Draft Listo"
```

Para drafts largos (artículos de blog, newsletters), guarda primero el contenido en un fichero y pásalo así:

```bash
python3 scripts/notion_client.py update \
  --page-id "PAGE_ID" \
  --draft-file "/tmp/draft_contenido.md" \
  --status "Draft Listo"
```

### Paso 3: Verificar la actualización

El script confirma la escritura:

```json
{
  "success": true,
  "page_id": "PAGE_ID",
  "status_updated": "Draft Listo",
  "fecha_draft": "2026-03-10"
}
```

### Paso 4: Manejo de errores

Si recibes un error de autenticación, verifica que `NOTION_API_KEY` tenga acceso a la base de datos.
Si el `page_id` no existe, revisa que lo estás pasando correctamente desde la lectura de tareas.

## Variables necesarias

| Variable | Descripción |
|----------|-------------|
| `NOTION_API_KEY` | Token de integración Notion |
