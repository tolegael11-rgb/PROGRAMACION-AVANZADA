
USE tienda_online;

SELECT p.id_producto, p.nombre,
       SUM(d.cantidad)                    AS unidades_vendidas,
       SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM detalle_orden d
JOIN ordenes   o ON o.id_orden    = d.id_orden
JOIN productos p ON p.id_producto = d.id_producto
WHERE o.estado <> 'CANCELADA'
GROUP BY p.id_producto, p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 5;

SELECT DATE_FORMAT(pg.fecha, '%Y-%m') AS periodo,
       COUNT(*)                       AS num_pagos,
       SUM(pg.monto)                  AS ingresos
FROM pagos pg
WHERE pg.estado = 'APROBADO'
GROUP BY DATE_FORMAT(pg.fecha, '%Y-%m')
ORDER BY periodo;

SELECT YEAR(pg.fecha) AS anio, SUM(pg.monto) AS ingresos
FROM pagos pg
WHERE pg.estado = 'APROBADO'
GROUP BY YEAR(pg.fecha)
ORDER BY anio;

SELECT SUM(pg.monto) AS ingresos_semestre
FROM pagos pg
WHERE pg.estado = 'APROBADO'
  AND pg.fecha >= '2025-01-01' AND pg.fecha < '2025-07-01';

SELECT c.nombre AS categoria,
       SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM detalle_orden d
JOIN ordenes    o ON o.id_orden     = d.id_orden
JOIN productos  p ON p.id_producto  = d.id_producto
JOIN categorias c ON c.id_categoria = p.id_categoria
WHERE o.estado <> 'CANCELADA'
GROUP BY c.nombre
ORDER BY ingresos DESC;

SELECT u.nombre, COUNT(o.id_orden) AS num_ordenes, SUM(o.total) AS total_comprado
FROM usuarios u
JOIN ordenes o ON o.id_usuario = u.id_usuario
WHERE o.estado <> 'CANCELADA'
GROUP BY u.id_usuario, u.nombre
ORDER BY total_comprado DESC;

SELECT p.nombre, i.cantidad, i.ubicacion_bodega
FROM inventario i
JOIN productos p ON p.id_producto = i.id_producto
WHERE i.cantidad < 10
ORDER BY i.cantidad;

SELECT o.id_orden, u.nombre AS cliente, o.fecha, o.total,
       o.estado AS estado_orden, pg.estado AS estado_pago
FROM ordenes o
JOIN usuarios u ON u.id_usuario = o.id_usuario
LEFT JOIN pagos pg ON pg.id_orden = o.id_orden
ORDER BY o.fecha;
