-- =========================================================
-- BASES DE DATOS 2 - OBLIGATORIO 2 - 2026
-- DML - Datos de prueba para lab02
-- IMPORTANTE: ejecutar luego de ddl.sql, constraints.sql
-- y triggers_procedimientos.sql
-- =========================================================

-- =====================================================
-- PROVEEDORES
-- =====================================================
INSERT INTO proveedores VALUES
(1, 'Atlantic Fish Suppliers'),
(2, 'Nordic Sea Foods'),
(3, 'Patagonia Spice Export'),
(4, 'Canadian Packaging Ltd');

-- =====================================================
-- MATERIAS PRIMAS
-- =====================================================
INSERT INTO materiaprima VALUES
(1, 'Trucha Fresca'),
(2, 'Sal Marina'),
(3, 'Mezcla de Especias'),
(4, 'Aceite Vegetal'),
(5, 'Conservante Natural'),
(6, 'Frascos de Vidrio');

-- =====================================================
-- PRODUCTOS
-- =====================================================
INSERT INTO producto VALUES
(1, 'Pate de Trucha Clasico'),
(2, 'Pate de Trucha Ahumado');

-- =====================================================
-- EMPLEADOS
-- =====================================================
INSERT INTO empleado VALUES
(1, 'Ana García', 'Inspector'),
(2, 'Carlos López', 'Inspector'),
(3, 'María Fernández', 'Inspector'),
(4, 'Jorge Martínez', 'Supervisor');

-- =====================================================
-- ORDENES DE COMPRA
-- =====================================================
INSERT INTO orden_compra VALUES
(1001, '2025-03-01', 1),
(1002, '2025-03-02', 2),
(1003, '2025-03-05', 3),
(1004, '2025-03-06', 4),
(1005, '2025-03-15', 1),
(1006, '2025-03-16', 2),
(1007, '2025-03-17', 3),
(1008, '2025-03-18', 4);

-- =====================================================
-- DETALLE ORDEN COMPRA
-- =====================================================
INSERT INTO detalle_orden_compra VALUES
(1, 1001, 1, 18.50, 1000), -- Trucha
(2, 1002, 2, 2.10, 500),   -- Sal
(3, 1003, 3, 7.50, 200),   -- Especias
(4, 1003, 5, 4.80, 150),   -- Conservante
(5, 1004, 6, 1.20, 800),   -- Frascos
(6, 1002, 4, 5.60, 300),   -- Aceite
(7, 1005, 1, 19.20, 1200), -- Trucha
(8, 1006, 2, 2.30, 700),   -- Sal
(9, 1007, 5, 5.10, 250),   -- Conservante
(10, 1008, 6, 1.35, 1000); -- Frascos

-- =====================================================
-- FACTURAS
-- =====================================================
INSERT INTO factura VALUES
(1, 1001, 1850.00, 'USD', '2025-03-10'),
(2, 1002, 273.00, 'USD', '2025-03-11'),
(3, 1003, 222.00, 'USD', '2025-03-12'),
(4, 1004, 96.00, 'USD', '2025-03-13'),
(5, 1005, 2304.00, 'USD', '2025-03-20'),
(6, 1006, 1610.00, 'USD', '2025-03-21'),
(7, 1007, 1275.00, 'USD', '2025-03-22'),
(8, 1008, 1350.00, 'USD', '2025-03-23');

-- =====================================================
-- LOTES RECIBIDOS
-- Se insertan con estado_final = NULL (pendientes de
-- inspección). El estado final se calculará a partir de
-- los controles de calidad cargados más abajo, mediante
-- los triggers definidos en triggers_procedimientos.sql
-- =====================================================
INSERT INTO lote (id_lote, id_orden, id_detalle, fecha_vencimiento, fecha_recepcion, origen, estado_final, cantidad_materiaprima) VALUES
(1, 1001, 1, '2025-03-20', '2025-03-08', 'Canada', NULL, 950),
(2, 1002, 2, '2026-01-15', '2025-03-09', 'Chile', NULL, 500),
(3, 1003, 3, '2026-06-10', '2025-03-10', 'India', NULL, 180),
(4, 1003, 4, '2026-02-01', '2025-03-10', 'Noruega', NULL, 140),
(5, 1004, 5, '2030-01-01', '2025-03-11', 'Canada', NULL, 800),
(6, 1002, 6, '2027-08-01', '2025-03-09', 'Argentina', NULL, 300),
(7, 1005, 7, '2026-12-01', '2025-03-19', 'Canada', NULL, 1150),
(8, 1006, 8, '2027-02-10', '2025-03-20', 'Chile', NULL, 680),
(9, 1007, 9, '2028-01-01', '2025-03-21', 'India', NULL, 240),
(10, 1008, 10, '2030-06-01', '2025-03-22', 'Argentina', NULL, 950);

-- =====================================================
-- TIPOS DE CONTROL
-- =====================================================
INSERT INTO tipo_control VALUES
(1, 'Temperatura', 'CUANTITATIVO'),
(2, 'Olor', 'CUALITATIVO'),
(3, 'Textura', 'CUALITATIVO'),
(4, 'Resultado Microbiologico', 'CUANTITATIVO'),
(5, 'Integridad del Envase', 'CUALITATIVO'),
(6, 'Composicion Quimica', 'CUANTITATIVO');

-- =====================================================
-- CONTROLES CUANTITATIVOS (umbrales min/max)
-- =====================================================
INSERT INTO cuantitativo VALUES
(1, 'Celsius', 0.00, 4.00),
(4, 'UFC/g', 0.00, 100.00),
(6, 'Porcentaje', 95.00, 100.00);

-- =====================================================
-- CONTROLES CUALITATIVOS
-- =====================================================
INSERT INTO cualitativo VALUES
(2, 'Verificacion de olor fresco y apto'),
(3, 'Evaluacion de textura uniforme'),
(5, 'Revision visual de envases sin daños');

-- =====================================================
-- RELACION MATERIA PRIMA - CONTROL REQUERIDO
-- =====================================================
INSERT INTO requiere VALUES
(1, 1), -- Trucha -> Temperatura
(1, 2), -- Trucha -> Olor
(1, 3), -- Trucha -> Textura
(1, 4), -- Trucha -> Microbiologico
(5, 6), -- Conservante -> Composicion Quimica
(6, 5); -- Frascos -> Integridad de Envase

-- =====================================================
-- CONTROLES DE CALIDAD
-- NOTA: no se inserta la columna "estado": el trigger
-- trg_calcular_estado_control la calcula automáticamente.
-- =====================================================

-- ---- Lote 1 (Trucha): se completan los 4 controles requeridos -> APROBADO
INSERT INTO control_calidad (id_lote, id_empleado, id_tipo, fecha, hora, medida, unidad, integridad_envase, observacion) VALUES
(1, 1, 1, '2025-03-08', '08:30:00', 2.50, 'Celsius', NULL, 'Temperatura correcta'),
(1, 2, 2, '2025-03-08', '09:00:00', NULL, NULL, NULL, 'Olor fresco normal'),
(1, 2, 3, '2025-03-08', '09:30:00', NULL, NULL, NULL, 'Textura uniforme'),
(1, 3, 4, '2025-03-08', '10:00:00', 40.00, 'UFC/g', NULL, 'Resultado microbiologico aceptable');

-- ---- Lote 7 (Trucha): se completan los 4 controles requeridos -> APROBADO
INSERT INTO control_calidad (id_lote, id_empleado, id_tipo, fecha, hora, medida, unidad, integridad_envase, observacion) VALUES
(7, 1, 1, '2025-03-19', '08:00:00', 3.00, 'Celsius', NULL, 'Temperatura dentro del rango'),
(7, 2, 2, '2025-03-19', '08:30:00', NULL, NULL, NULL, 'Olor fresco adecuado'),
(7, 2, 3, '2025-03-19', '09:00:00', NULL, NULL, NULL, 'Textura uniforme'),
(7, 3, 4, '2025-03-19', '09:30:00', 35.00, 'UFC/g', NULL, 'Resultado microbiologico aceptable');

-- ---- Lote 6 (Frascos): envase con daños -> control OBSERVADO -> lote OBSERVADO
--      (queda pendiente de reinspección)
INSERT INTO control_calidad (id_lote, id_empleado, id_tipo, fecha, hora, medida, unidad, integridad_envase, observacion) VALUES
(6, 1, 5, '2025-03-09', '15:00:00', NULL, NULL, 'con daños', 'Algunos frascos con rayaduras');

-- ---- Lote 4 (Conservante): composicion fuera de rango -> RECHAZADO
--      Se utiliza el procedimiento almacenado sp_registrar_control para
--      registrar el control y, en el mismo paso, el motivo de rechazo
--      y la acción tomada sobre el lote.
CALL sp_registrar_control(
    4,                                      -- id_lote
    '2025-03-10',                          -- fecha
    '14:00:00',                            -- hora
    6,                                      -- id_tipo (Composicion Quimica)
    82.00,                                  -- medida
    'Porcentaje',                           -- unidad
    NULL,                                   -- integridad_envase
    'Composicion fuera del rango permitido',-- observacion
    4,                                      -- id_empleado
    'Composicion quimica fuera de especificacion', -- motivo_rechazo
    'DESCARTADO',                           -- accion_rechazo
    NULL, NULL, NULL                        -- parametros OUT (se completan al ejecutar)
);

-- ---- Lote 9 (Conservante): composicion fuera de rango -> RECHAZADO
CALL sp_registrar_control(
    9,
    '2025-03-21',
    '11:30:00',
    6,
    80.00,
    'Porcentaje',
    NULL,
    'Composicion quimica fuera del limite',
    4,
    'Conservante fuera de especificacion',
    'DEVUELTO',
    NULL, NULL, NULL
);

-- Lotes 2, 3, 5, 8, 10 quedan sin controles registrados (estado_final NULL),
-- de forma de poder probar la opción 1 del menú ("lotes pendientes de
-- inspección o reinspección") con el programa en C.
