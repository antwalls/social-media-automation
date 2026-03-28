# Skill: Búsqueda de Tendencias

Esta skill te guía para descubrir trending topics relevantes para marketing de contenidos usando búsquedas web en tiempo real.

## Cuándo usar esta skill

Úsala al inicio de la sesión del **Trends Agent** para encontrar temas virales actuales.

## Fuentes a consultar

### 1. Google Trends
Busca con WebFetch o WebSearch:
```
https://trends.google.com/trending?geo=ES&hl=es
```
Busca tendencias de las últimas 24-48 horas en España/Latinoamérica.

### 2. Reddit — subreddits relevantes
Consulta los posts más votados (últimas 24h) en:
- `r/marketing`
- `r/entrepreneur`
- `r/socialmedia`
- `r/technology`
- Busca: `site:reddit.com trending marketing 2026`

### 3. Twitter/X (búsqueda web)
```
site:x.com OR site:twitter.com trending marketing OR emprendimiento
```

### 4. YouTube Trends
```
https://www.youtube.com/feed/trending
```
Busca vídeos virales de los últimos 3 días en temáticas de negocio, tecnología y lifestyle.

### 5. BuzzSumo / Search
Busca artículos con alto engagement:
```
most shared articles marketing digital "[mes actual] 2026"
```

## Proceso de análisis

Para cada tendencia encontrada, evalúa:

1. **Relevancia** — ¿Es aplicable a contenido de valor para el público objetivo?
2. **Timing** — ¿Está en la cresta de la ola (no ya pasado)?
3. **Ángulo diferenciador** — ¿Qué perspectiva única podemos aportar?
4. **Adaptabilidad por canal** — ¿Funciona para Newsletter, Instagram, TikTok y Blog?

## Criterios de selección

Selecciona entre **3-5 temas** que cumplan:
- ✅ Son tendencia en los últimos 1-7 días
- ✅ Tienen ángulo claro para varios canales
- ✅ Aportan valor real (no son clickbait vacío)
- ✅ Son relevantes para el nicho de la marca

## Output esperado

Para cada tema seleccionado, prepara:

```
Tema: [título del tema]
Fuente: [URL de la fuente]
Por qué es tendencia: [explicación en 1-2 frases]
Ángulos por canal:
  - Newsletter: [ángulo educativo/narrativo]
  - Instagram: [ángulo visual/emocional]
  - TikTok: [ángulo entretenido/sorprendente]
  - Blog: [ángulo informativo/SEO]
```

A continuación, usa la skill `notion-create-task` para crear las tareas en Notion.
