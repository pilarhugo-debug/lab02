-- =========================================================
-- BASES DE DATOS 2 - OBLIGATORIO 2 - 2026
-- CONSTRAINTS - claves primarias, foráneas y checks
-- =========================================================

-- =========================
-- PRIMARY KEYS
-- =========================

ALTER TABLE proveedores
ADD CONSTRAINT pk_proveedores PRIMARY KEY (id_proveedor);

ALTER TABLE materiaprima
ADD CONSTRAINT pk_materiaprima PRIMARY KEY (id_materiaprima);

ALTER TABLE producto
ADD CONSTRAINT pk_producto PRIMARY KEY (id_producto);

ALTER TABLE empleado
ADD CONSTRAINT pk_empleado PRIMARY KEY (id_empleado);

ALTER TABLE orden_compra
ADD CONSTRAINT pk_orden PRIMARY KEY (id_orden);

ALTER TABLE detalle_orden_compra
ADD CONSTRAINT pk_detalle PRIMARY KEY (id_detalle, id_orden);

ALTER TABLE factura
ADD CONSTRAINT pk_factura PRIMARY KEY (id_factura);

ALTER TABLE lote
ADD CONSTRAINT pk_lote PRIMARY KEY (id_lote);

ALTER TABLE lote_produccion
ADD CONSTRAINT pk_lote_produccion PRIMARY KEY (cod_lote_produccion);

ALTER TABLE producido_con
ADD CONSTRAINT pk_producido PRIMARY KEY (id_lote, cod_lote_produccion);

ALTER TABLE tipo_control
ADD CONSTRAINT pk_tipo_control PRIMARY KEY (id_tipo);

ALTER TABLE cuantitativo
ADD CONSTRAINT pk_cuantitativo PRIMARY KEY (id_tipo);

ALTER TABLE cualitativo
ADD CONSTRAINT pk_cualitativo PRIMARY KEY (id_tipo);

ALTER TABLE control_calidad
ADD CONSTRAINT pk_control PRIMARY KEY (id_control);

ALTER TABLE motivo
ADD CONSTRAINT pk_motivo PRIMARY KEY (id_control, descripcion_motivo);

ALTER TABLE requiere
ADD CONSTRAINT pk_requiere PRIMARY KEY (id_materiaprima, id_tipo);


-- =========================
-- FOREIGN KEYS
-- =========================

ALTER TABLE orden_compra
ADD CONSTRAINT fk_orden_proveedor
FOREIGN KEY (id_proveedor)
REFERENCES proveedores(id_proveedor)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE detalle_orden_compra
ADD CONSTRAINT fk_detalle_orden
FOREIGN KEY (id_orden)
REFERENCES orden_compra(id_orden)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE detalle_orden_compra
ADD CONSTRAINT fk_detalle_materia
FOREIGN KEY (id_materiaprima)
REFERENCES materiaprima(id_materiaprima)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE factura
ADD CONSTRAINT fk_factura_orden
FOREIGN KEY (id_orden)
REFERENCES orden_compra(id_orden)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE lote
ADD CONSTRAINT fk_lote_detalle_orden_compra
FOREIGN KEY (id_detalle, id_orden)
REFERENCES detalle_orden_compra(id_detalle, id_orden)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE lote_produccion
ADD CONSTRAINT fk_lote_prod_producto
FOREIGN KEY (id_producto)
REFERENCES producto(id_producto)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE producido_con
ADD CONSTRAINT fk_producido_lote
FOREIGN KEY (id_lote)
REFERENCES lote(id_lote)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE producido_con
ADD CONSTRAINT fk_producido_lote_prod
FOREIGN KEY (cod_lote_produccion)
REFERENCES lote_produccion(cod_lote_produccion)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE cuantitativo
ADD CONSTRAINT fk_cuantitativo_tipo
FOREIGN KEY (id_tipo)
REFERENCES tipo_control(id_tipo)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE cualitativo
ADD CONSTRAINT fk_cualitativo_tipo
FOREIGN KEY (id_tipo)
REFERENCES tipo_control(id_tipo)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE control_calidad
ADD CONSTRAINT fk_control_lote
FOREIGN KEY (id_lote)
REFERENCES lote(id_lote)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE control_calidad
ADD CONSTRAINT fk_control_empleado
FOREIGN KEY (id_empleado)
REFERENCES empleado(id_empleado)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE control_calidad
ADD CONSTRAINT fk_control_tipo
FOREIGN KEY (id_tipo)
REFERENCES tipo_control(id_tipo)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE motivo
ADD CONSTRAINT fk_motivo_control
FOREIGN KEY (id_control)
REFERENCES control_calidad(id_control)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE requiere
ADD CONSTRAINT fk_requiere_materia
FOREIGN KEY (id_materiaprima)
REFERENCES materiaprima(id_materiaprima)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE requiere
ADD CONSTRAINT fk_requiere_tipo
FOREIGN KEY (id_tipo)
REFERENCES tipo_control(id_tipo)
ON DELETE RESTRICT
ON UPDATE CASCADE;


-- =========================
-- CHECK CONSTRAINTS
-- =========================

ALTER TABLE lote
ADD CONSTRAINT chk_estado_lote
CHECK (estado_final IN ('APROBADO', 'RECHAZADO', 'OBSERVADO'));

ALTER TABLE lote
ADD CONSTRAINT chk_accion_rechazo
CHECK (accion_rechazo IS NULL OR accion_rechazo IN ('DEVUELTO', 'DESCARTADO'));

ALTER TABLE control_calidad
ADD CONSTRAINT chk_estado_control
CHECK (estado IS NULL OR estado IN ('APROBADO', 'RECHAZADO', 'OBSERVADO'));

ALTER TABLE control_calidad
ADD CONSTRAINT chk_integridad_envase
CHECK (integridad_envase IS NULL OR integridad_envase IN ('excelente', 'normal', 'con daños', 'inaceptable'));

ALTER TABLE tipo_control
ADD CONSTRAINT chk_tipo_control
CHECK (tipo_control IN ('CUANTITATIVO', 'CUALITATIVO'));

ALTER TABLE detalle_orden_compra
ADD CONSTRAINT chk_precio_unitario
CHECK (precio_unitario > 0);

ALTER TABLE detalle_orden_compra
ADD CONSTRAINT chk_cantidad
CHECK (cantidad > 0);

ALTER TABLE lote
ADD CONSTRAINT chk_cantidad_lote
CHECK (cantidad_materiaprima > 0);

ALTER TABLE producido_con
ADD CONSTRAINT chk_cantidad_produccion
CHECK (cantidad_materiaprima > 0);

ALTER TABLE cuantitativo
ADD CONSTRAINT chk_rango_valores
CHECK (valor_min < valor_max);
