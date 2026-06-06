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
go
--listar roles_socio sp
create procedure [dbo].[sp_listar_roles_socio]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [id_rol_socio]
          ,[rol_socio]
      FROM [dbo].[rol_socio]
END