-- =========================================================
-- BASES DE DATOS 2 - OBLIGATORIO 2 - 2026
-- DDL - Base de datos lab02
-- Se reutiliza y extiende el modelo del Laboratorio 1
-- =========================================================

CREATE DATABASE lab02;

-- Conectarse a lab02 antes de continuar (\c lab02 en psql)

CREATE TABLE proveedores (
    id_proveedor INT NOT NULL,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE materiaprima (
    id_materiaprima INT NOT NULL,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE producto (
    id_producto INT NOT NULL,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE empleado (
    id_empleado INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL
);

CREATE TABLE orden_compra (
    id_orden INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    id_proveedor INT NOT NULL
);

CREATE TABLE detalle_orden_compra (
    id_detalle INT NOT NULL,
    id_orden INT NOT NULL,
    id_materiaprima INT NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    cantidad INT NOT NULL
);

CREATE TABLE factura (
    id_factura INT NOT NULL,
    id_orden INT NOT NULL,
    precio_total NUMERIC(10,2) NOT NULL,
    moneda VARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL
);

-- Tabla lote: se agrega accion_rechazo (devuelto / descartado)
CREATE TABLE lote (
    id_lote INT NOT NULL,
    id_orden INT NOT NULL,
    id_detalle INT NOT NULL,
    fecha_vencimiento DATE,
    fecha_recepcion DATE NOT NULL,
    origen VARCHAR(50) NOT NULL,
    estado_final VARCHAR(20),
    cantidad_materiaprima INT NOT NULL,
    accion_rechazo VARCHAR(20)
);

CREATE TABLE lote_produccion (
    cod_lote_produccion INT NOT NULL,
    fecha_produccion DATE NOT NULL,
    id_producto INT NOT NULL
);

CREATE TABLE producido_con (
    id_lote INT NOT NULL,
    cod_lote_produccion INT NOT NULL,
    cantidad_materiaprima INT NOT NULL
);

CREATE TABLE tipo_control (
    id_tipo INT NOT NULL,
    nombre_tipo VARCHAR(50) NOT NULL,
    tipo_control VARCHAR(20) NOT NULL
);

CREATE TABLE cuantitativo (
    id_tipo INT NOT NULL,
    unidad VARCHAR(50) NOT NULL,
    valor_min NUMERIC(10,2) NOT NULL,
    valor_max NUMERIC(10,2) NOT NULL
);

CREATE TABLE cualitativo (
    id_tipo INT NOT NULL,
    descripcion VARCHAR(200) NOT NULL
);

-- Tabla control_calidad:
--  - se agrega "unidad" (la informada por el inspector al momento del control)
--  - se agrega "integridad_envase" (excelente / normal / con daños / inaceptable)
--  - "estado" ahora es calculado automáticamente por un trigger (no se inserta manualmente)
CREATE TABLE control_calidad (
    id_control SERIAL NOT NULL,
    id_lote INT NOT NULL,
    id_empleado INT NOT NULL,
    id_tipo INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    medida NUMERIC(10,2),
    unidad VARCHAR(50),
    integridad_envase VARCHAR(20),
    observacion VARCHAR(200),
    estado VARCHAR(20),
    descartado BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE motivo (
    id_control INT NOT NULL,
    descripcion_motivo VARCHAR(200) NOT NULL
);

CREATE TABLE requiere (
    id_materiaprima INT NOT NULL,
    id_tipo INT NOT NULL
);
