-- =====================================================================
-- Práctica 3 · Pruebas de restricciones del esquema

-- Parte A: datos válidos (todos deben aceptarse).
-- Parte B: INSERT/UPDATE/DELETE que el gestor DEBE rechazar.
-- =====================================================================
\set ECHO queries
\set VERBOSITY verbose

-- ============================ PARTE A ================================
\echo '=== PARTE A: datos válidos ==='

INSERT INTO deporte (nombre, descripcion) VALUES
    ('Futbol soccer', 'Deporte de conjunto'),
    ('Basquetbol',    'Deporte de conjunto'),
    ('Natacion',      'Deporte individual');

-- Supertipo + subtipo en la misma transacción (la completitud se revisa al COMMIT)
BEGIN;
INSERT INTO personal_deportivo (nombre, telefono, correo, tipo) VALUES
    ('Carlos Mendoza Ruiz', '5511111111', 'cmendoza@ipn.mx', 'ENTRENADOR'),
    ('Laura Ortega',        '5522222222', 'lortega@ipn.mx',  'ENTRENADOR'),
    ('Marta Salas Pérez',   '5533333333', 'msalas@ipn.mx',   'GESTOR');
INSERT INTO entrenador (id_personal, certificacion) VALUES (1, 'Licencia B FMF'), (2, 'Nivel 1 FIBA');
INSERT INTO gestor_deportivo (id_personal, cargo, nivel_acceso) VALUES (3, 'Jefa de Gestión Deportiva', 3);
COMMIT;

INSERT INTO seleccion (nombre, rama, estado, id_deporte, id_entrenador) VALUES
    ('Pumas ESCOM', 'varonil', 'activa', 1, 1),
    ('Aguilas ESCOM', 'femenil', 'en_reclutamiento', 2, 2);   -- sin estudiantes todavía (0,N)

INSERT INTO estudiante (boleta, nombre, apellido_paterno, apellido_materno, telefono,
                        correo, nss, carrera, promedio, adeudos, id_seleccion) VALUES
    ('2023630001', 'Ana',   'Lopez',  'Diaz',   '5544444444', 'alopez@alumno.ipn.mx',  '12345678901', 'ISC', 8.50, 0, 1),
    ('2023630002', 'Pedro', 'Gomez',  NULL,     '5566666666', 'pgomez@alumno.ipn.mx',  NULL,          'ISC', 5.80, 2, 1),
    ('2023630003', 'Sofia', 'Reyes',  'Cruz',   NULL,         'sreyes@alumno.ipn.mx',  NULL,          'IIA', 9.10, 1, NULL);  -- sin selección (0,1)

-- Multivaluado: varios teléfonos de emergencia por estudiante
INSERT INTO estudiante_telefono_emergencia VALUES
    ('2023630001', '5555555555'), ('2023630001', '5577777777'), ('2023630002', '5588888888');

INSERT INTO documento_medico VALUES
    ('2023630001', 'OF-001', 'examen',     CURRENT_DATE - 100, CURRENT_DATE + 265, 'docs/ana_examen.pdf'),
    ('2023630001', 'OF-002', 'constancia', CURRENT_DATE - 400, CURRENT_DATE - 35,  'docs/ana_constancia.pdf'),
    ('2023630002', 'OF-001', 'examen',     CURRENT_DATE - 340, CURRENT_DATE + 15,  'docs/pedro_examen.pdf');

INSERT INTO actividad_deportiva VALUES
    (1, 1, 'entrenamiento', CURRENT_DATE + 2, '17:00', '19:00', 'Cancha 1 ESCOM'),
    (1, 2, 'partido',       CURRENT_DATE + 9, '10:00', '12:00', 'Estadio Wilfrido Massieu');

INSERT INTO evaluacion_beca (boleta, num_evaluacion, promedio, adeudos, resultado) VALUES
    ('2023630001', 1, 8.50, 0, 'acreedor'),
    ('2023630002', 1, 5.80, 2, 'no_acreedor');

-- Solicitudes y firmas: la solicitud y sus autorizaciones se confirman juntas (disparador diferido)
BEGIN;
INSERT INTO solicitud_justificante (boleta, id_seleccion, num_actividad, motivo, estado, fecha_respuesta) VALUES
    ('2023630001', 1, 2, 'Partido oficial', 'autorizada', CURRENT_DATE),   -- 1: firmada por entrenador y gestor
    ('2023630002', 1, 2, 'Partido oficial', 'rechazada',  CURRENT_DATE),   -- 2: el gestor la rechaza
    ('2023630001', 1, 1, 'Entrenamiento',   'pendiente',  NULL);           -- 3: solo firma el entrenador
INSERT INTO autorizacion (id_solicitud, id_personal, tipo_revisor, resultado, observacion) VALUES
    (1, 1, 'ENTRENADOR', 'autorizada', 'Conforme'),
    (1, 3, 'GESTOR',     'autorizada', NULL),
    (2, 3, 'GESTOR',     'rechazada',  'Sin documento medico vigente'),
    (3, 1, 'ENTRENADOR', 'autorizada', NULL);
COMMIT;

INSERT INTO justificante (id_solicitud, fecha_caducidad, archivo)
    VALUES (1, CURRENT_DATE + 30, 'justificantes/J00001.pdf');

\echo '--- Atributo derivado: vigencia de documentos (no se almacena) ---'
SELECT * FROM v_documento_estado ORDER BY boleta, num_oficio;

-- ============================ PARTE B ================================
\echo ''
\echo '=== PARTE B: operaciones que el gestor debe RECHAZAR ==='

\echo '--- B1 · CHECK: promedio fuera de 0-10 ---'
INSERT INTO estudiante (boleta, nombre, apellido_paterno, correo, carrera, promedio)
VALUES ('2023630004', 'Luis', 'Soto', 'lsoto@alumno.ipn.mx', 'ISC', 11.5);

\echo '--- B2 · PRIMARY KEY: boleta repetida ---'
INSERT INTO estudiante (boleta, nombre, apellido_paterno, correo, carrera, promedio)
VALUES ('2023630001', 'Otra', 'Persona', 'otra@alumno.ipn.mx', 'ISC', 8);

\echo '--- B3 · UNIQUE (Regla 6): un entrenador dirige como máximo UNA selección ---'
INSERT INTO seleccion (nombre, rama, id_deporte, id_entrenador) VALUES ('Pumas B', 'varonil', 1, 1);

\echo '--- B4 · NOT NULL (cardinalidad 1,1): selección sin entrenador ---'
INSERT INTO seleccion (nombre, rama, id_deporte, id_entrenador) VALUES ('Sin entrenador', 'mixto', 3, NULL);

\echo '--- B5 · FOREIGN KEY: documento médico de una boleta que no existe (entidad débil) ---'
INSERT INTO documento_medico VALUES ('9999999999', 'OF-001', 'examen', CURRENT_DATE - 10, CURRENT_DATE + 100, 'docs/x.pdf');

\echo '--- B6 · CHECK: vencimiento anterior a la emisión ---'
INSERT INTO documento_medico VALUES ('2023630003', 'OF-001', 'examen', CURRENT_DATE, CURRENT_DATE - 5, 'docs/y.pdf');

\echo '--- B7 · Disyunción: un GESTOR no puede registrarse también como ENTRENADOR ---'
INSERT INTO entrenador (id_personal, certificacion) VALUES (3, 'Intento');

\echo '--- B8 · Completitud: personal_deportivo sin subtipo (se rechaza al COMMIT) ---'
BEGIN;
INSERT INTO personal_deportivo (nombre, correo, tipo) VALUES ('Sin Subtipo', 'sinsubtipo@ipn.mx', 'ENTRENADOR');
COMMIT;

\echo '--- B9 · FK compuesta: solo una solicitud AUTORIZADA genera justificante (la 2 fue rechazada) ---'
INSERT INTO justificante (id_solicitud, fecha_caducidad, archivo) VALUES (2, CURRENT_DATE + 30, 'justificantes/J00002.pdf');

\echo '--- B10 · UNIQUE: un mismo estudiante no repite solicitud para la misma actividad ---'
INSERT INTO solicitud_justificante (boleta, id_seleccion, num_actividad, motivo)
VALUES ('2023630001', 1, 1, 'Duplicada');

\echo '--- B11 · CHECK (regla de negocio): "acreedor" con promedio 5.0 ---'
INSERT INTO evaluacion_beca (boleta, num_evaluacion, promedio, adeudos, resultado)
VALUES ('2023630003', 1, 5.0, 0, 'acreedor');

\echo '--- B12 · CHECK: solicitud autorizada sin fecha de respuesta ---'
UPDATE solicitud_justificante SET estado = 'autorizada' WHERE id_solicitud = 3;

\echo '--- B13 · ON DELETE RESTRICT: borrar un deporte que tiene selecciones ---'
DELETE FROM deporte WHERE id_deporte = 1;

\echo '--- B14 · ON DELETE RESTRICT: borrar un entrenador que dirige una selección ---'
DELETE FROM personal_deportivo WHERE id_personal = 2;

\echo '--- B15 · ON UPDATE RESTRICT: rechazar una solicitud que ya generó justificante ---'
UPDATE solicitud_justificante SET estado = 'rechazada' WHERE id_solicitud = 1;

\echo '--- B16 · Relación justifica (FK compuesta): solicitud para una actividad que no existe ---'
INSERT INTO solicitud_justificante (boleta, id_seleccion, num_actividad, motivo)
VALUES ('2023630003', 1, 77, 'Actividad inexistente');

\echo '--- B17 · NOT NULL (cardinalidad 1,1 de justifica): solicitud sin actividad ---'
INSERT INTO solicitud_justificante (boleta, id_seleccion, num_actividad, motivo)
VALUES ('2023630003', NULL, NULL, 'Sin actividad');

\echo '--- B18 · UNIQUE (autoriza): no puede haber dos firmas del mismo tipo en una solicitud ---'
INSERT INTO autorizacion (id_solicitud, id_personal, tipo_revisor, resultado) VALUES (3, 2, 'ENTRENADOR', 'autorizada');

\echo '--- B19 · FK compuesta (autoriza): el tipo de revisor debe ser el real (el personal 2 es ENTRENADOR, no GESTOR) ---'
INSERT INTO autorizacion (id_solicitud, id_personal, tipo_revisor, resultado) VALUES (3, 2, 'GESTOR', 'autorizada');

\echo '--- B20 · Dos firmas: marcar "autorizada" una solicitud con una sola firma (se rechaza al COMMIT) ---'
BEGIN;
UPDATE solicitud_justificante SET estado = 'autorizada', fecha_respuesta = CURRENT_DATE WHERE id_solicitud = 3;
COMMIT;

\echo '--- B21 · Dos firmas: firma que contradice el estado (el gestor rechaza una solicitud "autorizada") ---'
BEGIN;
INSERT INTO solicitud_justificante (boleta, id_seleccion, num_actividad, motivo, estado, fecha_respuesta)
VALUES ('2023630003', 1, 1, 'Entrenamiento', 'autorizada', CURRENT_DATE);
INSERT INTO autorizacion VALUES (currval(pg_get_serial_sequence('solicitud_justificante','id_solicitud')), 1, 'ENTRENADOR', CURRENT_DATE, 'autorizada', NULL),
                                (currval(pg_get_serial_sequence('solicitud_justificante','id_solicitud')), 3, 'GESTOR',     CURRENT_DATE, 'rechazada', NULL);
COMMIT;

\echo '--- B22 · Multivaluado: el mismo teléfono de emergencia dos veces para un estudiante ---'
INSERT INTO estudiante_telefono_emergencia VALUES ('2023630001', '5555555555');

-- ====================== PARTE C · acciones referenciales =============
\echo ''
\echo '=== PARTE C: acciones referenciales que SÍ proceden ==='
\echo '--- C1 · Al borrar la selección 1: estudiantes -> SET NULL (conservan su fila), actividades -> CASCADE ---'
\echo '    (se prueba dentro de una transacción que se revierte)'
BEGIN;
SELECT boleta, id_seleccion FROM estudiante ORDER BY boleta;
DELETE FROM justificante;
DELETE FROM solicitud_justificante;
DELETE FROM seleccion WHERE id_seleccion = 1;
SELECT boleta, id_seleccion FROM estudiante ORDER BY boleta;
SELECT count(*) AS actividades_restantes FROM actividad_deportiva;   -- CASCADE: 0
ROLLBACK;

\echo '--- C2 · ON DELETE CASCADE: al borrar un estudiante desaparecen documentos, evaluaciones, teléfonos, solicitudes y firmas ---'
BEGIN;
DELETE FROM estudiante WHERE boleta = '2023630001';
SELECT count(*) AS docs_de_ana FROM documento_medico WHERE boleta = '2023630001';
SELECT count(*) AS evals_de_ana FROM evaluacion_beca WHERE boleta = '2023630001';
SELECT count(*) AS telefonos_de_ana FROM estudiante_telefono_emergencia WHERE boleta = '2023630001';
SELECT count(*) AS firmas_restantes FROM autorizacion;
ROLLBACK;
