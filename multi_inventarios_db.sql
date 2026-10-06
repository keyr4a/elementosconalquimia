-- SISTEMA MULTI INVENTARIOS — Script MySQL
DROP DATABASE IF EXISTS multi_inventarios;
CREATE DATABASE multi_inventarios CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE multi_inventarios;

-- CATÁLOGOS BASE
CREATE TABLE categoria_producto (
    id_categoria_producto BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_categoria_producto),
    UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE producto (
    id_producto BIGINT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(200) NOT NULL,
    id_categoria_producto BIGINT NOT NULL,
    costo_actual DECIMAL(12,2) NOT NULL DEFAULT 0,
    precio_general DECIMAL(12,2) NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_categoria_producto) REFERENCES categoria_producto(id_categoria_producto) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE inventario (
    id_inventario BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_inventario),
    UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE producto_inventario (
    id_producto_inventario BIGINT NOT NULL AUTO_INCREMENT,
    id_producto BIGINT NOT NULL,
    id_inventario BIGINT NOT NULL,
    clave_local VARCHAR(60) NOT NULL,
    precio_venta DECIMAL(12,2) NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    stock_maximo INT NOT NULL DEFAULT 0,
    existencia_actual INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_producto_inventario),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    UNIQUE (id_producto, id_inventario),
    UNIQUE (id_inventario, clave_local),
    CHECK (stock_maximo >= stock_minimo),
    CHECK (existencia_actual >= 0)
) ENGINE=InnoDB;

CREATE TABLE categoria_insumo (
    id_categoria_insumo BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_categoria_insumo),
    UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE insumo (
    id_insumo BIGINT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(200) NOT NULL,
    id_categoria_insumo BIGINT NOT NULL,
    unidad_medida VARCHAR(30) NOT NULL,
    costo_actual DECIMAL(12,4) NOT NULL DEFAULT 0,
    stock_minimo DECIMAL(14,3) NOT NULL DEFAULT 0,
    stock_maximo DECIMAL(14,3) NOT NULL DEFAULT 0,
    existencia_actual DECIMAL(14,3) NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_insumo),
    FOREIGN KEY (id_categoria_insumo) REFERENCES categoria_insumo(id_categoria_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (stock_maximo >= stock_minimo),
    CHECK (existencia_actual >= 0)
) ENGINE=InnoDB;

CREATE TABLE proveedor (
    id_proveedor BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    contacto VARCHAR(200) NULL,
    telefono VARCHAR(30) NULL,
    correo VARCHAR(150) NULL,
    direccion VARCHAR(300) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB;

-- RECETAS Y KITS
CREATE TABLE receta (
    id_receta BIGINT NOT NULL AUTO_INCREMENT,
    id_producto BIGINT NOT NULL,
    version INT NOT NULL DEFAULT 1,
    fecha_vigencia_desde DATE NOT NULL,
    fecha_vigencia_hasta DATE NULL,
    vigente BOOLEAN NOT NULL DEFAULT FALSE,
    comentario VARCHAR(500) NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_receta),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    UNIQUE (id_producto, version)
) ENGINE=InnoDB;

CREATE TABLE receta_detalle (
    id_receta_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_receta BIGINT NOT NULL,
    id_insumo BIGINT NOT NULL,
    cantidad_por_unidad DECIMAL(14,3) NOT NULL,
    PRIMARY KEY (id_receta_detalle),
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_insumo) REFERENCES insumo(id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    UNIQUE (id_receta, id_insumo),
    CHECK (cantidad_por_unidad > 0)
) ENGINE=InnoDB;

CREATE TABLE composicion_kit (
    id_composicion_kit BIGINT NOT NULL AUTO_INCREMENT,
    id_producto_kit BIGINT NOT NULL,
    version INT NOT NULL DEFAULT 1,
    fecha_vigencia_desde DATE NOT NULL,
    fecha_vigencia_hasta DATE NULL,
    vigente BOOLEAN NOT NULL DEFAULT FALSE,
    comentario VARCHAR(500) NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_composicion_kit),
    FOREIGN KEY (id_producto_kit) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    UNIQUE (id_producto_kit, version)
) ENGINE=InnoDB;

CREATE TABLE composicion_kit_detalle (
    id_composicion_kit_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_composicion_kit BIGINT NOT NULL,
    id_producto_componente BIGINT NULL,
    id_insumo_componente BIGINT NULL,
    cantidad DECIMAL(14,3) NOT NULL,
    PRIMARY KEY (id_composicion_kit_detalle),
    FOREIGN KEY (id_composicion_kit) REFERENCES composicion_kit(id_composicion_kit) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto_componente) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_insumo_componente) REFERENCES insumo(id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK ((id_producto_componente IS NOT NULL AND id_insumo_componente IS NULL) OR (id_producto_componente IS NULL AND id_insumo_componente IS NOT NULL)),
    CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- TIPOS DE MOVIMIENTO
CREATE TABLE tipo_movimiento_producto (
    id_tipo_movimiento_producto BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    naturaleza VARCHAR(7) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_tipo_movimiento_producto),
    UNIQUE (nombre),
    CHECK (naturaleza IN ('ENTRADA', 'SALIDA'))
) ENGINE=InnoDB;

CREATE TABLE tipo_movimiento_insumo (
    id_tipo_movimiento_insumo BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    naturaleza VARCHAR(7) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_tipo_movimiento_insumo),
    UNIQUE (nombre),
    CHECK (naturaleza IN ('ENTRADA', 'SALIDA'))
) ENGINE=InnoDB;

-- MOVIMIENTOS DE PRODUCTO
CREATE TABLE movimiento_producto (
    id_movimiento_producto BIGINT NOT NULL AUTO_INCREMENT,
    folio VARCHAR(20) NOT NULL,
    id_inventario BIGINT NOT NULL,
    id_tipo_movimiento_producto BIGINT NOT NULL,
    id_proveedor BIGINT NULL,
    procesar_receta_composicion BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_movimiento DATE NOT NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comentario VARCHAR(1000) NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
    fecha_hora_cancelacion DATETIME NULL,
    PRIMARY KEY (id_movimiento_producto),
    UNIQUE (folio),
    FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_tipo_movimiento_producto) REFERENCES tipo_movimiento_producto(id_tipo_movimiento_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (estado IN ('ACTIVO', 'CANCELADO'))
) ENGINE=InnoDB;

CREATE TABLE movimiento_producto_detalle (
    id_movimiento_producto_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_movimiento_producto BIGINT NOT NULL,
    id_producto_inventario BIGINT NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario_entrada DECIMAL(12,2) NULL,
    actualizar_costo_vigente BOOLEAN NULL,
    id_receta_aplicada BIGINT NULL,
    PRIMARY KEY (id_movimiento_producto_detalle),
    FOREIGN KEY (id_movimiento_producto) REFERENCES movimiento_producto(id_movimiento_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto_inventario) REFERENCES producto_inventario(id_producto_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_receta_aplicada) REFERENCES receta(id_receta) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- MOVIMIENTOS DE INSUMO
CREATE TABLE movimiento_insumo (
    id_movimiento_insumo BIGINT NOT NULL AUTO_INCREMENT,
    folio VARCHAR(20) NOT NULL,
    id_tipo_movimiento_insumo BIGINT NOT NULL,
    id_proveedor BIGINT NULL,
    id_movimiento_producto_origen BIGINT NULL,
    fecha_movimiento DATE NOT NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comentario VARCHAR(1000) NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
    fecha_hora_cancelacion DATETIME NULL,
    PRIMARY KEY (id_movimiento_insumo),
    UNIQUE (folio),
    FOREIGN KEY (id_tipo_movimiento_insumo) REFERENCES tipo_movimiento_insumo(id_tipo_movimiento_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_movimiento_producto_origen) REFERENCES movimiento_producto(id_movimiento_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (estado IN ('ACTIVO', 'CANCELADO'))
) ENGINE=InnoDB;

CREATE TABLE movimiento_insumo_detalle (
    id_movimiento_insumo_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_movimiento_insumo BIGINT NOT NULL,
    id_insumo BIGINT NOT NULL,
    cantidad DECIMAL(14,3) NOT NULL,
    costo_unitario_entrada DECIMAL(12,4) NULL,
    actualizar_costo_vigente BOOLEAN NULL,
    PRIMARY KEY (id_movimiento_insumo_detalle),
    FOREIGN KEY (id_movimiento_insumo) REFERENCES movimiento_insumo(id_movimiento_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_insumo) REFERENCES insumo(id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- VENTAS
CREATE TABLE venta (
    id_venta BIGINT NOT NULL AUTO_INCREMENT,
    folio VARCHAR(20) NOT NULL,
    id_inventario BIGINT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descuento_porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
    importe_descuento DECIMAL(14,2) NOT NULL DEFAULT 0,
    total DECIMAL(14,2) NOT NULL DEFAULT 0,
    comentario VARCHAR(1000) NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
    fecha_hora_cancelacion DATETIME NULL,
    PRIMARY KEY (id_venta),
    UNIQUE (folio),
    FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (descuento_porcentaje BETWEEN 0 AND 100),
    CHECK (estado IN ('ACTIVO', 'CANCELADO'))
) ENGINE=InnoDB;

CREATE TABLE venta_detalle (
    id_venta_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_venta BIGINT NOT NULL,
    id_producto_inventario BIGINT NOT NULL,
    cantidad INT NOT NULL,
    precio_configurado DECIMAL(12,2) NOT NULL DEFAULT 0,
    precio_unitario_venta DECIMAL(12,2) NOT NULL DEFAULT 0,
    importe_partida DECIMAL(14,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_venta_detalle),
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto_inventario) REFERENCES producto_inventario(id_producto_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- TRANSFERENCIAS
CREATE TABLE transferencia (
    id_transferencia BIGINT NOT NULL AUTO_INCREMENT,
    folio VARCHAR(20) NOT NULL,
    id_inventario_origen BIGINT NOT NULL,
    id_inventario_destino BIGINT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comentario VARCHAR(1000) NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
    fecha_hora_cancelacion DATETIME NULL,
    PRIMARY KEY (id_transferencia),
    UNIQUE (folio),
    FOREIGN KEY (id_inventario_origen) REFERENCES inventario(id_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_inventario_destino) REFERENCES inventario(id_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (id_inventario_origen <> id_inventario_destino),
    CHECK (estado IN ('ACTIVO', 'CANCELADO'))
) ENGINE=InnoDB;

CREATE TABLE transferencia_detalle (
    id_transferencia_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_transferencia BIGINT NOT NULL,
    id_producto BIGINT NOT NULL,
    id_producto_inventario_origen BIGINT NOT NULL,
    id_producto_inventario_destino BIGINT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_transferencia_detalle),
    FOREIGN KEY (id_transferencia) REFERENCES transferencia(id_transferencia) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto_inventario_origen) REFERENCES producto_inventario(id_producto_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto_inventario_destino) REFERENCES producto_inventario(id_producto_inventario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- DESARMADO DE KIT
CREATE TABLE desarmado_kit (
    id_desarmado_kit BIGINT NOT NULL AUTO_INCREMENT,
    id_movimiento_producto_detalle BIGINT NOT NULL,
    id_composicion_kit BIGINT NOT NULL,
    fecha_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_desarmado_kit),
    FOREIGN KEY (id_movimiento_producto_detalle) REFERENCES movimiento_producto_detalle(id_movimiento_producto_detalle) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_composicion_kit) REFERENCES composicion_kit(id_composicion_kit) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE desarmado_kit_detalle (
    id_desarmado_kit_detalle BIGINT NOT NULL AUTO_INCREMENT,
    id_desarmado_kit BIGINT NOT NULL,
    id_producto_componente BIGINT NULL,
    id_insumo_componente BIGINT NULL,
    cantidad_teorica DECIMAL(14,3) NOT NULL,
    cantidad_reintegro DECIMAL(14,3) NOT NULL DEFAULT 0,
    cantidad_merma DECIMAL(14,3) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_desarmado_kit_detalle),
    FOREIGN KEY (id_desarmado_kit) REFERENCES desarmado_kit(id_desarmado_kit) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_producto_componente) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (id_insumo_componente) REFERENCES insumo(id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK ((id_producto_componente IS NOT NULL AND id_insumo_componente IS NULL) OR (id_producto_componente IS NULL AND id_insumo_componente IS NOT NULL)),
    CHECK (cantidad_reintegro + cantidad_merma = cantidad_teorica)
) ENGINE=InnoDB;

-- VISTAS
CREATE OR REPLACE VIEW vw_kardex_producto AS
SELECT pi2.id_inventario, pi2.id_producto, mp.fecha_movimiento AS fecha, mp.fecha_hora_registro AS fecha_hora, mp.folio, tmp.nombre AS concepto, mp.estado,
    CASE WHEN tmp.naturaleza='ENTRADA' THEN mpd.cantidad ELSE 0 END AS entrada,
    CASE WHEN tmp.naturaleza='SALIDA' THEN mpd.cantidad ELSE 0 END AS salida, 'MOVIMIENTO_PRODUCTO' AS origen
FROM movimiento_producto_detalle mpd
JOIN movimiento_producto mp ON mp.id_movimiento_producto=mpd.id_movimiento_producto
JOIN tipo_movimiento_producto tmp ON tmp.id_tipo_movimiento_producto=mp.id_tipo_movimiento_producto
JOIN producto_inventario pi2 ON pi2.id_producto_inventario=mpd.id_producto_inventario
UNION ALL
SELECT v.id_inventario, pi2.id_producto, v.fecha_movimiento, v.fecha_hora_registro, v.folio, 'Venta', v.estado, 0, vd.cantidad, 'VENTA'
FROM venta_detalle vd JOIN venta v ON v.id_venta=vd.id_venta JOIN producto_inventario pi2 ON pi2.id_producto_inventario=vd.id_producto_inventario
UNION ALL
SELECT t.id_inventario_origen, td.id_producto, t.fecha_movimiento, t.fecha_hora_registro, t.folio, CONCAT('Transf. a inv.',t.id_inventario_destino), t.estado, 0, td.cantidad, 'TRANSFERENCIA_SALIDA'
FROM transferencia_detalle td JOIN transferencia t ON t.id_transferencia=td.id_transferencia
UNION ALL
SELECT t.id_inventario_destino, td.id_producto, t.fecha_movimiento, t.fecha_hora_registro, t.folio, CONCAT('Transf. desde inv.',t.id_inventario_origen), t.estado, td.cantidad, 0, 'TRANSFERENCIA_ENTRADA'
FROM transferencia_detalle td JOIN transferencia t ON t.id_transferencia=td.id_transferencia;

CREATE OR REPLACE VIEW vw_kardex_insumo AS
SELECT mid2.id_insumo, mi.fecha_movimiento AS fecha, mi.fecha_hora_registro AS fecha_hora, mi.folio, tmi.nombre AS concepto, mi.estado,
    CASE WHEN tmi.naturaleza='ENTRADA' THEN mid2.cantidad ELSE 0 END AS entrada,
    CASE WHEN tmi.naturaleza='SALIDA' THEN mid2.cantidad ELSE 0 END AS salida,
    mi.id_movimiento_producto_origen AS folio_producto_origen, 'MOVIMIENTO_INSUMO' AS origen
FROM movimiento_insumo_detalle mid2
JOIN movimiento_insumo mi ON mi.id_movimiento_insumo=mid2.id_movimiento_insumo
JOIN tipo_movimiento_insumo tmi ON tmi.id_tipo_movimiento_insumo=mi.id_tipo_movimiento_insumo;

CREATE OR REPLACE VIEW rpt_existencias_inventario AS
SELECT i.nombre AS inventario, p.descripcion AS producto, pi2.clave_local, pi2.precio_venta, pi2.stock_minimo, pi2.stock_maximo, pi2.existencia_actual, pi2.activo AS activo_inventario, p.activo AS activo_global
FROM producto_inventario pi2 JOIN producto p ON p.id_producto=pi2.id_producto JOIN inventario i ON i.id_inventario=pi2.id_inventario;

CREATE OR REPLACE VIEW rpt_stock_producto AS
SELECT i.nombre AS inventario, p.descripcion AS producto, pi2.clave_local, pi2.existencia_actual, pi2.stock_minimo, pi2.stock_maximo,
    CASE WHEN pi2.existencia_actual<pi2.stock_minimo THEN 'BAJO MÍNIMO' WHEN pi2.existencia_actual>pi2.stock_maximo AND pi2.stock_maximo>0 THEN 'SOBRE MÁXIMO' ELSE 'NORMAL' END AS alerta
FROM producto_inventario pi2 JOIN producto p ON p.id_producto=pi2.id_producto JOIN inventario i ON i.id_inventario=pi2.id_inventario
WHERE pi2.activo=TRUE AND (pi2.existencia_actual<pi2.stock_minimo OR (pi2.stock_maximo>0 AND pi2.existencia_actual>pi2.stock_maximo));

CREATE OR REPLACE VIEW rpt_stock_insumo AS
SELECT ins.descripcion AS insumo, ins.unidad_medida, ins.existencia_actual, ins.stock_minimo, ins.stock_maximo,
    CASE WHEN ins.existencia_actual<ins.stock_minimo THEN 'BAJO MÍNIMO' WHEN ins.existencia_actual>ins.stock_maximo AND ins.stock_maximo>0 THEN 'SOBRE MÁXIMO' ELSE 'NORMAL' END AS alerta
FROM insumo ins WHERE ins.activo=TRUE AND (ins.existencia_actual<ins.stock_minimo OR (ins.stock_maximo>0 AND ins.existencia_actual>ins.stock_maximo));

CREATE OR REPLACE VIEW rpt_ventas_periodo AS
SELECT v.id_venta, v.folio, i.nombre AS inventario, v.fecha_movimiento, p.descripcion AS producto, pi2.clave_local, vd.cantidad, vd.precio_unitario_venta, vd.importe_partida, v.descuento_porcentaje, v.subtotal, v.importe_descuento, v.total, v.estado
FROM venta v JOIN inventario i ON i.id_inventario=v.id_inventario JOIN venta_detalle vd ON vd.id_venta=v.id_venta
JOIN producto_inventario pi2 ON pi2.id_producto_inventario=vd.id_producto_inventario JOIN producto p ON p.id_producto=pi2.id_producto;

CREATE OR REPLACE VIEW rpt_productos_mas_vendidos AS
SELECT p.id_producto, p.descripcion AS producto, SUM(vd.cantidad) AS total_unidades, SUM(vd.importe_partida) AS total_importe
FROM venta_detalle vd JOIN venta v ON v.id_venta=vd.id_venta AND v.estado='ACTIVO'
JOIN producto_inventario pi2 ON pi2.id_producto_inventario=vd.id_producto_inventario JOIN producto p ON p.id_producto=pi2.id_producto
GROUP BY p.id_producto, p.descripcion ORDER BY total_unidades DESC;

-- DATOS DE EJEMPLO
INSERT INTO categoria_producto (nombre) VALUES ('Rituales y Kits'),('Elíxir Alquímico'),('Velas Intencionadas'),('Quemadores'),('Sahumerios'),('Inciensos Masala'),('Inciensos Artesanales'),('Amuletos y Talismanes');

INSERT INTO producto (descripcion, id_categoria_producto, costo_actual, precio_general, activo) VALUES
('Ritual Triada de Equilibrio Esencial',1,0,470,FALSE),('Ritual Intenciona un 2026 Mágico',1,0,100,FALSE),
('Kit Cuatro Elementos con Quemador',1,0,750,TRUE),('Kit Cuatro Elementos',1,0,395,TRUE),
('Elíxir Alquímico 30ml',2,0,120,TRUE),('Elíxir Alquímico 60ml',2,0,200,TRUE),
('Elíxir Alquímico 125ml',2,0,360,TRUE),('Elíxir Alquímico 500ml',2,0,1100,TRUE),
('Quemador Tablita',4,0,30,TRUE),('Quemador Hoja de Bodhi',4,0,90,TRUE),
('Quemador de Bambú',4,0,110,TRUE),('Quemador y porta incienso cristal',4,0,420,TRUE),
('Quemador 3 en 1',4,0,350,TRUE),('Quemador 3 en 1 con accesorios',4,0,380,TRUE),
('Palo Santo',5,0,60,TRUE),('Salvia Blanca con Eucalipto y Romero',5,0,55,TRUE),
('Salvia Blanca con Lavanda',5,0,55,TRUE),('Salvia Blanca con Pétalos de Rosa',5,0,55,TRUE),
('Salvia Blanca Sangre Dragón',5,0,55,TRUE),('Salvia Blanca con Palo Santo',5,0,55,TRUE);

INSERT INTO categoria_insumo (nombre) VALUES ('Velas'),('Envases'),('Atomizador / Tapas'),('Listones / Decoración'),('Cajas'),('Empaques'),('Etiquetas'),('Generales');

INSERT INTO insumo (descripcion, id_categoria_insumo, unidad_medida, costo_actual, stock_minimo, stock_maximo, existencia_actual) VALUES
('Vela cera de abeja 10x2cm natural',1,'pieza',0,25,50,0),('Vela cera de abeja 10x2cm color',1,'pieza',0,25,50,0),
('Vela cera de abeja 10x2cm blanca',1,'pieza',0,25,50,0),('Vela cera de abeja 10x2cm natural espiral',1,'pieza',0,25,50,0),
('Vela cera de abeja 10x2cm color espiral',1,'pieza',0,25,50,0),('Vela cera de abeja 10x2cm blanca espiral',1,'pieza',0,25,50,0),
('Vela cera de abeja 20x2cm natural',1,'pieza',0,3,10,10),('Vela cirio 1/2 kilo blanca',1,'pieza',0,3,10,0),
('Vela cirio 1/2 kilo amarilla',1,'pieza',0,3,10,0),('Vela cirio 1/2 kilo roja',1,'pieza',0,3,10,0),
('Envase ámbar 30ml',2,'pieza',4.64,5,20,10),('Envase ámbar 60ml',2,'pieza',4.99,5,20,20),
('Envase ámbar 125ml',2,'pieza',5.96,5,20,20),('Envase ámbar 500ml',2,'pieza',10.99,5,20,10),
('Atomizador dorado R-20',3,'pieza',10.99,15,50,50),('Atomizador plástico R-28',3,'pieza',4.20,5,20,10),
('Tapa plástica inviolable R-28',3,'pieza',1.99,5,20,10),('Listón 1.5cm ancho',4,'metro',0,10,100,28),
('Listón 2cm ancho',4,'metro',0,10,100,19),('Listón 2.5cm ancho',4,'metro',0,10,100,31),
('Listón 4cm ancho',4,'metro',0,10,100,31),('Cordón hilo delgado',4,'metro',0,15,100,35),
('Cordón hilo yute',4,'metro',0,15,100,95),('Alcohol Etilico',8,'litro',0,2,20,2.5),
('Romero + Canela + Clavo Olor',8,'porción',0,0,0,0),('Etiqueta logotipo',7,'pieza',0,20,200,150),
('Etiqueta Elíxir 30ml',7,'pieza',0,15,200,0),('Etiqueta Elíxir 60ml',7,'pieza',0,15,200,0),
('Etiqueta Elíxir 125ml',7,'pieza',0,15,100,0),('Etiqueta Elíxir 500ml',7,'pieza',0,15,50,0);

INSERT INTO receta (id_producto, version, fecha_vigencia_desde, fecha_vigencia_hasta, vigente) VALUES
(5,1,'2025-11-15',NULL,TRUE),(6,1,'2025-11-15',NULL,TRUE),(7,1,'2025-11-15',NULL,TRUE),(8,1,'2025-11-15',NULL,TRUE);

INSERT INTO receta_detalle (id_receta, id_insumo, cantidad_por_unidad) VALUES
(1,11,1),(1,15,1),(1,24,0.03),(1,25,0.03),(1,27,1),
(2,12,1),(2,15,1),(2,24,0.06),(2,25,0.06),(2,28,1),
(3,13,1),(3,15,1),(3,24,0.125),(3,25,0.125),(3,29,1),
(4,14,1),(4,16,1),(4,17,1),(4,24,0.5),(4,25,0.5),(4,30,1);

INSERT INTO tipo_movimiento_producto (nombre, naturaleza) VALUES
('Compra','ENTRADA'),('Producción','ENTRADA'),('Armado de kit','ENTRADA'),('Devolución','ENTRADA'),('Ajuste entrada','ENTRADA'),
('Merma','SALIDA'),('Desarmado de kit','SALIDA'),('Ajuste salida','SALIDA'),('Devolución prov.','SALIDA');

INSERT INTO tipo_movimiento_insumo (nombre, naturaleza) VALUES
('Compra','ENTRADA'),('Devolución','ENTRADA'),('Ajuste entrada','ENTRADA'),
('Consumo producción','SALIDA'),('Consumo armado','SALIDA'),('Merma','SALIDA'),('Ajuste salida','SALIDA'),('Reintegro desarmado','ENTRADA');
