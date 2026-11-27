# Lenguaje del backend — Alexis Cortés

## 1. Lenguaje y motivo

**Python.** Lo elijo porque su sintaxis es corta y legible, es un lenguaje del que ya tengo conocimiento y se que puedo aprender de una manera más rapida la forma en la que se desarrolla el backend en un proyecto real.

## 2. Marco de trabajo y biblioteca

- **Marco: FastAPI.** Define cada operación como una función con su ruta y su método HTTP, valida los datos de entrada con tipos y genera sola la documentación de la API.
- **Biblioteca para PostgreSQL: psycopg 3** (`psycopg`), que ejecuta las consultas SQL del esquema de la Práctica 3 con parámetros, sin armar el SQL con texto.

Las credenciales se leerían de variables de entorno, nunca del código.

## 3. Dos operaciones del backend

**a) Registrar una solicitud de justificante**

- Ruta: `POST /solicitudes`
- Recibe (JSON): `boleta`, `id_seleccion`, `num_actividad`, `motivo`.
- Hace: un `INSERT` en `solicitud_justificante`; la fecha y el estado `pendiente` los pone la base por defecto.
- Devuelve: `201` con `id_solicitud`, `estado` y `fecha_solicitud`. Si la actividad no existe o la solicitud ya estaba registrada, la base rechaza el `INSERT` (llave foránea o restricción única) y devuelve `409` con un mensaje claro.

**b) Registrar la firma de un revisor**

- Ruta: `POST /solicitudes/{id_solicitud}/autorizaciones`
- Recibe (JSON): `tipo_revisor` (`ENTRENADOR` o `GESTOR`), `id_entrenador` o `id_gestor` según el tipo, `resultado` y, opcionalmente, `observacion`.
- Hace: un `INSERT` en `autorizacion`. La base impide una segunda firma del mismo tipo y verifica que la solicitud tenga exactamente dos firmas para cambiar de estado.
- Devuelve: `201` con la firma registrada y el estado actual de la solicitud (`pendiente`, `autorizada` o `rechazada`).
