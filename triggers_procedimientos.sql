-- =========================================================
-- BASES DE DATOS 2 - OBLIGATORIO 2 - 2026
-- TRIGGERS Y PROCEDIMIENTOS ALMACENADOS (PL/pgSQL)
-- =========================================================

-- =========================================================
-- 1) TRIGGER: calcular automáticamente el estado de UN control
--    de calidad en base al valor observado / integridad del envase.
--    Se dispara ANTES de insertar la fila para fijar NEW.estado.
-- =========================================================

CREATE OR REPLACE FUNCTION fn_calcular_estado_control()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo_control  VARCHAR(20);
    v_nombre_tipo   VARCHAR(50);
    v_min           NUMERIC(10,2);
    v_max           NUMERIC(10,2);
BEGIN
    SELECT tc.tipo_control, tc.nombre_tipo
      INTO v_tipo_control, v_nombre_tipo
      FROM tipo_control tc
     WHERE tc.id_tipo = NEW.id_tipo;

    IF v_tipo_control = 'CUANTITATIVO' THEN
        SELECT c.valor_min, c.valor_max
          INTO v_min, v_max
          FROM cuantitativo c
         WHERE c.id_tipo = NEW.id_tipo;

        IF NEW.medida IS NULL THEN
            RAISE EXCEPTION 'El tipo de control % requiere un valor observado (medida)', v_nombre_tipo;
        END IF;

        IF NEW.medida BETWEEN v_min AND v_max THEN
            NEW.estado := 'APROBADO';
        ELSE
            NEW.estado := 'RECHAZADO';
        END IF;

    ELSE
        -- Control cualitativo. Si se trata de integridad de envase,
        -- el estado se deriva del estado del envase informado.
        IF v_nombre_tipo ILIKE '%envase%' OR NEW.integridad_envase IS NOT NULL THEN
            IF NEW.integridad_envase IS NULL THEN
                RAISE EXCEPTION 'Debe indicar la integridad del envase/empaquetado';
            END IF;

            CASE NEW.integridad_envase
                WHEN 'excelente' THEN NEW.estado := 'APROBADO';
                WHEN 'normal'    THEN NEW.estado := 'APROBADO';
                WHEN 'con daños' THEN NEW.estado := 'OBSERVADO';
                WHEN 'inaceptable' THEN NEW.estado := 'RECHAZADO';
                ELSE
                    RAISE EXCEPTION 'Valor de integridad_envase no reconocido: %', NEW.integridad_envase;
            END CASE;
        ELSE
            -- Otros controles cualitativos sin umbral numérico: por defecto
            -- se aprueban salvo que el inspector indique en observaciones
            -- una condición de rechazo explícita (se deja aprobado por defecto).
            NEW.estado := 'APROBADO';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calcular_estado_control ON control_calidad;

CREATE TRIGGER trg_calcular_estado_control
BEFORE INSERT ON control_calidad
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_estado_control();


-- =========================================================
-- 2) TRIGGER: recalcular el estado_final del LOTE luego de
--    insertar un control de calidad.
--    Regla:
--      - Si existe al menos un control RECHAZADO  -> lote RECHAZADO
--      - Si no hay rechazados pero existe al menos un OBSERVADO,
--        o aún faltan controles obligatorios por realizar
--                                                  -> lote OBSERVADO
--      - Si todos los controles requeridos para la materia prima
--        del lote fueron realizados y todos APROBADOS -> APROBADO
-- =========================================================

CREATE OR REPLACE FUNCTION fn_actualizar_estado_lote()
RETURNS TRIGGER AS $$
DECLARE
    v_id_materiaprima   INT;
    v_rechazados        INT;
    v_observados        INT;
    v_requeridos        INT;
    v_realizados        INT;
    v_estado            VARCHAR(20);
BEGIN
    -- materia prima del lote
    SELECT d.id_materiaprima
      INTO v_id_materiaprima
      FROM lote l
      JOIN detalle_orden_compra d
        ON d.id_detalle = l.id_detalle AND d.id_orden = l.id_orden
     WHERE l.id_lote = NEW.id_lote;

    SELECT COUNT(*) INTO v_rechazados
      FROM control_calidad
     WHERE id_lote = NEW.id_lote AND estado = 'RECHAZADO';

    SELECT COUNT(*) INTO v_observados
      FROM control_calidad
     WHERE id_lote = NEW.id_lote AND estado = 'OBSERVADO';

    SELECT COUNT(*) INTO v_requeridos
      FROM requiere
     WHERE id_materiaprima = v_id_materiaprima;

    SELECT COUNT(DISTINCT id_tipo) INTO v_realizados
      FROM control_calidad
     WHERE id_lote = NEW.id_lote;

    IF v_rechazados > 0 THEN
        v_estado := 'RECHAZADO';
    ELSIF v_observados > 0 OR (v_requeridos > 0 AND v_realizados < v_requeridos) THEN
        v_estado := 'OBSERVADO';
    ELSE
        v_estado := 'APROBADO';
    END IF;

    UPDATE lote
       SET estado_final = v_estado
     WHERE id_lote = NEW.id_lote;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_actualizar_estado_lote ON control_calidad;

CREATE TRIGGER trg_actualizar_estado_lote
AFTER INSERT ON control_calidad
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_estado_lote();


-- =========================================================
-- 3) PROCEDIMIENTO: registrar control de calidad
--    Inserta el control (el trigger calcula el estado del control
--    y, en cascada, el estado_final del lote). Si como consecuencia
--    el lote quedó RECHAZADO, registra el motivo de rechazo y,
--    opcionalmente, la acción tomada (devuelto / descartado).
--    Devuelve el id del control creado y el estado final del lote.
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_registrar_control(
    IN  p_id_lote           INT,
    IN  p_fecha             DATE,
    IN  p_hora              TIME,
    IN  p_id_tipo            INT,
    IN  p_medida             NUMERIC(10,2),
    IN  p_unidad             VARCHAR(50),
    IN  p_integridad_envase  VARCHAR(20),
    IN  p_observacion        VARCHAR(200),
    IN  p_id_empleado        INT,
    IN  p_motivo_rechazo     VARCHAR(200),
    IN  p_accion_rechazo     VARCHAR(20),
    OUT p_id_control         INT,
    OUT p_estado_control     VARCHAR(20),
    OUT p_estado_lote        VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO control_calidad
        (id_lote, id_empleado, id_tipo, fecha, hora, medida, unidad,
         integridad_envase, observacion, descartado)
    VALUES
        (p_id_lote, p_id_empleado, p_id_tipo, p_fecha, p_hora, p_medida, p_unidad,
         p_integridad_envase, p_observacion, FALSE)
    RETURNING id_control, estado INTO p_id_control, p_estado_control;

    SELECT estado_final INTO p_estado_lote
      FROM lote
     WHERE id_lote = p_id_lote;

    IF p_estado_lote = 'RECHAZADO' THEN
        IF p_motivo_rechazo IS NOT NULL THEN
            INSERT INTO motivo (id_control, descripcion_motivo)
            VALUES (p_id_control, p_motivo_rechazo);
        END IF;

        IF p_accion_rechazo IS NOT NULL THEN
            UPDATE lote
               SET accion_rechazo = p_accion_rechazo
             WHERE id_lote = p_id_lote;
        END IF;
    END IF;
END;
$$;


-- =========================================================
-- 4) FUNCION: listar lotes pendientes de inspección o reinspección
--    (estado_final NULL = nunca inspeccionado, u OBSERVADO = requiere
--     reinspección). Ordenado por fecha de recepción ascendente.
-- =========================================================

CREATE OR REPLACE FUNCTION fn_lotes_pendientes()
RETURNS TABLE (
    id_lote         INT,
    proveedor       VARCHAR(50),
    fecha_recepcion DATE
)
LANGUAGE sql
AS $$
    SELECT l.id_lote, p.nombre, l.fecha_recepcion
      FROM lote l
      JOIN orden_compra o ON o.id_orden = l.id_orden
      JOIN proveedores p  ON p.id_proveedor = o.id_proveedor
     WHERE l.estado_final IS NULL OR l.estado_final = 'OBSERVADO'
     ORDER BY l.fecha_recepcion ASC;
$$;


-- =========================================================
-- 5) FUNCION: reporte de controles por empleado en un rango de fechas
-- =========================================================

CREATE OR REPLACE FUNCTION fn_reporte_controles_empleado(
    p_fecha_ini DATE,
    p_fecha_fin DATE
)
RETURNS TABLE (
    id_empleado  INT,
    empleado     VARCHAR(100),
    aprobados    BIGINT,
    rechazados   BIGINT,
    observados   BIGINT
)
LANGUAGE sql
AS $$
    SELECT e.id_empleado,
           e.nombre,
           COUNT(*) FILTER (WHERE c.estado = 'APROBADO')  AS aprobados,
           COUNT(*) FILTER (WHERE c.estado = 'RECHAZADO') AS rechazados,
           COUNT(*) FILTER (WHERE c.estado = 'OBSERVADO') AS observados
      FROM control_calidad c
      JOIN empleado e ON e.id_empleado = c.id_empleado
     WHERE c.fecha BETWEEN p_fecha_ini AND p_fecha_fin
     GROUP BY e.id_empleado, e.nombre
     ORDER BY e.nombre;
$$;
