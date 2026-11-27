# Frontend y backend en el proyecto asignado

Proyecto:  [*Seismic Data Visualization System*](https://github.com/alexcor7/Seismic-Data-Visualization-System). 

## 1. Qué es frontend y qué es backend

En este proyecto no hay carpetas separadas: cada archivo `.php` de `src/` mezcla las dos cosas. El PHP del principio del archivo es backend y el HTML que genera es frontend.

| Ruta | Parte | Lenguaje |
|---|---|---|
| `src/vista.html` | Frontend (menú; carga cada mapa en un `iframe`, función `selectFile`) | HTML, CSS (Tailwind por CDN), JavaScript |
| `src/std.php` líneas 1–334 (conexión, consulta, `json_encode`) | Backend | PHP |
| `src/std.php` desde la línea 335 (formulario, `L.map`, Leaflet) | Frontend generado | HTML, CSS, JavaScript |
| `src/std2.php`, `src/std3.php`, `src/sismos.php`, `src/sismo.php`, `src/aeconomica.php`, `src/datos_sismicos.php` | Mismo esquema: backend PHP arriba, frontend abajo | PHP + HTML/JS |
| `src/test.php` | Backend (prueba de conexión) | PHP |
| `Dockerfile`, `docker-compose.yml` | Infraestructura: Apache con PHP 8.2 y PostgreSQL 17 | Docker |
| `sql/*.sql` | Datos: creación y carga de `datawarehouse` | SQL |

El JavaScript de los mapas (Leaflet, `leaflet.heat`, `choropleth`) se carga desde `unpkg.com` y corre en el navegador. No existe una API: el PHP incrusta los datos en la propia página, p. ej. `std.php:333` imprime `var sismoData = [...]`.

## 2. Dónde se conecta a la base de datos y con qué

| Archivo y línea | Biblioteca |
|---|---|
| `src/std.php:272`, `src/std2.php:254`, `src/std3.php:255`, `src/sismos.php:62`, `src/sismo.php:63`, `src/test.php` | `pg_connect()` (extensión `pgsql` de PHP) |
| `src/aeconomica.php:14` y `src/datos_sismicos.php:108` | `new PDO("pgsql:...")` (PDO con `pdo_pgsql`) |

Las extensiones se instalan en el `Dockerfile` (`docker-php-ext-install pdo pdo_pgsql pgsql`). El ejemplo principal es `std.php`: abre la conexión en la línea 272 con el servidor tomado de `POSTGRES_HOST` (`db` en Compose), ejecuta la consulta con `pg_query_params` en la línea 299 y recorre filas con `pg_fetch_assoc` (línea 311).

Hallazgo de seguridad: las credenciales están escritas en el código (`postgres`/`postgres` en `std*.php`; `secreto` en `datos_sismicos.php:105`). Además `datos_sismicos.php` usa `localhost:5432` fijo, así que en mi ejecución respondió «Error de conexión … Connection refused».

## 3. Tres peticiones del frontend al backend

| # | Dirección | Método | Qué devuelve |
|---|---|---|---|
| 1 | `/vista.html` | GET | 200, `text/html`, 3,502 bytes: el menú con los tres botones. |
| 2 | `/std.php` | GET (la dispara `selectFile`, `vista.html:57-64`, al asignar `iframe.src`) | 200, `text/html`, 28,497 bytes: la página del mapa con `sismoData` incrustado. |
| 3 | `/std.php?anio=2017&magnitud=6` | GET (el `<form method="GET">` de `std.php:349` al filtrar) | 200, `text/html`, 25,011 bytes: la misma página con solo los sismos de 2017 de magnitud ≥ 6 (2 en mi copia). |

Todas devuelven HTML completo, no JSON; no hay llamadas `fetch` ni AJAX en estos archivos.

## 4. Qué quedaría fuera de servicio con solo un hospedaje estático

Casi todo. Un hospedaje estático no ejecuta PHP, así que ninguno de los archivos `std*.php`, `sismos.php`, `sismo.php`, `aeconomica.php` ni `datos_sismicos.php` generaría su página; sin ellos no hay mapas, filtros ni datos. Tampoco habría base de datos, porque PostgreSQL es un contenedor aparte. Solo se vería `vista.html`, con los botones pero con un recuadro vacío o roto al elegir una opción.
