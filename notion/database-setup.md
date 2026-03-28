# Configuración de la Base de Datos Notion

Esta guía te explica cómo crear la base de datos **Social Media Content Board** en Notion para que los agentes puedan leer y escribir tareas.

---

## Paso 1: Crear una Integration de Notion

1. Ve a [https://www.notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Haz clic en **"+ New integration"**
3. Nombre: `Social Media Automation`
4. Tipo: **Internal integration**
5. Permisos necesarios:
   - ✅ Read content
   - ✅ Update content
   - ✅ Insert content
6. Guarda y copia el **"Internal Integration Secret"** → este es tu `NOTION_API_KEY`

---

## Paso 2: Crear la base de datos

1. En Notion, crea una página nueva (o usa una existente)
2. Escribe `/database` → selecciona **"Table — Full page"**
3. Nómbrala: **Social Media Content Board**

---

## Paso 3: Configurar las propiedades (columnas)

Elimina las columnas por defecto y añade exactamente estas:

| Nombre de la propiedad | Tipo en Notion | Opciones |
|----------------------|---------------|---------|
| `Título` | **Title** | (ya existe por defecto) |
| `Canal` | **Select** | Newsletter, Instagram, TikTok, Blog |
| `Status` | **Select** | Pendiente, En Proceso, Draft Listo, Publicado |
| `Ángulo` | **Text** (Rich Text) | — |
| `Fuente Tendencia` | **URL** | — |
| `Draft Contenido` | **Text** (Rich Text) | — |
| `Fecha Creación` | **Date** | — |
| `Fecha Draft` | **Date** | — |
| `Notas` | **Text** (Rich Text) | — |

> ⚠️ Los nombres deben ser **exactamente** iguales (mayúsculas, tildes, espacios) porque el script Python los referencia así.

---

## Paso 4: Obtener el Database ID

1. Abre la base de datos en Notion a pantalla completa
2. Copia la URL de la barra del navegador. Tendrá este formato:
   ```
   https://www.notion.so/TU-WORKSPACE/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx?v=yyyy
   ```
3. El **Database ID** son los 32 caracteres entre la última `/` y el `?v=`
   - Ejemplo URL: `https://www.notion.so/miworkspace/abc123def456ghi789jkl012mno345p?v=...`
   - Database ID: `abc123def456ghi789jkl012mno345p`
4. Copia ese ID → es tu `NOTION_DATABASE_ID`

---

## Paso 5: Conectar la Integration a tu base de datos

1. Abre la base de datos en Notion
2. Haz clic en los `...` (tres puntos) en la esquina superior derecha
3. Selecciona **"Connections"** → **"Connect to"**
4. Busca y selecciona tu integration **"Social Media Automation"**
5. Confirma el acceso

---

## Paso 6: Actualizar el .env

Abre el fichero `.env` en la raíz del proyecto y añade:

```env
NOTION_API_KEY=secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NOTION_DATABASE_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Paso 7: Verificar la conexión

Ejecuta este comando de prueba (sin agentes, solo el cliente):

```bash
python3 scripts/notion_client.py read --canal "Newsletter" --status "Pendiente"
```

**Si devuelve `[]`** → la conexión funciona, pero no hay tareas aún. Perfecto.

**Si devuelve un error 401** → revisa que `NOTION_API_KEY` es correcto.

**Si devuelve un error 400/404** → revisa que `NOTION_DATABASE_ID` es correcto y que la integration tiene acceso a la base de datos (Paso 5).

---

## Vista recomendada en Notion

Para visualizar mejor el flujo, crea una vista **Board (Kanban)** agrupada por `Status`:

1. En la base de datos, haz clic en **"+ Add a view"**
2. Selecciona **"Board"**
3. Agrupa por: `Status`
4. Ordena por: `Fecha Creación` (descendente)

Así verás las columnas: **Pendiente → En Proceso → Draft Listo → Publicado** 🎯
