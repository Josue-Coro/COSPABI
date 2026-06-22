-- ============================================================================
-- PROYECTO: Sistema de Gestión "PASOFIRME" (Compra / Venta / Inventario)
-- ARCHIVO : Datos_Prueba.sql  -> Inserción de datos de prueba
-- EXCLUYE : Usuario, Rol, Permiso, RolPermiso, Bitacora (por requerimiento)
-- NOTA    : Orden_Compra y Venta requieren un Usuario existente (FK NOT NULL).
--           El script usa un id_usuario ya presente en la BD.
-- ============================================================================

USE PASOFIRME;
GO

-- ============================================================================
-- 1. TABLAS MAESTRAS INDEPENDIENTES
-- ============================================================================

-- ---- Categorías ----
INSERT INTO Categoria (categoria) VALUES
('Deportivo'),
('Casual'),
('Formal'),
('Botas'),
('Sandalias'),
('Infantil');
GO

-- ---- Marcas ----
INSERT INTO Marca (marca) VALUES
('Nike'),
('Adidas'),
('Puma'),
('Reebok'),
('Vans'),
('Converse'),
('Caterpillar'),
('Bata');
GO

-- ---- Tipos de Pago ----
INSERT INTO Tipo_Pago (tipopago) VALUES
('Efectivo'),
('Tarjeta de Crédito'),
('Tarjeta de Débito'),
('Transferencia / QR');
GO

-- ---- Clientes (10) ----
INSERT INTO Cliente (ci, nombre, telefono, correo, fecha_nacimiento, fecha_registro) VALUES
('6543210', 'María Fernanda Quispe',   '71234567', 'maria.quispe@gmail.com',   '1995-03-12', '2025-01-10'),
('7654321', 'Juan Carlos Mamani',      '72345678', 'jc.mamani@hotmail.com',    '1988-07-25', '2025-01-18'),
('8765432', 'Ana Lucía Vargas',        '73456789', 'ana.vargas@gmail.com',     '1999-11-02', '2025-02-05'),
('9876543', 'Carlos Alberto Flores',   '74567890', 'carlos.flores@yahoo.com',  '1992-05-19', '2025-02-21'),
('5432109', 'Daniela Rojas Gutiérrez', '75678901', 'dani.rojas@gmail.com',     '2000-09-30', '2025-03-03'),
('4321098', 'Pedro Antonio Choque',    '76789012', NULL,                       '1985-12-08', '2025-03-15'),
('3210987', 'Lucía Beatriz Condori',   '77890123', 'lucia.condori@gmail.com',  '1997-06-14', '2025-04-01'),
('2109876', 'Jorge Luis Apaza',        '78901234', 'jorge.apaza@outlook.com',  '1990-01-27', '2025-04-19'),
('1098765', 'Sofía Gabriela Torrez',   '79012345', 'sofia.torrez@gmail.com',   '2001-08-21', '2025-05-06'),
('6789012', 'Miguel Ángel Sandoval',   '70123456', NULL,                       '1993-04-03', '2025-05-22');
GO

-- ---- Proveedores (5) ----
INSERT INTO Proveedor (nit, nombre_completo, contacto, telefono, correo, estado) VALUES
('1023456017', 'Distribuidora Calzados del Sur S.R.L.', 'Ramiro Pérez',   '22456789', 'ventas@calzadosdelsur.com', 1),
('2034567018', 'Importadora Andina de Calzado Ltda.',   'Gloria Méndez',  '22567890', 'compras@andinacalzado.com', 1),
('3045678019', 'Calzados Bolivia Import S.A.',          'Fernando Ríos',  '22678901', 'info@calzadosbolivia.com',  1),
('4056789010', 'Comercial El Caminante',                'Teresa Lima',    '22789012', 'elcaminante@gmail.com',     1),
('5067890011', 'Mayorista Pisada Fuerte',               'Andrés Vaca',    '22890123', NULL,                        0);
GO

-- ============================================================================
-- 2. PRODUCTOS (10)  -- precios en Bs.  (imagen queda NULL)
--    Se referencian Categoría y Marca por nombre para mayor robustez.
-- ============================================================================
INSERT INTO Producto (Categoria_id_categoria, Marca_id_marca, nombre, precio_compra, precio_venta, stock_minimo, estado, imagen) VALUES
((SELECT id_categoria FROM Categoria WHERE categoria='Deportivo'),(SELECT id_marca FROM Marca WHERE marca='Nike'),       'Nike Air Max 90',          350.00, 650.00, 5, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Deportivo'),(SELECT id_marca FROM Marca WHERE marca='Adidas'),     'Adidas Ultraboost 22',     450.00, 850.00, 5, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Casual'),   (SELECT id_marca FROM Marca WHERE marca='Puma'),       'Puma RS-X',                300.00, 580.00, 5, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Casual'),   (SELECT id_marca FROM Marca WHERE marca='Reebok'),     'Reebok Classic Leather',   250.00, 480.00, 5, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Casual'),   (SELECT id_marca FROM Marca WHERE marca='Vans'),       'Vans Old Skool',           220.00, 420.00, 6, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Casual'),   (SELECT id_marca FROM Marca WHERE marca='Converse'),   'Converse Chuck Taylor',    200.00, 380.00, 6, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Botas'),    (SELECT id_marca FROM Marca WHERE marca='Caterpillar'),'Caterpillar Colorado Bota',400.00, 750.00, 4, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Formal'),   (SELECT id_marca FROM Marca WHERE marca='Bata'),       'Bata Oxford Formal',       180.00, 350.00, 5, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Infantil'), (SELECT id_marca FROM Marca WHERE marca='Nike'),       'Nike Revolution 6 Niño',   230.00, 450.00, 8, 1, NULL),
((SELECT id_categoria FROM Categoria WHERE categoria='Sandalias'),(SELECT id_marca FROM Marca WHERE marca='Adidas'),     'Adidas Adilette Sandalia', 120.00, 250.00,10, 1, NULL);
GO

-- ============================================================================
-- 3. INVENTARIO (varias tallas/colores por producto)
-- ============================================================================
INSERT INTO Inventario (id_producto, talla, color, stock_disponible) VALUES
((SELECT id_producto FROM Producto WHERE nombre='Nike Air Max 90'),          '40', 'Negro',  12),
((SELECT id_producto FROM Producto WHERE nombre='Nike Air Max 90'),          '41', 'Blanco',  8),
((SELECT id_producto FROM Producto WHERE nombre='Nike Air Max 90'),          '42', 'Rojo',    5),
((SELECT id_producto FROM Producto WHERE nombre='Adidas Ultraboost 22'),     '41', 'Negro',  10),
((SELECT id_producto FROM Producto WHERE nombre='Adidas Ultraboost 22'),     '42', 'Gris',    6),
((SELECT id_producto FROM Producto WHERE nombre='Puma RS-X'),                '40', 'Gris',    9),
((SELECT id_producto FROM Producto WHERE nombre='Puma RS-X'),                '41', 'Azul',    7),
((SELECT id_producto FROM Producto WHERE nombre='Reebok Classic Leather'),   '39', 'Blanco', 11),
((SELECT id_producto FROM Producto WHERE nombre='Reebok Classic Leather'),   '40', 'Negro',   8),
((SELECT id_producto FROM Producto WHERE nombre='Vans Old Skool'),           '38', 'Negro',  14),
((SELECT id_producto FROM Producto WHERE nombre='Vans Old Skool'),           '39', 'Negro',  12),
((SELECT id_producto FROM Producto WHERE nombre='Converse Chuck Taylor'),    '38', 'Blanco', 10),
((SELECT id_producto FROM Producto WHERE nombre='Converse Chuck Taylor'),    '39', 'Rojo',    9),
((SELECT id_producto FROM Producto WHERE nombre='Caterpillar Colorado Bota'),'42', 'Café',    6),
((SELECT id_producto FROM Producto WHERE nombre='Caterpillar Colorado Bota'),'43', 'Negro',   4),
((SELECT id_producto FROM Producto WHERE nombre='Bata Oxford Formal'),       '40', 'Negro',  10),
((SELECT id_producto FROM Producto WHERE nombre='Bata Oxford Formal'),       '41', 'Café',    7),
((SELECT id_producto FROM Producto WHERE nombre='Nike Revolution 6 Niño'),   '34', 'Azul',   15),
((SELECT id_producto FROM Producto WHERE nombre='Nike Revolution 6 Niño'),   '35', 'Rosado', 13),
((SELECT id_producto FROM Producto WHERE nombre='Adidas Adilette Sandalia'), '41', 'Azul',   20),
((SELECT id_producto FROM Producto WHERE nombre='Adidas Adilette Sandalia'), '42', 'Negro',  18);
GO

-- ============================================================================
-- 4. PROCESOS: ÓRDENES DE COMPRA y VENTAS
--    (Requieren un Usuario existente. Todo en un solo batch por las variables.)
-- ============================================================================
DECLARE @Usuario_id INT = (SELECT MIN(id_usuario) FROM Usuario);

IF @Usuario_id IS NULL
BEGIN
    RAISERROR('No existe ningun Usuario. Orden_Compra y Venta requieren al menos un usuario registrado. Inserte un usuario y vuelva a ejecutar esta seccion.', 16, 1);
    RETURN;
END

DECLARE @oc INT;   -- id de orden de compra
DECLARE @v  INT;   -- id de venta

-- -------------------- ORDEN DE COMPRA 1 (Proveedor 1) -----------------------
INSERT INTO Orden_Compra (Proveedor_id_proveedor, Usuario_id_usuario, fecha_compra, total_compra)
VALUES ((SELECT id_proveedor FROM Proveedor WHERE nit='1023456017'), @Usuario_id, '2025-05-02', 9000.00);
SET @oc = SCOPE_IDENTITY();

INSERT INTO Detalle_Compra (Orden_Compra_id_orden_compra, id_producto, talla, color, cantidad, precio_costo, sub_total) VALUES
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Nike Air Max 90'),      '40', 'Negro',  10, 350.00, 3500.00),
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Nike Air Max 90'),      '41', 'Blanco',  8, 350.00, 2800.00),
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Adidas Ultraboost 22'), '42', 'Gris',    6, 450.00, 2700.00);

-- -------------------- ORDEN DE COMPRA 2 (Proveedor 2) -----------------------
INSERT INTO Orden_Compra (Proveedor_id_proveedor, Usuario_id_usuario, fecha_compra, total_compra)
VALUES ((SELECT id_proveedor FROM Proveedor WHERE nit='2034567018'), @Usuario_id, '2025-05-12', 6740.00);
SET @oc = SCOPE_IDENTITY();

INSERT INTO Detalle_Compra (Orden_Compra_id_orden_compra, id_producto, talla, color, cantidad, precio_costo, sub_total) VALUES
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Vans Old Skool'),        '39', 'Negro',  12, 220.00, 2640.00),
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Converse Chuck Taylor'), '38', 'Blanco', 10, 200.00, 2000.00),
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Puma RS-X'),             '41', 'Azul',    7, 300.00, 2100.00);

-- -------------------- ORDEN DE COMPRA 3 (Proveedor 3) -----------------------
INSERT INTO Orden_Compra (Proveedor_id_proveedor, Usuario_id_usuario, fecha_compra, total_compra)
VALUES ((SELECT id_proveedor FROM Proveedor WHERE nit='3045678019'), @Usuario_id, '2025-05-20', 5420.00);
SET @oc = SCOPE_IDENTITY();

INSERT INTO Detalle_Compra (Orden_Compra_id_orden_compra, id_producto, talla, color, cantidad, precio_costo, sub_total) VALUES
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Caterpillar Colorado Bota'),'42', 'Café',  5, 400.00, 2000.00),
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Bata Oxford Formal'),       '40', 'Negro', 9, 180.00, 1620.00),
(@oc, (SELECT id_producto FROM Producto WHERE nombre='Adidas Adilette Sandalia'), '41', 'Azul', 15, 120.00, 1800.00);

-- ============================================================================
-- VENTAS  (subtotal de Detalle_Venta es calculado: NO se inserta)
-- ============================================================================

-- -------------------- VENTA 1 -- Efectivo -----------------------------------
INSERT INTO Venta (Cliente_id_cliente, Usuario_id_usuario, Tipo_Pago_id_tipopago, fecha_venta, total, estado_venta)
VALUES ((SELECT id_cliente FROM Cliente WHERE ci='6543210'), @Usuario_id,
        (SELECT id_tipopago FROM Tipo_Pago WHERE tipopago='Efectivo'), '2025-05-25', 650.00, 'Completada');
SET @v = SCOPE_IDENTITY();
INSERT INTO Detalle_Venta (Venta_id_venta, id_producto, talla, color, cantidad, precio_venta) VALUES
(@v, (SELECT id_producto FROM Producto WHERE nombre='Nike Air Max 90'), '40', 'Negro', 1, 650.00);

-- -------------------- VENTA 2 -- Tarjeta de Crédito (2 ítems) ----------------
INSERT INTO Venta (Cliente_id_cliente, Usuario_id_usuario, Tipo_Pago_id_tipopago, fecha_venta, total, estado_venta)
VALUES ((SELECT id_cliente FROM Cliente WHERE ci='7654321'), @Usuario_id,
        (SELECT id_tipopago FROM Tipo_Pago WHERE tipopago='Tarjeta de Crédito'), '2025-05-26', 1270.00, 'Completada');
SET @v = SCOPE_IDENTITY();
INSERT INTO Detalle_Venta (Venta_id_venta, id_producto, talla, color, cantidad, precio_venta) VALUES
(@v, (SELECT id_producto FROM Producto WHERE nombre='Adidas Ultraboost 22'), '41', 'Negro', 1, 850.00),
(@v, (SELECT id_producto FROM Producto WHERE nombre='Vans Old Skool'),       '39', 'Negro', 1, 420.00);

-- -------------------- VENTA 3 -- QR (cantidad 2) ----------------------------
INSERT INTO Venta (Cliente_id_cliente, Usuario_id_usuario, Tipo_Pago_id_tipopago, fecha_venta, total, estado_venta)
VALUES ((SELECT id_cliente FROM Cliente WHERE ci='8765432'), @Usuario_id,
        (SELECT id_tipopago FROM Tipo_Pago WHERE tipopago='Transferencia / QR'), '2025-05-28', 760.00, 'Completada');
SET @v = SCOPE_IDENTITY();
INSERT INTO Detalle_Venta (Venta_id_venta, id_producto, talla, color, cantidad, precio_venta) VALUES
(@v, (SELECT id_producto FROM Producto WHERE nombre='Converse Chuck Taylor'), '38', 'Blanco', 2, 380.00);

-- -------------------- VENTA 4 -- Cliente ocasional (NULL) -------------------
INSERT INTO Venta (Cliente_id_cliente, Usuario_id_usuario, Tipo_Pago_id_tipopago, fecha_venta, total, estado_venta)
VALUES (NULL, @Usuario_id,
        (SELECT id_tipopago FROM Tipo_Pago WHERE tipopago='Efectivo'), '2025-05-30', 350.00, 'Completada');
SET @v = SCOPE_IDENTITY();
INSERT INTO Detalle_Venta (Venta_id_venta, id_producto, talla, color, cantidad, precio_venta) VALUES
(@v, (SELECT id_producto FROM Producto WHERE nombre='Bata Oxford Formal'), '40', 'Negro', 1, 350.00);

-- -------------------- VENTA 5 -- Tarjeta de Débito (2 ítems) -----------------
INSERT INTO Venta (Cliente_id_cliente, Usuario_id_usuario, Tipo_Pago_id_tipopago, fecha_venta, total, estado_venta)
VALUES ((SELECT id_cliente FROM Cliente WHERE ci='5432109'), @Usuario_id,
        (SELECT id_tipopago FROM Tipo_Pago WHERE tipopago='Tarjeta de Débito'), '2025-06-01', 1000.00, 'Completada');
SET @v = SCOPE_IDENTITY();
INSERT INTO Detalle_Venta (Venta_id_venta, id_producto, talla, color, cantidad, precio_venta) VALUES
(@v, (SELECT id_producto FROM Producto WHERE nombre='Caterpillar Colorado Bota'), '42', 'Café', 1, 750.00),
(@v, (SELECT id_producto FROM Producto WHERE nombre='Adidas Adilette Sandalia'),  '41', 'Azul', 1, 250.00);

-- -------------------- VENTA 6 -- ANULADA (con justificación) -----------------
INSERT INTO Venta (Cliente_id_cliente, Usuario_id_usuario, Tipo_Pago_id_tipopago, fecha_venta, total, estado_venta, justificacion_anulacion)
VALUES ((SELECT id_cliente FROM Cliente WHERE ci='9876543'), @Usuario_id,
        (SELECT id_tipopago FROM Tipo_Pago WHERE tipopago='Efectivo'), '2025-06-03', 580.00, 'Anulada', 'El cliente desistió de la compra por talla incorrecta.');
SET @v = SCOPE_IDENTITY();
INSERT INTO Detalle_Venta (Venta_id_venta, id_producto, talla, color, cantidad, precio_venta) VALUES
(@v, (SELECT id_producto FROM Producto WHERE nombre='Puma RS-X'), '41', 'Azul', 1, 580.00);
GO

-- ============================================================================
-- FIN DEL SCRIPT DE DATOS DE PRUEBA
-- ============================================================================
PRINT 'Datos de prueba insertados correctamente.';
GO
