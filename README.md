# Laboratorio Obligatorio 2 - Bases de Datos 2 - 2026

## Contenido del entregable

- `ddl.sql` — creación de la base `lab02` y de las tablas (extiende el modelo del Laboratorio 1).
- `constraints.sql` — claves primarias, foráneas y restricciones CHECK.
- `triggers_procedimientos.sql` — funciones, triggers y procedimiento almacenado en PL/pgSQL:
  - `fn_calcular_estado_control` / `trg_calcular_estado_control`: calcula el estado (Aprobado/Rechazado/Observado) de **cada control** comparando el valor observado contra los umbrales de `cuantitativo`, o evaluando la integridad del envase para controles cualitativos.
  - `fn_actualizar_estado_lote` / `trg_actualizar_estado_lote`: recalcula automáticamente el `estado_final` del **lote** luego de cada control insertado.
  - `sp_registrar_control(...)`: procedimiento que registra un control de calidad y, si el lote queda rechazado, registra el motivo de rechazo y la acción tomada (devuelto/descartado).
  - `fn_lotes_pendientes()`: lotes que requieren inspección o reinspección, ordenados por fecha de recepción.
  - `fn_reporte_controles_empleado(fecha_ini, fecha_fin)`: cantidad de controles aprobados/rechazados/observados por empleado en un rango de fechas.
- `dml.sql` — datos de prueba (proveedores, materias primas, órdenes, lotes, controles de calidad, etc.).
- `dcl.sql` — usuarios, roles y privilegios.
- `lab02.pgc` — programa en C con SQL embebido (ECPG) que implementa el menú solicitado.
- `Makefile` — compilación del programa ECPG.

## Orden de ejecución de los scripts SQL

```bash
psql -U postgres -f ddl.sql
psql -U postgres -d lab02 -f constraints.sql
psql -U postgres -d lab02 -f triggers_procedimientos.sql
psql -U postgres -d lab02 -f dml.sql
psql -U postgres -d lab02 -f dcl.sql
```

## Compilación del programa en C con SQL embebido

Requiere tener instalado `postgresql-server-dev-XX` (provee `ecpg`) y las librerías `libecpg` y `libpq`.

```bash
make
./lab02
```

Si se prefiere hacerlo manualmente:

```bash
ecpg lab02.pgc
gcc -c lab02.c -I$(pg_config --includedir)
gcc -o lab02 lab02.o -L$(pg_config --libdir) -lecpg -lpq
./lab02
```

> Antes de ejecutar, ajustar en `lab02.pgc` (sentencia `EXEC SQL CONNECT TO ...`) el host, usuario y contraseña según el entorno (por defecto se conecta a la base `lab02` con el usuario `inspector` creado en `dcl.sql`).

## Menú implementado

1. Listar los lotes que deben recibir una inspección o reinspección (id de lote, proveedor, fecha de recepción), ordenados por fecha de recepción ascendente.
2. Registrar el control de calidad de un lote (lote, fecha/hora, tipo de control, valor observado y unidad, integridad del envase, observaciones, empleado). El sistema calcula automáticamente, mediante triggers en la base de datos, si el control resulta Aprobado, Rechazado u Observado y actualiza en cascada el estado final del lote. Si el lote queda rechazado se solicita y registra el motivo y la acción tomada.
3. Reporte de controles por empleado en un rango de fechas, indicando cantidad de aprobados, rechazados y observados.
0. Salir.

## Respaldo de la base de datos

Luego de cargar el modelo y los datos, generar el respaldo con:

```bash
pg_dump -U postgres -d lab02 -F c -f lab02_backup.dump
```

(El archivo de respaldo se debe adjuntar junto con el resto del entregable, según lo solicitado en el enunciado.)
