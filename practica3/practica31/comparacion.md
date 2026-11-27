# Comparación de hospedajes


| | GitHub Pages | Netlify | Neocities |
|---|---|---|---|
| Pasos que pidió | Settings → Pages → elegir rama y carpeta (`docs` o raíz) | Crear cuenta → Add new site → conectar GitHub (elegir repo, rama y carpeta docs) o arrastrar carpeta manualmente (Netlify Drop)|Crear cuenta y subdominio → ir a Dashboard → Edit Site → subir/arrastrar archivos (index.html, CSS e imágenes)|
| Cuánto tardó | 2:34 min | 5.404s | 4.504s |
| Dirección que otorga | [Githubpages](https://alexcor7.github.io/BD-Practica2/) |[Netlify](https://sistemaintegraldegestiondeportivaipn.netlify.app/)  |[Neocities](https://escomsistemadeportivo.neocities.org/)|
| HTTPS | Sí, automático en `github.io` (hay que marcar *Enforce HTTPS*) | Sí, automático y gratuito (Let's Encrypt) en `.netlify.app` | Sí, automático y gratuito en `.neocities.org` |
| Se actualiza solo al confirmar | Sí, al subir a la rama elegida |Sí, al hacer `push` si está vinculado a GitHub (no si se subió manualmente arrastrando carpeta) | No directamente con `git push` (requiere subir archivos manualmente en el panel o configurar una GitHub Action con su CLI/API)|
| Límites declarados | Sitio ≤ 1 GB; 100 GB/mes (flexible); 10 compilaciones/hora (flexible); despliegue ≤ 10 min; sin comercio ni contraseñas ni código de servidor | 100 GB de ancho de banda/mes; 300 minutos de compilación (build minutes)/mes; límite de carga de archivos individuales ~100 MB; solo sitios estáticos y funciones serverless cortas| 1 GB de almacenamiento total; 200 GB de ancho de banda/mes; solo archivos estáticos permitidos (HTML, CSS, JS, imágenes, fuentes, etc.; sin ejecución de servidor)|


## Propuesta para proyecto propio

Ninguno de los servicios solo estáticos nos sirve: el proyecto propio necesitará un backend en Python que hable con PostgreSQL, y eso exige un servidor que ejecute código persistente y una base de datos relacional accesible desde él. Entre las opciones de la tabla, Neocities y GitHub Pages son exclusivamente estáticos, mientras que Netlify añade funciones serverless, pero son ejecuciones cortas sin estado, no un servidor siempre activo con PostgreSQL. Por ello, para la versión funcional elegiríamos un servidor virtual privado (VPS) o una plataforma PaaS en la nube (como Render, Railway o Fly.io) donde podamos desplegar el backend en Python y conectar una instancia administrada de PostgreSQL, dejando el frontend estático en alguno de los servicios gratuitos probados apuntando a la API del backend.
