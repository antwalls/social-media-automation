# Social Media Automation — Plan de Implementación

Sistema de agentes IA especializados que se coordinan a través de **Notion** para generar contenido en **draft** para Newsletter, Instagram, TikTok y Blog. Un agente orquestador busca tendencias y asigna tareas a los demás agentes via Notion.

---

## Arquitectura General

```
🔍 Trends Agent  ──► Notion Board ──► 📧 Newsletter Agent
                       (Tareas)    ──► 📸 Instagram Agent
                                   ──► 🎵 TikTok Agent
                                   ──► ✍️  Blog Agent
                                        │
                                        ▼
                                  Drafts en Notion
                                  (listos para revisar)
```

### Flujo de trabajo
1. **Trends Agent** busca trending topics (Google Trends, Reddit, YouTube, X/Twitter)
2. Crea **tareas en Notion** asignadas a cada agente especializado con el tema y ángulo sugerido
3. Cada agente especializado **lee sus tareas pendientes** en Notion (filtradas por canal)
4. Genera el contenido en **formato draft** y lo escribe de vuelta en Notion
5. El contenido queda en Notion listo para revisión humana antes de publicar

---

## Estructura de Carpetas

```
/new_source/social-media-automation/
├── IMPLEMENTATION_PLAN.md             ← este fichero
├── README.md                          # Descripción y uso del proyecto
├── .env.example                       # Variables de entorno necesarias
├── install.sh                         # Setup del proyecto
│
├── agents/
│   ├── trends-research.md             # Agente: Búsqueda de tendencias
│   ├── newsletter-writer.md           # Agente: Escritor de newsletters
│   ├── instagram-creator.md           # Agente: Creador de contenido Instagram
│   ├── tiktok-creator.md              # Agente: Creador de scripts TikTok
│   └── blog-writer.md                 # Agente: Escritor de entradas de blog
│
├── skills/
│   ├── notion-read-tasks.md           # Skill: Leer tareas de Notion
│   ├── notion-create-task.md          # Skill: Crear tarea en Notion
│   ├── notion-update-draft.md         # Skill: Escribir draft en Notion
│   ├── trends-search.md               # Skill: Búsqueda de tendencias web
│   └── content-guidelines.md          # Skill: Guías de estilo por canal
│
├── scripts/
│   ├── notion_client.py               # Cliente Notion API (helper compartido)
│   ├── run_trends.sh                  # Lanzar agente de tendencias
│   ├── run_newsletter.sh              # Lanzar agente newsletter
│   ├── run_instagram.sh               # Lanzar agente instagram
│   ├── run_tiktok.sh                  # Lanzar agente tiktok
│   ├── run_blog.sh                    # Lanzar agente blog
│   └── run_all.sh                     # Lanzar todos los agentes en secuencia
│
├── templates/
│   ├── newsletter-template.md         # Plantilla de newsletter
│   ├── instagram-template.md          # Plantilla post Instagram
│   ├── tiktok-template.md             # Plantilla script TikTok
│   └── blog-template.md               # Plantilla entrada blog
│
└── notion/
    └── database-setup.md              # Instrucciones de setup de la BD Notion
```

---

## Agentes Detallados

### 1. 🔍 Trends Agent (`agents/trends-research.md`)
- **Responsabilidad**: Descubrir trending topics relevantes mediante búsquedas web
- **Herramientas OpenClaw**: WebSearch, WebFetch
- **Output**: Crea una tarea por canal en Notion para cada tema encontrado
- **Campos que escribe**:
  - Título del tema
  - Descripción del ángulo recomendado
  - Canal de destino (Newsletter / Instagram / TikTok / Blog)
  - Status: `Pendiente`
  - Fuente de la tendencia (URL)

### 2. 📧 Newsletter Agent (`agents/newsletter-writer.md`)
- **Lee de Notion**: Tareas con `Canal = Newsletter` y `Status = Pendiente`
- **Output**: Subject, Preview text, Cuerpo del email, CTA
- **Formato**: Conversacional, estructurado, máx 600 palabras

### 3. 📸 Instagram Agent (`agents/instagram-creator.md`)
- **Lee de Notion**: Tareas con `Canal = Instagram` y `Status = Pendiente`
- **Output**: Caption (máx 2200 chars), hashtags (≤30), descripción visual del post/carrusel, texto stories
- **Formato**: Gancho en primera línea, emojis estratégicos, CTA claro

### 4. 🎵 TikTok Agent (`agents/tiktok-creator.md`)
- **Lee de Notion**: Tareas con `Canal = TikTok` y `Status = Pendiente`
- **Output**: Script con hook (0-3s), desarrollo (3 actos), CTA final, hashtags, descripción visual
- **Formato**: Conversacional, duración estimada 30-60s, ritmo rápido

### 5. ✍️ Blog Agent (`agents/blog-writer.md`)
- **Lee de Notion**: Tareas con `Canal = Blog` y `Status = Pendiente`
- **Output**: Título SEO, meta description, slug, artículo completo (800-1500 palabras), tags
- **Formato**: H1 → H2 → H3 estructurado, párrafos cortos, interno links sugeridos, CTA final

---

## Base de Datos Notion

### Database: `Social Media Content Board`

| Campo | Tipo | Valores posibles |
|-------|------|-----------------|
| `Título` | Title | Tema del contenido |
| `Canal` | Select | Newsletter / Instagram / TikTok / Blog |
| `Status` | Select | Pendiente / En Proceso / Draft Listo / Publicado |
| `Ángulo` | Rich Text | Descripción del enfoque sugerido |
| `Fuente Tendencia` | URL | Link a la fuente del trend |
| `Draft Contenido` | Rich Text | El draft generado por el agente |
| `Fecha Creación` | Date | Auto al crear la tarea |
| `Fecha Draft` | Date | Cuando se completó el draft |
| `Notas` | Rich Text | Notas adicionales del agente |

---

## Variables de Entorno Requeridas

```env
# LLM (según configuración de OpenClaw)
ANTHROPIC_API_KEY=sk-ant-...

# Notion
NOTION_API_KEY=secret_...
NOTION_DATABASE_ID=...          # ID de la base de datos creada

# Búsqueda (usa el motor que tenga configurado OpenClaw)
BRAVE_SEARCH_API_KEY=...        # Opcional, para búsquedas de tendencias
```

---

## Checklist de Implementación

### Fase 1 — Estructura base
- [ ] Crear estructura de carpetas del proyecto
- [ ] `README.md` con instrucciones de uso
- [ ] `.env.example` con variables necesarias
- [ ] `install.sh` para setup inicial

### Fase 2 — Skills compartidas
- [ ] `skills/notion-read-tasks.md`
- [ ] `skills/notion-create-task.md`
- [ ] `skills/notion-update-draft.md`
- [ ] `skills/trends-search.md`
- [ ] `skills/content-guidelines.md`
- [ ] `scripts/notion_client.py` (cliente Python Notion API)

### Fase 3 — Agentes
- [ ] `agents/trends-research.md`
- [ ] `agents/newsletter-writer.md`
- [ ] `agents/instagram-creator.md`
- [ ] `agents/tiktok-creator.md`
- [ ] `agents/blog-writer.md`

### Fase 4 — Templates y scripts de lanzamiento
- [ ] Templates de contenido por canal
- [ ] Scripts `run_*.sh` para cada agente
- [ ] `scripts/run_all.sh` orquestador

### Fase 5 — Setup Notion
- [ ] Instrucciones creación de base de datos
- [ ] Documentación de campos y filtros

---

## Verificación Final

1. Lanzar `agents/trends-research` → verificar tareas creadas en Notion
2. Lanzar `agents/newsletter-writer` → verificar draft en Notion
3. Lanzar `agents/instagram-creator` → verificar draft en Notion
4. Lanzar `agents/tiktok-creator` → verificar draft en Notion
5. Lanzar `agents/blog-writer` → verificar draft en Notion
6. Probar `run_all.sh` → verificar flujo completo

> **IMPORTANTE**: Antes de ejecutar los agentes:
> - Configura la base de datos Notion siguiendo `notion/database-setup.md`
> - Copia `.env.example` a `.env` y rellena tus API keys
> - OpenClaw debe estar instalado y configurado con tu LLM preferido
