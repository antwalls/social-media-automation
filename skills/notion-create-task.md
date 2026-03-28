# Skill: Crear Tarea en Notion

Esta skill te permite crear nuevas tareas en la base de datos **Social Media Content Board** de Notion. La usa el **Trends Agent** para asignar temas a los agentes especializados.

## Cuándo usar esta skill

Úsala después de descubrir un trending topic y querer asignarlo a un agente de contenido.

## Instrucciones

### Paso 1: Preparar los datos de la tarea

Para cada tarea a crear, ten preparados:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `titulo` | Título claro del tema | "5 tendencias de IA en marketing 2026" |
| `canal` | Canal de destino | `Newsletter`, `Instagram`, `TikTok`, `Blog` |
| `angulo` | Ángulo/perspectiva sugerida | "Hablar desde el punto de vista del emprendedor" |
| `fuente` | URL de la fuente | "https://trends.google.com/..." |

### Paso 2: Ejecutar el script

```bash
python3 scripts/notion_client.py create \
  --titulo "TITULO" \
  --canal "CANAL" \
  --angulo "ANGULO" \
  --fuente "URL_FUENTE"
```

### Paso 3: Verificar la creación

El script devuelve el ID de la página creada y confirma el éxito:

```json
{
  "success": true,
  "page_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "titulo": "TITULO",
  "canal": "CANAL",
  "status": "Pendiente"
}
```

### Paso 4: Crear tareas para múltiples canales

Por cada trending topic encontrado, crea al menos **una tarea por canal** (Newsletter, Instagram, TikTok, Blog) adaptando el ángulo a cada formato:

- **Newsletter**: enfoque educativo, profundidad, narrativa
- **Instagram**: visual, conciso, emocional
- **TikTok**: entretenido, sorprendente, rápido
- **Blog**: SEO, informativo, con ejemplos prácticos

## Variables necesarias

| Variable | Descripción |
|----------|-------------|
| `NOTION_API_KEY` | Token de integración Notion |
| `NOTION_DATABASE_ID` | ID de la base de datos en Notion |
