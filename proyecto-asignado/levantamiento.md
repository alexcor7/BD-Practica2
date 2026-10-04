# Levantamiento del proyecto Sismos

## 1. Repositorio

Repositorio original:

https://github.com/gabrielhuav/Seismic-Data-Visualization-System

Fork utilizado:

[https://github.com/alexcor7/Seismic-Data-Visualization-System]



## 2. Requisitos

Para poner en funcionamiento el proyecto se utilizaron:

- Git para obtener el código fuente.
- Docker y Docker Compose para construir y ejecutar los contenedores.
- Un navegador web para acceder a la aplicación.
- PostgreSQL, ejecutándose dentro del contenedor proporcionado por Docker.

El proyecto utiliza dos servicios principales:

- Un contenedor web para la aplicación.
- Un contenedor PostgreSQL para la base de datos.

La base de datos utilizada por el proyecto se denomina `datawarehouse`.

---

## 3. Instalación y puesta en funcionamiento

Primero se realizó el fork del repositorio original y posteriormente se clonó el fork en el equipo local mediante Git.

### 3.1 Clonación

El repositorio fue clonado utilizando:

```bash
git clone https://github.com/alexcor7/Seismic-Data-Visualization-System
```

### 3.2 Construcción y ejecución de Docker
Se ejecutó Docker Compose para construir las imágenes y levantar los servicios:

docker-compose up -d

El proceso terminó correctamente y se crearon e iniciaron los contenedores correspondientes al servidor web y a PostgreSQL.

### 3.3 Comprobación de los contenedores

Se verificó el estado de los contenedores mediante:

docker ps

Se observaron los siguientes servicios en ejecución:

seismic-data-visualization-system-web-1
seismic-data-visualization-system-db-1

El servidor web quedó disponible mediante el puerto 80 y PostgreSQL mediante el puerto 5433 del equipo local.

### 3.4 Acceso a la aplicación

La aplicación fue accesible desde el navegador mediante:

http://localhost/vista.html

Después de volver a levantar el entorno, la aplicación cargó correctamente y permitió visualizar el sistema sin mostrar errores de conexión con PostgreSQL.

Se conservó una captura de pantalla como evidencia de la aplicación funcionando en el equipo local.

### 3.5 Acceso a PostgreSQL

Se ingresó directamente al contenedor de PostgreSQL mediante:

docker exec -it seismic-data-visualization-system-db-1 psql -U postgres -d datawarehouse

Una vez dentro de PostgreSQL se consultaron las tablas disponibles mediante:

\dt

Posteriormente se realizaron consultas sobre la tabla dim_sismos.

### 3.6 Consulta realizada

Primero se consultó el número de registros existentes en dim_sismos:

SELECT COUNT(*) FROM dim_sismos;

El resultado fue:

 count
--------
 319592
(1 row)

Esto permitió comprobar que la tabla contiene 319,592 registros sísmicos.

También se ejecutó:

SELECT *
FROM dim_sismos
LIMIT 10;

La consulta devolvió registros que contienen información como:

identificador del sismo;
magnitud;
latitud;
longitud;
profundidad;
referencia de localización;
estado;
nombre del estado.

Entre los registros obtenidos se encuentran, por ejemplo, sismos con magnitudes de 7.4, 6.9, 7.0 y 7.5, junto con sus respectivas coordenadas y referencias de localización.

## 4. Errores encontrados y soluciones

Durante el primer intento de ejecución, al acceder a:

http://localhost/vista.html

la aplicación mostró un mensaje de advertencia relacionado con la conexión de PHP con PostgreSQL:

pg_connect(): Unable to connect to PostgreSQL server:
connection to server at "db" (172.20.0.2),
port 5432 failed: Connection refused

El mensaje se presentó en el archivo std.php.

Posteriormente se volvió a ejecutar el entorno mediante Docker Compose y se comprobó nuevamente la aplicación. En el segundo intento, la aplicación cargó correctamente y el mensaje de error ya no apareció.

Por lo tanto, se verificó nuevamente el funcionamiento de la aplicación antes de continuar con las pruebas de la base de datos.

## 5. Confirmación utilizada

Confirmacion utilizada: 

`8569667cf4f46fab640dba3f82a7b324ca7efaf7`

---

## 6. Evidencias

Las evidencias de la puesta en funcionamiento se encuentran en el directorio evidencias/.

Se incluyen:

Captura de la construcción y arranque de los contenedores Docker.
Captura de la aplicación funcionando en el navegador.
Captura de la consulta realizada directamente sobre PostgreSQL y su resultado.