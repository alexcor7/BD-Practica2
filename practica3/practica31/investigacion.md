# Investigación: frontend, backend y hospedaje


## 1. Frontend y backend

El frontend es la parte del sistema que se ejecuta en el equipo de quien lo usa: el navegador descarga HTML, CSS y JavaScript y con eso arma lo que se ve y reacciona a los clics. El backend es el código que corre en un servidor, una máquina que está encendida y conectada todo el tiempo; recibe las peticiones, decide qué responder y, si hace falta, consulta la base de datos (MDN contributors, 2026c). Cuando uso un sistema escolar, lo que veo en la pantalla es frontend; la verificación de mi boleta y la lectura de mis calificaciones ocurren en el backend.

En el navegador solo se ejecutan HTML, CSS y JavaScript. En el servidor se puede usar casi cualquier lenguaje: PHP, Python, Ruby, C# o JavaScript con Node.js, normalmente apoyado en un marco de trabajo (MDN contributors, 2026c). En el proyecto asignado, por ejemplo, el servidor ejecuta PHP y el navegador ejecuta el JavaScript de los mapas.

## 2. De la dirección a la página

Cuando escribo una dirección ocurre esto (MDN contributors, 2026a):

1. El navegador pregunta al sistema de nombres de dominio (DNS) cuál es la dirección IP del servidor que corresponde al nombre.
2. Abre una conexión con esa IP mediante TCP/IP; los datos viajan partidos en paquetes que se reensamblan al llegar.
3. Envía una petición HTTP, por ejemplo `GET /ruta`, con el nombre del servidor en la cabecera `Host`.
4. El servidor responde con un código de estado (200 si todo salió bien, 404 si no existe lo pedido), cabeceras y el cuerpo, que normalmente es HTML.
5. El navegador junta HTML, CSS, JavaScript e imágenes y dibuja la página. Si el HTML menciona más archivos, repite peticiones para cada uno.

## 3. API y por qué una página estática no llega a la base de datos

Una interfaz de programación de aplicaciones (API) es un conjunto de piezas que un programa ofrece a otro para que lo use sin conocer cómo está hecho por dentro (MDN contributors, 2026d). En web, el backend suele exponer una API: direcciones a las que el frontend envía peticiones HTTP y de las que recibe datos, a menudo en JSON.

Una página estática no puede conectarse directamente a PostgreSQL por dos razones que se ven en este curso. Primera, el navegador solo habla HTTP y no tiene un controlador para el protocolo propio del gestor de base de datos. Segunda, aunque pudiera, el JavaScript se descarga completo en el equipo de cada visitante: la contraseña de la base quedaría a la vista de cualquiera. Por eso el acceso a los datos vive en el servidor, que además controla qué puede ver cada usuario (MDN contributors, 2026c).

## 4. Hospedaje

Un servicio de hospedaje es una empresa que presta una máquina conectada a internet para que el sitio esté disponible todo el tiempo. Un servidor web estático solo entrega los archivos tal como están guardados; uno dinámico agrega un servidor de aplicaciones y una base de datos, que arman la respuesta al momento, por ejemplo llenando una plantilla HTML con datos (MDN contributors, 2026b). GitHub Pages es de los primeros: toma HTML, CSS y JavaScript de un repositorio y los publica (GitHub, n.d.-c). Por eso no sirve, por sí solo, para un sistema que consulta una base de datos.

Según Baker (2025):

- En el **hospedaje compartido**, mi sitio comparte máquina y recursos con muchos otros; es barato pero con poco control.
- En un **servidor virtual privado (VPS)** la máquina física también se comparte, pero una capa de virtualización me da una partición propia donde instalo mi sistema operativo y mi software; tengo más control y también más responsabilidad sobre seguridad y actualizaciones.
- En la **nube**, el servidor virtual no depende de una máquina física concreta y se pueden añadir recursos cuando hace falta; el costo sube conforme crece el uso.

## 5. Dominio, DNS y de quién es el dominio de mi sitio

Un dominio es el nombre legible de un sitio, por ejemplo `github.io`. El DNS funciona como la guía telefónica de internet: traduce ese nombre a una dirección IP. El navegador pregunta a un resolvedor recursivo, este consulta a un servidor raíz, que lo manda al servidor del dominio de nivel superior (como `.io`), y este señala al servidor autoritativo del dominio, que da la IP. Las respuestas se guardan en memoria temporal durante el tiempo que marca cada registro (TTL), para no repetir todo el recorrido (Cloudflare, n.d.).

Mi sitio está en `alexcor7.github.io/BD-Practica2`: el dominio `github.io` es de GitHub, y yo solo uso un subdirectorio con el nombre de mi usuario y el de mi repositorio (GitHub, n.d.-c). El sitio no tiene dominio propio.

## 6. HTTPS y límites del plan gratuito

HTTPS es la versión cifrada de HTTP: TLS cifra todo lo que viaja entre el cliente y el servidor, de modo que nadie en el camino lee datos como contraseñas (MDN contributors, 2025). Los sitios `github.io` se sirven por HTTPS automáticamente, y en la configuración del repositorio se puede marcar «Enforce HTTPS» para obligarlo; con dominio propio, GitHub pide el certificado a Let's Encrypt (GitHub, n.d.-b).

Los límites declarados de GitHub Pages (GitHub, n.d.-a): sitio publicado de hasta 1 GB, un límite recomendado de 1 GB para el repositorio, un límite flexible de 100 GB de transferencia al mes, un límite flexible de 10 compilaciones por hora y 10 minutos máximo por despliegue. Tampoco se permite alojar tiendas en línea ni recibir contraseñas o tarjetas, y no ejecuta código del lado del servidor.

## Referencias

Baker, K. (2025, 14 de mayo). *Shared hosting, VPS, or cloud hosting: Here's how to choose the right one for your website*. HubSpot. https://blog.hubspot.com/website/shared-hosting-vps-cloud-hosting

Cloudflare. (s. f.). *What is DNS?* https://cloudflare.com/learning/dns

GitHub. (s. f.-a). *GitHub Pages limits*. GitHub Docs. https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits

GitHub. (s. f.-b). *Securing your GitHub Pages site with HTTPS*. GitHub Docs. https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https

GitHub. (s. f.-c). *What is GitHub Pages?* GitHub Docs. https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages

MDN contributors. (2025, 30 de noviembre). *HTTPS*. MDN Web Docs. https://developer.mozilla.org/docs/Glossary/HTTPS

MDN contributors. (2026a, 20 de julio). *How the web works*. MDN Web Docs. https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/How_the_Web_works

MDN contributors. (2026b, 5 de noviembre). *What is a web server?* MDN Web Docs. https://developer.mozilla.org/en-US/Learn/What_is_a_web_server

MDN contributors. (2026c, 12 de septiembre). *Server-side website programming first steps: Introduction*. MDN Web Docs. https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/First_steps/Introduction

MDN contributors. (2026d, 4 de septiembre). *Introduction to web APIs*. MDN Web Docs. https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Client-side_web_APIs/Introduction
