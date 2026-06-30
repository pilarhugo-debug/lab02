-- =========================================================
-- BASES DE DATOS 2 - OBLIGATORIO 2 - 2026
-- DCL - usuarios, roles y privilegios sobre lab02
-- =========================================================

--1) Gerente de calidad: permisos totales sobre la base
CREATE USER gerente_calidad WITH PASSWORD 'gerente123';
GRANT ALL PRIVILEGES ON DATABASE lab02 TO gerente_calidad;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gerente_calidad;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gerente_calidad;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO gerente_calidad;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO gerente_calidad;

--2) Inspector: visualizar e insertar controles de calidad,
--   consultar lotes y materias primas; ejecutar el programa
--   en C requiere además poder ejecutar el procedimiento y
--   las funciones del menú.
CREATE USER inspector WITH PASSWORD 'inspector123';
GRANT SELECT, INSERT ON control_calidad TO inspector;
GRANT USAGE, SELECT ON SEQUENCE control_calidad_id_control_seq TO inspector;
GRANT SELECT ON lote TO inspector;
GRANT UPDATE (estado_final, accion_rechazo) ON lote TO inspector;
GRANT SELECT ON materiaprima TO inspector;
GRANT SELECT ON tipo_control, cuantitativo, cualitativo, requiere, empleado TO inspector;
GRANT INSERT ON motivo TO inspector;
GRANT EXECUTE ON PROCEDURE sp_registrar_control(
    INT, DATE, TIME, INT, NUMERIC, VARCHAR, VARCHAR, VARCHAR, INT, VARCHAR, VARCHAR,
    INT, VARCHAR, VARCHAR
) TO inspector;
GRANT EXECUTE ON FUNCTION fn_lotes_pendientes() TO inspector;
GRANT EXECUTE ON FUNCTION fn_reporte_controles_empleado(DATE, DATE) TO inspector;

--3) Compras: visualizar e insertar proveedores, órdenes de
--   compra, recepciones (facturas) y lotes recibidos.
CREATE USER compras WITH PASSWORD 'compras123';
GRANT SELECT, INSERT ON proveedores TO compras;
GRANT SELECT, INSERT ON orden_compra TO compras;
GRANT SELECT, INSERT ON detalle_orden_compra TO compras;
GRANT SELECT, INSERT ON factura TO compras;
GRANT SELECT, INSERT ON lote TO compras;

--4) Auditor: únicamente consulta la vista materializada del
--   punto 7 del Laboratorio 1 (vista_query07 / vista_proveedores_2025)
CREATE USER auditor WITH PASSWORD 'auditor123';
GRANT SELECT ON vista_proveedores_2025 TO auditor;
