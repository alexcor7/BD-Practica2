-- =====================================================================
-- Práctica 3, Ejercicio 8 — Cambio de esquema por integrante
-- Integrante: Alexis Cortés Rios
-- Proyecto asignado: Sistema de visualización sísmica en México (almacén)
-- Propuesta (issue de la Práctica 2): Propuesta 3 — Integrar información
--   de alertas sísmicas  (entidad ALERTA_SISMICA, SISMO 0..N — 1..1)
--
-- Se ejecuta sobre una COPIA de la base del proyecto asignado:
--   createdb -T almacen almacen_alertas
--   psql -d almacen_alertas -f cambio-usuario.sql
--
-- Regla aplicada: relación 1:N -> la llave primaria del lado «1» (dim_sismos)
-- pasa como llave foránea al lado «N» (alerta_sismica). Como la participación
-- de ALERTA_SISMICA es (1,1), la llave foránea es NOT NULL.
-- No se modifica ninguna tabla existente.
-- =====================================================================
BEGIN;

CREATE TABLE alerta_sismica (
    id_alerta     INTEGER GENERATED ALWAYS AS IDENTITY,
    fecha_hora    TIMESTAMP    NOT NULL,
    nivel         VARCHAR(30)  NOT NULL,
    estado_alerta VARCHAR(30)  NOT NULL,
    fuente        VARCHAR(100) NOT NULL,
    id_sismo      INTEGER      NOT NULL,
    CONSTRAINT pk_alerta_sismica PRIMARY KEY (id_alerta),
    -- Cada alerta corresponde a exactamente un sismo; un sismo puede no tener
    -- alertas o tener varias (0,N). RESTRICT: no se borra un sismo con alertas.
    CONSTRAINT fk_alerta_sismo FOREIGN KEY (id_sismo)
        REFERENCES dim_sismos (id_sismo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- La misma fuente no registra dos veces la misma alerta para un sismo.
    CONSTRAINT uq_alerta_fuente UNIQUE (id_sismo, fuente, fecha_hora),
    CONSTRAINT ck_alerta_nivel   CHECK (length(btrim(nivel)) > 0),
    CONSTRAINT ck_alerta_estado  CHECK (length(btrim(estado_alerta)) > 0),
    CONSTRAINT ck_alerta_fuente  CHECK (length(btrim(fuente)) > 0)
);

-- Las consultas parten del sismo para llegar a sus alertas.
CREATE INDEX ix_alerta_sismo ON alerta_sismica (id_sismo);

COMMENT ON TABLE alerta_sismica IS
  'Alertas emitidas por plataformas oficiales; cada una corresponde a un sismo de dim_sismos.';

COMMIT;
