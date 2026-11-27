# ESCOM Deportes — Sistema Integral de Gestión Deportiva

A static prototype of a school sports management portal (students, teams, sports activities, medical documents and absence justifications), built as the own project of our Databases course.

| | |
|---|---|
| Academic program / curriculum | Ingeniería en Sistemas Computacionales / 2020 |
| Course | Bases de Datos |

## Addresses

- **Site (GitHub Pages):** https://alexcor7.github.io/BD-Practica2/proyectopropio.html
- **Repository:** https://github.com/alexcor7/BD-Practica2
- **Assigned project (fork):** https://github.com/alexcor7/Seismic-Data-Visualization-System
- **Other hosts (exercise 5):** _TODO: add the two addresses once published_

## Team

| Member | Contribution |
|---|---|
| Alexis Cortés Rios (`alexcor7`) | Landing page, repository and Pages setup, setup of the assigned project (fork), relational schema, data loading and integrity practices, schema change for her own improvement proposal |
| Luis Villanueva Morales | _TODO: confirm_ — improvement proposal [#4](https://github.com/alexcor7/BD-Practica2/issues/4), review of pull requests, schema change for his own proposal |

## View the site and run it locally

Online: open the site address above. Everything uses relative paths, so it also works offline.

```bash
git clone https://github.com/alexcor7/BD-Practica2.git
cd BD-Practica2
# any static server works; Python is enough
python3 -m http.server 8000
# then open http://localhost:8000/proyectopropio.html
```

## Index of files

- Practice 2 (EER model, article analysis, proposals): [README.es.md](README.es.md), [`proyecto-propio/`](proyecto-propio/), [`proyecto-asignado/`](proyecto-asignado/), [`propuestas/`](propuestas/)
- Practice 3 (EER to relational): [`practica3/README.md`](practica3/README.md)
- Practices 4 and 5 (domains, loading, roles, referential integrity): [`practica4/`](practica4/), [`practica5/`](practica5/)
- Practice 3.1 (web publishing):
  - [`practica31/investigacion.md`](practica31/investigacion.md) — frontend, backend and hosting
  - [`practica31/identificacion.md`](practica31/identificacion.md) — frontend and backend of the assigned project
  - [`practica31/comparacion.md`](practica31/comparacion.md) — hosting comparison
  - [`practica31/lenguajes/lenguaje-alexis.md`](practica31/lenguajes/lenguaje-alexis.md) — backend language of each member

## Project status

- **Exists today:** the static front end (HTML, CSS and JavaScript with demonstration data), the EER model, the relational schema in PostgreSQL with synthetic sample data, roles and permissions, and the documentation.
- **Missing:** the **backend**. There is no server code yet: the site does not talk to the database, and all data on the page is fake. The plan is a Python API (FastAPI) in front of PostgreSQL, to be built in the next practices.
- **Also pending:** publishing on two more hosts and the final deployment with a backend.

## Use of generative AI

We used Claude as a support tool to understand the problems that came up during the practices and to draft SQL scripts and documents. We reviewed the results, ran the code, and are responsible for being able to explain each decision.
