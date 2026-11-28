-- =====================================================================
-- Práctica 3 · Sistema de Gestión Deportiva Escolar

-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- Regla 1 · DEPORTE (entidad fuerte)
-- ---------------------------------------------------------------------
CREATE TABLE deporte (
    id_deporte   INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre       VARCHAR(60)  NOT NULL,
    descripcion  VARCHAR(250),
    estado       VARCHAR(10)  NOT NULL DEFAULT 'activo',
    CONSTRAINT pk_deporte        PRIMARY KEY (id_deporte),
    CONSTRAINT uq_deporte_nombre UNIQUE (nombre),
    CONSTRAINT ck_deporte_estado CHECK (estado IN ('activo', 'inactivo'))
);

-- ---------------------------------------------------------------------
-- Regla 1 + Regla 9 (estrategia A) · PERSONAL_DEPORTIVO
-- Supertipo de la jerarquía (d,t). 'tipo' es el atributo discriminador.
-- (En el EER el nombre del personal es un atributo simple.)
-- ---------------------------------------------------------------------
CREATE TABLE personal_deportivo (
    id_personal       INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre            VARCHAR(120) NOT NULL,
    telefono          VARCHAR(15) NOT NULL,
    correo            VARCHAR(100) NOT NULL,
    tipo              VARCHAR(10)  NOT NULL,          -- discriminador
    CONSTRAINT pk_personal_deportivo PRIMARY KEY (id_personal),
    CONSTRAINT uq_personal_correo    UNIQUE (correo),
    -- necesaria para que los subtipos puedan referenciar (id, tipo)
    CONSTRAINT uq_personal_id_tipo   UNIQUE (id_personal, tipo),
    CONSTRAINT ck_personal_tipo      CHECK (tipo IN ('ENTRENADOR', 'GESTOR')),
    CONSTRAINT ck_personal_correo    CHECK (correo LIKE '%_@_%._%'),
    CONSTRAINT ck_personal_telefono  CHECK (telefono IS NULL OR telefono ~ '^[0-9]{10,15}$')
);

-- ---------------------------------------------------------------------
-- Regla 9 (estrategia A) · ENTRENADOR  (subtipo)
-- La PK es a la vez FK al supertipo. La FK compuesta (id_personal, tipo)
-- + CHECK (tipo = 'ENTRENADOR') hace cumplir la DISYUNCIÓN: una fila de
-- personal_deportivo con tipo 'GESTOR' no puede aparecer aquí.
-- ---------------------------------------------------------------------
CREATE TABLE entrenador (
    id_personal   INTEGER      NOT NULL,
    tipo          VARCHAR(10)  NOT NULL DEFAULT 'ENTRENADOR',
    certificacion VARCHAR(100),
    CONSTRAINT pk_entrenador      PRIMARY KEY (id_personal),
    CONSTRAINT ck_entrenador_tipo CHECK (tipo = 'ENTRENADOR'),
    CONSTRAINT fk_entrenador_personal FOREIGN KEY (id_personal, tipo)
        REFERENCES personal_deportivo (id_personal, tipo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 9 (estrategia A) · GESTOR_DEPORTIVO  (subtipo)
-- ---------------------------------------------------------------------
CREATE TABLE gestor_deportivo (
    id_personal   INTEGER      NOT NULL,
    tipo          VARCHAR(10)  NOT NULL DEFAULT 'GESTOR',
    cargo         VARCHAR(80)  NOT NULL,
    nivel_acceso  SMALLINT     NOT NULL DEFAULT 1,
    CONSTRAINT pk_gestor_deportivo PRIMARY KEY (id_personal),
    CONSTRAINT ck_gestor_tipo      CHECK (tipo = 'GESTOR'),
    CONSTRAINT ck_gestor_nivel     CHECK (nivel_acceso BETWEEN 1 AND 3),
    CONSTRAINT fk_gestor_personal  FOREIGN KEY (id_personal, tipo)
        REFERENCES personal_deportivo (id_personal, tipo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 1 + Regla 4 + Regla 6 · SELECCION
--   deporte (0,N) — tiene — (1,1) selección      -> Regla 4
--   entrenador (0,1) — dirige — (1,1) selección  -> Regla 6, FK UNIQUE NOT NULL
-- ---------------------------------------------------------------------
CREATE TABLE seleccion (
    id_seleccion  INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR(80)  NOT NULL,
    rama          VARCHAR(10)  NOT NULL,
    estado        VARCHAR(20)  NOT NULL DEFAULT 'activa',
    id_deporte    INTEGER      NOT NULL,
    id_entrenador INTEGER      NOT NULL,
    CONSTRAINT pk_seleccion        PRIMARY KEY (id_seleccion),
    CONSTRAINT uq_seleccion_nombre UNIQUE (nombre, rama),
    CONSTRAINT uq_seleccion_entrenador UNIQUE (id_entrenador),   -- máx. una selección por entrenador
    CONSTRAINT ck_seleccion_rama   CHECK (rama IN ('varonil', 'femenil')),
    CONSTRAINT ck_seleccion_estado CHECK (estado IN ('activa', 'inactiva')),
    CONSTRAINT fk_seleccion_deporte FOREIGN KEY (id_deporte)
        REFERENCES deporte (id_deporte)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_seleccion_entrenador FOREIGN KEY (id_entrenador)
        REFERENCES entrenador (id_personal)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 1 + Regla 2 + Regla 4 · ESTUDIANTE
--   estudiante (1,1) — pertenece — (1,N) selección
--   -> FK id_seleccion obligatoria (NOT NULL)
-- ---------------------------------------------------------------------
CREATE TABLE estudiante (
    boleta              VARCHAR(10)  NOT NULL,
    nombre              VARCHAR(60)  NOT NULL,
    apellido_paterno    VARCHAR(60)  NOT NULL,
    apellido_materno    VARCHAR(60),
    telefono            VARCHAR(15)  NOT NULL,
    correo              VARCHAR(100) NOT NULL,
    nss                 VARCHAR(11)  NOT NULL,
    carrera             VARCHAR(100) NOT NULL,
    promedio            NUMERIC(4,2) NOT NULL,
    adeudos             SMALLINT     NOT NULL DEFAULT 0,   -- materias adeudadas
    id_seleccion        INTEGER      NOT NULL,
    CONSTRAINT pk_estudiante        PRIMARY KEY (boleta),
    CONSTRAINT uq_estudiante_correo UNIQUE (correo),
    CONSTRAINT uq_estudiante_nss    UNIQUE (nss),
    CONSTRAINT ck_estudiante_boleta CHECK (boleta ~ '^[0-9]{10}$'),
    CONSTRAINT ck_estudiante_nss    CHECK (nss IS NULL OR nss ~ '^[0-9]{11}$'),
    CONSTRAINT ck_estudiante_tel    CHECK (telefono IS NULL OR telefono ~ '^[0-9]{10,15}$'),
    CONSTRAINT ck_estudiante_prom   CHECK (promedio BETWEEN 0 AND 10),
    CONSTRAINT ck_estudiante_adeud  CHECK (adeudos >= 0),
    CONSTRAINT fk_estudiante_seleccion FOREIGN KEY (id_seleccion)
        REFERENCES seleccion (id_seleccion)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 3 · TELEFONO_EMERGENCIA de ESTUDIANTE (atributo multivaluado)
-- PK = (clave de la entidad original, valor)
-- ---------------------------------------------------------------------
CREATE TABLE estudiante_telefono_emergencia (
    boleta    VARCHAR(10) NOT NULL,
    telefono  VARCHAR(15) NOT NULL,
    CONSTRAINT pk_estudiante_telefono_emergencia PRIMARY KEY (boleta, telefono),
    CONSTRAINT ck_telemerg_formato CHECK (telefono ~ '^[0-9]{10,15}$'),
    CONSTRAINT fk_telemerg_estudiante FOREIGN KEY (boleta)
        REFERENCES estudiante (boleta)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 8 · DOCUMENTO_MEDICO (entidad débil, dependencia de identificación)
-- PK compuesta = FK del propietario + discriminador (num_oficio)
-- ---------------------------------------------------------------------
CREATE TABLE documento_medico (
    boleta             VARCHAR(10)  NOT NULL,
    num_oficio         VARCHAR(20)  NOT NULL,
    tipo_documento     VARCHAR(20)  NOT NULL,
    fecha_emision      DATE         NOT NULL,
    fecha_vencimiento  DATE         NOT NULL,
    archivo            VARCHAR(255) NOT NULL,
    CONSTRAINT pk_documento_medico PRIMARY KEY (boleta, num_oficio),
    CONSTRAINT ck_documento_oficio CHECK (btrim(num_oficio) <> ''),
    CONSTRAINT ck_documento_tipo   CHECK (tipo_documento IN ('constancia', 'examen', 'certificado', 'otro')),
    CONSTRAINT ck_documento_fechas CHECK (fecha_vencimiento > fecha_emision),
    CONSTRAINT fk_documento_estudiante FOREIGN KEY (boleta)
        REFERENCES estudiante (boleta)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 8 · ACTIVIDAD_DEPORTIVA (entidad débil respecto a SELECCION)
-- ---------------------------------------------------------------------
CREATE TABLE actividad_deportiva (
    id_seleccion    INTEGER      NOT NULL,
    num_actividad   SMALLINT     NOT NULL,
    tipo_actividad  VARCHAR(20)  NOT NULL,
    fecha           DATE         NOT NULL,
    hora_inicio     TIME         NOT NULL,
    hora_fin        TIME         NOT NULL,
    lugar           VARCHAR(100) NOT NULL,
    CONSTRAINT pk_actividad_deportiva PRIMARY KEY (id_seleccion, num_actividad),
    CONSTRAINT ck_actividad_num   CHECK (num_actividad > 0),
    CONSTRAINT ck_actividad_tipo  CHECK (tipo_actividad IN ('entrenamiento', 'partido', 'competencia', 'otro')),
    CONSTRAINT ck_actividad_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT fk_actividad_seleccion FOREIGN KEY (id_seleccion)
        REFERENCES seleccion (id_seleccion)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 8 · EVALUACION_BECA (entidad débil respecto a ESTUDIANTE)
-- Conserva los datos académicos usados (promedio, adeudos) y el resultado.
-- El CHECK implementa la regla de negocio: acreedor <=> promedio >= 6.0
-- y como máximo una materia adeudada.
-- ---------------------------------------------------------------------
CREATE TABLE evaluacion_beca (
    boleta            VARCHAR(10)  NOT NULL,
    num_evaluacion    SMALLINT     NOT NULL,
    fecha_evaluacion  DATE         NOT NULL DEFAULT CURRENT_DATE,
    promedio          NUMERIC(4,2) NOT NULL,
    adeudos           SMALLINT     NOT NULL,
    resultado         VARCHAR(12)  NOT NULL,
    CONSTRAINT pk_evaluacion_beca PRIMARY KEY (boleta, num_evaluacion),
    CONSTRAINT ck_evaluacion_num       CHECK (num_evaluacion > 0),
    CONSTRAINT ck_evaluacion_promedio  CHECK (promedio BETWEEN 0 AND 10),
    CONSTRAINT ck_evaluacion_adeudos   CHECK (adeudos >= 0),
    CONSTRAINT ck_evaluacion_resultado CHECK (resultado IN ('acreedor', 'no_acreedor')),
    CONSTRAINT ck_evaluacion_regla     CHECK ((resultado = 'acreedor') = (promedio >= 6.0 AND adeudos <= 1)),
    CONSTRAINT fk_evaluacion_estudiante FOREIGN KEY (boleta)
        REFERENCES estudiante (boleta)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Reglas 4 y 5 · SOLICITUD_JUSTIFICANTE (entidad fuerte; asociativa en la práctica)
--   estudiante (0,N) — realiza — (1,1) solicitud      -> Regla 4: FK boleta NOT NULL
--   actividad  (0,N) — justifica — (1,1) solicitud    -> Regla 4: FK compuesta
--                       (id_seleccion, num_actividad) NOT NULL, porque la
--                       actividad es entidad débil y su clave tiene dos columnas.
-- Un estudiante pide como máximo un justificante por actividad (UNIQUE).
-- El estado final (pendiente / autorizada / rechazada) lo determinan las
-- AUTORIZACIONES (ver más abajo); aquí se guarda y un disparador lo verifica.
-- ---------------------------------------------------------------------
CREATE TABLE solicitud_justificante (
    id_solicitud         INTEGER GENERATED ALWAYS AS IDENTITY,
    boleta               VARCHAR(10)  NOT NULL,
    id_seleccion         INTEGER      NOT NULL,
    num_actividad        SMALLINT     NOT NULL,
    fecha_solicitud      DATE         NOT NULL DEFAULT CURRENT_DATE,
    motivo               VARCHAR(250) NOT NULL,
    estado               VARCHAR(10)  NOT NULL DEFAULT 'pendiente',
    fecha_respuesta      DATE,
    CONSTRAINT pk_solicitud PRIMARY KEY (id_solicitud),
    CONSTRAINT uq_solicitud_natural UNIQUE (boleta, id_seleccion, num_actividad),
    -- necesaria para que JUSTIFICANTE solo pueda colgar de solicitudes autorizadas
    CONSTRAINT uq_solicitud_id_estado UNIQUE (id_solicitud, estado),
    CONSTRAINT ck_solicitud_estado CHECK (estado IN ('pendiente', 'autorizada', 'rechazada')),
    CONSTRAINT ck_solicitud_respuesta CHECK ((estado = 'pendiente') = (fecha_respuesta IS NULL)),
    CONSTRAINT ck_solicitud_fechas CHECK (fecha_respuesta IS NULL OR fecha_respuesta >= fecha_solicitud),
    CONSTRAINT fk_solicitud_estudiante FOREIGN KEY (boleta)
        REFERENCES estudiante (boleta)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_actividad FOREIGN KEY (id_seleccion, num_actividad)
        REFERENCES actividad_deportiva (id_seleccion, num_actividad)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 5 · AUTORIZACION  (relación M:N "autoriza" PERSONAL_DEPORTIVO – SOLICITUD)
-- Atributos propios de la relación: fecha_autorizacion, resultado, observacion.
-- PK = combinación de las dos claves. Regla del dominio: firman EXACTAMENTE
-- DOS personas, un entrenador y un gestor. Para eso la tabla guarda
-- 'tipo_revisor' y:
--   * FK compuesta (id_personal, tipo_revisor) -> personal_deportivo(id_personal, tipo)
--     garantiza que el tipo guardado es el real;
--   * UNIQUE (id_solicitud, tipo_revisor) permite a lo más una firma por tipo,
--     o sea a lo más dos por solicitud (una de cada tipo).
-- Que lleguen a ser dos (mínimo) y que el estado de la solicitud concuerde con
-- las firmas lo verifica el disparador diferido de más abajo.
-- ---------------------------------------------------------------------
CREATE TABLE autorizacion (
    id_solicitud       INTEGER      NOT NULL,
    id_personal        INTEGER      NOT NULL,
    tipo_revisor       VARCHAR(10)  NOT NULL,
    fecha_autorizacion DATE         NOT NULL DEFAULT CURRENT_DATE,
    resultado          VARCHAR(10)  NOT NULL,
    observacion        VARCHAR(250),
    CONSTRAINT pk_autorizacion PRIMARY KEY (id_solicitud, id_personal),
    CONSTRAINT uq_autorizacion_tipo UNIQUE (id_solicitud, tipo_revisor),
    CONSTRAINT ck_autorizacion_tipo      CHECK (tipo_revisor IN ('ENTRENADOR', 'GESTOR')),
    CONSTRAINT ck_autorizacion_resultado CHECK (resultado IN ('autorizada', 'rechazada')),
    CONSTRAINT fk_autorizacion_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud_justificante (id_solicitud)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_autorizacion_personal FOREIGN KEY (id_personal, tipo_revisor)
        REFERENCES personal_deportivo (id_personal, tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- Regla 6 · JUSTIFICANTE  (relación 1:1 "genera" con SOLICITUD)
-- solicitud (0,1) — genera — (1,1) justificante.
-- La FK viaja al lado de participación total (JUSTIFICANTE), por lo que
-- puede ser UNIQUE y NOT NULL. La FK compuesta (id_solicitud,
-- estado_solicitud) hace cumplir "solo una solicitud AUTORIZADA genera
-- justificante; una rechazada o pendiente no".
-- ---------------------------------------------------------------------
CREATE TABLE justificante (
    id_justificante   INTEGER GENERATED ALWAYS AS IDENTITY,
    id_solicitud      INTEGER      NOT NULL,
    estado_solicitud  VARCHAR(10)  NOT NULL DEFAULT 'autorizada',
    fecha_emision     DATE         NOT NULL DEFAULT CURRENT_DATE,
    fecha_caducidad   DATE         NOT NULL,
    estado            VARCHAR(10)  NOT NULL DEFAULT 'vigente',
    archivo           VARCHAR(255) NOT NULL,
    CONSTRAINT pk_justificante PRIMARY KEY (id_justificante),
    CONSTRAINT uq_justificante_solicitud UNIQUE (id_solicitud),
    CONSTRAINT ck_justificante_estsol  CHECK (estado_solicitud = 'autorizada'),
    CONSTRAINT ck_justificante_estado  CHECK (estado IN ('vigente', 'cancelado')),
    CONSTRAINT ck_justificante_fechas  CHECK (fecha_caducidad >= fecha_emision),
    CONSTRAINT fk_justificante_solicitud FOREIGN KEY (id_solicitud, estado_solicitud)
        REFERENCES solicitud_justificante (id_solicitud, estado)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- ---------------------------------------------------------------------
-- Disyunción y completitud de la jerarquía PERSONAL_DEPORTIVO (d,t)
--  * Disyunción: ya garantizada por la FK compuesta + CHECK de tipo.
--  * Completitud (total): SQL declarativo no puede exigir "toda fila del
--    supertipo tiene fila en un subtipo", así que se usa un disparador
--    de restricción DIFERIDO (se evalúa al COMMIT, para poder insertar
--    supertipo y subtipo dentro de la misma transacción).
-- ---------------------------------------------------------------------
CREATE FUNCTION fn_personal_total() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    existe_sub BOOLEAN;
BEGIN
    IF TG_TABLE_NAME = 'personal_deportivo' THEN
        IF NEW.tipo = 'ENTRENADOR' THEN
            SELECT EXISTS (SELECT 1 FROM entrenador WHERE id_personal = NEW.id_personal) INTO existe_sub;
        ELSE
            SELECT EXISTS (SELECT 1 FROM gestor_deportivo WHERE id_personal = NEW.id_personal) INTO existe_sub;
        END IF;
        IF NOT existe_sub THEN
            RAISE EXCEPTION 'Especialización total: personal_deportivo % (%) no tiene fila en su subtipo',
                NEW.id_personal, NEW.tipo USING ERRCODE = 'check_violation';
        END IF;
    ELSE  -- se borró una fila de un subtipo: el supertipo no puede quedar huérfano
        IF EXISTS (SELECT 1 FROM personal_deportivo WHERE id_personal = OLD.id_personal) THEN
            RAISE EXCEPTION 'Especialización total: no se puede borrar el subtipo de personal_deportivo %',
                OLD.id_personal USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_personal_total
    AFTER INSERT OR UPDATE OF tipo ON personal_deportivo
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_personal_total();

CREATE CONSTRAINT TRIGGER trg_entrenador_total
    AFTER DELETE ON entrenador
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_personal_total();

CREATE CONSTRAINT TRIGGER trg_gestor_total
    AFTER DELETE ON gestor_deportivo
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_personal_total();

-- ---------------------------------------------------------------------
-- Regla "firman dos personas, un entrenador y un gestor": coherencia entre
-- SOLICITUD.estado y sus AUTORIZACIONES. Disparador de restricción DIFERIDO
-- (se evalúa al COMMIT, para poder insertar solicitud y firmas juntas):
--   * alguna firma "rechazada"               -> estado 'rechazada'
--   * dos firmas, ambas "autorizada"         -> estado 'autorizada'
--   * cualquier otro caso (0 o 1 firma ok)   -> estado 'pendiente'
--   * fecha_respuesta = fecha de la última firma cuando ya no está pendiente
--   * ninguna firma es anterior a la fecha de la solicitud
-- ---------------------------------------------------------------------
CREATE FUNCTION fn_solicitud_firmas() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    id_s INTEGER;
    sol  solicitud_justificante%ROWTYPE;
    n_ok INTEGER; n_no INTEGER; ultima DATE; primera DATE; esperado TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN id_s := OLD.id_solicitud; ELSE id_s := NEW.id_solicitud; END IF;
    SELECT * INTO sol FROM solicitud_justificante WHERE id_solicitud = id_s;
    IF NOT FOUND THEN RETURN NULL; END IF;       -- la solicitud se borró (CASCADE)
    SELECT count(*) FILTER (WHERE resultado = 'autorizada'), count(*) FILTER (WHERE resultado = 'rechazada'),
           max(fecha_autorizacion), min(fecha_autorizacion)
      INTO n_ok, n_no, ultima, primera FROM autorizacion WHERE id_solicitud = id_s;
    esperado := CASE WHEN n_no > 0 THEN 'rechazada' WHEN n_ok = 2 THEN 'autorizada' ELSE 'pendiente' END;
    IF sol.estado <> esperado THEN
        RAISE EXCEPTION 'Solicitud %: estado "%" no concuerda con sus firmas (% autorizadas, % rechazadas); debería ser "%"',
            id_s, sol.estado, n_ok, n_no, esperado USING ERRCODE = 'check_violation';
    END IF;
    IF sol.estado <> 'pendiente' AND sol.fecha_respuesta IS DISTINCT FROM ultima THEN
        RAISE EXCEPTION 'Solicitud %: fecha_respuesta (%) debe ser la fecha de la última firma (%)',
            id_s, sol.fecha_respuesta, ultima USING ERRCODE = 'check_violation';
    END IF;
    IF primera IS NOT NULL AND primera < sol.fecha_solicitud THEN
        RAISE EXCEPTION 'Solicitud %: una firma (%) es anterior a la fecha de la solicitud (%)',
            id_s, primera, sol.fecha_solicitud USING ERRCODE = 'check_violation';
    END IF;
    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_solicitud_firmas
    AFTER INSERT OR UPDATE ON solicitud_justificante
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_solicitud_firmas();

CREATE CONSTRAINT TRIGGER trg_autorizacion_firmas
    AFTER INSERT OR UPDATE OR DELETE ON autorizacion
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_solicitud_firmas();

-- ---------------------------------------------------------------------
-- Atributo derivado · estado de vigencia del documento médico
-- No se almacena (se calcula a partir de fecha_vencimiento). Umbral de
-- "próximo a vencer": 30 días.
-- ---------------------------------------------------------------------
CREATE VIEW v_documento_estado AS
SELECT d.boleta,
       d.num_oficio,
       d.tipo_documento,
       d.fecha_vencimiento,
       CASE
           WHEN d.fecha_vencimiento <  CURRENT_DATE                      THEN 'vencido'
           WHEN d.fecha_vencimiento <= CURRENT_DATE + INTERVAL '30 days' THEN 'proximo_a_vencer'
           ELSE 'vigente'
       END AS estado_vigencia
FROM documento_medico d;

COMMIT;
