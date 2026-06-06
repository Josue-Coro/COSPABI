-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2026-05-09 23:01:34 BOT
--   sitio:      SQL Server 2012
--   tipo:      SQL Server 2012

CREATE DATABASE cospabirl
GO
USE cospabirl;
GO

CREATE TABLE aviso 
    (
     id_aviso INTEGER NOT NULL IDENTITY(1,1), 
     fecha_emision DATE NOT NULL , 
     fecha_vencimiento DATE NOT NULL , 
     total_consumo DECIMAL (30,2) NOT NULL , 
     total_aviso DECIMAL (30,2) NOT NULL , 
     estado VARCHAR (50) NOT NULL , 
     deuda_actual DECIMAL (30,2) NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL , 
     cargo_extra_id_carga_extra INTEGER , 
     credito_inscripcion_id_credito INTEGER , 
     estado_id_estado INTEGER NOT NULL , 
     lectura_id_lectura INTEGER , 
     socio_id_socio INTEGER NOT NULL , 
     caja_id_caja INTEGER 
    )
GO

ALTER TABLE aviso ADD CONSTRAINT aviso_PK PRIMARY KEY CLUSTERED (id_aviso)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE bitacora 
    (
     id_bitacora INTEGER NOT NULL IDENTITY(1,1), 
     accion VARCHAR (255) NOT NULL , 
     fecha DATE NOT NULL , 
     hora DATETIME NOT NULL , 
     usuario_admin_id_usuario_admin INTEGER NOT NULL 
    )
GO

ALTER TABLE bitacora ADD CONSTRAINT bitacora_PK PRIMARY KEY CLUSTERED (id_bitacora)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE caja 
    (
     id_caja INTEGER NOT NULL IDENTITY(1,1), 
     fecha DATE NOT NULL , 
     hora_apertura DATETIME NOT NULL , 
     hors_cierre DATETIME NOT NULL , 
     monto_cobrado DECIMAL (30,3) NOT NULL , 
     usuario_admin_id_usuario_admin INTEGER NOT NULL , 
     estado BIT NOT NULL 
    )
GO

ALTER TABLE caja ADD CONSTRAINT caja_PK PRIMARY KEY CLUSTERED (id_caja)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE cargo_extra 
    (
     id_carga_extra INTEGER NOT NULL IDENTITY(1,1), 
     monto DECIMAL (30,2) NOT NULL , 
     descripcion VARCHAR (150) NOT NULL , 
     fecha_registro DATE NOT NULL , 
     estado VARCHAR (150) NOT NULL , 
     tipo_cargo_id_tipo INTEGER NOT NULL , 
     socio_id_socio INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL 
    )
GO

ALTER TABLE cargo_extra ADD CONSTRAINT cargo_extra_PK PRIMARY KEY CLUSTERED (id_carga_extra)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE cliente 
    (
     id_cliente INTEGER NOT NULL IDENTITY(1,1), 
     genero VARCHAR (255) NOT NULL , 
     nombre_completo VARCHAR (250) NOT NULL , 
     ci VARCHAR (50) NOT NULL , 
     fecha_nacimiento DATE NOT NULL , 
     fecha_registro DATE NOT NULL , 
     estado BIT NOT NULL , 
     rol_id_rol INTEGER NOT NULL , 
     telefono INTEGER 
    )
GO

ALTER TABLE cliente ADD CONSTRAINT cliente_PK PRIMARY KEY CLUSTERED (id_cliente)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE credito_inscripcion 
    (
     id_credito INTEGER NOT NULL IDENTITY(1,1), 
     monto_pago DECIMAL (10,2) NOT NULL , 
     estado VARCHAR (50) NOT NULL , 
     num_cuota INTEGER NOT NULL , 
     socio_id_socio INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL 
    )
GO

ALTER TABLE credito_inscripcion ADD CONSTRAINT credito_inscripcion_PK PRIMARY KEY CLUSTERED (id_credito)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE cuenta_socio 
    (
     id_cuenta_socio INTEGER NOT NULL IDENTITY(1,1), 
     usuario VARCHAR (150) NOT NULL , 
     contraseña VARCHAR (500) NOT NULL , 
     ultimo_acceso DATETIME NOT NULL , 
     estado BIT NOT NULL , 
     socio_id_socio INTEGER NOT NULL 
     
    )
GO



ALTER TABLE cuenta_socio ADD CONSTRAINT cuenta_socio_PK PRIMARY KEY CLUSTERED (id_cuenta_socio)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE estado 
    (
     id_estado INTEGER NOT NULL IDENTITY(1,1), 
     estado VARCHAR (150) NOT NULL 
    )
GO

ALTER TABLE estado ADD CONSTRAINT estado_PK PRIMARY KEY CLUSTERED (id_estado)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE lectura 
    (
     id_lectura INTEGER NOT NULL IDENTITY(1,1), 
     fecha_lectura DATE NOT NULL , 
     lectura_anterior INTEGER NOT NULL , 
     lectura_actual INTEGER NOT NULL , 
     dias_lectura INTEGER NOT NULL , 
     observacion VARCHAR (255) NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL , 
     usuario_admin_id_usuario_admin INTEGER NOT NULL , 
     medidor_id_medidor INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL , 
     consumo_m3 DECIMAL (30,2) NOT NULL , 
     ruta_id_ruta INTEGER NOT NULL 
    )
GO

ALTER TABLE lectura ADD CONSTRAINT lectura_PK PRIMARY KEY CLUSTERED (id_lectura)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE medidor 
    (
     id_medidor INTEGER NOT NULL IDENTITY(1,1), 
     serie VARCHAR (150) NOT NULL , 
     numero INTEGER NOT NULL , 
     fecha_instalacion DATE 
    )
GO

ALTER TABLE medidor ADD CONSTRAINT medidor_PK PRIMARY KEY CLUSTERED (id_medidor)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE metodo_pago 
    (
     id_metodo_pago INTEGER NOT NULL IDENTITY(1,1), 
     metodo VARCHAR (150) NOT NULL , 
     referencia VARCHAR (255) NOT NULL 
    )
GO

ALTER TABLE metodo_pago ADD CONSTRAINT metodo_pago_PK PRIMARY KEY CLUSTERED (id_metodo_pago)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE notificacion 
    (
     id_notificacion INTEGER NOT NULL IDENTITY(1,1), 
     titulo VARCHAR (255) NOT NULL , 
     mensaje VARCHAR (1000) NOT NULL , 
     tipo VARCHAR (255) NOT NULL , 
     fecha_publicacion DATE NOT NULL , 
     estado BIT NOT NULL 
    )
GO

ALTER TABLE notificacion ADD CONSTRAINT notificacion_PK PRIMARY KEY CLUSTERED (id_notificacion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE notificacion_socio 
    (
     id_notificacion_socio INTEGER NOT NULL IDENTITY(1,1), 
     fecha_lectura DATE NOT NULL , 
     leido BIT NOT NULL , 
     notificacion_id_notificacion INTEGER NOT NULL , 
     socio_id_socio INTEGER NOT NULL 
    )
GO

ALTER TABLE notificacion_socio ADD CONSTRAINT notificacion_socio_PK PRIMARY KEY CLUSTERED (id_notificacion_socio)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE pago 
    (
     id_pago INTEGER NOT NULL IDENTITY(1,1), 
     fecha_pago DATE NOT NULL , 
     monto_pagado DECIMAL (30,2) NOT NULL , 
     monto_recibido DECIMAL (30,3) NOT NULL , 
     cajero VARCHAR (150) NOT NULL , 
     estado BIT NOT NULL , 
     aviso_id_aviso INTEGER NOT NULL , 
     metodo_pago_id_metodo_pago INTEGER NOT NULL , 
     vuelto DECIMAL (30,3) 
    )
GO

ALTER TABLE pago ADD CONSTRAINT pago_PK PRIMARY KEY CLUSTERED (id_pago)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE periodo 
    (
     id_periodo INTEGER NOT NULL IDENTITY(1,1), 
     periodo VARCHAR (50) NOT NULL 
    )
GO

ALTER TABLE periodo ADD CONSTRAINT periodo_PK PRIMARY KEY CLUSTERED (id_periodo)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE permiso 
    (
     id_permiso INTEGER NOT NULL IDENTITY(1,1), 
     accion VARCHAR (150) NOT NULL , 
     descripcion VARCHAR (150) 
    )
GO

ALTER TABLE permiso ADD CONSTRAINT permiso_PK PRIMARY KEY CLUSTERED (id_permiso)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE rol 
    (
     id_rol INTEGER NOT NULL IDENTITY(1,1), 
     nombre VARCHAR (150) NOT NULL , 
     descripcion VARCHAR (250) , 
     estado BIT NOT NULL 
    )
GO

ALTER TABLE rol ADD CONSTRAINT rol_PK PRIMARY KEY CLUSTERED (id_rol)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE rol_permiso 
    (
     id_rol_permiso INTEGER NOT NULL IDENTITY(1,1), 
     permiso_id_permiso INTEGER NOT NULL , 
     rol_id_rol INTEGER NOT NULL 
    )
GO

ALTER TABLE rol_permiso ADD CONSTRAINT rol_permiso_PK PRIMARY KEY CLUSTERED (id_rol_permiso)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE rol_socio 
    (
     id_rol_socio INTEGER NOT NULL IDENTITY(1,1), 
     rol_socio VARCHAR (150) NOT NULL 
    )
GO

ALTER TABLE rol_socio ADD CONSTRAINT rol_socio_PK PRIMARY KEY CLUSTERED (id_rol_socio)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO
--insertar por default al crear la tabla el rol de ("SOCIO", "USUARIO") solo esos 2 van a existir en la tabla rol_socio
iNSERT INTO rol_socio (rol_socio) VALUES ('SOCIO')
INSERT INTO rol_socio (rol_socio) VALUES ('USUARIO')


CREATE TABLE ruta 
    (
     id_ruta INTEGER NOT NULL IDENTITY(1,1), 
     ruta INTEGER NOT NULL , 
     descripcion VARCHAR (150) 
    )
GO

ALTER TABLE ruta ADD CONSTRAINT ruta_PK PRIMARY KEY CLUSTERED (id_ruta)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE socio 
    (
     id_socio INTEGER NOT NULL IDENTITY(1,1), 
     nombre_socio VARCHAR (255) NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL , 
     rol_socio_id_rol_socio INTEGER NOT NULL , 
     ubicacion INTEGER , 
     medidor_id_medidor INTEGER NOT NULL , 
     num_casa INTEGER , 
     num_ocupantes INTEGER , 
     tipo_instalacion VARCHAR (255) , 
     dim_instalacion VARCHAR (255) , 
     actividad VARCHAR (255) NOT NULL , 
     categoria VARCHAR (255) NOT NULL , 
     fecha_registro DATE NOT NULL , 
     ruta_id_ruta INTEGER NOT NULL ,
     codigo_fijo INTEGER NOT NULL 
    )
GO

ALTER TABLE socio ADD CONSTRAINT socio_PK PRIMARY KEY CLUSTERED (id_socio)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE tarifa 
    (
     id_tarifa INTEGER NOT NULL IDENTITY(1,1), 
     consumo_minimo_m3 INTEGER , 
     monto_minimo DECIMAL (30,3) NOT NULL , 
     precio_m3 INTEGER NOT NULL , 
     rol_socio_id_rol_socio INTEGER NOT NULL 
    )
GO

ALTER TABLE tarifa ADD CONSTRAINT tarifa_PK PRIMARY KEY CLUSTERED (id_tarifa)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE tipo_cargo 
    (
     id_tipo INTEGER NOT NULL IDENTITY(1,1), 
     nombre VARCHAR (150) NOT NULL , 
     monto DECIMAL (30,3) NOT NULL , 
     estado BIT NOT NULL 
    )
GO

ALTER TABLE tipo_cargo ADD CONSTRAINT tipo_cargo_PK PRIMARY KEY CLUSTERED (id_tipo)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE usuario_admin 
    (
     id_usuario_admin INTEGER NOT NULL IDENTITY(1,1), 
     nombre VARCHAR (255) NOT NULL , 
     apellido VARCHAR (255) NOT NULL , 
     usuario VARCHAR (255) NOT NULL , 
     contraseña VARCHAR (550) NOT NULL , 
     estado BIT NOT NULL , 
     fecha_creacion DATE NOT NULL , 
     rol_id_rol INTEGER NOT NULL 
    )
GO

ALTER TABLE usuario_admin ADD CONSTRAINT usuario_admin_PK PRIMARY KEY CLUSTERED (id_usuario_admin)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_caja_FK FOREIGN KEY 
    ( 
     caja_id_caja
    ) 
    REFERENCES caja 
    ( 
     id_caja 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_cargo_extra_FK FOREIGN KEY 
    ( 
     cargo_extra_id_carga_extra
    ) 
    REFERENCES cargo_extra 
    ( 
     id_carga_extra 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_credito_inscripcion_FK FOREIGN KEY 
    ( 
     credito_inscripcion_id_credito
    ) 
    REFERENCES credito_inscripcion 
    ( 
     id_credito 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_estado_FK FOREIGN KEY 
    ( 
     estado_id_estado
    ) 
    REFERENCES estado 
    ( 
     id_estado 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_lectura_FK FOREIGN KEY 
    ( 
     lectura_id_lectura
    ) 
    REFERENCES lectura 
    ( 
     id_lectura 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_periodo_FK FOREIGN KEY 
    ( 
     periodo_id_periodo
    ) 
    REFERENCES periodo 
    ( 
     id_periodo 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE aviso 
    ADD CONSTRAINT aviso_socio_FK FOREIGN KEY 
    ( 
     socio_id_socio
    ) 
    REFERENCES socio 
    ( 
     id_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE bitacora 
    ADD CONSTRAINT bitacora_usuario_admin_FK FOREIGN KEY 
    ( 
     usuario_admin_id_usuario_admin
    ) 
    REFERENCES usuario_admin 
    ( 
     id_usuario_admin 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE caja 
    ADD CONSTRAINT caja_usuario_admin_FK FOREIGN KEY 
    ( 
     usuario_admin_id_usuario_admin
    ) 
    REFERENCES usuario_admin 
    ( 
     id_usuario_admin 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE cargo_extra 
    ADD CONSTRAINT cargo_extra_periodo_FK FOREIGN KEY 
    ( 
     periodo_id_periodo
    ) 
    REFERENCES periodo 
    ( 
     id_periodo 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE cargo_extra 
    ADD CONSTRAINT cargo_extra_socio_FK FOREIGN KEY 
    ( 
     socio_id_socio
    ) 
    REFERENCES socio 
    ( 
     id_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE cargo_extra 
    ADD CONSTRAINT cargo_extra_tipo_cargo_FK FOREIGN KEY 
    ( 
     tipo_cargo_id_tipo
    ) 
    REFERENCES tipo_cargo 
    ( 
     id_tipo 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE cliente 
    ADD CONSTRAINT cliente_rol_FK FOREIGN KEY 
    ( 
     rol_id_rol
    ) 
    REFERENCES rol 
    ( 
     id_rol 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE credito_inscripcion 
    ADD CONSTRAINT credito_inscripcion_periodo_FK FOREIGN KEY 
    ( 
     periodo_id_periodo
    ) 
    REFERENCES periodo 
    ( 
     id_periodo 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE credito_inscripcion 
    ADD CONSTRAINT credito_inscripcion_socio_FK FOREIGN KEY 
    ( 
     socio_id_socio
    ) 
    REFERENCES socio 
    ( 
     id_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE cuenta_socio 
    ADD CONSTRAINT cuenta_socio_socio_FK FOREIGN KEY 
    ( 
     socio_id_socio
    ) 
    REFERENCES socio 
    ( 
     id_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE lectura 
    ADD CONSTRAINT lectura_cliente_FK FOREIGN KEY 
    ( 
     cliente_id_cliente
    ) 
    REFERENCES cliente 
    ( 
     id_cliente 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE lectura 
    ADD CONSTRAINT lectura_medidor_FK FOREIGN KEY 
    ( 
     medidor_id_medidor
    ) 
    REFERENCES medidor 
    ( 
     id_medidor 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE lectura 
    ADD CONSTRAINT lectura_periodo_FK FOREIGN KEY 
    ( 
     periodo_id_periodo
    ) 
    REFERENCES periodo 
    ( 
     id_periodo 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE lectura 
    ADD CONSTRAINT lectura_ruta_FK FOREIGN KEY 
    ( 
     ruta_id_ruta
    ) 
    REFERENCES ruta 
    ( 
     id_ruta 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE lectura 
    ADD CONSTRAINT lectura_usuario_admin_FK FOREIGN KEY 
    ( 
     usuario_admin_id_usuario_admin
    ) 
    REFERENCES usuario_admin 
    ( 
     id_usuario_admin 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE notificacion_socio 
    ADD CONSTRAINT notificacion_socio_notificacion_FK FOREIGN KEY 
    ( 
     notificacion_id_notificacion
    ) 
    REFERENCES notificacion 
    ( 
     id_notificacion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE notificacion_socio 
    ADD CONSTRAINT notificacion_socio_socio_FK FOREIGN KEY 
    ( 
     socio_id_socio
    ) 
    REFERENCES socio 
    ( 
     id_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE pago 
    ADD CONSTRAINT pago_aviso_FK FOREIGN KEY 
    ( 
     aviso_id_aviso
    ) 
    REFERENCES aviso 
    ( 
     id_aviso 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE pago 
    ADD CONSTRAINT pago_metodo_pago_FK FOREIGN KEY 
    ( 
     metodo_pago_id_metodo_pago
    ) 
    REFERENCES metodo_pago 
    ( 
     id_metodo_pago 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE rol_permiso 
    ADD CONSTRAINT rol_permiso_permiso_FK FOREIGN KEY 
    ( 
     permiso_id_permiso
    ) 
    REFERENCES permiso 
    ( 
     id_permiso 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE rol_permiso 
    ADD CONSTRAINT rol_permiso_rol_FK FOREIGN KEY 
    ( 
     rol_id_rol
    ) 
    REFERENCES rol 
    ( 
     id_rol 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE socio 
    ADD CONSTRAINT socio_cliente_FK FOREIGN KEY 
    ( 
     cliente_id_cliente
    ) 
    REFERENCES cliente 
    ( 
     id_cliente 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE socio 
    ADD CONSTRAINT socio_medidor_FK FOREIGN KEY 
    ( 
     medidor_id_medidor
    ) 
    REFERENCES medidor 
    ( 
     id_medidor 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE socio 
    ADD CONSTRAINT socio_rol_socio_FK FOREIGN KEY 
    ( 
     rol_socio_id_rol_socio
    ) 
    REFERENCES rol_socio 
    ( 
     id_rol_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE socio 
    ADD CONSTRAINT socio_ruta_FK FOREIGN KEY 
    ( 
     ruta_id_ruta
    ) 
    REFERENCES ruta 
    ( 
     id_ruta 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE tarifa 
    ADD CONSTRAINT tarifa_rol_socio_FK FOREIGN KEY 
    ( 
     rol_socio_id_rol_socio
    ) 
    REFERENCES rol_socio 
    ( 
     id_rol_socio 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE usuario_admin 
    ADD CONSTRAINT usuario_admin_rol_FK FOREIGN KEY 
    ( 
     rol_id_rol
    ) 
    REFERENCES rol 
    ( 
     id_rol 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            24
-- CREATE INDEX                             0
-- ALTER TABLE                             57
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE DATABASE                          0
-- CREATE DEFAULT                           0
-- CREATE INDEX ON VIEW                     0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE ROLE                              0
-- CREATE RULE                              0
-- CREATE SCHEMA                            0
-- CREATE SEQUENCE                          0
-- CREATE PARTITION FUNCTION                0
-- CREATE PARTITION SCHEME                  0
-- 
-- DROP DATABASE                            0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0


SET IDENTITY_INSERT [dbo].[bitacora] ON 
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (1, N'Inicio de sesión exitoso', CAST(N'2026-04-30' AS Date), CAST(N'2026-04-30T00:06:34.700' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (2, N'Inicio de sesión exitoso', CAST(N'2026-04-30' AS Date), CAST(N'2026-04-30T00:13:32.863' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (3, N'Inicio de sesión exitoso', CAST(N'2026-04-30' AS Date), CAST(N'2026-04-30T00:14:25.500' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (4, N'Inicio de sesión exitoso', CAST(N'2026-04-30' AS Date), CAST(N'2026-04-30T16:26:04.020' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (5, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:09:25.177' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (6, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:11:35.420' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (7, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:11:48.050' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (8, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:27:08.203' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (9, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:27:21.573' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (10, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:28:21.250' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (11, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:29:22.370' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (12, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:30:04.133' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (13, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:30:11.353' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (14, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:30:32.167' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (15, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:33:12.910' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (16, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:37:10.730' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (17, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:37:41.880' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (18, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:44:09.570' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (19, N'Inicio de sesión exitoso', CAST(N'2026-05-06' AS Date), CAST(N'2026-05-06T23:49:14.033' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (20, N'Inicio de sesión exitoso', CAST(N'2026-05-07' AS Date), CAST(N'2026-05-07T00:05:02.807' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (21, N'Inicio de sesión exitoso', CAST(N'2026-05-07' AS Date), CAST(N'2026-05-07T00:05:31.903' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (22, N'Inicio de sesión exitoso', CAST(N'2026-05-07' AS Date), CAST(N'2026-05-07T00:07:39.213' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (23, N'Inicio de sesión exitoso', CAST(N'2026-05-07' AS Date), CAST(N'2026-05-07T00:07:55.293' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (24, N'Inicio de sesión exitoso', CAST(N'2026-05-08' AS Date), CAST(N'2026-05-08T22:25:58.143' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (25, N'Inicio de sesión exitoso', CAST(N'2026-05-08' AS Date), CAST(N'2026-05-08T22:26:17.507' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (26, N'Inicio de sesión exitoso', CAST(N'2026-05-08' AS Date), CAST(N'2026-05-08T22:36:31.850' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (27, N'Inicio de sesión exitoso', CAST(N'2026-05-08' AS Date), CAST(N'2026-05-08T22:36:46.810' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (28, N'Inicio de sesión exitoso', CAST(N'2026-05-08' AS Date), CAST(N'2026-05-08T23:33:11.977' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (29, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T00:17:21.073' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (30, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T00:26:14.160' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (31, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T09:02:33.540' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (32, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:24:27.380' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (33, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:27:26.263' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (34, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:27:35.420' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (35, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:28:00.560' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (36, N'Edición del usuario: admin', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:28:20.947' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (37, N'Edición del usuario: admin', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:28:27.483' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (38, N'Edición del usuario: cajero', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:29:17.623' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (39, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:40:13.147' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (40, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:41:37.317' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (41, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:42:04.890' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (42, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:59:04.640' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (43, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T15:59:22.673' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (44, N'Actualización de permisos del rol ID: 1', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:01:07.917' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (45, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:01:27.650' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (46, N'Actualización de permisos del rol ID: 1', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:01:48.020' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (47, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:02:12.503' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (48, N'Actualización de permisos del rol ID: 3', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:02:28.997' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (49, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:02:33.523' AS DateTime), 2)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (50, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:02:51.733' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (51, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:33:27.710' AS DateTime), 1)
GO
INSERT [dbo].[bitacora] ([id_bitacora], [accion], [fecha], [hora], [usuario_admin_id_usuario_admin]) VALUES (52, N'Inicio de sesión exitoso', CAST(N'2026-05-09' AS Date), CAST(N'2026-05-09T16:33:36.167' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[bitacora] OFF
GO
SET IDENTITY_INSERT [dbo].[permiso] ON 
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (1, N'Gestionar Usuarios', N'Gestion de Usuarios')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (2, N'Gestionar Cliente', N'Gestion de cliente')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (3, N'Gestionar Avisos', N'Gestion de avisos')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (4, N'Gestionar Caja', N'Gestion de caja')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (5, N'Gestionar Lecturas', N'Gestion de lecturas')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (6, N'Gestionar Notificaciones', N'Gestion de notificaciones')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (7, N'Gestionar Rol', N'Gestion de rol')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (8, N'Gestionar Tarifa', N'Gestion de tarifa')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (9, N'Crear Rol', N'Registrar nuevos roles')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (10, N'Editar Rol', N'Modificar roles existentes')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (11, N'Desactivar Rol', N'Desactivar roles')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (12, N'Crear Usuario', N'Registrar nuevos usuarios')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (13, N'Editar Usuario', N'Modificar usuarios')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (14, N'Desactivar Usuario', N'Desactivar usuarios')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (15, N'Gestionar Permiso', N'Editar los permisos de un rol')
GO
INSERT [dbo].[permiso] ([id_permiso], [accion], [descripcion]) VALUES (16, N'Visualizar Bitacora', N'Ver la bitácora de acciones')
GO
SET IDENTITY_INSERT [dbo].[permiso] OFF
GO
SET IDENTITY_INSERT [dbo].[rol] ON 
GO
INSERT [dbo].[rol] ([id_rol], [nombre], [descripcion], [estado]) VALUES (1, N'Super Admin', N'Acceso total al sistema', 1)
GO
INSERT [dbo].[rol] ([id_rol], [nombre], [descripcion], [estado]) VALUES (2, N'Admin', N'Acceso limitado al sistema', 1)
GO
INSERT [dbo].[rol] ([id_rol], [nombre], [descripcion], [estado]) VALUES (3, N'Cajero', N'Acceso solo a caja, cliente y avisos', 1)
GO
SET IDENTITY_INSERT [dbo].[rol] OFF
GO
SET IDENTITY_INSERT [dbo].[rol_permiso] ON 
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (1, 1, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (2, 2, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (3, 3, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (4, 4, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (5, 5, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (6, 6, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (7, 7, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (8, 8, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (9, 2, 2)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (10, 3, 2)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (11, 4, 2)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (12, 5, 2)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (13, 6, 2)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (14, 2, 3)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (15, 3, 3)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (16, 4, 3)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (18, 9, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (19, 10, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (20, 11, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (21, 12, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (23, 14, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (24, 15, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (25, 16, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (26, 13, 1)
GO
INSERT [dbo].[rol_permiso] ([id_rol_permiso], [permiso_id_permiso], [rol_id_rol]) VALUES (27, 7, 3)
GO
SET IDENTITY_INSERT [dbo].[rol_permiso] OFF
GO
SET IDENTITY_INSERT [dbo].[usuario_admin] ON 
GO
INSERT [dbo].[usuario_admin] ([id_usuario_admin], [nombre], [apellido], [usuario], [contraseña], [estado], [fecha_creacion], [rol_id_rol]) VALUES (1, N'Admin', N'Principal', N'admin', N'EF797C8118F02DFB649607DD5D3F8C7623048C9C063D532CC95C5ED7A898A64F', 1, CAST(N'2026-04-29' AS Date), 1)
GO
INSERT [dbo].[usuario_admin] ([id_usuario_admin], [nombre], [apellido], [usuario], [contraseña], [estado], [fecha_creacion], [rol_id_rol]) VALUES (2, N'Cajero', N'Principal2', N'cajero', N'EF797C8118F02DFB649607DD5D3F8C7623048C9C063D532CC95C5ED7A898A64F', 1, CAST(N'2026-05-06' AS Date), 3)
GO
SET IDENTITY_INSERT [dbo].[usuario_admin] OFF
GO