# 🤖 Social Media Automation

Sistema multi-agente con OpenClaw para generar contenido en **draft** coordinado a través de **Notion**. Un agente orquestador busca tendencias y asigna tareas a agentes especializados en Newsletter, Instagram, TikTok y Blog.

---

## ¿Cómo funciona?

```
🔍 Trends Agent
      │
      ▼
  Notion Board  ──► 📧 Newsletter Agent  ──► Draft en Notion
  (Tareas)      ──► 📸 Instagram Agent   ──► Draft en Notion
                ──► 🎵 TikTok Agent      ──► Draft en Notion
                ──► ✍️  Blog Agent        ──► Draft en Notion
```

1. **Trends Agent** descubre temas virales y crea tareas en Notion para cada canal
2. Cada **agente especializado** lee sus tareas pendientes y genera el contenido en draft
3. Los drafts quedan en Notion listos para revisión y publicación manual

---

## Configuración rápida

### 1. Requisitos

- [OpenClaw](https://openclaw.ai) instalado y configurado
- Cuenta de [Notion](https://notion.so) con acceso a la API
- Python 3.9+ (para el cliente Notion)
- **LLM** (elige una opción):
  - **LM Studio** (recomendado para uso local) — Descarga en [lmstudio.ai](https://lmstudio.ai), carga un modelo y activa el servidor local en `http://127.0.0.1:1234`
  - **Anthropic Claude** (cloud) — Necesitas una `ANTHROPIC_API_KEY`

### 2. Setup inicial

```bash
# Clonar/entrar al directorio
cd social-media-automation

# Ejecutar instalador
./install.sh
```

### 3. Configurar variables de entorno

```bash
cp .env.example .env
# Edita .env con tus API keys
```

Variables necesarias (el `.env.example` tiene ambas opciones comentadas; activa la que uses):

| Variable | Descripción | Opción |
|----------|-------------|--------|
| `OPENAI_BASE_URL` | URL del servidor LM Studio | LM Studio |
| `OPENAI_API_KEY` | Placeholder (`lm-studio`) | LM Studio |
| `OPENAI_MODEL` | Nombre del modelo cargado en LM Studio | LM Studio |
| `ANTHROPIC_API_KEY` | Tu clave de Anthropic | Claude |
| `NOTION_API_KEY` | Integration token de Notion | Ambas |
| `NOTION_DATABASE_ID` | ID de la base de datos | Ambas |

### 4. Crear la base de datos Notion

Sigue las instrucciones en [`notion/database-setup.md`](notion/database-setup.md) para crear la base de datos con los campos correctos.

---

## Uso

### Lanzar el agente de tendencias (crea tareas en Notion)

```bash
./scripts/run_trends.sh
```

### Lanzar un agente de contenido específico

```bash
./scripts/run_newsletter.sh   # Newsletter
./scripts/run_instagram.sh    # Instagram
./scripts/run_tiktok.sh       # TikTok
./scripts/run_blog.sh         # Blog
```

### Lanzar todo el flujo completo

```bash
./scripts/run_all.sh
```

---

## Agentes

| Agente | Fichero | Canal |
|--------|---------|-------|
| 🔍 Trends Research | `agents/trends-research.md` | Orquestador |
| 📧 Newsletter Writer | `agents/newsletter-writer.md` | Email |
| 📸 Instagram Creator | `agents/instagram-creator.md` | Instagram |
| 🎵 TikTok Creator | `agents/tiktok-creator.md` | TikTok/Reels |
| ✍️ Blog Writer | `agents/blog-writer.md` | Blog |

---

## Estructura del proyecto

```
social-media-automation/
├── agents/          # Definiciones de los agentes OpenClaw
├── skills/          # Skills compartidas entre agentes
├── scripts/         # Scripts de lanzamiento y cliente Notion
├── templates/       # Plantillas de contenido por canal
├── notion/          # Instrucciones de setup Notion
├── .env.example     # Variables de entorno necesarias
└── install.sh       # Instalador
```

---

## Licencia

MIT
