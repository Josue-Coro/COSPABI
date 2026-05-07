--CREATE DATABASE COSPABIRL

-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2026-04-28 22:37:35 BOT
--   sitio:      SQL Server 2012
--   tipo:      SQL Server 2012



CREATE TABLE aviso 
    (
     id_aviso INTEGER NOT NULL IDENTITY(1,1), 
     periodo DATE NOT NULL , 
     fecha_emision DATE NOT NULL , 
     fecha_vencimiento DATE NOT NULL , 
     total_consumo DECIMAL (30,2) NOT NULL , 
     total_aviso DECIMAL (30,2) NOT NULL , 
     estado VARCHAR (50) NOT NULL , 
     deuda_actual DECIMAL (30,2) NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL , 
     lectura_id_lectura INTEGER , 
     tarifa_id_tarifa INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL , 
     cargo_extra_id_carga_extra INTEGER , 
     credito_inscripcion_id_credito INTEGER , 
     estado_id_estado INTEGER NOT NULL , 
     caja_id_caja INTEGER , 
     id_lectura INTEGER 
    )
GO

ALTER TABLE aviso ADD CONSTRAINT factura_PK PRIMARY KEY CLUSTERED (id_aviso)
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
     cliente_id_cliente INTEGER NOT NULL , 
     tipo_cargo_id_tipo INTEGER NOT NULL , 
     factura_id_factura INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL 
    )
GO

ALTER TABLE cargo_extra ADD CONSTRAINT cargo_extra_PK PRIMARY KEY CLUSTERED (id_carga_extra)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE categoria_tarifa 
    (
     id_categoria_tarifa INTEGER NOT NULL IDENTITY(1,1), 
     descripcion VARCHAR (150) NOT NULL 
    )
GO

ALTER TABLE categoria_tarifa ADD CONSTRAINT categoria_PK PRIMARY KEY CLUSTERED (id_categoria_tarifa)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE cliente 
    (
     id_cliente INTEGER NOT NULL IDENTITY(1,1), 
     codigo_fijo VARCHAR (20) NOT NULL , 
     codigo_ubicacion VARCHAR (20) NOT NULL , 
     nombre_completo VARCHAR (250) NOT NULL , 
     ci VARCHAR (50) NOT NULL , 
     direccion VARCHAR (255) NOT NULL , 
     actividad VARCHAR (150) NOT NULL , 
     fecha_registro DATE NOT NULL , 
     estado BIT NOT NULL , 
     rol_id_rol INTEGER NOT NULL , 
     rol_cliente_id_rol_cliente INTEGER NOT NULL , 
     categoria VARCHAR (150) NOT NULL , 
     ruta_id_ruta INTEGER NOT NULL , 
     medidor_id_medidor INTEGER NOT NULL 
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
     saldo_pendiente DECIMAL (10,2) NOT NULL , 
     numero_cuotas INTEGER NOT NULL , 
     fecha_registro DATE NOT NULL , 
     estado VARCHAR (50) NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL , 
     cliente_id_cliente2 INTEGER NOT NULL , 
     num_cuota INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL 
    )
GO

ALTER TABLE credito_inscripcion ADD CONSTRAINT inscripcion_PK PRIMARY KEY CLUSTERED (id_credito)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE cuenta_cliente 
    (
     id_cuenta INTEGER NOT NULL IDENTITY(1,1) , 
     usuario VARCHAR (150) NOT NULL , 
     contraseña VARCHAR (500) NOT NULL , 
     ultimo_acceso DATETIME NOT NULL , 
     estado BIT NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL 
    )
GO

ALTER TABLE cuenta_cliente ADD CONSTRAINT cuenta_cliente_PK PRIMARY KEY CLUSTERED (id_cuenta)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE detalle_factura 
    (
     id_detalle INTEGER NOT NULL IDENTITY(1,1), 
     concepto VARCHAR (500) NOT NULL , 
     importe DECIMAL (30,2) NOT NULL , 
     monto_unitario DECIMAL (30,2) NOT NULL , 
     sub_total DECIMAL (30,2) NOT NULL , 
     factura_id_factura INTEGER NOT NULL 
    )
GO

ALTER TABLE detalle_factura ADD CONSTRAINT detalle_factura_PK PRIMARY KEY CLUSTERED (id_detalle)
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
     consumo_m3 NUMERIC (30,2) NOT NULL , 
     dias_lectura INTEGER NOT NULL , 
     observacion VARCHAR (255) NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL , 
     usuario_admin_id_usuario_admin INTEGER NOT NULL , 
     lectura_actual INTEGER NOT NULL , 
     medidor_id_medidor INTEGER NOT NULL , 
     periodo_id_periodo INTEGER NOT NULL , 
     consumo_m32 DECIMAL (30,2) NOT NULL 
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
     cliente_id_cliente INTEGER NOT NULL , 
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
     referencia VARCHAR (255) NOT NULL , 
     entidad_pago VARCHAR (150) , 
     fecha_confirmacion DATE , 
     pago_id_pago INTEGER NOT NULL 
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

CREATE TABLE notificacion_cliente 
    (
     id_notificacion_cliente INTEGER NOT NULL IDENTITY(1,1), 
     fecha_lectura DATE NOT NULL , 
     leido BIT NOT NULL , 
     notificacion_id_notificacion INTEGER NOT NULL , 
     cliente_id_cliente INTEGER NOT NULL 
    )
GO

ALTER TABLE notificacion_cliente ADD CONSTRAINT notificacion_cliente_PK PRIMARY KEY CLUSTERED (id_notificacion_cliente)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE pago 
    (
     id_pago INTEGER NOT NULL IDENTITY(1,1), 
     fecha_pago DATE NOT NULL , 
     metodo_pago VARCHAR (50) NOT NULL , 
     monto_pagado DECIMAL (30,2) NOT NULL , 
     numero_recibo INTEGER NOT NULL , 
     cajero VARCHAR (150) NOT NULL , 
     estado BIT NOT NULL , 
     aviso_id_aviso INTEGER NOT NULL , 
     metodo_pago_id_metodo_pago INTEGER NOT NULL 
    )
GO

ALTER TABLE pago ADD CONSTRAINT pago_PK PRIMARY KEY CLUSTERED (id_pago)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE pago_inscripcion 
    (
     id_pago_inscripcion INTEGER NOT NULL IDENTITY(1,1), 
     monto_pagado DECIMAL (10,2) NOT NULL , 
     fecha_pago DATE NOT NULL , 
     numero_recibo INTEGER NOT NULL , 
     inscripcion_id_inscripcion INTEGER NOT NULL , 
     metodo_pago_id_metodo_pago INTEGER NOT NULL , 
     cajero VARCHAR (150) NOT NULL , 
     credito_inscripcion_id_credito INTEGER NOT NULL 
    )
GO

ALTER TABLE pago_inscripcion ADD CONSTRAINT pago_inscripcion_PK PRIMARY KEY CLUSTERED (id_pago_inscripcion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO


ALTER TABLE periodo ADD CONSTRAINT periodo_PK PRIMARY KEY CLUSTERED (id_periodo)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE permiso 
    (
     id_permiso INTEGER NOT NULL IDENTITY(1,1), 
     codigo VARCHAR (150) NOT NULL , 
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
     nombre_rol VARCHAR (150) NOT NULL , 
     descripcion VARCHAR (250) , 
     estado BIT NOT NULL 
    )
GO

ALTER TABLE rol ADD CONSTRAINT rol_PK PRIMARY KEY CLUSTERED (id_rol)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE rol_cliente 
    (
     id_rol_cliente INTEGER NOT NULL IDENTITY(1,1), 
     rol_cliente VARCHAR (150) NOT NULL 
    )
GO

ALTER TABLE rol_cliente ADD CONSTRAINT rol_cliente_PK PRIMARY KEY CLUSTERED (id_rol_cliente)
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

CREATE TABLE ruta 
    (
     id_ruta INTEGER NOT NULL IDENTITY(1,1), 
     ruta INTEGER , 
     usuario_admin_id_usuario_admin INTEGER NOT NULL , 
     descripcion VARCHAR (150) 
    )
GO

ALTER TABLE ruta ADD CONSTRAINT ruta_PK PRIMARY KEY CLUSTERED (id_ruta)
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
     categoria_tarifa_id_categoria_tarifa INTEGER NOT NULL 
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
    ADD CONSTRAINT aviso_cliente_FK FOREIGN KEY 
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
    ADD CONSTRAINT aviso_tarifa_FK FOREIGN KEY 
    ( 
     tarifa_id_tarifa
    ) 
    REFERENCES tarifa 
    ( 
     id_tarifa 
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
    ADD CONSTRAINT cargo_extra_cliente_FK FOREIGN KEY 
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

ALTER TABLE cargo_extra 
    ADD CONSTRAINT cargo_extra_factura_FK FOREIGN KEY 
    ( 
     factura_id_factura
    ) 
    REFERENCES aviso 
    ( 
     id_aviso 
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
    ADD CONSTRAINT cliente_rol_cliente_FK FOREIGN KEY 
    ( 
     rol_cliente_id_rol_cliente
    ) 
    REFERENCES rol_cliente 
    ( 
     id_rol_cliente 
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

ALTER TABLE cliente 
    ADD CONSTRAINT cliente_ruta_FK FOREIGN KEY 
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

ALTER TABLE metodo_pago 
    ADD CONSTRAINT comprobante_pago_pago_FK FOREIGN KEY 
    ( 
     pago_id_pago
    ) 
    REFERENCES pago 
    ( 
     id_pago 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE credito_inscripcion 
    ADD CONSTRAINT credito_inscripcion_cliente_FK FOREIGN KEY 
    ( 
     cliente_id_cliente2
    ) 
    REFERENCES cliente 
    ( 
     id_cliente 
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

ALTER TABLE cuenta_cliente 
    ADD CONSTRAINT cuenta_cliente_cliente_FK FOREIGN KEY 
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

ALTER TABLE detalle_factura 
    ADD CONSTRAINT detalle_factura_factura_FK FOREIGN KEY 
    ( 
     factura_id_factura
    ) 
    REFERENCES aviso 
    ( 
     id_aviso 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE credito_inscripcion 
    ADD CONSTRAINT inscripcion_cliente_FK FOREIGN KEY 
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

ALTER TABLE notificacion_cliente 
    ADD CONSTRAINT notificacion_cliente_cliente_FK FOREIGN KEY 
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

ALTER TABLE notificacion_cliente 
    ADD CONSTRAINT notificacion_cliente_notificacion_FK FOREIGN KEY 
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

ALTER TABLE pago_inscripcion 
    ADD CONSTRAINT pago_inscripcion_credito_inscripcion_FK FOREIGN KEY 
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

ALTER TABLE pago_inscripcion 
    ADD CONSTRAINT pago_inscripcion_inscripcion_FK FOREIGN KEY 
    ( 
     inscripcion_id_inscripcion
    ) 
    REFERENCES credito_inscripcion 
    ( 
     id_credito 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE pago_inscripcion 
    ADD CONSTRAINT pago_inscripcion_metodo_pago_FK FOREIGN KEY 
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

ALTER TABLE ruta 
    ADD CONSTRAINT ruta_usuario_admin_FK FOREIGN KEY 
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

ALTER TABLE tarifa 
    ADD CONSTRAINT tarifa_categoria_tarifa_FK FOREIGN KEY 
    ( 
     categoria_tarifa_id_categoria_tarifa
    ) 
    REFERENCES categoria_tarifa 
    ( 
     id_categoria_tarifa 
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
-- CREATE TABLE                            25
-- CREATE INDEX                             2
-- ALTER TABLE                             63
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
