
USE tienda_online;

CREATE INDEX idx_pagos_estado_fecha  ON pagos   (estado, fecha);

CREATE INDEX idx_ordenes_estado_fecha ON ordenes (estado, fecha);

CREATE INDEX idx_ordenes_usuario_fecha ON ordenes (id_usuario, fecha);

CREATE INDEX idx_inventario_cantidad ON inventario (cantidad);

EXPLAIN SELECT SUM(monto) FROM pagos
WHERE estado = 'APROBADO' AND fecha >= '2025-01-01' AND fecha < '2025-07-01';

EXPLAIN SELECT * FROM ordenes WHERE id_usuario = 1 ORDER BY fecha;

SHOW INDEX FROM ordenes;

DROP TABLE IF EXISTS ordenes_historico;
CREATE TABLE ordenes_historico (
  id_orden    INT UNSIGNED  NOT NULL,
  id_usuario  INT UNSIGNED  NOT NULL,
  fecha       DATETIME      NOT NULL,
  total       DECIMAL(12,2) NOT NULL,
  estado      VARCHAR(20)   NOT NULL,
  PRIMARY KEY (id_orden, fecha)
) ENGINE=InnoDB
PARTITION BY RANGE (YEAR(fecha)) (
  PARTITION p2024   VALUES LESS THAN (2025),
  PARTITION p2025   VALUES LESS THAN (2026),
  PARTITION p2026   VALUES LESS THAN (2027),
  PARTITION pfuturo VALUES LESS THAN MAXVALUE
);

INSERT INTO ordenes_historico (id_orden,id_usuario,fecha,total,estado)
SELECT id_orden, id_usuario, fecha, total, estado FROM ordenes;

CREATE INDEX idx_hist_usuario ON ordenes_historico (id_usuario);

SELECT PARTITION_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'tienda_online' AND TABLE_NAME = 'ordenes_historico';

EXPLAIN SELECT SUM(total) FROM ordenes_historico
WHERE fecha >= '2025-01-01' AND fecha < '2026-01-01';

ALTER TABLE ordenes_historico REORGANIZE PARTITION pfuturo INTO (
  PARTITION p2027   VALUES LESS THAN (2028),
  PARTITION pfuturo VALUES LESS THAN MAXVALUE
);

