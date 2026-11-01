
DROP DATABASE IF EXISTS tienda_online;
CREATE DATABASE tienda_online
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_online;

CREATE TABLE categorias (
  id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(80)  NOT NULL,
  CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
  CONSTRAINT uq_categorias_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE productos (
  id_producto    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_categoria   INT UNSIGNED  NOT NULL,
  sku            VARCHAR(40)   NOT NULL,
  nombre         VARCHAR(150)  NOT NULL,
  descripcion    TEXT,
  precio         DECIMAL(12,2) NOT NULL,
  imagen_url     VARCHAR(255),
  activo         TINYINT(1)    NOT NULL DEFAULT 1,
  fecha_creacion TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_productos PRIMARY KEY (id_producto),
  CONSTRAINT uq_productos_sku UNIQUE (sku),
  CONSTRAINT ck_productos_precio CHECK (precio >= 0),
  CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria)
    REFERENCES categorias (id_categoria)
) ENGINE=InnoDB;

CREATE TABLE inventario (
  id_producto         INT UNSIGNED NOT NULL,
  cantidad            INT          NOT NULL DEFAULT 0,
  ubicacion_bodega    VARCHAR(50)  NOT NULL,
  fecha_actualizacion TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_inventario PRIMARY KEY (id_producto),
  CONSTRAINT ck_inventario_cantidad CHECK (cantidad >= 0),
  CONSTRAINT fk_inventario_producto FOREIGN KEY (id_producto)
    REFERENCES productos (id_producto) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id_usuario      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(120) NOT NULL,
  correo          VARCHAR(150) NOT NULL,
  contrasena_hash VARCHAR(255) NOT NULL,
  telefono        VARCHAR(30),
  direccion_envio VARCHAR(255) NOT NULL,
  ciudad          VARCHAR(80)  NOT NULL,
  pais            VARCHAR(60)  NOT NULL DEFAULT 'Colombia',
  fecha_registro  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_usuarios PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuarios_correo UNIQUE (correo)
) ENGINE=InnoDB;

CREATE TABLE ordenes (
  id_orden        INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_usuario      INT UNSIGNED  NOT NULL,
  fecha           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal        DECIMAL(12,2) NOT NULL DEFAULT 0,
  costo_envio     DECIMAL(12,2) NOT NULL DEFAULT 0,
  total           DECIMAL(12,2) NOT NULL DEFAULT 0,
  direccion_envio VARCHAR(255)  NOT NULL,
  estado          ENUM('PENDIENTE','PAGADA','ENVIADA','ENTREGADA','CANCELADA')
                  NOT NULL DEFAULT 'PENDIENTE',
  CONSTRAINT pk_ordenes PRIMARY KEY (id_orden),
  CONSTRAINT ck_ordenes_total CHECK (total >= 0 AND costo_envio >= 0),
  CONSTRAINT fk_ordenes_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE detalle_orden (
  id_orden        INT UNSIGNED  NOT NULL,
  id_producto     INT UNSIGNED  NOT NULL,
  cantidad        INT UNSIGNED  NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  CONSTRAINT pk_detalle_orden PRIMARY KEY (id_orden, id_producto),
  CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
  CONSTRAINT fk_detalle_orden FOREIGN KEY (id_orden)
    REFERENCES ordenes (id_orden) ON DELETE CASCADE,
  CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
    REFERENCES productos (id_producto)
) ENGINE=InnoDB;

CREATE TABLE pagos (
  id_pago             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_orden            INT UNSIGNED  NOT NULL,
  fecha               DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  monto               DECIMAL(12,2) NOT NULL,
  metodo              VARCHAR(30)   NOT NULL,
  estado              ENUM('PENDIENTE','APROBADO','RECHAZADO','REEMBOLSADO')
                      NOT NULL DEFAULT 'PENDIENTE',
  referencia_pasarela VARCHAR(80),
  CONSTRAINT pk_pagos PRIMARY KEY (id_pago),
  CONSTRAINT uq_pagos_orden UNIQUE (id_orden),
  CONSTRAINT ck_pagos_monto CHECK (monto >= 0),
  CONSTRAINT fk_pagos_orden FOREIGN KEY (id_orden)
    REFERENCES ordenes (id_orden)
) ENGINE=InnoDB;
