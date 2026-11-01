
USE tienda_online;

INSERT INTO categorias (id_categoria, nombre) VALUES
 (1,'Tecnología'),(2,'Hogar'),(3,'Deportes');

INSERT INTO productos (id_producto,id_categoria,sku,nombre,descripcion,precio,imagen_url) VALUES
 (1,1,'TEC-001','Audífonos Bluetooth','Audífonos inalámbricos con cancelación de ruido',180000,'https://cdn.tienda.com/img/audifonos.jpg'),
 (2,1,'TEC-002','Mouse inalámbrico','Mouse ergonómico 2.4 GHz',65000,'https://cdn.tienda.com/img/mouse.jpg'),
 (3,1,'TEC-003','Teclado mecánico','Teclado mecánico retroiluminado',250000,'https://cdn.tienda.com/img/teclado.jpg'),
 (4,2,'HOG-001','Licuadora 600W','Licuadora con vaso de vidrio',120000,'https://cdn.tienda.com/img/licuadora.jpg'),
 (5,2,'HOG-002','Lámpara LED de escritorio','Lámpara regulable',45000,'https://cdn.tienda.com/img/lampara.jpg'),
 (6,3,'DEP-001','Balón de fútbol','Balón profesional No. 5',90000,'https://cdn.tienda.com/img/balon.jpg'),
 (7,3,'DEP-002','Tapete de yoga','Tapete antideslizante 6 mm',55000,'https://cdn.tienda.com/img/yoga.jpg'),
 (8,3,'DEP-003','Pesas ajustables','Par de mancuernas 20 kg',210000,'https://cdn.tienda.com/img/pesas.jpg');

INSERT INTO inventario (id_producto,cantidad,ubicacion_bodega) VALUES
 (1,50,'A-01-01'),(2,120,'A-01-02'),(3,35,'A-02-01'),(4,40,'B-01-01'),
 (5,8,'B-01-02'),(6,60,'C-01-01'),(7,5,'C-01-02'),(8,25,'C-02-01');

INSERT INTO usuarios (id_usuario,nombre,correo,contrasena_hash,telefono,direccion_envio,ciudad) VALUES
 (1,'Laura Gómez','laura@correo.com','hash_demo_1','3001112233','Cra 10 # 20-30','Bogotá'),
 (2,'Carlos Pérez','carlos@correo.com','hash_demo_2','3002223344','Cl 45 # 12-08','Soacha'),
 (3,'Ana Torres','ana@correo.com','hash_demo_3','3003334455','Av 68 # 5-40','Bogotá'),
 (4,'Juan Rodríguez','juan@correo.com','hash_demo_4','3004445566','Cl 100 # 15-20','Medellín'),
 (5,'María López','maria@correo.com','hash_demo_5','3005556677','Cra 7 # 72-10','Bogotá');

INSERT INTO ordenes (id_orden,id_usuario,fecha,costo_envio,direccion_envio,estado) VALUES
 (1,1,'2025-01-15 10:30:00',12000,'Cra 10 # 20-30','ENTREGADA'),
 (2,2,'2025-02-03 14:10:00',12000,'Cl 45 # 12-08','ENTREGADA'),
 (3,3,'2025-02-20 09:45:00',0,    'Av 68 # 5-40','ENTREGADA'),
 (4,1,'2025-03-11 16:20:00',12000,'Cra 10 # 20-30','ENTREGADA'),
 (5,4,'2025-04-05 11:00:00',15000,'Cl 100 # 15-20','ENTREGADA'),
 (6,5,'2025-05-18 18:30:00',12000,'Cra 7 # 72-10','ENVIADA'),
 (7,2,'2025-06-02 13:15:00',12000,'Cl 45 # 12-08','ENTREGADA'),
 (8,3,'2025-07-21 08:50:00',0,    'Av 68 # 5-40','PAGADA'),
 (9,4,'2025-08-09 20:05:00',15000,'Cl 100 # 15-20','CANCELADA'),
 (10,1,'2025-09-14 15:40:00',12000,'Cra 10 # 20-30','ENTREGADA'),
 (11,5,'2025-10-30 12:25:00',12000,'Cra 7 # 72-10','PENDIENTE'),
 (12,2,'2026-01-08 10:10:00',12000,'Cl 45 # 12-08','ENTREGADA');

INSERT INTO detalle_orden (id_orden,id_producto,cantidad,precio_unitario) VALUES
 (1,1,1,180000),(1,2,2,65000),
 (2,4,1,120000),
 (3,3,1,250000),(3,2,1,65000),
 (4,6,2,90000),(4,7,1,55000),
 (5,8,1,210000),
 (6,1,1,180000),(6,5,2,45000),
 (7,2,3,65000),(7,7,2,55000),
 (8,3,1,250000),(8,1,1,180000),
 (9,4,2,120000),
 (10,2,1,65000),(10,5,1,45000),
 (11,6,1,90000),
 (12,1,2,180000),(12,3,1,250000);

UPDATE ordenes o
SET o.subtotal = (SELECT SUM(d.cantidad * d.precio_unitario)
                  FROM detalle_orden d WHERE d.id_orden = o.id_orden);
UPDATE ordenes SET total = subtotal + costo_envio;

INSERT INTO pagos (id_orden,fecha,monto,metodo,estado,referencia_pasarela)
SELECT o.id_orden,
       DATE_ADD(o.fecha, INTERVAL 5 MINUTE),
       o.total,
       CASE WHEN o.id_orden % 2 = 0 THEN 'TARJETA' ELSE 'PSE' END,
       CASE WHEN o.id_orden = 9  THEN 'RECHAZADO'
            WHEN o.id_orden = 11 THEN 'PENDIENTE'
            ELSE 'APROBADO' END,
       CONCAT('TX-', LPAD(o.id_orden, 6, '0'))
FROM ordenes o;
