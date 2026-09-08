USE [COSPABIRL1]
GO
/****** Object:  UserDefinedTableType [dbo].[TVP_IdsPermisos]    Script Date: 7/9/2026 23:07:01 ******/
CREATE TYPE [dbo].[TVP_IdsPermisos] AS TABLE(
	[id_permiso] [int] NOT NULL
)
GO
/****** Object:  Table [dbo].[aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aviso](
	[id_aviso] [int] IDENTITY(1,1) NOT NULL,
	[fecha_emision] [date] NOT NULL,
	[fecha_vencimiento] [date] NOT NULL,
	[total_consumo] [decimal](30, 2) NOT NULL,
	[total_aviso] [decimal](30, 2) NOT NULL,
	[deuda_actual] [decimal](30, 2) NOT NULL,
	[periodo_id_periodo] [int] NOT NULL,
	[estado_id_estado] [int] NOT NULL,
	[lectura_id_lectura] [int] NULL,
	[socio_id_socio] [int] NOT NULL,
 CONSTRAINT [aviso_PK] PRIMARY KEY CLUSTERED 
(
	[id_aviso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[bitacora]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bitacora](
	[id_bitacora] [int] IDENTITY(1,1) NOT NULL,
	[accion] [varchar](255) NOT NULL,
	[fecha] [date] NOT NULL,
	[hora] [datetime] NOT NULL,
	[usuario_admin_id_usuario_admin] [int] NOT NULL,
 CONSTRAINT [bitacora_PK] PRIMARY KEY CLUSTERED 
(
	[id_bitacora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[caja](
	[id_caja] [int] IDENTITY(1,1) NOT NULL,
	[fecha] [date] NOT NULL,
	[hora_apertura] [datetime] NOT NULL,
	[hora_cierre] [datetime] NULL,
	[monto_cobrado] [decimal](30, 3) NULL,
	[usuario_admin_id_usuario_admin] [int] NOT NULL,
	[estado] [bit] NOT NULL,
	[monto_apertura] [decimal](30, 2) NOT NULL,
 CONSTRAINT [caja_PK] PRIMARY KEY CLUSTERED 
(
	[id_caja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cargo_extra]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cargo_extra](
	[id_cargo_extra] [int] IDENTITY(1,1) NOT NULL,
	[monto] [decimal](30, 2) NOT NULL,
	[descripcion] [varchar](150) NOT NULL,
	[fecha_registro] [date] NOT NULL,
	[estado] [varchar](150) NOT NULL,
	[tipo_cargo_id_tipo] [int] NOT NULL,
	[socio_id_socio] [int] NOT NULL,
	[periodo_id_periodo] [int] NOT NULL,
 CONSTRAINT [cargo_extra_PK] PRIMARY KEY CLUSTERED 
(
	[id_cargo_extra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cliente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cliente](
	[id_cliente] [int] IDENTITY(1,1) NOT NULL,
	[genero] [varchar](255) NOT NULL,
	[nombre_completo] [varchar](250) NOT NULL,
	[ci] [varchar](50) NOT NULL,
	[fecha_nacimiento] [date] NOT NULL,
	[fecha_registro] [date] NOT NULL,
	[estado] [bit] NOT NULL,
	[telefono] [int] NULL,
	[email] [varchar](150) NULL,
 CONSTRAINT [cliente_PK] PRIMARY KEY CLUSTERED 
(
	[id_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[credito_inscripcion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[credito_inscripcion](
	[id_credito] [int] IDENTITY(1,1) NOT NULL,
	[monto_pago] [decimal](10, 2) NOT NULL,
	[estado] [varchar](50) NOT NULL,
	[num_cuota] [int] NOT NULL,
	[socio_id_socio] [int] NOT NULL,
	[periodo_id_periodo] [int] NOT NULL,
	[pago_id_pago] [int] NULL,
 CONSTRAINT [credito_inscripcion_PK] PRIMARY KEY CLUSTERED 
(
	[id_credito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cuenta_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cuenta_socio](
	[id_cuenta_socio] [int] IDENTITY(1,1) NOT NULL,
	[usuario] [varchar](150) NOT NULL,
	[contraseña] [varchar](500) NOT NULL,
	[ultimo_acceso] [datetime] NOT NULL,
	[estado] [bit] NOT NULL,
	[socio_id_socio] [int] NOT NULL,
	[intentos_fallidos] [int] NOT NULL,
	[bloqueado_hasta] [datetime] NULL,
 CONSTRAINT [cuenta_socio_PK] PRIMARY KEY CLUSTERED 
(
	[id_cuenta_socio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[estado]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[estado](
	[id_estado] [int] IDENTITY(1,1) NOT NULL,
	[estado] [varchar](150) NOT NULL,
 CONSTRAINT [estado_PK] PRIMARY KEY CLUSTERED 
(
	[id_estado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[lectura]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lectura](
	[id_lectura] [int] IDENTITY(1,1) NOT NULL,
	[fecha_lectura] [date] NOT NULL,
	[lectura_anterior] [int] NOT NULL,
	[lectura_actual] [int] NOT NULL,
	[dias_lectura] [int] NOT NULL,
	[observacion] [varchar](255) NULL,
	[usuario_admin_id_usuario_admin] [int] NOT NULL,
	[medidor_id_medidor] [int] NOT NULL,
	[periodo_id_periodo] [int] NOT NULL,
	[consumo_m3] [decimal](30, 2) NOT NULL,
 CONSTRAINT [lectura_PK] PRIMARY KEY CLUSTERED 
(
	[id_lectura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[medidor]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[medidor](
	[id_medidor] [int] IDENTITY(1,1) NOT NULL,
	[serie] [varchar](150) NOT NULL,
	[numero] [int] NOT NULL,
	[fecha_instalacion] [date] NULL,
 CONSTRAINT [medidor_PK] PRIMARY KEY CLUSTERED 
(
	[id_medidor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[metodo_pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[metodo_pago](
	[id_metodo_pago] [int] IDENTITY(1,1) NOT NULL,
	[metodo] [varchar](150) NOT NULL,
	[referencia] [varchar](255) NULL,
 CONSTRAINT [metodo_pago_PK] PRIMARY KEY CLUSTERED 
(
	[id_metodo_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notificacion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notificacion](
	[id_notificacion] [int] IDENTITY(1,1) NOT NULL,
	[titulo] [varchar](255) NOT NULL,
	[mensaje] [varchar](1000) NOT NULL,
	[tipo] [varchar](255) NOT NULL,
	[fecha_publicacion] [date] NOT NULL,
	[estado] [bit] NOT NULL,
 CONSTRAINT [notificacion_PK] PRIMARY KEY CLUSTERED 
(
	[id_notificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notificacion_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notificacion_socio](
	[id_notificacion_socio] [int] IDENTITY(1,1) NOT NULL,
	[fecha_lectura] [date] NOT NULL,
	[leido] [bit] NOT NULL,
	[notificacion_id_notificacion] [int] NOT NULL,
	[socio_id_socio] [int] NOT NULL,
 CONSTRAINT [notificacion_socio_PK] PRIMARY KEY CLUSTERED 
(
	[id_notificacion_socio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pago](
	[id_pago] [int] IDENTITY(1,1) NOT NULL,
	[fecha_pago] [datetime] NOT NULL,
	[monto_pagado] [decimal](30, 2) NOT NULL,
	[cajero] [varchar](150) NOT NULL,
	[aviso_id_aviso] [int] NULL,
	[metodo_pago_id_metodo_pago] [int] NOT NULL,
	[vuelto] [decimal](30, 3) NULL,
	[caja_id_caja] [int] NULL,
	[identificador_deuda] [varchar](100) NULL,
	[id_transaccion] [varchar](100) NULL,
	[forma_pago] [varchar](60) NULL,
	[codigo_recaudacion] [varchar](50) NULL,
	[url_pasarela] [varchar](500) NULL,
	[qr_url] [varchar](500) NULL,
	[estado_pago] [varchar](30) NOT NULL,
 CONSTRAINT [pago_PK] PRIMARY KEY CLUSTERED 
(
	[id_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[periodo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[periodo](
	[id_periodo] [int] IDENTITY(1,1) NOT NULL,
	[periodo] [varchar](50) NOT NULL,
	[costo_inscripcion] [decimal](10, 2) NULL,
 CONSTRAINT [periodo_PK] PRIMARY KEY CLUSTERED 
(
	[id_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[permiso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[permiso](
	[id_permiso] [int] IDENTITY(1,1) NOT NULL,
	[accion] [varchar](150) NOT NULL,
	[descripcion] [varchar](150) NULL,
	[modulo] [varchar](100) NULL,
 CONSTRAINT [permiso_PK] PRIMARY KEY CLUSTERED 
(
	[id_permiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rol]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rol](
	[id_rol] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](150) NOT NULL,
	[descripcion] [varchar](250) NULL,
	[estado] [bit] NOT NULL,
 CONSTRAINT [rol_PK] PRIMARY KEY CLUSTERED 
(
	[id_rol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rol_permiso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rol_permiso](
	[id_rol_permiso] [int] IDENTITY(1,1) NOT NULL,
	[permiso_id_permiso] [int] NOT NULL,
	[rol_id_rol] [int] NOT NULL,
 CONSTRAINT [rol_permiso_PK] PRIMARY KEY CLUSTERED 
(
	[id_rol_permiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rol_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rol_socio](
	[id_rol_socio] [int] IDENTITY(1,1) NOT NULL,
	[rol_socio] [varchar](150) NOT NULL,
 CONSTRAINT [rol_socio_PK] PRIMARY KEY CLUSTERED 
(
	[id_rol_socio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ruta]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ruta](
	[id_ruta] [int] IDENTITY(1,1) NOT NULL,
	[ruta] [int] NOT NULL,
	[descripcion] [varchar](150) NULL,
 CONSTRAINT [ruta_PK] PRIMARY KEY CLUSTERED 
(
	[id_ruta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[socio](
	[id_socio] [int] IDENTITY(1,1) NOT NULL,
	[nombre_socio] [varchar](255) NOT NULL,
	[cliente_id_cliente] [int] NOT NULL,
	[rol_socio_id_rol_socio] [int] NOT NULL,
	[ubicacion] [int] NULL,
	[medidor_id_medidor] [int] NULL,
	[num_casa] [int] NULL,
	[num_ocupantes] [int] NULL,
	[tipo_instalacion] [varchar](255) NULL,
	[dim_instalacion] [varchar](255) NULL,
	[actividad] [varchar](255) NOT NULL,
	[categoria] [varchar](255) NOT NULL,
	[fecha_registro] [date] NOT NULL,
	[ruta_id_ruta] [int] NOT NULL,
	[codigo_fijo] [int] NOT NULL,
	[estado] [bit] NOT NULL,
 CONSTRAINT [socio_PK] PRIMARY KEY CLUSTERED 
(
	[id_socio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tarifa]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tarifa](
	[id_tarifa] [int] IDENTITY(1,1) NOT NULL,
	[consumo_minimo_m3] [int] NULL,
	[monto_minimo] [decimal](30, 3) NOT NULL,
	[precio_m3] [int] NOT NULL,
	[rol_socio_id_rol_socio] [int] NOT NULL,
 CONSTRAINT [tarifa_PK] PRIMARY KEY CLUSTERED 
(
	[id_tarifa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tipo_cargo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tipo_cargo](
	[id_tipo] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](150) NOT NULL,
	[monto] [decimal](30, 3) NOT NULL,
	[estado] [bit] NOT NULL,
	[automatico] [bit] NOT NULL,
 CONSTRAINT [tipo_cargo_PK] PRIMARY KEY CLUSTERED 
(
	[id_tipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[usuario_admin]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usuario_admin](
	[id_usuario_admin] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](255) NOT NULL,
	[apellido] [varchar](255) NOT NULL,
	[usuario] [varchar](255) NOT NULL,
	[contraseña] [varchar](550) NOT NULL,
	[estado] [bit] NOT NULL,
	[fecha_creacion] [date] NOT NULL,
	[rol_id_rol] [int] NOT NULL,
	[intentos_fallidos] [int] NOT NULL,
	[bloqueado_hasta] [datetime] NULL,
 CONSTRAINT [usuario_admin_PK] PRIMARY KEY CLUSTERED 
(
	[id_usuario_admin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[caja] ADD  CONSTRAINT [DF_caja_monto_apertura]  DEFAULT ((0)) FOR [monto_apertura]
GO
ALTER TABLE [dbo].[cuenta_socio] ADD  CONSTRAINT [DF_cuenta_socio_intentos]  DEFAULT ((0)) FOR [intentos_fallidos]
GO
ALTER TABLE [dbo].[pago] ADD  CONSTRAINT [DF_pago_estado_pago]  DEFAULT ('APROBADO') FOR [estado_pago]
GO
ALTER TABLE [dbo].[socio] ADD  CONSTRAINT [DF_socio_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[tipo_cargo] ADD  CONSTRAINT [DF_tipo_cargo_automatico]  DEFAULT ((0)) FOR [automatico]
GO
ALTER TABLE [dbo].[usuario_admin] ADD  CONSTRAINT [DF_usuario_admin_intentos]  DEFAULT ((0)) FOR [intentos_fallidos]
GO
ALTER TABLE [dbo].[aviso]  WITH CHECK ADD  CONSTRAINT [aviso_estado_FK] FOREIGN KEY([estado_id_estado])
REFERENCES [dbo].[estado] ([id_estado])
GO
ALTER TABLE [dbo].[aviso] CHECK CONSTRAINT [aviso_estado_FK]
GO
ALTER TABLE [dbo].[aviso]  WITH CHECK ADD  CONSTRAINT [aviso_lectura_FK] FOREIGN KEY([lectura_id_lectura])
REFERENCES [dbo].[lectura] ([id_lectura])
GO
ALTER TABLE [dbo].[aviso] CHECK CONSTRAINT [aviso_lectura_FK]
GO
ALTER TABLE [dbo].[aviso]  WITH CHECK ADD  CONSTRAINT [aviso_periodo_FK] FOREIGN KEY([periodo_id_periodo])
REFERENCES [dbo].[periodo] ([id_periodo])
GO
ALTER TABLE [dbo].[aviso] CHECK CONSTRAINT [aviso_periodo_FK]
GO
ALTER TABLE [dbo].[aviso]  WITH CHECK ADD  CONSTRAINT [aviso_socio_FK] FOREIGN KEY([socio_id_socio])
REFERENCES [dbo].[socio] ([id_socio])
GO
ALTER TABLE [dbo].[aviso] CHECK CONSTRAINT [aviso_socio_FK]
GO
ALTER TABLE [dbo].[bitacora]  WITH CHECK ADD  CONSTRAINT [bitacora_usuario_admin_FK] FOREIGN KEY([usuario_admin_id_usuario_admin])
REFERENCES [dbo].[usuario_admin] ([id_usuario_admin])
GO
ALTER TABLE [dbo].[bitacora] CHECK CONSTRAINT [bitacora_usuario_admin_FK]
GO
ALTER TABLE [dbo].[caja]  WITH CHECK ADD  CONSTRAINT [caja_usuario_admin_FK] FOREIGN KEY([usuario_admin_id_usuario_admin])
REFERENCES [dbo].[usuario_admin] ([id_usuario_admin])
GO
ALTER TABLE [dbo].[caja] CHECK CONSTRAINT [caja_usuario_admin_FK]
GO
ALTER TABLE [dbo].[cargo_extra]  WITH CHECK ADD  CONSTRAINT [cargo_extra_periodo_FK] FOREIGN KEY([periodo_id_periodo])
REFERENCES [dbo].[periodo] ([id_periodo])
GO
ALTER TABLE [dbo].[cargo_extra] CHECK CONSTRAINT [cargo_extra_periodo_FK]
GO
ALTER TABLE [dbo].[cargo_extra]  WITH CHECK ADD  CONSTRAINT [cargo_extra_socio_FK] FOREIGN KEY([socio_id_socio])
REFERENCES [dbo].[socio] ([id_socio])
GO
ALTER TABLE [dbo].[cargo_extra] CHECK CONSTRAINT [cargo_extra_socio_FK]
GO
ALTER TABLE [dbo].[cargo_extra]  WITH CHECK ADD  CONSTRAINT [cargo_extra_tipo_cargo_FK] FOREIGN KEY([tipo_cargo_id_tipo])
REFERENCES [dbo].[tipo_cargo] ([id_tipo])
GO
ALTER TABLE [dbo].[cargo_extra] CHECK CONSTRAINT [cargo_extra_tipo_cargo_FK]
GO
ALTER TABLE [dbo].[credito_inscripcion]  WITH CHECK ADD  CONSTRAINT [credito_inscripcion_periodo_FK] FOREIGN KEY([periodo_id_periodo])
REFERENCES [dbo].[periodo] ([id_periodo])
GO
ALTER TABLE [dbo].[credito_inscripcion] CHECK CONSTRAINT [credito_inscripcion_periodo_FK]
GO
ALTER TABLE [dbo].[credito_inscripcion]  WITH CHECK ADD  CONSTRAINT [credito_inscripcion_socio_FK] FOREIGN KEY([socio_id_socio])
REFERENCES [dbo].[socio] ([id_socio])
GO
ALTER TABLE [dbo].[credito_inscripcion] CHECK CONSTRAINT [credito_inscripcion_socio_FK]
GO
ALTER TABLE [dbo].[credito_inscripcion]  WITH CHECK ADD  CONSTRAINT [FK_credito_inscripcion_pago] FOREIGN KEY([pago_id_pago])
REFERENCES [dbo].[pago] ([id_pago])
GO
ALTER TABLE [dbo].[credito_inscripcion] CHECK CONSTRAINT [FK_credito_inscripcion_pago]
GO
ALTER TABLE [dbo].[cuenta_socio]  WITH CHECK ADD  CONSTRAINT [cuenta_socio_socio_FK] FOREIGN KEY([socio_id_socio])
REFERENCES [dbo].[socio] ([id_socio])
GO
ALTER TABLE [dbo].[cuenta_socio] CHECK CONSTRAINT [cuenta_socio_socio_FK]
GO
ALTER TABLE [dbo].[lectura]  WITH CHECK ADD  CONSTRAINT [lectura_medidor_FK] FOREIGN KEY([medidor_id_medidor])
REFERENCES [dbo].[medidor] ([id_medidor])
GO
ALTER TABLE [dbo].[lectura] CHECK CONSTRAINT [lectura_medidor_FK]
GO
ALTER TABLE [dbo].[lectura]  WITH CHECK ADD  CONSTRAINT [lectura_periodo_FK] FOREIGN KEY([periodo_id_periodo])
REFERENCES [dbo].[periodo] ([id_periodo])
GO
ALTER TABLE [dbo].[lectura] CHECK CONSTRAINT [lectura_periodo_FK]
GO
ALTER TABLE [dbo].[lectura]  WITH CHECK ADD  CONSTRAINT [lectura_usuario_admin_FK] FOREIGN KEY([usuario_admin_id_usuario_admin])
REFERENCES [dbo].[usuario_admin] ([id_usuario_admin])
GO
ALTER TABLE [dbo].[lectura] CHECK CONSTRAINT [lectura_usuario_admin_FK]
GO
ALTER TABLE [dbo].[notificacion_socio]  WITH CHECK ADD  CONSTRAINT [notificacion_socio_notificacion_FK] FOREIGN KEY([notificacion_id_notificacion])
REFERENCES [dbo].[notificacion] ([id_notificacion])
GO
ALTER TABLE [dbo].[notificacion_socio] CHECK CONSTRAINT [notificacion_socio_notificacion_FK]
GO
ALTER TABLE [dbo].[notificacion_socio]  WITH CHECK ADD  CONSTRAINT [notificacion_socio_socio_FK] FOREIGN KEY([socio_id_socio])
REFERENCES [dbo].[socio] ([id_socio])
GO
ALTER TABLE [dbo].[notificacion_socio] CHECK CONSTRAINT [notificacion_socio_socio_FK]
GO
ALTER TABLE [dbo].[pago]  WITH CHECK ADD  CONSTRAINT [pago_aviso_FK] FOREIGN KEY([aviso_id_aviso])
REFERENCES [dbo].[aviso] ([id_aviso])
GO
ALTER TABLE [dbo].[pago] CHECK CONSTRAINT [pago_aviso_FK]
GO
ALTER TABLE [dbo].[pago]  WITH CHECK ADD  CONSTRAINT [pago_caja_FK] FOREIGN KEY([caja_id_caja])
REFERENCES [dbo].[caja] ([id_caja])
GO
ALTER TABLE [dbo].[pago] CHECK CONSTRAINT [pago_caja_FK]
GO
ALTER TABLE [dbo].[pago]  WITH CHECK ADD  CONSTRAINT [pago_metodo_pago_FK] FOREIGN KEY([metodo_pago_id_metodo_pago])
REFERENCES [dbo].[metodo_pago] ([id_metodo_pago])
GO
ALTER TABLE [dbo].[pago] CHECK CONSTRAINT [pago_metodo_pago_FK]
GO
ALTER TABLE [dbo].[rol_permiso]  WITH CHECK ADD  CONSTRAINT [rol_permiso_permiso_FK] FOREIGN KEY([permiso_id_permiso])
REFERENCES [dbo].[permiso] ([id_permiso])
GO
ALTER TABLE [dbo].[rol_permiso] CHECK CONSTRAINT [rol_permiso_permiso_FK]
GO
ALTER TABLE [dbo].[rol_permiso]  WITH CHECK ADD  CONSTRAINT [rol_permiso_rol_FK] FOREIGN KEY([rol_id_rol])
REFERENCES [dbo].[rol] ([id_rol])
GO
ALTER TABLE [dbo].[rol_permiso] CHECK CONSTRAINT [rol_permiso_rol_FK]
GO
ALTER TABLE [dbo].[socio]  WITH CHECK ADD  CONSTRAINT [socio_cliente_FK] FOREIGN KEY([cliente_id_cliente])
REFERENCES [dbo].[cliente] ([id_cliente])
GO
ALTER TABLE [dbo].[socio] CHECK CONSTRAINT [socio_cliente_FK]
GO
ALTER TABLE [dbo].[socio]  WITH CHECK ADD  CONSTRAINT [socio_medidor_FK] FOREIGN KEY([medidor_id_medidor])
REFERENCES [dbo].[medidor] ([id_medidor])
GO
ALTER TABLE [dbo].[socio] CHECK CONSTRAINT [socio_medidor_FK]
GO
ALTER TABLE [dbo].[socio]  WITH CHECK ADD  CONSTRAINT [socio_rol_socio_FK] FOREIGN KEY([rol_socio_id_rol_socio])
REFERENCES [dbo].[rol_socio] ([id_rol_socio])
GO
ALTER TABLE [dbo].[socio] CHECK CONSTRAINT [socio_rol_socio_FK]
GO
ALTER TABLE [dbo].[socio]  WITH CHECK ADD  CONSTRAINT [socio_ruta_FK] FOREIGN KEY([ruta_id_ruta])
REFERENCES [dbo].[ruta] ([id_ruta])
GO
ALTER TABLE [dbo].[socio] CHECK CONSTRAINT [socio_ruta_FK]
GO
ALTER TABLE [dbo].[tarifa]  WITH CHECK ADD  CONSTRAINT [tarifa_rol_socio_FK] FOREIGN KEY([rol_socio_id_rol_socio])
REFERENCES [dbo].[rol_socio] ([id_rol_socio])
GO
ALTER TABLE [dbo].[tarifa] CHECK CONSTRAINT [tarifa_rol_socio_FK]
GO
ALTER TABLE [dbo].[usuario_admin]  WITH CHECK ADD  CONSTRAINT [usuario_admin_rol_FK] FOREIGN KEY([rol_id_rol])
REFERENCES [dbo].[rol] ([id_rol])
GO
ALTER TABLE [dbo].[usuario_admin] CHECK CONSTRAINT [usuario_admin_rol_FK]
GO
/****** Object:  StoredProcedure [dbo].[sp_abrir_caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- Modulo CAJA  (estado: 1 = ABIERTA, 0 = CERRADA)
-- Una caja ABIERTA por cajero (respaldado por indice caja_cajero_abierta_UX).
-- monto_cobrado se calcula al cerrar = SUM(pagos APROBADO de la caja).
-- =============================================================================

-- 1. Abrir caja --------------------------------------------------------------
CREATE   PROCEDURE [dbo].[sp_abrir_caja]
    @id_usuario     INT,
    @monto_apertura DECIMAL(30,2),
    @Resultado      INT           OUTPUT,   -- id_caja nuevo (>0) | 0 error
    @Mensaje        NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM caja
                   WHERE usuario_admin_id_usuario_admin = @id_usuario AND estado = 1)
        BEGIN
            SET @Mensaje = 'Ya tiene una caja abierta. Ciérrela antes de abrir otra.';
            RETURN;
        END
        IF @monto_apertura < 0
        BEGIN
            SET @Mensaje = 'El monto de apertura no puede ser negativo.';
            RETURN;
        END

        INSERT INTO caja (fecha, hora_apertura, hora_cierre, monto_apertura,
                          monto_cobrado, usuario_admin_id_usuario_admin, estado)
        VALUES (CAST(GETDATE() AS DATE), GETDATE(), NULL, @monto_apertura,
                0, @id_usuario, 1);

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Caja abierta correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_anular_aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 5. sp_anular_aviso
--    Marca un aviso como ANULADO (no lo elimina).
--    Solo aplica si el aviso no esta PAGADO.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_anular_aviso]
    @id_aviso  INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        DECLARE @estado_actual VARCHAR(150);
        SELECT @estado_actual = e.estado 
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @estado_actual IS NULL
        BEGIN
            SET @Mensaje = 'Aviso no encontrado.';
            RETURN;
        END

        IF @estado_actual = 'PAGADO'
        BEGIN
            SET @Mensaje = 'No se puede anular un aviso PAGADO.';
            RETURN;
        END

        IF @estado_actual = 'ANULADO'
        BEGIN
            SET @Mensaje = 'El aviso ya estaba anulado.';
            RETURN;
        END

        DECLARE @id_estado_anulado INT;
        SELECT @id_estado_anulado = id_estado FROM estado WHERE estado = 'ANULADO';

        UPDATE aviso
        SET estado_id_estado = @id_estado_anulado
        WHERE id_aviso = @id_aviso;

        SET @Resultado = 1;
        SET @Mensaje   = 'Aviso anulado correctamente. Ya puede registrar cargos y regenerar el aviso.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_anular_cargo_extra]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. sp_anular_cargo_extra
-- =============================================
CREATE   PROCEDURE [dbo].[sp_anular_cargo_extra]
    @id_cargo_extra INT,
    @Resultado      INT          OUTPUT,
    @Mensaje        VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM cargo_extra WHERE id_cargo_extra = @id_cargo_extra)
        BEGIN
            SET @Mensaje = 'El cargo no existe.';
            RETURN;
        END

        -- El cargo está aplicado si existe un aviso no anulado para el mismo socio y periodo
        IF EXISTS (
            SELECT 1 FROM aviso a
            INNER JOIN cargo_extra ce ON ce.socio_id_socio = a.socio_id_socio AND ce.periodo_id_periodo = a.periodo_id_periodo
            WHERE ce.id_cargo_extra = @id_cargo_extra
              AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
        )
        BEGIN
            SET @Mensaje = 'El cargo ya fue aplicado a un aviso y no puede anularse.';
            RETURN;
        END

        DECLARE @estadoActual VARCHAR(150);
        SELECT @estadoActual = estado FROM cargo_extra WHERE id_cargo_extra = @id_cargo_extra;

        IF @estadoActual != 'PENDIENTE'
        BEGIN
            SET @Mensaje = 'Solo se pueden anular cargos en estado PENDIENTE.';
            RETURN;
        END

        UPDATE cargo_extra SET estado = 'ANULADO' WHERE id_cargo_extra = @id_cargo_extra;

        SET @Resultado = 1;
        SET @Mensaje   = 'Cargo anulado correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_arqueo_caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Arqueo de una caja -------------------------------------------------------
--    Result set 1: cabecera (fondo, total, efectivo cobrado)
--    Result set 2: total por metodo de pago
CREATE   PROCEDURE [dbo].[sp_arqueo_caja]
    @id_caja       INT,
    @id_usuario    INT,           -- cajero de la sesion (dueno esperado)
    @es_superadmin BIT = 0        -- SUPERADMIN puede arquear cualquier caja
AS
BEGIN
    SET NOCOUNT ON;

    -- Guarda de propiedad: sin ella el arqueo (y el reporte impreso que lo usa)
    -- exponia los montos y el detalle de pagos de la caja de otro cajero.
    IF @es_superadmin = 0
       AND NOT EXISTS (SELECT 1 FROM caja
                       WHERE id_caja = @id_caja
                         AND usuario_admin_id_usuario_admin = @id_usuario)
    BEGIN
        SELECT TOP 0 c.id_caja, c.fecha, c.hora_apertura, c.hora_cierre, c.estado,
                     c.monto_apertura,
                     CAST(0 AS DECIMAL(30,2)) AS total_cobrado,
                     CAST(0 AS DECIMAL(30,2)) AS efectivo_cobrado
        FROM caja c;
        SELECT TOP 0 mp.metodo,
                     CAST(0 AS DECIMAL(30,2)) AS total,
                     CAST(0 AS INT)           AS cantidad
        FROM metodo_pago mp;
        RETURN;
    END

    SELECT
        c.id_caja, c.fecha, c.hora_apertura, c.hora_cierre, c.estado,
        c.monto_apertura,
        ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO'), 0) AS total_cobrado,
        ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO'
                  AND mp.metodo = 'Efectivo'), 0)                                    AS efectivo_cobrado
    FROM caja c
    WHERE c.id_caja = @id_caja;

    SELECT
        mp.metodo,
        SUM(p.monto_pagado) AS total,
        COUNT(*)            AS cantidad
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.caja_id_caja = @id_caja AND p.estado_pago = 'APROBADO'
    GROUP BY mp.metodo
    ORDER BY mp.metodo;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_asignar_notificacion_socios]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- ══════════════════════════════════════════
-- ASIGNAR SOCIOS a una notificacion
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_asignar_notificacion_socios]
(
    @IdNotificacion INT,
    @EnviarATodos   BIT          = 0,
    @IdsSocios      VARCHAR(MAX) = ''
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar asignaciones previas
    DELETE FROM notificacion_socio
    WHERE notificacion_id_notificacion = @IdNotificacion;

    IF @EnviarATodos = 1
    BEGIN
        INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
        SELECT CAST(GETDATE() AS DATE), 0, @IdNotificacion, id_socio
        FROM socio;
    END
    ELSE
    BEGIN
        INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
        SELECT CAST(GETDATE() AS DATE), 0, @IdNotificacion, CAST(value AS INT)
        FROM STRING_SPLIT(@IdsSocios, ',')
        WHERE RTRIM(LTRIM(value)) <> '';
    END

    SELECT 1 AS Resultado, 'Socios asignados correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscar_socios_cargo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. sp_buscar_socios_cargo
-- =============================================
CREATE   PROCEDURE [dbo].[sp_buscar_socios_cargo]
    @Busqueda NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 10 id_socio, nombre_socio, codigo_fijo
    FROM socio
    WHERE nombre_socio LIKE '%' + @Busqueda + '%'
       OR CAST(codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    ORDER BY codigo_fijo;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_caja_abierta]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Caja abierta del cajero (con total cobrado en vivo) ----------------------
CREATE   PROCEDURE [dbo].[sp_caja_abierta]
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        c.id_caja,
        c.fecha,
        c.hora_apertura,
        c.monto_apertura,
        c.estado,
        ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO'), 0) AS total_cobrado,
        (SELECT COUNT(*) FROM pago p
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO')     AS num_pagos
    FROM caja c
    WHERE c.usuario_admin_id_usuario_admin = @id_usuario AND c.estado = 1;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cambiar_estado_aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. sp_cambiar_estado_aviso
--    Solo avanza estado (no retrocede).
--    PAGADO unicamente desde modulo de Pagos.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_cambiar_estado_aviso]
    @id_aviso  INT,
    @id_estado INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        DECLARE @estado_actual INT;
        SELECT @estado_actual = estado_id_estado
        FROM aviso WHERE id_aviso = @id_aviso;

        IF @estado_actual IS NULL
        BEGIN
            SET @Mensaje = 'Aviso no encontrado.';
            RETURN;
        END

        IF @id_estado <= @estado_actual
        BEGIN
            SET @Mensaje = 'No se puede retroceder el estado de un aviso.';
            RETURN;
        END

        DECLARE @id_pagado INT;
        SELECT @id_pagado = id_estado FROM estado WHERE estado = 'PAGADO';
        IF @id_estado = @id_pagado
        BEGIN
            SET @Mensaje = 'El estado PAGADO solo puede asignarse desde el modulo de Pagos.';
            RETURN;
        END

        DECLARE @nombre_estado VARCHAR(150);
        SELECT @nombre_estado = estado FROM estado WHERE id_estado = @id_estado;

        UPDATE aviso
        SET estado_id_estado = @id_estado
        WHERE id_aviso = @id_aviso;

        SET @Resultado = 1;
        SET @Mensaje   = 'Estado actualizado a ' + ISNULL(@nombre_estado, '') + '.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_cambiar_estado_cliente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- CAMBIAR ESTADO
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_cambiar_estado_cliente]
(
    @IdCliente INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @IdCliente)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El cliente no existe.';
        RETURN;
    END

    UPDATE cliente
    SET estado = CASE WHEN estado = 1 THEN 0 ELSE 1 END
    WHERE id_cliente = @IdCliente;

    SET @Resultado = 1;
    SET @Mensaje   = 'Estado actualizado correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_cambiar_estado_cuenta_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- CAMBIAR ESTADO
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_cambiar_estado_cuenta_socio]
(
    @IdCuentaSocio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cuenta_socio
    SET estado = CASE WHEN estado = 1 THEN 0 ELSE 1 END
    WHERE id_cuenta_socio = @IdCuentaSocio;

    SELECT estado AS NuevoEstado FROM cuenta_socio WHERE id_cuenta_socio = @IdCuentaSocio;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cerrar_caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Cerrar caja --------------------------------------------------------------
--    Solo el cajero dueno de la caja puede cerrarla. Sin esta guarda cualquier
--    usuario con el permiso 'Gestionar Caja' cerraba la caja de otro cajero
--    mandando otro @id_caja desde el navegador (IDOR).
CREATE   PROCEDURE [dbo].[sp_cerrar_caja]
    @id_caja       INT,
    @id_usuario    INT,                    -- cajero de la sesion (dueno esperado)
    @es_superadmin BIT           = 0,      -- SUPERADMIN puede cerrar cualquier caja
    @Resultado     INT           OUTPUT,   -- 1 ok | 0 error
    @Mensaje       NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja)
        BEGIN SET @Mensaje = 'Caja no encontrada.'; RETURN; END

        -- Mismo mensaje que 'no encontrada': no revelar que la caja existe.
        IF @es_superadmin = 0
           AND NOT EXISTS (SELECT 1 FROM caja
                           WHERE id_caja = @id_caja
                             AND usuario_admin_id_usuario_admin = @id_usuario)
        BEGIN SET @Mensaje = 'Caja no encontrada.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'La caja ya está cerrada.'; RETURN; END

        DECLARE @total DECIMAL(30,2) =
            ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                    WHERE p.caja_id_caja = @id_caja AND p.estado_pago = 'APROBADO'), 0);

        UPDATE caja
        SET monto_cobrado = @total,
            hora_cierre   = GETDATE(),
            estado        = 0
        WHERE id_caja = @id_caja;

        SET @Resultado = 1;
        SET @Mensaje   = 'Caja cerrada correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_confirmar_pago_qr]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Confirmar pago QR (callback PAGO EXITOSO / conciliacion). Idempotente. ---
CREATE   PROCEDURE [dbo].[sp_confirmar_pago_qr]
    @id_transaccion    VARCHAR(100),
    @forma_pago        VARCHAR(60)   = NULL,
    @codigo_recaudacion VARCHAR(50)  = NULL,
    @Resultado         INT           OUTPUT,   -- id_pago confirmado (>0) | 0 error
    @Mensaje           NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        DECLARE @id_pago INT, @estado_pago VARCHAR(30), @id_aviso INT;
        SELECT @id_pago = id_pago, @estado_pago = estado_pago, @id_aviso = aviso_id_aviso
        FROM pago WHERE id_transaccion = @id_transaccion;

        IF @id_pago IS NULL
        BEGIN SET @Mensaje = 'Transaccion no encontrada.'; RETURN; END

        -- Idempotencia: reconfirmar no es un error
        IF @estado_pago = 'APROBADO'
        BEGIN SET @Resultado = @id_pago; SET @Mensaje = 'El pago ya estaba confirmado.'; RETURN; END

        IF @estado_pago <> 'PENDIENTE'
        BEGIN SET @Mensaje = 'El pago esta en estado ' + @estado_pago + ' y no puede confirmarse.'; RETURN; END

        DECLARE @estado_aviso VARCHAR(50) =
            (SELECT e.estado FROM aviso a
             INNER JOIN estado e ON e.id_estado = a.estado_id_estado
             WHERE a.id_aviso = @id_aviso);

        IF @estado_aviso IN ('PAGADO', 'ANULADO')
        BEGIN
            -- El aviso ya se cobro por otra via o fue anulado: este QR caduca.
            -- Si ademas llego dinero a la pasarela, requiere devolucion manual.
            UPDATE pago SET estado_pago = 'EXPIRADO' WHERE id_pago = @id_pago;
            SET @Mensaje = 'El aviso esta ' + @estado_aviso +
                           '; el QR quedo expirado y no se registro el cobro.';
            RETURN;
        END

        DECLARE @id_pagado INT = (SELECT id_estado FROM estado WHERE estado = 'PAGADO');
        DECLARE @socio_id INT, @periodo_id INT, @total_aviso DECIMAL(30,2), @consumo DECIMAL(30,2);
        SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo,
               @total_aviso = total_aviso,  @consumo = total_consumo
        FROM aviso WHERE id_aviso = @id_aviso;

        -- Misma comprobacion de coherencia que en el cobro por caja, pero AQUI NO SE
        -- ABORTA: el socio ya pago en la pasarela y rechazar dejaria el dinero fuera
        -- del sistema con el aviso impago. Se confirma el cobro y se deja constancia
        -- en bitacora para que alguien revise el descuadre.
        DECLARE @desglose DECIMAL(30,2) =
              @consumo
            + ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                      WHERE ce.socio_id_socio     = @socio_id
                        AND ce.periodo_id_periodo = @periodo_id
                        AND ce.estado             = 'PENDIENTE'), 0)
            + ISNULL((SELECT SUM(ci.monto_pago) FROM credito_inscripcion ci
                      WHERE ci.socio_id_socio     = @socio_id
                        AND ci.periodo_id_periodo = @periodo_id
                        AND ci.estado             = 'PENDIENTE'), 0);

        -- Si la caja del cajero ya cerro (pago confirmado tarde o en background),
        -- el pago pasa a ser "online" (sin caja): no distorsiona un arqueo ya hecho.
        DECLARE @id_caja INT = (SELECT caja_id_caja FROM pago WHERE id_pago = @id_pago);
        IF @id_caja IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
            SET @id_caja = NULL;

        BEGIN TRAN;

        UPDATE pago
        SET estado_pago        = 'APROBADO',
            fecha_pago         = GETDATE(),
            forma_pago         = ISNULL(@forma_pago, forma_pago),
            codigo_recaudacion = ISNULL(@codigo_recaudacion, codigo_recaudacion),
            caja_id_caja       = @id_caja
        WHERE id_pago = @id_pago;

        UPDATE aviso SET estado_id_estado = @id_pagado WHERE id_aviso = @id_aviso;

        UPDATE cargo_extra SET estado = 'PAGADO'
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE';

        -- Igual que en el cobro por caja: se sella el pago que cancelo la cuota.
        UPDATE credito_inscripcion
        SET estado       = 'CANCELADO',
            pago_id_pago = @id_pago
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE';

        COMMIT;

        -- Constancia del descuadre detectado arriba (el cobro ya se confirmo).
        IF @desglose <> @total_aviso
        BEGIN
            DECLARE @accDescuadre VARCHAR(255) =
                'Descuadre al confirmar pago QR: aviso #' + CAST(@id_aviso AS VARCHAR) +
                ' total Bs. ' + CONVERT(VARCHAR, @total_aviso) +
                ' vs. detalle Bs. ' + CONVERT(VARCHAR, @desglose) + '. Revisar cargos del periodo.';
            EXEC dbo.sp_registrar_bitacora @accDescuadre, 0;
        END

        -- RF-27: notificacion automatica al portal del socio (best-effort)
        EXEC dbo.sp_notificar_pago_confirmado @id_pago;

        SET @Resultado = @id_pago;
        SET @Mensaje   = 'Pago QR confirmado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_crear_medidor]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- REGISTRAR MEDIDOR
-- =============================================
CREATE   PROCEDURE [dbo].[sp_crear_medidor]
    @serie            VARCHAR(150),
    @numero           INTEGER,
    @fecha_instalacion DATE,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE serie = @serie)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE numero = @numero)
        BEGIN
            INSERT INTO [dbo].[medidor] (serie, numero, fecha_instalacion)
            VALUES (@serie, @numero, @fecha_instalacion);
            SET @Resultado = SCOPE_IDENTITY();
            SET @Mensaje   = 'Medidor registrado correctamente.';
        END
        ELSE
            SET @Mensaje = 'Ya existe un medidor con este numero.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un medidor con esta serie.';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crear_rol]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--crear rol sp
CREATE   procedure [dbo].[sp_crear_rol]
    @nombre nvarchar(100),
    @descripcion nvarchar(255),
    @estado bit,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
as
begin
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    -- Validar que el nombre no esté duplicado
    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE nombre = @nombre)
    BEGIN
        INSERT INTO [dbo].[rol] (nombre, descripcion, estado)
        VALUES (@nombre, @descripcion, @estado);
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Rol registrado correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un rol con este nombre.';
    
end
GO
/****** Object:  StoredProcedure [dbo].[sp_crear_ruta]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Crear ruta
CREATE PROCEDURE [dbo].[sp_crear_ruta]
    @ruta INT,
    @descripcion VARCHAR(150),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[ruta] WHERE ruta = @ruta)
    BEGIN
        INSERT INTO [dbo].[ruta] (ruta, descripcion)
        VALUES (@ruta, @descripcion);
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Ruta registrada correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe una ruta con este número.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_crear_tipo_cargo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Crear
CREATE   PROCEDURE [dbo].[sp_crear_tipo_cargo]
    @nombre VARCHAR(150),
    @monto DECIMAL(30,3),
    @estado BIT,
    @automatico BIT = 0,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_cargo] WHERE nombre = @nombre)
    BEGIN
        INSERT INTO [dbo].[tipo_cargo] (nombre, monto, estado, automatico)
        VALUES (@nombre, @monto, @estado, @automatico);
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Tipo de cargo registrado correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un tipo de cargo con este nombre.';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crear_usuario]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- CREAR USUARIO
-- =============================================
CREATE   PROCEDURE [dbo].[sp_crear_usuario]
    @nombre      VARCHAR(255),
    @apellido    VARCHAR(255),
    @usuario     VARCHAR(255),
    @contrasena  VARCHAR(550),
    @estado      BIT,
    @rol_id_rol  INT,
    @Resultado   INT OUTPUT,
    @Mensaje     VARCHAR(500) OUTPUT,
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    -- Solo un SUPERADMIN puede asignar el rol SUPERADMIN
    IF @SolicitanteEsSuperadmin = 0
       AND EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @rol_id_rol AND nombre = 'SUPERADMIN')
    BEGIN
        SET @Mensaje = 'No tienes permiso para asignar el rol SUPERADMIN.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[usuario_admin] WHERE usuario = @usuario)
    BEGIN
        SET @Mensaje = 'Ya existe un usuario con ese nombre de usuario.';
        RETURN;
    END

    -- No permitir registrar dos veces a la misma persona (nombre + apellido)
    IF EXISTS (SELECT 1 FROM [dbo].[usuario_admin]
               WHERE LTRIM(RTRIM(nombre))   = LTRIM(RTRIM(@nombre))
                 AND LTRIM(RTRIM(apellido)) = LTRIM(RTRIM(@apellido)))
    BEGIN
        SET @Mensaje = 'Ya existe un usuario registrado con ese nombre y apellido.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @rol_id_rol AND estado = 1)
    BEGIN
        SET @Mensaje = 'El rol seleccionado no existe o está inactivo.';
        RETURN;
    END

    INSERT INTO [dbo].[usuario_admin]
        (nombre, apellido, usuario, contraseña, estado, fecha_creacion, rol_id_rol)
    VALUES 
        (@nombre, @apellido, @usuario, @contrasena, @estado, GETDATE(), @rol_id_rol);

    SET @Resultado = SCOPE_IDENTITY();
    SET @Mensaje   = 'Usuario registrado correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_datos_deuda_qr]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 1. Datos del aviso para registrar la deuda en Libelula ----------------------
--    Resultset 1: cabecera (incluye email del cliente y QR pendiente si existe).
--    Resultset 2: detalle de la deuda (concepto, subtotal), igual que el recibo.
CREATE   PROCEDURE [dbo].[sp_datos_deuda_qr]
    @id_aviso INT,
    @id_socio INT = NULL   -- portal del socio: dueno esperado del aviso
AS
BEGIN
    SET NOCOUNT ON;

    -- Cuando la llamada viene del portal, el id del aviso lo elige el
    -- navegador: se exige que el aviso sea del socio de la sesion o no se
    -- devuelve nada (la capa de negocio lo trata como 'aviso no encontrado').
    -- El admin no manda @id_socio y conserva el acceso a cualquier aviso.
    IF @id_socio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM aviso
                       WHERE id_aviso = @id_aviso AND socio_id_socio = @id_socio)
        RETURN;

    SELECT
        a.id_aviso,
        a.total_aviso,
        e.estado,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo AS nombre_periodo,
        c.email,
        pqr.id_pago         AS pendiente_id_pago,
        pqr.id_transaccion  AS pendiente_id_transaccion,
        pqr.url_pasarela    AS pendiente_url_pasarela,
        pqr.qr_url          AS pendiente_qr_url
    FROM aviso a
    INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
    INNER JOIN socio   s   ON s.id_socio     = a.socio_id_socio
    INNER JOIN cliente c   ON c.id_cliente   = s.cliente_id_cliente
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    OUTER APPLY (
        SELECT TOP 1 p.id_pago, p.id_transaccion, p.url_pasarela, p.qr_url
        FROM pago p
        WHERE p.aviso_id_aviso = a.id_aviso
          AND p.estado_pago    = 'PENDIENTE'
          AND p.id_transaccion IS NOT NULL
          -- Solo el QR generado HOY es reutilizable: la deuda se registra en
          -- Libelula con vencimiento al final del dia, asi que uno de un dia
          -- anterior ya no puede pagarse en la pasarela.
          AND CAST(p.fecha_pago AS DATE) = CAST(GETDATE() AS DATE)
        ORDER BY p.id_pago DESC
    ) pqr
    WHERE a.id_aviso = @id_aviso;

    -- Detalle para lineas_detalle_deuda de Libelula
    DECLARE @socio_id INT, @periodo_id INT, @total_consumo DECIMAL(30,2);
    SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo,
           @total_consumo = total_consumo
    FROM aviso WHERE id_aviso = @id_aviso;

    SELECT concepto, subtotal FROM (
        SELECT 'Consumo Agua' AS concepto, @total_consumo AS subtotal, 0 AS orden
        WHERE @total_consumo > 0
        UNION ALL
        SELECT descripcion, monto, 1
        FROM cargo_extra
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE'
        UNION ALL
        SELECT 'Cuota de Inscripcion (' + CAST(num_cuota AS VARCHAR) + ')', monto_pago, 2
        FROM credito_inscripcion
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE'
    ) d
    ORDER BY d.orden;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_detalle_aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 6. sp_detalle_aviso
--    Devuelve el desglose completo de un aviso:
--    socio, lectura, tarifa, cargo extra, credito.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_detalle_aviso]
    @id_aviso INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Cabecera: socio, lectura, tarifa, totales y cuota de credito (0..1)
    SELECT
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado        AS estado,
        -- Socio
        s.nombre_socio,
        s.codigo_fijo,
        -- Ruta y Periodo
        r.ruta          AS nombre_ruta,
        p.periodo       AS nombre_periodo,
        e.estado        AS nombre_estado,
        -- Medidor y Lectura
        m.serie         AS serie_medidor,
        l.lectura_anterior,
        l.lectura_actual,
        l.consumo_m3,
        l.dias_lectura,
        -- Tarifa y Rol
        rs.rol_socio    AS nombre_rol,
        t.monto_minimo,
        t.consumo_minimo_m3,
        t.precio_m3,
        -- Suma de cargos extra del socio en el periodo (1:N)
        -- Un cargo ANULADO nunca se facturo: sumarlo hacia que el detalle
        -- mostrara un total mayor al total_aviso realmente cobrado.
        ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                WHERE ce.socio_id_socio = a.socio_id_socio
                  AND ce.periodo_id_periodo = a.periodo_id_periodo
                  AND ce.estado <> 'ANULADO'), 0) AS total_cargos,
        -- Cuota de credito de inscripcion (0..1)
        ci.monto_pago   AS monto_credito
    FROM aviso a
    INNER JOIN socio     s  ON s.id_socio               = a.socio_id_socio
    INNER JOIN ruta      r  ON r.id_ruta                = s.ruta_id_ruta
    INNER JOIN periodo   p  ON p.id_periodo             = a.periodo_id_periodo
    INNER JOIN estado    e  ON e.id_estado              = a.estado_id_estado
    INNER JOIN lectura   l  ON l.id_lectura             = a.lectura_id_lectura
    INNER JOIN medidor   m  ON m.id_medidor             = l.medidor_id_medidor
    INNER JOIN rol_socio rs ON rs.id_rol_socio          = s.rol_socio_id_rol_socio
    INNER JOIN tarifa    t  ON t.rol_socio_id_rol_socio = s.rol_socio_id_rol_socio
    -- La cuota inicial de inscripcion se paga en efectivo al registrar al socio,
    -- en el periodo de registro. Si ese periodo coincide con el de un aviso,
    -- aparecia en el detalle sin haber entrado nunca en total_aviso. Se
    -- reconoce porque su pago no tiene aviso; las cuotas cobradas via aviso
    -- quedan ligadas a un pago que si lo tiene.
    LEFT  JOIN credito_inscripcion ci 
        ON ci.socio_id_socio = a.socio_id_socio
       AND ci.periodo_id_periodo = a.periodo_id_periodo
       AND NOT EXISTS (SELECT 1 FROM pago pg
                       WHERE pg.id_pago = ci.pago_id_pago
                         AND pg.aviso_id_aviso IS NULL)
    WHERE a.id_aviso = @id_aviso;

    -- 2) Lista de cargos extra del aviso (N filas)
    DECLARE @socio_id INT, @periodo_id INT;
    SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo FROM aviso WHERE id_aviso = @id_aviso;

    SELECT
        ce.id_cargo_extra,
        ce.monto,
        ce.descripcion,
        ce.fecha_registro,
        tc.nombre AS nombre_tipo_cargo
    FROM cargo_extra ce
    INNER JOIN tipo_cargo tc ON tc.id_tipo = ce.tipo_cargo_id_tipo
    WHERE ce.socio_id_socio = @socio_id
      AND ce.periodo_id_periodo = @periodo_id
      AND ce.estado <> 'ANULADO'
    ORDER BY ce.id_cargo_extra;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_detalle_credito_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- sp_detalle_credito_socio : todas las cuotas de inscripcion de un socio
-- =============================================================================
CREATE   PROCEDURE [dbo].[sp_detalle_credito_socio]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ci.id_credito,
        ci.num_cuota,
        p.periodo                                                AS nombre_periodo,
        ci.monto_pago,
        ci.estado,
        CASE WHEN av.id_aviso IS NOT NULL THEN 1 ELSE 0 END      AS en_aviso,
        av.id_aviso                                              AS aviso_id_aviso,
        ci.pago_id_pago                                          AS pago_id_pago
    FROM credito_inscripcion ci
    INNER JOIN periodo p ON p.id_periodo = ci.periodo_id_periodo
    OUTER APPLY (
        SELECT TOP 1 a.id_aviso
        FROM aviso a
        WHERE a.socio_id_socio = ci.socio_id_socio
          AND a.periodo_id_periodo = ci.periodo_id_periodo
          AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
    ) av
    WHERE ci.socio_id_socio = @id_socio
    ORDER BY ci.num_cuota;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_cliente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_editar_cliente]
(
    @IdCliente       INT,
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @Email           VARCHAR(150),
    @FechaNacimiento DATE,
    @Resultado       INT          OUTPUT,
    @Mensaje         VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Mismo criterio que en el alta: normalizar y exigir email. Editar no puede
    -- ser la puerta de atras para dejar sin correo a una persona que ya lo tenia
    -- (si tiene cuenta de portal, se quedaria sin poder pagar con QR).
    SET @Email = NULLIF(LTRIM(RTRIM(@Email)), '');

    IF @Email IS NULL
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El email es obligatorio (requerido para pagos por QR).';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM cliente WHERE ci = @CI AND id_cliente <> @IdCliente)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El CI ya está registrado en otro cliente.';
        RETURN;
    END

    -- Email único en OTRO cliente (se usa como referencia para pagos QR)
    IF EXISTS (SELECT 1 FROM cliente
               WHERE LTRIM(RTRIM(email)) = @Email
                 AND id_cliente <> @IdCliente)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El email ya está registrado en otro cliente.';
        RETURN;
    END

    UPDATE cliente SET
        nombre_completo  = @NombreCompleto,
        ci               = @CI,
        genero           = @Genero,
        telefono         = @Telefono,
        email            = @Email,
        fecha_nacimiento = @FechaNacimiento
    WHERE id_cliente = @IdCliente;

    SET @Resultado = 1;
    SET @Mensaje   = 'Cliente actualizado correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_editar_cuenta_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_editar_cuenta_socio]
(
    @IdCuentaSocio  INT,
    @Usuario        VARCHAR(150),
    @Contrasena     VARCHAR(500) = '', -- Si viene vacio no se actualiza
    @IdSocio        INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE usuario = @Usuario AND id_cuenta_socio <> @IdCuentaSocio)
    BEGIN
        SELECT 0 AS Resultado, 'El nombre de usuario ya está en uso por otra cuenta.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE socio_id_socio = @IdSocio AND id_cuenta_socio <> @IdCuentaSocio)
    BEGIN
        SELECT 0 AS Resultado, 'El socio ya tiene una cuenta asignada diferente.' AS Mensaje;
        RETURN;
    END

    -- El portal ofrece pago por QR y la pasarela exige el email del cliente
    IF NOT EXISTS (
        SELECT 1
        FROM socio s
        INNER JOIN cliente c ON c.id_cliente = s.cliente_id_cliente
        WHERE s.id_socio = @IdSocio
          AND c.email IS NOT NULL
          AND LTRIM(RTRIM(c.email)) <> ''
    )
    BEGIN
        SELECT 0 AS Resultado,
               'El socio no tiene email registrado. Registre el email en el módulo Clientes antes de crearle una cuenta del portal.' AS Mensaje;
        RETURN;
    END

    IF (@Contrasena <> '')
    BEGIN
        UPDATE cuenta_socio SET
            usuario        = @Usuario,
            contraseña     = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Contrasena), 2),
            socio_id_socio = @IdSocio
        WHERE id_cuenta_socio = @IdCuentaSocio;
    END
    ELSE
    BEGIN
        UPDATE cuenta_socio SET
            usuario        = @Usuario,
            socio_id_socio = @IdSocio
        WHERE id_cuenta_socio = @IdCuentaSocio;
    END

    SELECT 1 AS Resultado, 'Cuenta actualizada correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_medidor]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- EDITAR MEDIDOR
-- =============================================
CREATE   PROCEDURE [dbo].[sp_editar_medidor]
    @id_medidor       INTEGER,
    @serie            VARCHAR(150),
    @numero           INTEGER,
    @fecha_instalacion DATE,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE serie = @serie AND id_medidor <> @id_medidor)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE numero = @numero AND id_medidor <> @id_medidor)
        BEGIN
            UPDATE [dbo].[medidor]
            SET serie             = @serie,
                numero            = @numero,
                fecha_instalacion = @fecha_instalacion
            WHERE id_medidor = @id_medidor;
            SET @Resultado = 1;
            SET @Mensaje   = 'Medidor actualizado correctamente.';
        END
        ELSE
            SET @Mensaje = 'Ya existe un medidor con este numero.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un medidor con esta serie.';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_metodo_pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE PROCEDURE [dbo].[sp_editar_metodo_pago]
(
    @IdMetodoPago INT,
    @Metodo       VARCHAR(150),
    @Referencia   VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM metodo_pago WHERE metodo = @Metodo AND id_metodo_pago <> @IdMetodoPago)
    BEGIN
        SELECT 0 AS Resultado, 'El nombre del método de pago ya está en uso.' AS Mensaje;
        RETURN;
    END

    UPDATE metodo_pago SET
        metodo     = @Metodo,
        referencia = @Referencia
    WHERE id_metodo_pago = @IdMetodoPago;

    SELECT 1 AS Resultado, 'Método de pago actualizado correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_notificacion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_editar_notificacion]
(
    @IdNotificacion INT,
    @Titulo         VARCHAR(255),
    @Mensaje        VARCHAR(1000),
    @Tipo           VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM notificacion WHERE id_notificacion = @IdNotificacion)
    BEGIN
        SELECT 0 AS Resultado, 'La notificación no existe.' AS Mensaje;
        RETURN;
    END

    -- No permitir duplicar OTRA notificación (mismo título y mensaje)
    IF EXISTS (SELECT 1 FROM notificacion
               WHERE LTRIM(RTRIM(titulo))  = LTRIM(RTRIM(@Titulo))
                 AND LTRIM(RTRIM(mensaje)) = LTRIM(RTRIM(@Mensaje))
                 AND id_notificacion <> @IdNotificacion)
    BEGIN
        SELECT 0 AS Resultado, 'Ya existe otra notificación con el mismo título y mensaje.' AS Mensaje;
        RETURN;
    END

    UPDATE notificacion SET
        titulo  = @Titulo,
        mensaje = @Mensaje,
        tipo    = @Tipo
    WHERE id_notificacion = @IdNotificacion;

    SELECT 1 AS Resultado, 'Notificacion actualizada correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_rol]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--editar rol sp
CREATE   procedure [dbo].[sp_editar_rol]
    @id_rol int,
    @nombre nvarchar(100),
    @descripcion nvarchar(255),
    @estado bit,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT,
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    -- Solo un SUPERADMIN puede modificar el rol SUPERADMIN
    IF @SolicitanteEsSuperadmin = 0
       AND EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol AND nombre = 'SUPERADMIN')
    BEGIN
        SET @Mensaje = 'No tienes permiso para modificar el rol SUPERADMIN.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE nombre = @nombre and id_rol <> @id_rol)
    BEGIN
          UPDATE [dbo].[rol]
          SET nombre = @nombre, descripcion = @descripcion, estado = @estado
          WHERE id_rol = @id_rol;

          SET @Resultado = 1;
          SET @Mensaje = 'Rol actualizado correctamente.';
     END
     ELSE
          SET @Mensaje = 'Ya existe un rol con este nombre.';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_ruta]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Editar ruta
CREATE PROCEDURE [dbo].[sp_editar_ruta]
    @id_ruta INT,
    @ruta INT,
    @descripcion VARCHAR(150),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[ruta] WHERE ruta = @ruta AND id_ruta <> @id_ruta)
    BEGIN
        UPDATE [dbo].[ruta]
        SET ruta = @ruta, descripcion = @descripcion
        WHERE id_ruta = @id_ruta;
        SET @Resultado = 1;
        SET @Mensaje = 'Ruta actualizada correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe una ruta con este número.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_editar_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP_Socio_Editar
-- =============================================
CREATE   PROCEDURE [dbo].[sp_editar_socio]
    @id_socio                INT,
    @nombre_socio            VARCHAR(255),
    @cliente_id_cliente      INT,
    @rol_socio_id_rol_socio  INT,
    @ubicacion               INT           = NULL,
    @medidor_id_medidor      INT           = NULL,
    @num_casa                INT           = NULL,
    @num_ocupantes           INT           = NULL,
    @tipo_instalacion        VARCHAR(255)  = NULL,
    @dim_instalacion         VARCHAR(255)  = NULL,
    @actividad               VARCHAR(255),
    @categoria               VARCHAR(255),
    @fecha_registro          DATE,
    @ruta_id_ruta            INT,
    @codigo_fijo             INT,
    @estado                  BIT           = 1,
    @Resultado               INT OUTPUT,
    @Mensaje                 NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El socio no existe.';
            RETURN;
        END

        -- Validar medidor no asignado a OTRO socio (solo si no es NULL)
        IF @medidor_id_medidor IS NOT NULL AND EXISTS (
            SELECT 1 FROM socio 
            WHERE medidor_id_medidor = @medidor_id_medidor 
              AND id_socio <> @id_socio
        )
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El medidor ya está asignado a otro socio.';
            RETURN;
        END

        -- Validar código fijo único en OTRO socio
        IF EXISTS (
            SELECT 1 FROM socio
            WHERE codigo_fijo = @codigo_fijo
              AND id_socio <> @id_socio
        )
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El código fijo ya existe en otro socio.';
            RETURN;
        END

        -- Validar que OTRO socio no tenga el mismo nombre
        IF EXISTS (
            SELECT 1 FROM socio
            WHERE LTRIM(RTRIM(nombre_socio)) = LTRIM(RTRIM(@nombre_socio))
              AND id_socio <> @id_socio
        )
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'Ya existe otro socio registrado con ese nombre.';
            RETURN;
        END

        UPDATE socio SET
            nombre_socio           = @nombre_socio,
            cliente_id_cliente     = @cliente_id_cliente,
            rol_socio_id_rol_socio = @rol_socio_id_rol_socio,
            ubicacion              = @ubicacion,
            medidor_id_medidor     = @medidor_id_medidor,
            num_casa               = @num_casa,
            num_ocupantes          = @num_ocupantes,
            tipo_instalacion       = @tipo_instalacion,
            dim_instalacion        = @dim_instalacion,
            actividad              = @actividad,
            categoria              = @categoria,
            fecha_registro         = @fecha_registro,
            ruta_id_ruta           = @ruta_id_ruta,
            codigo_fijo            = @codigo_fijo,
            estado                 = @estado
        WHERE id_socio = @id_socio;

        SET @Resultado = 1;
        SET @Mensaje   = 'Socio actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_editar_tarifa]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- EDITAR TARIFA
-- =============================================
-- consumo_minimo_m3 y precio_m3 son INT en la tabla: los parametros son INT.
-- monto_minimo es DECIMAL(30,3) en la tabla y si admite decimales.
CREATE   PROCEDURE [dbo].[sp_editar_tarifa]
    @id_tarifa INT,
    @consumo_minimo_m3 INT,
    @monto_minimo DECIMAL(18,3),
    @precio_m3 INT,
    @rol_socio_id_rol_socio INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tarifa] WHERE id_tarifa = @id_tarifa)
    BEGIN
        SET @Mensaje = 'No existe una tarifa con este ID.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].tarifa
               WHERE rol_socio_id_rol_socio = @rol_socio_id_rol_socio AND id_tarifa <> @id_tarifa)
    BEGIN
        SET @Mensaje = 'Ya existe otra tarifa con ese rol de socio.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol_socio] WHERE id_rol_socio = @rol_socio_id_rol_socio)
    BEGIN
        SET @Mensaje = 'El rol seleccionado no existe.';
        RETURN;
    END

    UPDATE [dbo].[tarifa]
    SET
        consumo_minimo_m3      = @consumo_minimo_m3,
        monto_minimo           = @monto_minimo,
        precio_m3              = @precio_m3,
        rol_socio_id_rol_socio = @rol_socio_id_rol_socio
    WHERE id_tarifa = @id_tarifa;

    SET @Resultado = 1;
    SET @Mensaje   = 'Tarifa actualizada correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_editar_tipo_cargo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Editar
CREATE   PROCEDURE [dbo].[sp_editar_tipo_cargo]
    @id_tipo INT,
    @nombre VARCHAR(150),
    @monto DECIMAL(30,3),
    @estado BIT,
    @automatico BIT = 0,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_cargo] WHERE nombre = @nombre AND id_tipo <> @id_tipo)
    BEGIN
        UPDATE [dbo].[tipo_cargo]
        SET nombre = @nombre, monto = @monto, estado = @estado, automatico = @automatico
        WHERE id_tipo = @id_tipo;
        SET @Resultado = 1;
        SET @Mensaje = 'Tipo de cargo actualizado correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un tipo de cargo con este nombre.';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editar_usuario]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- EDITAR USUARIO
-- =============================================
CREATE   PROCEDURE [dbo].[sp_editar_usuario]
    @id_usuario_admin INT,
    @nombre           VARCHAR(255),
    @apellido         VARCHAR(255),
    @usuario          VARCHAR(255),
    @contrasena       VARCHAR(550),
    @estado           BIT,
    @rol_id_rol       INT,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT,
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[usuario_admin] WHERE id_usuario_admin = @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'No existe un usuario con este ID.';
        RETURN;
    END

    -- Solo un SUPERADMIN puede modificar a un usuario SUPERADMIN
    IF @SolicitanteEsSuperadmin = 0
       AND EXISTS (SELECT 1 FROM [dbo].[usuario_admin] u
                   INNER JOIN [dbo].[rol] r ON r.id_rol = u.rol_id_rol
                   WHERE u.id_usuario_admin = @id_usuario_admin AND r.nombre = 'SUPERADMIN')
    BEGIN
        SET @Mensaje = 'No tienes permiso para modificar a un usuario SUPERADMIN.';
        RETURN;
    END

    -- ...y tampoco puede promover a nadie al rol SUPERADMIN
    IF @SolicitanteEsSuperadmin = 0
       AND EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @rol_id_rol AND nombre = 'SUPERADMIN')
    BEGIN
        SET @Mensaje = 'No tienes permiso para asignar el rol SUPERADMIN.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[usuario_admin]
               WHERE usuario = @usuario AND id_usuario_admin <> @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'Ya existe otro usuario con ese nombre de usuario.';
        RETURN;
    END

    -- No permitir que otro usuario tenga el mismo nombre + apellido
    IF EXISTS (SELECT 1 FROM [dbo].[usuario_admin]
               WHERE LTRIM(RTRIM(nombre))   = LTRIM(RTRIM(@nombre))
                 AND LTRIM(RTRIM(apellido)) = LTRIM(RTRIM(@apellido))
                 AND id_usuario_admin <> @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'Ya existe otro usuario registrado con ese nombre y apellido.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @rol_id_rol AND estado = 1)
    BEGIN
        SET @Mensaje = 'El rol seleccionado no existe o está inactivo.';
        RETURN;
    END

    UPDATE [dbo].[usuario_admin]
    SET 
        nombre       = @nombre,
        apellido     = @apellido,
        usuario      = @usuario,
        contraseña   = CASE 
                           WHEN @contrasena IS NOT NULL AND @contrasena != '' 
                           THEN @contrasena 
                           ELSE contraseña 
                       END,
        estado       = @estado,
        rol_id_rol   = @rol_id_rol
    WHERE id_usuario_admin = @id_usuario_admin;

    SET @Resultado = 1;
    SET @Mensaje   = 'Usuario actualizado correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_metodo_pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- ELIMINAR (Físico con validación)
-- ══════════════════════════════════════════
CREATE PROCEDURE [dbo].[sp_eliminar_metodo_pago]
(
    @IdMetodoPago INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM pago WHERE metodo_pago_id_metodo_pago = @IdMetodoPago)
    BEGIN
        SELECT 0 AS Resultado, 'El método de pago ya está en uso (asociado a un pago).' AS Mensaje;
        RETURN;
    END

    DELETE FROM metodo_pago
    WHERE id_metodo_pago = @IdMetodoPago;

    SELECT 1 AS Resultado, 'Método de pago eliminado correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_notificacion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- ELIMINAR (Fisico con validacion)
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_eliminar_notificacion]
(
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM notificacion_socio WHERE notificacion_id_notificacion = @IdNotificacion)
    BEGIN
        SELECT 0 AS Resultado, 'La notificacion ya esta en uso (asignada a uno o mas socios).' AS Mensaje;
        RETURN;
    END

    DELETE FROM notificacion
    WHERE id_notificacion = @IdNotificacion;

    SELECT 1 AS Resultado, 'Notificacion eliminada correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_rol]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--eliminar rol sp, solo poner estado en 0
CREATE   procedure [dbo].[sp_eliminar_rol]
    @id_rol int,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT,
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    -- Solo un SUPERADMIN puede desactivar el rol SUPERADMIN
    IF @SolicitanteEsSuperadmin = 0
       AND EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol AND nombre = 'SUPERADMIN')
    BEGIN
        SET @Mensaje = 'No tienes permiso para desactivar el rol SUPERADMIN.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol)
    BEGIN
        UPDATE [dbo].[rol]
        SET estado = 0
        WHERE id_rol = @id_rol;

        SET @Resultado = 1;
        SET @Mensaje = 'Rol eliminado correctamente.';
    END
    ELSE
        SET @Mensaje = 'No existe un rol con este ID.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_tipo_cargo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Eliminar (soft delete)
CREATE   PROCEDURE [dbo].[sp_eliminar_tipo_cargo]
    @id_tipo INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF EXISTS (SELECT 1 FROM [dbo].[tipo_cargo] WHERE id_tipo = @id_tipo)
    BEGIN
        UPDATE [dbo].[tipo_cargo]
        SET estado = 0
        WHERE id_tipo = @id_tipo;
        SET @Resultado = 1;
        SET @Mensaje = 'Tipo de cargo desactivado correctamente.';
    END
    ELSE
        SET @Mensaje = 'No existe un tipo de cargo con este ID.';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_usuario]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- ELIMINAR (DESACTIVAR) USUARIO
-- =============================================
CREATE   PROCEDURE [dbo].[sp_eliminar_usuario]
    @id_usuario_admin INT,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT,
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[usuario_admin] WHERE id_usuario_admin = @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'No existe un usuario con este ID.';
        RETURN;
    END

    -- Solo un SUPERADMIN puede desactivar a un usuario SUPERADMIN
    IF @SolicitanteEsSuperadmin = 0
       AND EXISTS (SELECT 1 FROM [dbo].[usuario_admin] u
                   INNER JOIN [dbo].[rol] r ON r.id_rol = u.rol_id_rol
                   WHERE u.id_usuario_admin = @id_usuario_admin AND r.nombre = 'SUPERADMIN')
    BEGIN
        SET @Mensaje = 'No tienes permiso para desactivar a un usuario SUPERADMIN.';
        RETURN;
    END

    UPDATE [dbo].[usuario_admin]
    SET estado = 0
    WHERE id_usuario_admin = @id_usuario_admin;

    SET @Resultado = 1;
    SET @Mensaje   = 'Usuario desactivado correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_estado_pago_qr]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 5. Estado actual de un pago (polling desde la pantalla de cobro y desde el
--    portal del socio). Devuelve tambien id_transaccion para que el portal
--    pueda pedir la verificacion contra la pasarela sin recibirla del
--    navegador. Con @id_socio informado, solo responde por los pagos de ese
--    socio; el admin no lo manda y ve cualquier pago.
CREATE   PROCEDURE [dbo].[sp_estado_pago_qr]
    @id_pago INT,
    @id_socio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.id_pago, p.estado_pago, p.id_transaccion, p.aviso_id_aviso
    FROM pago p
    LEFT JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    WHERE p.id_pago = @id_pago
      AND (@id_socio IS NULL OR a.socio_id_socio = @id_socio);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_existe_aviso_activo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 1. sp_existe_aviso_activo
-- =============================================
CREATE   PROCEDURE [dbo].[sp_existe_aviso_activo]
    @idSocio INT,
    @idPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 1 FROM aviso 
    WHERE socio_id_socio = @idSocio 
      AND periodo_id_periodo = @idPeriodo 
      AND estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO');
END

GO
/****** Object:  StoredProcedure [dbo].[sp_generar_avisos_periodo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 1. sp_generar_avisos_periodo
--    Genera avisos para socios con lectura en el
--    periodo que aun no tienen aviso generado.
--    Calcula total segun tarifa del rol_socio.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_generar_avisos_periodo]
    @id_periodo INT,
    @id_ruta    INT          = NULL,
    @Generados  INT          OUTPUT,
    @Mensaje    VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Generados = 0;
    SET @Mensaje   = '';

    DECLARE @id_estado_gen INT;
    SELECT @id_estado_gen = id_estado FROM estado WHERE estado = 'GENERADO';

    IF @id_estado_gen IS NULL
    BEGIN
        SET @Mensaje = 'Tabla estado no inicializada. Ejecute el script de siembra primero.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        -- 0) Estampar los cargos automaticos (tipo_cargo.automatico = 1) a los socios
        --    que van a recibir aviso en este periodo. VA ANTES del INSERT del aviso:
        --    total_aviso es una foto inmutable, si el cargo se creara despues el aviso
        --    no lo incluiria pero el detalle si lo listaria (descuadre).
        --    El monto sale de tipo_cargo.monto, asi la cooperativa lo cambia desde la UI.
        INSERT INTO cargo_extra
            (monto, descripcion, fecha_registro, estado,
             tipo_cargo_id_tipo, socio_id_socio, periodo_id_periodo)
        SELECT DISTINCT
            CAST(tc.monto AS DECIMAL(30,2)),
            tc.nombre,
            CAST(GETDATE() AS DATE),
            'PENDIENTE',
            tc.id_tipo,
            s.id_socio,
            @id_periodo
        FROM lectura l
        INNER JOIN socio s ON s.medidor_id_medidor = l.medidor_id_medidor
        CROSS JOIN tipo_cargo tc
        WHERE l.periodo_id_periodo = @id_periodo
          AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
          AND tc.automatico = 1
          AND tc.estado     = 1
          -- solo socios que efectivamente recibiran aviso ahora
          AND NOT EXISTS (
              SELECT 1 FROM aviso a
              WHERE a.socio_id_socio     = s.id_socio
                AND a.periodo_id_periodo = @id_periodo
                AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
          )
          -- no duplicar si el cargo ya existe (registrado a mano o en una corrida anterior)
          AND NOT EXISTS (
              SELECT 1 FROM cargo_extra ce
              WHERE ce.socio_id_socio     = s.id_socio
                AND ce.periodo_id_periodo = @id_periodo
                AND ce.tipo_cargo_id_tipo = tc.id_tipo
                AND ce.estado <> 'ANULADO'
          );

        -- 1) Crear los avisos del periodo. total_aviso = consumo + SUMA(cargos) + cuota_credito
        INSERT INTO aviso (
            fecha_emision, fecha_vencimiento,
            total_consumo, total_aviso, deuda_actual,
            estado_id_estado,
            socio_id_socio, periodo_id_periodo,
            lectura_id_lectura
        )
        SELECT
            CAST(GETDATE() AS DATE),
            CAST(DATEADD(DAY, 30, GETDATE()) AS DATE),
            calc.total_consumo,
            calc.total_consumo + calc.sum_cargos + calc.cuota_credito,   -- total_aviso
            calc.total_consumo + calc.sum_cargos + calc.cuota_credito,   -- deuda_actual
            @id_estado_gen,
            s.id_socio,
            l.periodo_id_periodo,
            l.id_lectura
        FROM lectura l
        INNER JOIN socio  s ON s.medidor_id_medidor     = l.medidor_id_medidor
        INNER JOIN tarifa t ON t.rol_socio_id_rol_socio = s.rol_socio_id_rol_socio
        CROSS APPLY (
            SELECT
                -- consumo segun tarifa del rol_socio
                total_consumo =
                    CASE
                        WHEN l.consumo_m3 <= ISNULL(t.consumo_minimo_m3, 0)
                            THEN CAST(t.monto_minimo AS DECIMAL(30,2))
                        ELSE CAST(
                                t.monto_minimo
                                + (l.consumo_m3 - ISNULL(t.consumo_minimo_m3, 0)) * t.precio_m3
                            AS DECIMAL(30,2))
                    END,
                -- SUMA de TODOS los cargos pendientes del socio en el periodo (1:N)
                sum_cargos = ISNULL((
                    SELECT SUM(ce.monto)
                    FROM cargo_extra ce
                    WHERE ce.socio_id_socio     = s.id_socio
                      AND ce.periodo_id_periodo = l.periodo_id_periodo
                      AND ce.estado             = 'PENDIENTE'), 0),
                -- cuota de credito de inscripcion del periodo (0..1). SUMA, no resta.
                cuota_credito = ISNULL((
                    SELECT SUM(ci.monto_pago)
                    FROM credito_inscripcion ci
                    WHERE ci.socio_id_socio     = s.id_socio
                      AND ci.periodo_id_periodo = l.periodo_id_periodo
                      AND ci.estado             = 'PENDIENTE'), 0)
        ) calc
        WHERE l.periodo_id_periodo = @id_periodo
          AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
          -- excluir socios que ya tienen aviso activo en este periodo
          AND NOT EXISTS (
              SELECT 1 FROM aviso a
              WHERE a.socio_id_socio     = s.id_socio
                AND a.periodo_id_periodo = @id_periodo
                AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
          );

        SET @Generados = @@ROWCOUNT;

        COMMIT;

        IF @Generados = 0
            SET @Mensaje = 'No hay lecturas pendientes de aviso para el periodo y ruta seleccionados.';
        ELSE
            SET @Mensaje = CAST(@Generados AS VARCHAR) + ' aviso(s) generado(s) correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Generados = 0;

        -- 2601/2627 = violacion de indice unico. Desde la Migracion 15 existe
        -- aviso_socio_periodo_UX, que impide dos avisos vivos del mismo socio y
        -- periodo. Si salta aqui es porque otra sesion genero los avisos de este
        -- periodo mientras esta corria: el NOT EXISTS de arriba no ve los INSERT
        -- de la otra transaccion hasta que confirma. No se genero nada (la
        -- transaccion completa se deshizo) y reintentar es seguro: los avisos que
        -- alcanzo a crear la otra corrida ya excluyen a esos socios.
        IF ERROR_NUMBER() IN (2601, 2627)
            SET @Mensaje = 'Otro usuario genero los avisos de este periodo al mismo tiempo. ' +
                           'No se genero ningun aviso duplicado; vuelva a intentar para ' +
                           'completar los que falten.';
        ELSE
            SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_generar_notificaciones_vencimiento]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Recordatorios de vencimiento: un aviso no pagado que vence dentro de
-- @DiasAntes dias genera UNA notificacion al socio (no se repite: se
-- detecta por la marca [Aviso #id] con tipo 'Vencimiento').
CREATE   PROCEDURE [dbo].[sp_generar_notificaciones_vencimiento]
    @DiasAntes INT           = 3,
    @Resultado INT           OUTPUT,   -- cantidad de recordatorios generados
    @Mensaje   NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

        DECLARE @porVencer TABLE (id_aviso INT, id_socio INT, periodo VARCHAR(50),
                                  vence DATE, deuda DECIMAL(30,2));
        INSERT INTO @porVencer
        SELECT a.id_aviso, a.socio_id_socio, per.periodo, a.fecha_vencimiento, a.deuda_actual
        FROM aviso a
        INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
        INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
        WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
          AND a.fecha_vencimiento BETWEEN @hoy AND DATEADD(DAY, @DiasAntes, @hoy)
          AND NOT EXISTS (SELECT 1 FROM notificacion n
                          WHERE n.tipo = 'Vencimiento'
                            AND n.mensaje LIKE '%[[]Aviso #' + CAST(a.id_aviso AS VARCHAR) + ']%');

        DECLARE @id_aviso INT, @id_socio INT, @periodo VARCHAR(50),
                @vence DATE, @deuda DECIMAL(30,2), @id_notif INT;
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT id_aviso, id_socio, periodo, vence, deuda FROM @porVencer;
        OPEN cur;
        FETCH NEXT FROM cur INTO @id_aviso, @id_socio, @periodo, @vence, @deuda;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO notificacion (titulo, mensaje, tipo, fecha_publicacion, estado)
            VALUES ('Aviso proximo a vencer',
                    'Tu aviso del periodo ' + @periodo + ' vence el ' +
                    CONVERT(VARCHAR, @vence, 103) + '. Deuda: Bs. ' +
                    CONVERT(VARCHAR, @deuda) + '. [Aviso #' + CAST(@id_aviso AS VARCHAR) + ']',
                    'Vencimiento', @hoy, 1);
            SET @id_notif = CAST(SCOPE_IDENTITY() AS INT);

            INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
            VALUES (@hoy, 0, @id_notif, @id_socio);

            SET @Resultado = @Resultado + 1;
            FETCH NEXT FROM cur INTO @id_aviso, @id_socio, @periodo, @vence, @deuda;
        END
        CLOSE cur; DEALLOCATE cur;

        SET @Mensaje = CAST(@Resultado AS VARCHAR) + ' recordatorio(s) de vencimiento generado(s).';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_guardar_permisos_rol]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE   PROCEDURE [dbo].[sp_guardar_permisos_rol]
    @id_rol         INT,
    @TVP_Permisos   [dbo].[TVP_IdsPermisos] READONLY,
    @Resultado      INT OUTPUT,
    @Mensaje        VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    -- 1. Validación
    IF @id_rol IS NULL OR @id_rol = 0
    BEGIN
        SET @Mensaje   = 'ID de Rol no especificado.';
        SET @Resultado = 0;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol)
    BEGIN
        SET @Mensaje   = 'El rol especificado no existe.';
        SET @Resultado = 0;
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY

        -- 2. REVOCAR: eliminar permisos que el rol tiene pero que NO vienen en el TVP
        DELETE RP
        FROM [dbo].[rol_permiso] RP
        LEFT JOIN @TVP_Permisos TVP ON RP.permiso_id_permiso = TVP.id_permiso
        WHERE RP.rol_id_rol = @id_rol
          AND TVP.id_permiso IS NULL;

        -- 3. ASIGNAR: insertar permisos del TVP que el rol aún NO tiene
        INSERT INTO [dbo].[rol_permiso] (rol_id_rol, permiso_id_permiso)
        SELECT @id_rol, TVP.id_permiso
        FROM @TVP_Permisos TVP
        LEFT JOIN [dbo].[rol_permiso] RP 
            ON RP.permiso_id_permiso = TVP.id_permiso 
           AND RP.rol_id_rol = @id_rol
        WHERE RP.rol_id_rol IS NULL;

        COMMIT TRANSACTION;
        SET @Resultado = 1;
        SET @Mensaje   = 'Permisos actualizados correctamente.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_imprimir_aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- sp_imprimir_aviso
-- -----------------------------------------------------------------------------
-- Devuelve TODOS los datos para imprimir un "Aviso de Cobranza" (media carta),
-- al estilo del recibo físico de COSPABI. Tres result sets:
--   1) Cabecera ampliada (socio + lectura + tarifa + totales + cuota crédito).
--   2) Cargos extra estampados en el aviso (incluye la "TASA AFCOOP" que hoy se
--      maneja como cargo extra). Alimentan "DATOS FACTURADOS".
--   3) Histórico: últimos 12 avisos del socio (mes, N° factura = id_aviso,
--      consumo m³, total, fecha de pago y estado Pag./Imp.).
--
-- NO modifica sp_detalle_aviso (ese sigue alimentando el modal "Ver detalle").
-- Re-ejecutable (CREATE OR ALTER).
-- =============================================================================
CREATE   PROCEDURE [dbo].[sp_imprimir_aviso]
    @id_aviso INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_socio INT = (SELECT socio_id_socio FROM aviso WHERE id_aviso = @id_aviso);

    -- 1) CABECERA -------------------------------------------------------------
    SELECT
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado        AS estado,
        e.estado        AS nombre_estado,
        -- Socio
        s.id_socio,
        s.codigo_fijo,
        s.nombre_socio,
        s.ubicacion,                 -- COD. UB
        s.num_casa,
        s.categoria,
        s.actividad,
        -- Ruta y Período
        r.ruta          AS nombre_ruta,
        p.periodo       AS nombre_periodo,
        -- Medidor y Lectura
        m.serie         AS serie_medidor,
        l.lectura_anterior,
        l.lectura_actual,
        l.consumo_m3,
        l.dias_lectura,
        l.fecha_lectura                                 AS fecha_lectura_actual,
        DATEADD(DAY, -l.dias_lectura, l.fecha_lectura)  AS fecha_lectura_anterior,
        -- Tarifa y Rol
        rs.rol_socio    AS nombre_rol,
        t.monto_minimo,
        t.consumo_minimo_m3,
        t.precio_m3,
        -- Suma de cargos extra del socio en el periodo (1:N)
        -- Un cargo ANULADO nunca se facturo: no puede aparecer en el impreso.
        ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                WHERE ce.socio_id_socio = a.socio_id_socio
                  AND ce.periodo_id_periodo = a.periodo_id_periodo
                  AND ce.estado <> 'ANULADO'), 0) AS total_cargos,
        -- Cuota de crédito de inscripción (0..1)
        ci.monto_pago   AS monto_credito
    FROM aviso a
    INNER JOIN socio     s  ON s.id_socio               = a.socio_id_socio
    INNER JOIN ruta      r  ON r.id_ruta                = s.ruta_id_ruta
    INNER JOIN periodo   p  ON p.id_periodo             = a.periodo_id_periodo
    INNER JOIN estado    e  ON e.id_estado              = a.estado_id_estado
    INNER JOIN lectura   l  ON l.id_lectura             = a.lectura_id_lectura
    INNER JOIN medidor   m  ON m.id_medidor             = l.medidor_id_medidor
    INNER JOIN rol_socio rs ON rs.id_rol_socio          = s.rol_socio_id_rol_socio
    INNER JOIN tarifa    t  ON t.rol_socio_id_rol_socio = s.rol_socio_id_rol_socio
    -- La cuota inicial de inscripcion se paga en efectivo al registrar al socio,
    -- en el periodo de registro. Si ese periodo coincide con el de un aviso,
    -- aparecia en el detalle sin haber entrado nunca en total_aviso. Se
    -- reconoce porque su pago no tiene aviso; las cuotas cobradas via aviso
    -- quedan ligadas a un pago que si lo tiene.
    LEFT  JOIN credito_inscripcion ci 
        ON ci.socio_id_socio = a.socio_id_socio
       AND ci.periodo_id_periodo = a.periodo_id_periodo
       AND NOT EXISTS (SELECT 1 FROM pago pg
                       WHERE pg.id_pago = ci.pago_id_pago
                         AND pg.aviso_id_aviso IS NULL)
    WHERE a.id_aviso = @id_aviso;

    -- 2) CARGOS EXTRA (Datos Facturados) --------------------------------------
    DECLARE @socio_id INT, @periodo_id INT;
    SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo FROM aviso WHERE id_aviso = @id_aviso;

    SELECT
        ce.id_cargo_extra,
        ce.monto,
        ce.descripcion,
        tc.nombre AS nombre_tipo_cargo
    FROM cargo_extra ce
    INNER JOIN tipo_cargo tc ON tc.id_tipo = ce.tipo_cargo_id_tipo
    WHERE ce.socio_id_socio = @socio_id
      AND ce.periodo_id_periodo = @periodo_id
      AND ce.estado <> 'ANULADO'
    ORDER BY ce.id_cargo_extra;

    -- 3) HISTÓRICO (últimos 12 avisos del socio) ------------------------------
    SELECT TOP (12)
        av.id_aviso,
        p2.periodo        AS nombre_periodo,
        l2.consumo_m3,
        av.total_aviso,
        pg.fecha_pago,
        CASE WHEN pg.id_pago IS NOT NULL THEN 'Pag.' ELSE 'Imp.' END AS estado_pago_label,
        e2.estado         AS estado
    FROM aviso av
    INNER JOIN periodo p2 ON p2.id_periodo = av.periodo_id_periodo
    INNER JOIN lectura l2 ON l2.id_lectura = av.lectura_id_lectura
    INNER JOIN estado  e2 ON e2.id_estado  = av.estado_id_estado
    OUTER APPLY (
        SELECT TOP (1) pa.id_pago, pa.fecha_pago
        FROM pago pa
        WHERE pa.aviso_id_aviso = av.id_aviso
          AND pa.estado_pago = 'APROBADO'
        ORDER BY pa.id_pago DESC
    ) pg
    WHERE av.socio_id_socio = @id_socio
      AND av.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
    ORDER BY av.fecha_emision DESC, av.id_aviso DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_avisos]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 2. sp_listar_avisos
--    Listado paginado con filtros por periodo,
--    estado, ruta y busqueda por nombre/codigo.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_avisos]
    @id_periodo   INT           = NULL,
    @id_estado    INT           = NULL,
    @id_ruta      INT           = NULL,
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado                                                                  AS estado,
        a.estado_id_estado,
        e.estado                                                                  AS nombre_estado,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo                                                                 AS nombre_periodo,
        r.ruta                                                                    AS nombre_ruta,
        CASE WHEN EXISTS (
            SELECT 1 FROM cargo_extra ce 
            WHERE ce.socio_id_socio = a.socio_id_socio AND ce.periodo_id_periodo = a.periodo_id_periodo
              AND ce.estado <> 'ANULADO'
        ) THEN 1 ELSE 0 END                                                       AS tiene_cargo_extra,
        CASE WHEN EXISTS (
            SELECT 1 FROM credito_inscripcion ci 
            WHERE ci.socio_id_socio = a.socio_id_socio AND ci.periodo_id_periodo = a.periodo_id_periodo
        ) THEN 1 ELSE 0 END                                                       AS tiene_credito
    FROM aviso    a
    INNER JOIN socio   s ON s.id_socio   = a.socio_id_socio
    INNER JOIN ruta    r ON r.id_ruta    = s.ruta_id_ruta
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE
        (@id_periodo IS NULL OR a.periodo_id_periodo = @id_periodo)
        AND (@id_estado IS NULL OR a.estado_id_estado = @id_estado)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        )
    ORDER BY a.id_aviso DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM aviso a
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    WHERE
        (@id_periodo IS NULL OR a.periodo_id_periodo = @id_periodo)
        AND (@id_estado IS NULL OR a.estado_id_estado = @id_estado)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        );
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_avisos_por_cobrar]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- Modulo PAGO (cobro manual de avisos; SIN pasarela/QR por ahora).
-- Pago COMPLETO: un pago salda el aviso. estado_pago = 'APROBADO' al instante.
-- Requiere una caja ABIERTA. Cierra el ciclo: aviso->PAGADO, cargos->PAGADO,
-- cuotas de credito->CANCELADO.
-- =============================================================================

-- 1. Avisos por cobrar (no PAGADO ni ANULADO) --------------------------------
CREATE   PROCEDURE [dbo].[sp_listar_avisos_por_cobrar]
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        a.id_aviso,
        a.total_aviso,
        a.deuda_actual,
        e.estado AS estado,
        a.fecha_emision,
        a.fecha_vencimiento,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo AS nombre_periodo
    FROM aviso a
    INNER JOIN socio   s ON s.id_socio   = a.socio_id_socio
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND (@Busqueda = ''
           OR s.nombre_socio LIKE '%' + @Busqueda + '%'
           OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%')
    ORDER BY a.id_aviso DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT COUNT(*) AS TotalRegistros
    FROM aviso a
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    INNER JOIN estado e ON e.id_estado = a.estado_id_estado
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND (@Busqueda = ''
           OR s.nombre_socio LIKE '%' + @Busqueda + '%'
           OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%');
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_bitacora]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_listar_bitacora]
    @fecha_inicio DATE     = NULL,
    @fecha_fin    DATE     = NULL,
    @id_usuario   INT      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.id_bitacora,
        b.accion,
        b.fecha,
        b.hora,
        b.usuario_admin_id_usuario_admin,
        u.nombre + ' ' + u.apellido AS nombre_completo,
        u.usuario
    FROM [dbo].[bitacora] b
    INNER JOIN [dbo].[usuario_admin] u 
        ON u.id_usuario_admin = b.usuario_admin_id_usuario_admin
    WHERE
        (@fecha_inicio IS NULL OR b.fecha >= @fecha_inicio)
        AND (@fecha_fin    IS NULL OR b.fecha <= @fecha_fin)
        AND (@id_usuario   IS NULL OR b.usuario_admin_id_usuario_admin = @id_usuario)
    ORDER BY b.hora DESC
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_cajas]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 5. Historial de cajas del cajero (solo las suyas) ---------------------------
CREATE   PROCEDURE [dbo].[sp_listar_cajas]
    @id_usuario   INT,
    @Pagina       INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        c.id_caja, c.fecha, c.hora_apertura, c.hora_cierre,
        c.monto_apertura, c.monto_cobrado, c.estado
    FROM caja c
    WHERE c.usuario_admin_id_usuario_admin = @id_usuario
    ORDER BY c.id_caja DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT COUNT(*) AS TotalRegistros
    FROM caja c
    WHERE c.usuario_admin_id_usuario_admin = @id_usuario;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_cajeros_con_caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Cajeros que registraron cajas (para el filtro del reporte de caja) -------
CREATE   PROCEDURE [dbo].[sp_listar_cajeros_con_caja]
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT
        u.id_usuario_admin,
        u.nombre + ' ' + u.apellido AS nombre_completo
    FROM caja c
    INNER JOIN usuario_admin u ON u.id_usuario_admin = c.usuario_admin_id_usuario_admin
    INNER JOIN rol ro ON ro.id_rol = u.rol_id_rol
    WHERE (@SolicitanteEsSuperadmin = 1 OR ro.nombre <> 'SUPERADMIN')
    ORDER BY nombre_completo;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_cargos_extra]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 2. sp_listar_cargos_extra
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_cargos_extra]
    @id_periodo   INT           = NULL,
    @id_ruta      INT           = NULL,
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        ce.id_cargo_extra,
        ce.monto,
        ce.descripcion,
        ce.fecha_registro,
        ce.estado,
        ce.tipo_cargo_id_tipo,
        ce.socio_id_socio,
        ce.periodo_id_periodo,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo                                                                    AS nombre_periodo,
        t.nombre                                                                     AS nombre_tipo_cargo,
        r.ruta                                                                       AS nombre_ruta,
        CASE WHEN EXISTS (
            SELECT 1 FROM aviso a
            WHERE a.socio_id_socio = ce.socio_id_socio
              AND a.periodo_id_periodo = ce.periodo_id_periodo
              AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
        ) THEN 1 ELSE 0 END                                                          AS aplicado
    FROM cargo_extra ce
    INNER JOIN socio    s ON s.id_socio   = ce.socio_id_socio
    INNER JOIN periodo  p ON p.id_periodo = ce.periodo_id_periodo
    INNER JOIN tipo_cargo t ON t.id_tipo  = ce.tipo_cargo_id_tipo
    INNER JOIN ruta     r ON r.id_ruta    = s.ruta_id_ruta
    WHERE
        (@id_periodo IS NULL OR ce.periodo_id_periodo = @id_periodo)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        )
    ORDER BY ce.id_cargo_extra DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM cargo_extra ce
    INNER JOIN socio s ON s.id_socio = ce.socio_id_socio
    WHERE
        (@id_periodo IS NULL OR ce.periodo_id_periodo = @id_periodo)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        );
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_clientes]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_listar_clientes]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT COUNT(*) AS TotalRegistros
    FROM cliente
    WHERE (@Busqueda = ''
           OR nombre_completo LIKE '%' + @Busqueda + '%'
           OR ci              LIKE '%' + @Busqueda + '%');

    SELECT
        id_cliente,
        nombre_completo,
        ci,
        genero,
        telefono,
        email,
        fecha_nacimiento,
        fecha_registro,
        estado
    FROM cliente
    WHERE (@Busqueda = ''
           OR nombre_completo LIKE '%' + @Busqueda + '%'
           OR ci              LIKE '%' + @Busqueda + '%')
    ORDER BY id_cliente DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_creditos_pendientes]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- sp_listar_creditos_pendientes : socios con cuotas de inscripcion PENDIENTES
--   Una fila por socio: total, pagado, saldo, nro de cuotas pend. y proxima cuota.
-- =============================================================================
CREATE   PROCEDURE [dbo].[sp_listar_creditos_pendientes]
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    ;WITH socios_pend AS (
        SELECT s.id_socio, s.codigo_fijo, s.nombre_socio
        FROM socio s
        WHERE EXISTS (SELECT 1 FROM credito_inscripcion ci
                      WHERE ci.socio_id_socio = s.id_socio AND ci.estado = 'PENDIENTE')
          AND ( @Busqueda = ''
                OR s.nombre_socio LIKE '%' + @Busqueda + '%'
                OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%' )
    )
    SELECT
        sp.id_socio,
        sp.codigo_fijo,
        sp.nombre_socio,
        SUM(ci.monto_pago)                                                   AS total_inscripcion,
        SUM(CASE WHEN ci.estado = 'CANCELADO' THEN ci.monto_pago ELSE 0 END) AS pagado,
        SUM(CASE WHEN ci.estado = 'PENDIENTE' THEN ci.monto_pago ELSE 0 END) AS saldo,
        SUM(CASE WHEN ci.estado = 'PENDIENTE' THEN 1 ELSE 0 END)             AS cuotas_pendientes,
        prox.periodo                                                        AS proximo_periodo,
        ISNULL(prox.monto_pago, 0)                                          AS proximo_monto
    FROM socios_pend sp
    INNER JOIN credito_inscripcion ci ON ci.socio_id_socio = sp.id_socio
    OUTER APPLY (
        SELECT TOP 1 p.periodo, c.monto_pago
        FROM credito_inscripcion c
        INNER JOIN periodo p ON p.id_periodo = c.periodo_id_periodo
        WHERE c.socio_id_socio = sp.id_socio AND c.estado = 'PENDIENTE'
        ORDER BY c.num_cuota
    ) prox
    GROUP BY sp.id_socio, sp.codigo_fijo, sp.nombre_socio, prox.periodo, prox.monto_pago
    ORDER BY sp.nombre_socio
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM socio s
    WHERE EXISTS (SELECT 1 FROM credito_inscripcion ci
                  WHERE ci.socio_id_socio = s.id_socio AND ci.estado = 'PENDIENTE')
      AND ( @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%' );
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_cuenta_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- CUENTA DE SOCIO (credenciales del portal, 1:1 con socio).
-- Regla de negocio: una cuenta de portal solo puede crearse si el cliente
-- (persona) detras del socio tiene email. El portal ofrece pagar el aviso con
-- QR y la pasarela Libelula EXIGE el email del cliente para registrar la
-- deuda; sin el, el socio entraria a un portal donde el boton de pagar falla
-- siempre. Se valida al registrar y al reasignar la cuenta a otro socio.
-- =============================================================================


-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_listar_cuenta_socio]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT COUNT(*) AS TotalRegistros
    FROM cuenta_socio cs
    INNER JOIN socio s ON cs.socio_id_socio = s.id_socio
    WHERE (@Busqueda = ''
           OR cs.usuario LIKE '%' + @Busqueda + '%'
           OR s.nombre_socio LIKE '%' + @Busqueda + '%');

    SELECT
        cs.id_cuenta_socio,
        cs.usuario,
        cs.ultimo_acceso,
        cs.estado,
        cs.socio_id_socio,
        s.nombre_socio as nombre_socio
    FROM cuenta_socio cs
    INNER JOIN socio s ON cs.socio_id_socio = s.id_socio
    WHERE (@Busqueda = ''
           OR cs.usuario LIKE '%' + @Busqueda + '%'
           OR s.nombre_socio LIKE '%' + @Busqueda + '%')
    ORDER BY cs.id_cuenta_socio DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_estados]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 2. sp_listar_estados
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_estados]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT id_estado, estado 
    FROM estado 
    ORDER BY id_estado;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_lecturas]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 4. Historial de lecturas con paginacion y filtros
--    JOIN a socio via medidor (sin socio_id en lectura)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_lecturas]
    @id_periodo   INT           = NULL,
    @id_ruta      INT           = NULL,
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        l.id_lectura,
        l.fecha_lectura,
        l.lectura_anterior,
        l.lectura_actual,
        l.dias_lectura,
        l.consumo_m3,
        l.observacion,
        m.serie                                      AS serie_medidor,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo                                    AS nombre_periodo,
        r.ruta                                       AS nombre_ruta,
        u.nombre + ' ' + u.apellido                  AS nombre_usuario
    FROM lectura l
    INNER JOIN medidor       m ON m.id_medidor        = l.medidor_id_medidor
    INNER JOIN socio         s ON s.medidor_id_medidor = m.id_medidor
    INNER JOIN periodo       p ON p.id_periodo        = l.periodo_id_periodo
    INNER JOIN ruta          r ON r.id_ruta           = s.ruta_id_ruta
    INNER JOIN usuario_admin u ON u.id_usuario_admin  = l.usuario_admin_id_usuario_admin
    WHERE
        (@id_periodo IS NULL OR l.periodo_id_periodo = @id_periodo)
        AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR m.serie        LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        )
    ORDER BY l.fecha_lectura DESC, l.id_lectura DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM lectura l
    INNER JOIN medidor m ON m.id_medidor        = l.medidor_id_medidor
    INNER JOIN socio   s ON s.medidor_id_medidor = m.id_medidor
    WHERE
        (@id_periodo IS NULL OR l.periodo_id_periodo = @id_periodo)
        AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR m.serie        LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        );
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_medidores]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- MEDIDOR. Archivo re-ejecutable (CREATE OR ALTER); sin EXEC de prueba sueltos.
-- =============================================================================

-- =============================================
-- LISTAR MEDIDORES (todos, con su socio si lo tiene)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_medidores]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    -- Total de registros para la paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE (
        @Busqueda = ''
        OR m.serie        LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero  AS VARCHAR) LIKE '%' + @Busqueda + '%'
        OR s.nombre_socio LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    );

    -- Datos paginados
    SELECT
        m.id_medidor,
        m.serie,
        m.numero,
        m.fecha_instalacion,
        s.nombre_socio,
        s.codigo_fijo
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE (
        @Busqueda = ''
        OR m.serie        LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero  AS VARCHAR) LIKE '%' + @Busqueda + '%'
        OR s.nombre_socio LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    )
    ORDER BY m.id_medidor DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_medidores_para_lectura]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 2. Listar medidores de una ruta para lecturar
--    Muestra: datos del socio, lectura anterior,
--    y si ya fue leido en el periodo actual
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_medidores_para_lectura]
    @id_ruta    INT,
    @id_periodo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id_medidor,
        m.serie,
        s.id_socio,
        s.nombre_socio,
        s.codigo_fijo,

        -- Ultima lectura ANTES del periodo actual (sera la lectura_anterior)
        ISNULL(ult.lectura_actual, 0)                        AS lectura_anterior_valor,
        ult.fecha_lectura                                    AS fecha_ultima_lectura,

        -- Ya fue leido en el periodo actual?
        CASE WHEN act.id_lectura IS NOT NULL THEN 1 ELSE 0 END AS ya_leido,
        act.id_lectura                                       AS id_lectura_actual,
        act.lectura_anterior                                 AS lect_ant_registrada,
        act.lectura_actual                                   AS lect_act_registrada,
        act.consumo_m3                                       AS consumo_registrado,
        act.observacion                                      AS observacion_registrada,
        act.dias_lectura                                     AS dias_registrados

    FROM medidor m
    INNER JOIN socio s
        ON s.medidor_id_medidor = m.id_medidor
        AND s.ruta_id_ruta = @id_ruta

    -- Ultima lectura de otro periodo (para obtener lectura_anterior)
    OUTER APPLY (
        SELECT TOP 1
            l.lectura_actual,
            l.fecha_lectura
        FROM lectura l
        WHERE l.medidor_id_medidor = m.id_medidor
          AND l.periodo_id_periodo <> @id_periodo
        ORDER BY l.fecha_lectura DESC
    ) ult

    -- Lectura del periodo actual (para saber si ya fue registrada)
    LEFT JOIN lectura act
        ON act.medidor_id_medidor  = m.id_medidor
        AND act.periodo_id_periodo = @id_periodo

    ORDER BY s.codigo_fijo ASC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_medidores_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- LISTAR MEDIDORES LIBRES (no asignados a ningun socio)
--
-- El COUNT y el SELECT de datos deben filtrar por lo MISMO. El total contaba
-- todos los medidores mientras la lista solo devolvia los libres, asi que la
-- paginacion mostraba paginas vacias (15 registros anunciados, 0 filas).
-- El filtro de busqueda tampoco puede mirar al socio: estos medidores no
-- tienen uno.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_medidores_socio]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    -- Total de registros para la paginacion (mismos filtros que los datos)
    SELECT COUNT(*) AS TotalRegistros
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE s.medidor_id_medidor IS NULL
      AND (
        @Busqueda = ''
        OR m.serie       LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero AS VARCHAR) LIKE '%' + @Busqueda + '%'
    );

    -- Datos paginados
    SELECT
        m.id_medidor,
        m.serie,
        m.numero,
        m.fecha_instalacion,
        s.nombre_socio,
        s.codigo_fijo
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE s.medidor_id_medidor IS NULL
      AND (
        @Busqueda = ''
        OR m.serie       LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero AS VARCHAR) LIKE '%' + @Busqueda + '%'
    )
    ORDER BY m.id_medidor DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_metodo_pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE PROCEDURE [dbo].[sp_listar_metodo_pago]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT COUNT(*) AS TotalRegistros
    FROM metodo_pago
    WHERE (@Busqueda = ''
           OR metodo LIKE '%' + @Busqueda + '%'
           OR referencia LIKE '%' + @Busqueda + '%');

    SELECT
        id_metodo_pago,
        metodo,
        referencia
    FROM metodo_pago
    WHERE (@Busqueda = ''
           OR metodo LIKE '%' + @Busqueda + '%'
           OR referencia LIKE '%' + @Busqueda + '%')
    ORDER BY id_metodo_pago DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_notificacion_socios]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- LISTAR SOCIOS asignados a una notificacion
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_listar_notificacion_socios]
(
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ns.id_notificacion_socio,
        ns.socio_id_socio,
        s.nombre_socio,
        s.codigo_fijo
    FROM notificacion_socio ns
    INNER JOIN socio s ON s.id_socio = ns.socio_id_socio
    WHERE ns.notificacion_id_notificacion = @IdNotificacion;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_notificaciones]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_listar_notificaciones]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT COUNT(*) AS TotalRegistros
    FROM notificacion
    WHERE (@Busqueda = ''
           OR titulo LIKE '%' + @Busqueda + '%'
           OR tipo LIKE '%' + @Busqueda + '%');

    SELECT
        id_notificacion,
        titulo,
        mensaje,
        tipo,
        fecha_publicacion,
        estado
    FROM notificacion
    WHERE (@Busqueda = ''
           OR titulo LIKE '%' + @Busqueda + '%'
           OR tipo LIKE '%' + @Busqueda + '%')
    ORDER BY id_notificacion DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_pagos_caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Pagos registrados en una caja (para la sesion del cajero) ---------------
CREATE   PROCEDURE [dbo].[sp_listar_pagos_caja]
    @id_caja INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.id_pago,
        p.fecha_pago,
        p.monto_pagado,
        p.vuelto,
        p.estado_pago,
        mp.metodo        AS nombre_metodo,
        p.aviso_id_aviso,
        s.nombre_socio,
        s.codigo_fijo
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    LEFT  JOIN socio s ON s.id_socio = a.socio_id_socio
    WHERE p.caja_id_caja = @id_caja
    ORDER BY p.id_pago DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_pagos_qr_pendientes]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 6. Pagos QR pendientes (para conciliacion con Libelula) ---------------------
CREATE   PROCEDURE [dbo].[sp_listar_pagos_qr_pendientes]
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpieza: los QR pendientes de dias anteriores ya vencieron en Libelula
    -- (fecha_vencimiento = mismo dia), asi que aqui quedan EXPIRADO y dejan
    -- de consultarse en cada conciliacion.
    UPDATE pago SET estado_pago = 'EXPIRADO'
    WHERE estado_pago = 'PENDIENTE'
      AND id_transaccion IS NOT NULL
      AND CAST(fecha_pago AS DATE) < CAST(GETDATE() AS DATE);

    SELECT p.id_pago, p.identificador_deuda, p.id_transaccion,
           p.monto_pagado, p.fecha_pago, p.aviso_id_aviso
    FROM pago p
    WHERE p.estado_pago = 'PENDIENTE'
      AND p.id_transaccion IS NOT NULL
    ORDER BY p.id_pago;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_permisos]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- LISTAR TODOS LOS PERMISOS (agrupados por módulo)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_permisos]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_permiso, accion, descripcion, modulo
    FROM [dbo].[permiso]
    ORDER BY
        CASE modulo
            WHEN 'Administración'      THEN 1
            WHEN 'Atención al Cliente' THEN 2
            WHEN 'Operaciones'         THEN 3
            WHEN 'Caja y Pagos'        THEN 4
            WHEN 'Configuración'       THEN 5
            WHEN 'Portal de Socios'    THEN 6
            WHEN 'Reportes'            THEN 7
            ELSE 99
        END,
        accion
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_permisos_por_rol]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- LISTAR PERMISOS DE UN ROL ESPECÍFICO
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_permisos_por_rol]
    @id_rol INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.id_permiso, p.accion, p.descripcion
    FROM [dbo].[permiso] p
    INNER JOIN [dbo].[rol_permiso] rp ON rp.permiso_id_permiso = p.id_permiso
    WHERE rp.rol_id_rol = @id_rol
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_personas_disponibles_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- LISTAR PERSONAS DISPONIBLES PARA SOCIO
-- Regla institucional: una persona puede tener como máximo 4 socios
-- (4 medidores). Excluye a quienes ya alcanzaron ese tope.
-- Mismo shape que sp_listar_clientes (total + datos) para reusar el mapeo.
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_listar_personas_disponibles_socio]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset    INT = (@Pagina - 1) * @TamanoPagina;
    DECLARE @MaxSocios INT = 4;

    SELECT COUNT(*) AS TotalRegistros
    FROM cliente c
    WHERE (@Busqueda = ''
           OR c.nombre_completo LIKE '%' + @Busqueda + '%'
           OR c.ci              LIKE '%' + @Busqueda + '%')
      AND (SELECT COUNT(*) FROM socio s WHERE s.cliente_id_cliente = c.id_cliente) < @MaxSocios;

    SELECT
        c.id_cliente,
        c.nombre_completo,
        c.ci,
        c.genero,
        c.telefono,
        c.email,
        c.fecha_nacimiento,
        c.fecha_registro,
        c.estado
    FROM cliente c
    WHERE (@Busqueda = ''
           OR c.nombre_completo LIKE '%' + @Busqueda + '%'
           OR c.ci              LIKE '%' + @Busqueda + '%')
      AND (SELECT COUNT(*) FROM socio s WHERE s.cliente_id_cliente = c.id_cliente) < @MaxSocios
    ORDER BY c.id_cliente DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_roles]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--listar roles sp
CREATE   procedure [dbo].[sp_listar_roles]
    @IncluirSuperadmin BIT = 1   -- 0 = ocultar el rol SUPERADMIN (para no-superadmins)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [id_rol]
          ,[nombre]
          ,[descripcion]
          ,[estado]
      FROM [dbo].[rol]
     WHERE (@IncluirSuperadmin = 1 OR nombre <> 'SUPERADMIN')
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_roles_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_listar_roles_socio]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [id_rol_socio]
          ,[rol_socio]
      FROM [dbo].[rol_socio]
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_rutas]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Listar rutas
CREATE PROCEDURE [dbo].[sp_listar_rutas]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [id_ruta], [ruta], [descripcion]
    FROM [dbo].[ruta]
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- SP_Socio_Listar (con paginación y búsqueda)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_socio]
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        s.id_socio,
        s.nombre_socio,
        s.cliente_id_cliente,
        c.nombre_completo                  AS nombre_cliente,
        c.ci                               AS ci_cliente,
        c.email                            AS email_cliente,
        s.rol_socio_id_rol_socio,
        rs.rol_socio                       AS nombre_rol_socio,
        s.medidor_id_medidor,
        m.serie                            AS serie_medidor,
        s.ruta_id_ruta,
        r.ruta                             AS nombre_ruta,
        s.ubicacion,
        s.num_casa,
        s.num_ocupantes,
        s.tipo_instalacion,
        s.dim_instalacion,
        s.actividad,
        s.categoria,
        s.fecha_registro,
        s.codigo_fijo,
        s.estado
    FROM socio s
    INNER JOIN cliente      c  ON c.id_cliente      = s.cliente_id_cliente
    INNER JOIN rol_socio    rs ON rs.id_rol_socio   = s.rol_socio_id_rol_socio
    LEFT JOIN  medidor      m  ON m.id_medidor      = s.medidor_id_medidor
    INNER JOIN ruta         r  ON r.id_ruta         = s.ruta_id_ruta
    WHERE
        s.nombre_socio     LIKE '%' + @Busqueda + '%'
        OR c.nombre_completo LIKE '%' + @Busqueda + '%'
        OR c.ci              LIKE '%' + @Busqueda + '%'
        OR m.serie           LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
    ORDER BY s.id_socio DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total registros para paginación
    SELECT COUNT(*) AS TotalRegistros
    FROM socio s
    INNER JOIN cliente c ON c.id_cliente = s.cliente_id_cliente
    LEFT JOIN  medidor  m ON m.id_medidor  = s.medidor_id_medidor
    WHERE
        s.nombre_socio       LIKE '%' + @Busqueda + '%'
        OR c.nombre_completo LIKE '%' + @Busqueda + '%'
        OR c.ci              LIKE '%' + @Busqueda + '%'
        OR m.serie           LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_tarifa]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- TARIFA  (una tarifa por rol_socio: consumo_minimo_m3 / monto_minimo / precio_m3)
--
-- Las tarifas NO se siembran desde aqui: las filas ya existen en la base. Este
-- archivo solo define procedimientos y es re-ejecutable (CREATE OR ALTER).
-- =============================================================================

-- =============================================
-- LISTAR TARIFAS
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_tarifa]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.id_tarifa,
        u.consumo_minimo_m3,
        u.monto_minimo,
        u.precio_m3,
        u.rol_socio_id_rol_socio,
        r.rol_socio AS nombre_rol
    FROM [dbo].[tarifa] u
    -- El JOIN unia rol_socio.id_rol_socio contra tarifa.id_tarifa (la PK de la
    -- tarifa, no su FK). Coincidia por casualidad mientras id_tarifa y
    -- rol_socio_id_rol_socio llevaban el mismo valor; con una tarifa mas, el
    -- listado mostraba el rol equivocado o perdia la fila.
    INNER JOIN [dbo].[rol_socio] r ON r.id_rol_socio = u.rol_socio_id_rol_socio
END
GO
/****** Object:  StoredProcedure [dbo].[sp_listar_tipo_cargo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Listar
CREATE   PROCEDURE [dbo].[sp_listar_tipo_cargo]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [id_tipo], [nombre], [monto], [estado], [automatico]
    FROM [dbo].[tipo_cargo]
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listar_usuarios]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- LISTAR USUARIOS
-- =============================================
CREATE   PROCEDURE [dbo].[sp_listar_usuarios]
    @IncluirSuperadmin BIT = 1   -- 0 = ocultar usuarios con rol SUPERADMIN (para no-superadmins)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.id_usuario_admin,
        u.nombre,
        u.apellido,
        u.usuario,
        u.estado,
        u.fecha_creacion,
        u.rol_id_rol,
        r.nombre AS nombre_rol
    FROM [dbo].[usuario_admin] u
    INNER JOIN [dbo].[rol] r ON r.id_rol = u.rol_id_rol
    WHERE (@IncluirSuperadmin = 1 OR r.nombre <> 'SUPERADMIN')
END
GO
/****** Object:  StoredProcedure [dbo].[sp_login_admin]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   PROCEDURE [dbo].[sp_login_admin]
(
    @Usuario    VARCHAR(255),
    @Contrasena VARCHAR(550),
    @Resultado  INT          OUTPUT,   -- 1 = OK, 0 = credenciales inválidas, -1 = cuenta bloqueada
    @Mensaje    VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    DECLARE @MAX_INTENTOS INT = 5;    -- intentos permitidos antes de bloquear
    DECLARE @MIN_BLOQUEO  INT = 15;   -- minutos de bloqueo

    DECLARE @id        INT,
            @hash      VARCHAR(550),
            @intentos  INT,
            @bloqueado DATETIME,
            @estadoU   BIT,
            @estadoR   BIT,
            @idRol     INT;

    SELECT
        @id        = U.id_usuario_admin,
        @hash      = U.contraseña,
        @intentos  = U.intentos_fallidos,
        @bloqueado = U.bloqueado_hasta,
        @estadoU   = U.estado,
        @estadoR   = R.estado,
        @idRol     = R.id_rol
    FROM usuario_admin U
    INNER JOIN rol R ON U.rol_id_rol = R.id_rol
    WHERE U.usuario = @Usuario;

    -- Usuario inexistente o inactivo: mismo mensaje genérico (no revelar si la cuenta existe)
    IF @id IS NULL OR @estadoU = 0 OR @estadoR = 0
    BEGIN
        SET @Mensaje = 'Usuario o contraseña incorrectos, o el usuario/rol no está activo.';
        SELECT NULL AS id_usuario_admin, NULL AS nombre, NULL AS apellido,
               NULL AS usuario, NULL AS EstadoUsuario, NULL AS id_rol, NULL AS NombreRol
        WHERE 1 = 0;
        SELECT NULL AS id_permiso, NULL AS accion WHERE 1 = 0;
        RETURN;
    END

    -- Cuenta bloqueada por intentos fallidos
    IF @bloqueado IS NOT NULL AND @bloqueado > GETDATE()
    BEGIN
        SET @Resultado = -1;
        SET @Mensaje   = 'Cuenta bloqueada por intentos fallidos. Intenta nuevamente en '
                       + CAST(DATEDIFF(MINUTE, GETDATE(), @bloqueado) + 1 AS VARCHAR)
                       + ' minuto(s).';
        SELECT NULL AS id_usuario_admin, NULL AS nombre, NULL AS apellido,
               NULL AS usuario, NULL AS EstadoUsuario, NULL AS id_rol, NULL AS NombreRol
        WHERE 1 = 0;
        SELECT NULL AS id_permiso, NULL AS accion WHERE 1 = 0;
        RETURN;
    END

    -- Contraseña incorrecta: acumular intento y bloquear si llegó al límite
    IF @hash <> @Contrasena
    BEGIN
        SET @intentos = @intentos + 1;

        IF @intentos >= @MAX_INTENTOS
        BEGIN
            UPDATE usuario_admin
            SET intentos_fallidos = 0,
                bloqueado_hasta   = DATEADD(MINUTE, @MIN_BLOQUEO, GETDATE())
            WHERE id_usuario_admin = @id;

            DECLARE @accBloqueo VARCHAR(255) =
                'Cuenta bloqueada por ' + CAST(@MIN_BLOQUEO AS VARCHAR) + ' minutos tras '
                + CAST(@MAX_INTENTOS AS VARCHAR) + ' intentos fallidos de inicio de sesión';
            EXEC dbo.sp_registrar_bitacora @accBloqueo, @id;

            SET @Resultado = -1;
            SET @Mensaje   = 'Cuenta bloqueada por ' + CAST(@MIN_BLOQUEO AS VARCHAR)
                           + ' minutos tras ' + CAST(@MAX_INTENTOS AS VARCHAR)
                           + ' intentos fallidos.';
        END
        ELSE
        BEGIN
            UPDATE usuario_admin
            SET intentos_fallidos = @intentos
            WHERE id_usuario_admin = @id;

            DECLARE @accFallo VARCHAR(255) =
                'Intento de inicio de sesión fallido (' + CAST(@intentos AS VARCHAR)
                + ' de ' + CAST(@MAX_INTENTOS AS VARCHAR) + ')';
            EXEC dbo.sp_registrar_bitacora @accFallo, @id;

            SET @Mensaje = 'Usuario o contraseña incorrectos, o el usuario/rol no está activo.';
        END

        SELECT NULL AS id_usuario_admin, NULL AS nombre, NULL AS apellido,
               NULL AS usuario, NULL AS EstadoUsuario, NULL AS id_rol, NULL AS NombreRol
        WHERE 1 = 0;
        SELECT NULL AS id_permiso, NULL AS accion WHERE 1 = 0;
        RETURN;
    END

    -- Login exitoso: resetear contador y bloqueo
    UPDATE usuario_admin
    SET intentos_fallidos = 0,
        bloqueado_hasta   = NULL
    WHERE id_usuario_admin = @id;

    SET @Resultado = 1;
    SET @Mensaje   = 'Acceso concedido.';

    -- Primer ResultSet: datos del usuario
    SELECT
        U.id_usuario_admin,
        U.nombre,
        U.apellido,
        U.usuario,
        U.estado AS EstadoUsuario,
        R.id_rol,
        R.nombre AS NombreRol
    FROM usuario_admin U
    INNER JOIN rol R ON U.rol_id_rol = R.id_rol
    WHERE U.id_usuario_admin = @id;

    -- Segundo ResultSet: permisos del rol
    SELECT
        P.id_permiso,
        P.accion
    FROM rol_permiso RP
    INNER JOIN permiso P ON RP.permiso_id_permiso = P.id_permiso
    WHERE RP.rol_id_rol = @idRol;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_login_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- SP LOGIN SOCIO (Panel Cliente)
--
-- Espejo de sp_login_admin: el conteo de intentos fallidos y el bloqueo viven
-- aqui dentro, no en la capa web, para que ninguna ruta alterna los salte.
-- Requiere la Migracion 14 (cuenta_socio.intentos_fallidos / bloqueado_hasta).
--
-- Los mensajes de fallo son deliberadamente genericos: no revelan si el
-- usuario existe. La unica excepcion es el bloqueo, que si se informa porque
-- el socio necesita saber por que no puede entrar.
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_login_socio]
(
    @Usuario    VARCHAR(150),
    @Contrasena VARCHAR(500),
    @Resultado  INT          OUTPUT,   -- 1 = OK, 0 = credenciales invalidas, -1 = cuenta bloqueada
    @Mensaje    VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    DECLARE @MAX_INTENTOS INT = 5;    -- intentos permitidos antes de bloquear
    DECLARE @MIN_BLOQUEO  INT = 15;   -- minutos de bloqueo

    DECLARE @id        INT,
            @hash      VARCHAR(500),
            @intentos  INT,
            @bloqueado DATETIME,
            @estado    BIT;

    SELECT
        @id        = cs.id_cuenta_socio,
        @hash      = cs.contraseña,
        @intentos  = cs.intentos_fallidos,
        @bloqueado = cs.bloqueado_hasta,
        @estado    = cs.estado
    FROM cuenta_socio cs
    WHERE cs.usuario = @Usuario;

    -- Cuenta inexistente o inactiva: mismo mensaje generico
    IF @id IS NULL OR @estado = 0
    BEGIN
        SET @Mensaje = 'Usuario o contraseña incorrectos, o la cuenta no está activa.';
        SELECT NULL AS id_cuenta_socio, NULL AS usuario, NULL AS EstadoCuenta,
               NULL AS ultimo_acceso, NULL AS id_socio, NULL AS nombre_socio,
               NULL AS id_rol_socio, NULL AS NombreRolSocio
        WHERE 1 = 0;
        RETURN;
    END

    -- Cuenta bloqueada por intentos fallidos
    IF @bloqueado IS NOT NULL AND @bloqueado > GETDATE()
    BEGIN
        SET @Resultado = -1;
        SET @Mensaje   = 'Cuenta bloqueada por intentos fallidos. Intenta nuevamente en '
                       + CAST(DATEDIFF(MINUTE, GETDATE(), @bloqueado) + 1 AS VARCHAR)
                       + ' minuto(s).';
        SELECT NULL AS id_cuenta_socio, NULL AS usuario, NULL AS EstadoCuenta,
               NULL AS ultimo_acceso, NULL AS id_socio, NULL AS nombre_socio,
               NULL AS id_rol_socio, NULL AS NombreRolSocio
        WHERE 1 = 0;
        RETURN;
    END

    -- Contraseña incorrecta: acumular intento y bloquear al llegar al limite
    IF @hash <> @Contrasena
    BEGIN
        SET @intentos = @intentos + 1;

        IF @intentos >= @MAX_INTENTOS
        BEGIN
            UPDATE cuenta_socio
            SET intentos_fallidos = 0,
                bloqueado_hasta   = DATEADD(MINUTE, @MIN_BLOQUEO, GETDATE())
            WHERE id_cuenta_socio = @id;

            SET @Resultado = -1;
            SET @Mensaje   = 'Cuenta bloqueada por ' + CAST(@MIN_BLOQUEO AS VARCHAR)
                           + ' minutos tras ' + CAST(@MAX_INTENTOS AS VARCHAR)
                           + ' intentos fallidos.';
        END
        ELSE
        BEGIN
            UPDATE cuenta_socio
            SET intentos_fallidos = @intentos
            WHERE id_cuenta_socio = @id;

            SET @Mensaje = 'Usuario o contraseña incorrectos, o la cuenta no está activa.';
        END

        SELECT NULL AS id_cuenta_socio, NULL AS usuario, NULL AS EstadoCuenta,
               NULL AS ultimo_acceso, NULL AS id_socio, NULL AS nombre_socio,
               NULL AS id_rol_socio, NULL AS NombreRolSocio
        WHERE 1 = 0;
        RETURN;
    END

    -- Login exitoso: resetear contador, bloqueo y sellar el ultimo acceso
    UPDATE cuenta_socio
    SET intentos_fallidos = 0,
        bloqueado_hasta   = NULL,
        ultimo_acceso     = GETDATE()
    WHERE id_cuenta_socio = @id;

    SET @Resultado = 1;
    SET @Mensaje   = 'Acceso concedido.';

    SELECT
        cs.id_cuenta_socio,
        cs.usuario,
        cs.estado           AS EstadoCuenta,
        cs.ultimo_acceso,
        s.id_socio,
        s.nombre_socio,
        rs.id_rol_socio,
        rs.rol_socio        AS NombreRolSocio
    FROM cuenta_socio cs
    INNER JOIN socio s      ON cs.socio_id_socio        = s.id_socio
    INNER JOIN rol_socio rs ON s.rol_socio_id_rol_socio = rs.id_rol_socio
    WHERE cs.id_cuenta_socio = @id;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_marcar_aviso_impreso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC dbo.sp_imprimir_aviso 30;   -- usá un id_aviso que exista


-- =============================================================================
-- sp_marcar_aviso_impreso
-- -----------------------------------------------------------------------------
-- Avanza el aviso al estado IMPRESO de forma AUTOMATICA, al abrir la vista de
-- impresion. Reemplaza el cambio manual de estado que hacia el select de la
-- pantalla de Avisos (LECTURADO / IMPRESO).
--
-- Es idempotente y no lanza error: si el aviso ya esta IMPRESO, PAGADO o
-- ANULADO simplemente no hace nada y devuelve @Resultado = 0. Solo avanza desde
-- GENERADO o LECTURADO (LECTURADO queda por compatibilidad con avisos viejos;
-- los nuevos nacen GENERADO y ya implican lectura registrada).
--
-- @Resultado = 1 -> el estado cambio realmente (la capa CN registra bitacora).
-- @Resultado = 0 -> no habia nada que cambiar (o el aviso no existe).
-- =============================================================================
CREATE   PROCEDURE [dbo].[sp_marcar_aviso_impreso]
    @id_aviso  INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        DECLARE @estado_actual VARCHAR(150);
        SELECT @estado_actual = e.estado
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @estado_actual IS NULL
        BEGIN
            SET @Mensaje = 'Aviso no encontrado.';
            RETURN;
        END

        IF @estado_actual NOT IN ('GENERADO', 'LECTURADO')
        BEGIN
            SET @Mensaje = 'El aviso ya estaba en estado ' + @estado_actual + '.';
            RETURN;
        END

        DECLARE @id_impreso INT;
        SELECT @id_impreso = id_estado FROM estado WHERE estado = 'IMPRESO';

        IF @id_impreso IS NULL
        BEGIN
            SET @Mensaje = 'Tabla estado no inicializada (falta IMPRESO).';
            RETURN;
        END

        UPDATE aviso
        SET estado_id_estado = @id_impreso
        WHERE id_aviso = @id_aviso;

        SET @Resultado = 1;
        SET @Mensaje   = 'Aviso marcado como IMPRESO.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_notificar_pago_confirmado]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ══════════════════════════════════════════════════════════════════
-- RF-27: Notificaciones AUTOMATICAS al portal del socio
-- ══════════════════════════════════════════════════════════════════

-- Confirmacion de pago: se invoca desde sp_registrar_pago_aviso y
-- sp_confirmar_pago_qr (despues del COMMIT; si falla no afecta el cobro).
CREATE   PROCEDURE [dbo].[sp_notificar_pago_confirmado]
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id_socio INT, @monto DECIMAL(30,2), @periodo VARCHAR(50), @id_aviso INT;
        SELECT @id_socio = a.socio_id_socio, @monto = p.monto_pagado,
               @periodo = per.periodo, @id_aviso = a.id_aviso
        FROM pago p
        INNER JOIN aviso a     ON a.id_aviso    = p.aviso_id_aviso
        INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
        WHERE p.id_pago = @id_pago;

        IF @id_socio IS NULL RETURN;   -- pago sin aviso (inscripcion): sin notificacion

        DECLARE @id_notif INT;
        INSERT INTO notificacion (titulo, mensaje, tipo, fecha_publicacion, estado)
        VALUES ('Pago confirmado',
                'Tu pago de Bs. ' + CONVERT(VARCHAR, @monto) +
                ' del aviso del periodo ' + @periodo +
                ' fue registrado correctamente. [Aviso #' + CAST(@id_aviso AS VARCHAR) + ']',
                'Pago', CAST(GETDATE() AS DATE), 1);
        SET @id_notif = CAST(SCOPE_IDENTITY() AS INT);

        INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
        VALUES (CAST(GETDATE() AS DATE), 0, @id_notif, @id_socio);
    END TRY
    BEGIN CATCH
        -- best-effort: una notificacion fallida nunca debe romper un cobro
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_cliente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_obtener_cliente]
(
    @IdCliente INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_cliente,
        nombre_completo,
        ci,
        genero,
        telefono,
        email,
        fecha_nacimiento,
        fecha_registro,
        estado
    FROM cliente
    WHERE id_cliente = @IdCliente;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_costo_inscripcion_vigente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 4. sp_obtener_costo_inscripcion_vigente
-- =============================================
CREATE   PROCEDURE [dbo].[sp_obtener_costo_inscripcion_vigente]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 1 costo_inscripcion 
    FROM periodo 
    WHERE costo_inscripcion IS NOT NULL 
    ORDER BY id_periodo DESC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_cuenta_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_obtener_cuenta_socio]
(
    @IdCuentaSocio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_cuenta_socio,
        usuario,
        ultimo_acceso,
        estado,
        socio_id_socio
    FROM cuenta_socio
    WHERE id_cuenta_socio = @IdCuentaSocio;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_estadisticas_dashboard]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_obtener_estadisticas_dashboard]
    @periodo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_periodo INT;
    SELECT @id_periodo = id_periodo FROM periodo WHERE periodo = @periodo;

    SELECT
        (SELECT COUNT(*) FROM socio)         AS TotalSocios,
        (SELECT COUNT(*) FROM cliente)       AS TotalClientes,
        (SELECT COUNT(*) FROM medidor)       AS TotalMedidores,
        (SELECT COUNT(*) FROM ruta)          AS TotalRutas,
        (SELECT COUNT(*) FROM usuario_admin) AS TotalUsuarios,
        (SELECT COUNT(*) FROM lectura WHERE periodo_id_periodo = ISNULL(@id_periodo, 0)) AS TotalLecturas,
        (SELECT COUNT(*) FROM aviso  WHERE periodo_id_periodo = ISNULL(@id_periodo, 0)) AS TotalAvisos;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_metodo_pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE PROCEDURE [dbo].[sp_obtener_metodo_pago]
(
    @IdMetodoPago INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_metodo_pago,
        metodo,
        referencia
    FROM metodo_pago
    WHERE id_metodo_pago = @IdMetodoPago;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_notificacion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_obtener_notificacion]
(
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_notificacion,
        titulo,
        mensaje,
        tipo,
        fecha_publicacion,
        estado
    FROM notificacion
    WHERE id_notificacion = @IdNotificacion;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_o_crear_periodo]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 1. Obtener o crear periodo
-- =============================================
CREATE   PROCEDURE [dbo].[sp_obtener_o_crear_periodo]
    @periodo_nombre VARCHAR(50),
    @id_periodo     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Reiniciar el OUTPUT: si el caller pasa un valor previo y el periodo NO existe,
    -- el SELECT no tocaria la variable y devolveria un id incorrecto (stale).
    SET @id_periodo = NULL;

    SELECT @id_periodo = id_periodo
    FROM periodo
    WHERE periodo = @periodo_nombre;

    IF @id_periodo IS NULL
    BEGIN
        INSERT INTO periodo (periodo) VALUES (@periodo_nombre);
        SET @id_periodo = SCOPE_IDENTITY();
    END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_pago_qr]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Obtener un pago QR por id_transaccion (para verificar el callback) -------
CREATE   PROCEDURE [dbo].[sp_obtener_pago_qr]
    @id_transaccion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.id_pago, p.identificador_deuda, p.id_transaccion, p.estado_pago,
           p.monto_pagado, p.aviso_id_aviso, p.caja_id_caja
    FROM pago p
    WHERE p.id_transaccion = @id_transaccion;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_portal_avisos_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Historial de avisos del socio --------------------------------------------
CREATE   PROCEDURE [dbo].[sp_portal_avisos_socio]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.id_aviso,
        per.periodo AS nombre_periodo,
        a.fecha_emision,
        a.fecha_vencimiento,
        l.consumo_m3,                    -- RF-26: historial de consumo
        a.total_aviso,
        a.deuda_actual,
        e.estado,
        CASE WHEN e.estado NOT IN ('PAGADO', 'ANULADO')
                  AND a.fecha_vencimiento < CAST(GETDATE() AS DATE)
             THEN 1 ELSE 0 END AS vencido
    FROM aviso a
    INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN lectura l   ON l.id_lectura   = a.lectura_id_lectura
    WHERE a.socio_id_socio = @id_socio
    ORDER BY a.id_aviso DESC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_portal_marcar_notificacion_leida]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 5. Marcar una notificacion como leida (registra la fecha de lectura) --------
CREATE   PROCEDURE [dbo].[sp_portal_marcar_notificacion_leida]
    @id_notificacion_socio INT,
    @id_socio              INT,            -- guarda: solo el dueno puede marcarla
    @Resultado             INT           OUTPUT,
    @Mensaje               NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        UPDATE notificacion_socio
        SET leido = 1, fecha_lectura = GETDATE()
        WHERE id_notificacion_socio = @id_notificacion_socio
          AND socio_id_socio = @id_socio
          AND leido = 0;

        SET @Resultado = 1;   -- idempotente: ya leida tambien es exito
        SET @Mensaje   = 'Notificacion marcada como leida.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_portal_notificaciones_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Notificaciones del socio (HU19: visibles en el portal) -------------------
CREATE   PROCEDURE [dbo].[sp_portal_notificaciones_socio]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ns.id_notificacion_socio,
        n.titulo,
        n.mensaje,
        n.tipo,
        n.fecha_publicacion,
        ns.leido,
        ns.fecha_lectura
    FROM notificacion_socio ns
    INNER JOIN notificacion n ON n.id_notificacion = ns.notificacion_id_notificacion
    WHERE ns.socio_id_socio = @id_socio
      AND n.estado = 1
    ORDER BY n.fecha_publicacion DESC, ns.id_notificacion_socio DESC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_portal_pagos_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Historial de pagos del socio (avisos e inscripcion) ----------------------
CREATE   PROCEDURE [dbo].[sp_portal_pagos_socio]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.id_pago,
        p.fecha_pago,
        p.monto_pagado,
        mp.metodo AS nombre_metodo,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion'
             ELSE 'Aviso ' + ISNULL(per.periodo, '') END AS concepto
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso   a   ON a.id_aviso    = p.aviso_id_aviso
    LEFT  JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    WHERE p.estado_pago = 'APROBADO'
      AND (a.socio_id_socio = @id_socio
           OR EXISTS (SELECT 1 FROM credito_inscripcion ci
                      WHERE ci.pago_id_pago = p.id_pago
                        AND ci.socio_id_socio = @id_socio))
    ORDER BY p.fecha_pago DESC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_portal_resumen_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- PORTAL DEL SOCIO (HU18 consulta autonoma / HU19 notificaciones visibles).
-- SPs de solo lectura sobre los datos del socio logueado, mas marcar leida.
-- =============================================================================

-- 1. Resumen del estado de cuenta del socio -----------------------------------
CREATE   PROCEDURE [dbo].[sp_portal_resumen_socio]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT ISNULL(SUM(a.deuda_actual), 0)
         FROM aviso a
         INNER JOIN estado e ON e.id_estado = a.estado_id_estado
         WHERE a.socio_id_socio = @id_socio
           AND e.estado NOT IN ('PAGADO', 'ANULADO'))          AS deuda_total,
        (SELECT COUNT(*)
         FROM aviso a
         INNER JOIN estado e ON e.id_estado = a.estado_id_estado
         WHERE a.socio_id_socio = @id_socio
           AND e.estado NOT IN ('PAGADO', 'ANULADO'))          AS avisos_pendientes,
        (SELECT COUNT(*)
         FROM aviso a
         INNER JOIN estado e ON e.id_estado = a.estado_id_estado
         WHERE a.socio_id_socio = @id_socio
           AND e.estado NOT IN ('PAGADO', 'ANULADO')
           AND a.fecha_vencimiento < CAST(GETDATE() AS DATE))  AS avisos_vencidos,
        (SELECT COUNT(*)
         FROM notificacion_socio ns
         INNER JOIN notificacion n ON n.id_notificacion = ns.notificacion_id_notificacion
         WHERE ns.socio_id_socio = @id_socio
           AND ns.leido = 0 AND n.estado = 1)                  AS notificaciones_sin_leer;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_recibo_pago_aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 5. Obtener recibo de pago ----------------------------------------------------
CREATE   PROCEDURE [dbo].[sp_recibo_pago_aviso]
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Cabecera del recibo
    SELECT 
        p.id_pago,
        p.fecha_pago,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo AS nombre_periodo,
        l.consumo_m3 AS consumo,
        a.total_consumo,
        p.monto_pagado AS total_pagado,
        p.vuelto,
        p.cajero,
        mp.metodo AS metodo_pago,
        s.categoria,
        r.ruta AS nombre_ruta,
        s.ubicacion
    FROM pago p
    INNER JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT JOIN lectura l ON l.id_lectura = a.lectura_id_lectura
    LEFT JOIN ruta r ON r.id_ruta = s.ruta_id_ruta
    LEFT JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.id_pago = @id_pago;

    -- 2. Detalles del recibo (Concepto, Subtotal)
    DECLARE @id_aviso INT = (SELECT aviso_id_aviso FROM pago WHERE id_pago = @id_pago);
    DECLARE @total_consumo DECIMAL(30,2) = (SELECT total_consumo FROM aviso WHERE id_aviso = @id_aviso);

    CREATE TABLE #Detalle (
        concepto VARCHAR(255),
        subtotal DECIMAL(30,2)
    );

    IF @total_consumo > 0
    BEGIN
        INSERT INTO #Detalle (concepto, subtotal) VALUES ('Consumo Agua', @total_consumo);
    END

    DECLARE @socio_id_rec INT, @periodo_id_rec INT;
    SELECT @socio_id_rec = socio_id_socio, @periodo_id_rec = periodo_id_periodo 
    FROM aviso 
    WHERE id_aviso = @id_aviso;

    INSERT INTO #Detalle (concepto, subtotal)
    SELECT descripcion AS concepto, monto 
    FROM cargo_extra 
    WHERE socio_id_socio = @socio_id_rec 
      AND periodo_id_periodo = @periodo_id_rec
      AND estado <> 'ANULADO';   -- un cargo anulado no se cobro: fuera del recibo

    -- Mismo criterio que sp_detalle_aviso / sp_imprimir_aviso: la cuota inicial
    -- de inscripcion se cobro aparte al registrar al socio (su pago no tiene
    -- aviso), asi que no forma parte de lo que se pago con ESTE recibo.
    INSERT INTO #Detalle (concepto, subtotal)
    SELECT 'Cuota de Inscripción (' + CAST(ci.num_cuota AS VARCHAR) + ')', ci.monto_pago
    FROM credito_inscripcion ci
    WHERE ci.socio_id_socio = @socio_id_rec 
      AND ci.periodo_id_periodo = @periodo_id_rec
      AND NOT EXISTS (SELECT 1 FROM pago pg
                      WHERE pg.id_pago = ci.pago_id_pago
                        AND pg.aviso_id_aviso IS NULL);

    SELECT concepto, subtotal FROM #Detalle;
    DROP TABLE #Detalle;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_recibo_pago_inscripcion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- sp_recibo_pago_inscripcion : recibo del pago inicial de inscripcion.
-- El pago de inscripcion NO tiene aviso (aviso_id_aviso = NULL); se ubica por
-- la cuota de credito_inscripcion que lo referencia (pago_id_pago).
-- Devuelve la MISMA forma (cabecera + detalle) que sp_recibo_pago_aviso para
-- reutilizar la vista ImprimirRecibo y el modelo CM_ReciboPago.
-- =============================================================================
CREATE   PROCEDURE [dbo].[sp_recibo_pago_inscripcion]
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cuota de inscripcion ligada a este pago (normalmente la cuota inicial)
    DECLARE @id_credito INT, @socio_id INT, @periodo_id INT, @monto_cuota DECIMAL(30,2), @num_cuota INT;
    SELECT TOP 1
        @id_credito  = ci.id_credito,
        @socio_id    = ci.socio_id_socio,
        @periodo_id  = ci.periodo_id_periodo,
        @monto_cuota = ci.monto_pago,
        @num_cuota   = ci.num_cuota
    FROM credito_inscripcion ci
    WHERE ci.pago_id_pago = @id_pago;

    -- 1. Cabecera del recibo
    SELECT
        p.id_pago,
        p.fecha_pago,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo               AS nombre_periodo,
        CAST(NULL AS DECIMAL(30,2)) AS consumo,
        CAST(0 AS DECIMAL(30,2))    AS total_consumo,
        p.monto_pagado            AS total_pagado,
        p.vuelto,
        p.cajero,
        mp.metodo                 AS metodo_pago,
        s.categoria,
        r.ruta                    AS nombre_ruta,
        s.ubicacion
    FROM pago p
    INNER JOIN credito_inscripcion ci ON ci.pago_id_pago = p.id_pago
    INNER JOIN socio s   ON s.id_socio   = ci.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = ci.periodo_id_periodo
    LEFT  JOIN ruta r    ON r.id_ruta     = s.ruta_id_ruta
    LEFT  JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.id_pago = @id_pago;

    -- 2. Detalle: la cuota de inscripcion pagada
    SELECT
        'Inscripción - Cuota ' + CAST(@num_cuota AS VARCHAR) + ' (pago inicial)' AS concepto,
        @monto_cuota AS subtotal;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_bitacora]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- BITACORA (registro de auditoria).
-- bitacora.usuario_admin_id_usuario_admin es NOT NULL con FK a usuario_admin,
-- asi que toda accion auditada necesita un usuario. Las acciones que nacen en
-- el portal del socio no tienen usuario humano: para esos casos la capa de
-- negocio manda @IdUsuario = 0 y aqui se resuelve al usuario SISTEMA
-- (Migracion 13), en vez de perder el registro por una FK invalida.
-- =============================================================================

CREATE   PROCEDURE [dbo].[sp_registrar_bitacora]
(
    @Accion    VARCHAR(255),
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Sin usuario humano (portal del socio, procesos automaticos) -> SISTEMA
    IF @IdUsuario IS NULL OR @IdUsuario <= 0
       OR NOT EXISTS (SELECT 1 FROM usuario_admin WHERE id_usuario_admin = @IdUsuario)
        SELECT @IdUsuario = (SELECT TOP 1 id_usuario_admin
                             FROM usuario_admin WHERE usuario = 'SISTEMA');

    -- Si ni siquiera existe SISTEMA no se inserta: la auditoria se pierde,
    -- pero jamas se rompe la operacion que la origino.
    IF @IdUsuario IS NULL RETURN;

    INSERT INTO bitacora (accion, fecha, hora, usuario_admin_id_usuario_admin)
    VALUES (
        @Accion,
        CAST(GETDATE() AS DATE),
        GETDATE(),
        @IdUsuario
    );
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_cargo_extra]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 1. sp_registrar_cargo_extra
-- =============================================
CREATE   PROCEDURE [dbo].[sp_registrar_cargo_extra]
    @id_periodo    INT,
    @id_socio      INT,
    @id_tipo_cargo INT,
    @monto         DECIMAL(30,2),
    @descripcion   VARCHAR(150),
    @Resultado     INT          OUTPUT,
    @Mensaje       VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
        BEGIN
            SET @Mensaje = 'El socio no existe.';
            RETURN;
        END

        -- Un periodo ya facturado NO admite cargos nuevos.
        --
        -- total_aviso es una foto inmutable tomada al generar el aviso, y
        -- sp_generar_avisos_periodo solo suma cargos del MISMO periodo del aviso
        -- (no hay arrastre al periodo siguiente). Un cargo nacido despues de la
        -- emision terminaba de una de estas dos formas, ninguna cobrable:
        --   * antes del pago  -> el UPDATE de sp_registrar_pago_aviso lo marcaba
        --                        PAGADO sin que estuviera en el total.
        --   * despues del pago-> quedaba PENDIENTE para siempre, sin aviso que
        --                        pudiera recogerlo nunca.
        -- La regla ya la asumian sp_anular_cargo_extra ('El cargo ya fue aplicado
        -- a un aviso y no puede anularse') y sp_anular_aviso ('Ya puede registrar
        -- cargos y regenerar el aviso'); faltaba implementarla en el alta.
        -- Vive en el SP a proposito: la advertencia de la vista se podia ignorar.
        DECLARE @id_aviso_activo INT, @nombre_periodo VARCHAR(50);

        SELECT TOP 1 @id_aviso_activo = a.id_aviso
        FROM aviso a
        WHERE a.socio_id_socio     = @id_socio
          AND a.periodo_id_periodo = @id_periodo
          AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO');

        IF @id_aviso_activo IS NOT NULL
        BEGIN
            SELECT @nombre_periodo = periodo FROM periodo WHERE id_periodo = @id_periodo;
            SET @Mensaje = 'El periodo ' + ISNULL(@nombre_periodo, '') +
                           ' ya fue facturado para este socio (aviso #' +
                           CAST(@id_aviso_activo AS VARCHAR) + '). Registre el cargo en el ' +
                           'periodo siguiente, o anule ese aviso y vuelva a generarlo.';
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM cargo_extra
            WHERE socio_id_socio      = @id_socio
              AND periodo_id_periodo  = @id_periodo
              AND tipo_cargo_id_tipo  = @id_tipo_cargo
              AND estado              = 'PENDIENTE'
        )
        BEGIN
            SET @Mensaje = 'Ya existe un cargo pendiente de este tipo para el socio en el periodo seleccionado.';
            RETURN;
        END

        INSERT INTO cargo_extra
            (monto, descripcion, fecha_registro, estado, tipo_cargo_id_tipo, socio_id_socio, periodo_id_periodo)
        VALUES
            (@monto, @descripcion, CAST(GETDATE() AS DATE), 'PENDIENTE', @id_tipo_cargo, @id_socio, @id_periodo);

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Cargo extra registrado correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_cliente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_registrar_cliente]
(
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @Email           VARCHAR(150),
    @FechaNacimiento DATE,
    @Resultado       INT          OUTPUT,
    @Mensaje         VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Se guarda ya normalizado: el email viaja tal cual a Libelula como
    -- email_cliente, y un espacio al inicio o al final rompe el registro
    -- de la deuda. NULLIF deja en NULL lo que solo tenia espacios.
    SET @Email = NULLIF(LTRIM(RTRIM(@Email)), '');

    -- Email obligatorio. La regla tambien esta en CN_Cliente, pero se repite
    -- aqui para que ninguna ruta pueda esquivarla: sin email el socio no puede
    -- tener cuenta de portal (sp_registrar_cuenta_socio lo rechaza) ni pagar
    -- con QR (la pasarela exige el correo del cliente).
    IF @Email IS NULL
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El email es obligatorio (requerido para pagos por QR).';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM cliente WHERE ci = @CI)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El CI ya está registrado.';
        RETURN;
    END

    -- Email único (se usa como referencia para pagos QR)
    IF EXISTS (SELECT 1 FROM cliente WHERE LTRIM(RTRIM(email)) = @Email)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El email ya está registrado en otro cliente.';
        RETURN;
    END

    INSERT INTO cliente (
        nombre_completo,
        ci,
        genero,
        telefono,
        email,
        fecha_nacimiento,
        fecha_registro,
        estado
    )
    VALUES (
        @NombreCompleto,
        @CI,
        @Genero,
        @Telefono,
        @Email,
        @FechaNacimiento,
        CAST(GETDATE() AS DATE),
        1
    );

    SET @Resultado = 1;
    SET @Mensaje   = 'Cliente registrado correctamente.';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_cuenta_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_registrar_cuenta_socio]
(
    @Usuario        VARCHAR(150),
    @Contrasena     VARCHAR(500),
    @IdSocio        INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE usuario = @Usuario)
    BEGIN
        SELECT 0 AS Resultado, 'El nombre de usuario ya está registrado.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE socio_id_socio = @IdSocio)
    BEGIN
        SELECT 0 AS Resultado, 'El socio ya tiene una cuenta asignada.' AS Mensaje;
        RETURN;
    END

    -- El portal ofrece pago por QR y la pasarela exige el email del cliente
    IF NOT EXISTS (
        SELECT 1
        FROM socio s
        INNER JOIN cliente c ON c.id_cliente = s.cliente_id_cliente
        WHERE s.id_socio = @IdSocio
          AND c.email IS NOT NULL
          AND LTRIM(RTRIM(c.email)) <> ''
    )
    BEGIN
        SELECT 0 AS Resultado,
               'El socio no tiene email registrado. Registre el email en el módulo Clientes antes de crearle una cuenta del portal.' AS Mensaje;
        RETURN;
    END

    INSERT INTO cuenta_socio (
        usuario,
        contraseña,
        ultimo_acceso,
        estado,
        socio_id_socio
    )
    VALUES (
        @Usuario,
        CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Contrasena), 2),
        GETDATE(),
        1,
        @IdSocio
    );

    SELECT 1 AS Resultado, 'Cuenta de socio registrada correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_lectura]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. Registrar una lectura
-- =============================================
CREATE   PROCEDURE [dbo].[sp_registrar_lectura]
    @fecha_lectura                  DATE,
    @lectura_anterior               INT,
    @lectura_actual                 INT,
    @observacion                    VARCHAR(255),
    @usuario_admin_id_usuario_admin INT,
    @medidor_id_medidor             INT,
    @periodo_id_periodo             INT,
    @ruta_id_ruta                   INT          = NULL, -- Se mantiene en firma por compatibilidad C#
    @Resultado                      INT          OUTPUT,
    @Mensaje                        VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;

    BEGIN TRY

        -- Validar que no exista ya lectura para este medidor en este periodo
        IF EXISTS (
            SELECT 1 FROM lectura
            WHERE medidor_id_medidor = @medidor_id_medidor
              AND periodo_id_periodo = @periodo_id_periodo
        )
        BEGIN
            SET @Resultado = -1;
            SET @Mensaje = 'Este medidor ya tiene una lectura registrada en el periodo seleccionado.';
            RETURN;
        END

        -- Validar que lectura_actual >= lectura_anterior
        IF @lectura_actual < @lectura_anterior
        BEGIN
            SET @Resultado = -2;
            SET @Mensaje = 'La lectura actual no puede ser menor que la lectura anterior ('
                           + CAST(@lectura_anterior AS VARCHAR) + ').';
            RETURN;
        END

        -- Calcular consumo
        DECLARE @consumo_m3 DECIMAL(30,2) = @lectura_actual - @lectura_anterior;

        -- Calcular dias desde la ultima lectura
        DECLARE @dias_lectura INT = 30;
        SELECT TOP 1
            @dias_lectura = DATEDIFF(DAY, l.fecha_lectura, @fecha_lectura)
        FROM lectura l
        WHERE l.medidor_id_medidor = @medidor_id_medidor
          AND l.periodo_id_periodo <> @periodo_id_periodo
        ORDER BY l.fecha_lectura DESC;

        -- Insertar la lectura
        INSERT INTO lectura (
            fecha_lectura, lectura_anterior, lectura_actual,
            dias_lectura, observacion, consumo_m3,
            usuario_admin_id_usuario_admin,
            medidor_id_medidor, periodo_id_periodo
        )
        VALUES (
            @fecha_lectura, @lectura_anterior, @lectura_actual,
            @dias_lectura, @observacion, @consumo_m3,
            @usuario_admin_id_usuario_admin,
            @medidor_id_medidor, @periodo_id_periodo
        );

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Lectura registrada correctamente.';

    END TRY
    BEGIN CATCH
        SET @Resultado = -99;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_metodo_pago]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE PROCEDURE [dbo].[sp_registrar_metodo_pago]
(
    @Metodo       VARCHAR(150),
    @Referencia   VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM metodo_pago WHERE metodo = @Metodo)
    BEGIN
        SELECT 0 AS Resultado, 'Este método de pago ya existe.' AS Mensaje;
        RETURN;
    END

    INSERT INTO metodo_pago (
        metodo,
        referencia
    )
    VALUES (
        @Metodo,
        @Referencia
    );

    SELECT 1 AS Resultado, 'Método de pago registrado correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_notificacion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE   PROCEDURE [dbo].[sp_registrar_notificacion]
(
    @Titulo       VARCHAR(255),
    @Mensaje      VARCHAR(1000),
    @Tipo         VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- No permitir una notificación duplicada (mismo título y mensaje)
    IF EXISTS (SELECT 1 FROM notificacion
               WHERE LTRIM(RTRIM(titulo))  = LTRIM(RTRIM(@Titulo))
                 AND LTRIM(RTRIM(mensaje)) = LTRIM(RTRIM(@Mensaje)))
    BEGIN
        SELECT 0 AS IdGenerado, 0 AS Resultado, 'Ya existe una notificación con el mismo título y mensaje.' AS Mensaje;
        RETURN;
    END

    INSERT INTO notificacion (
        titulo,
        mensaje,
        tipo,
        fecha_publicacion,
        estado
    )
    VALUES (
        @Titulo,
        @Mensaje,
        @Tipo,
        CAST(GETDATE() AS DATE),
        1
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS IdGenerado, 1 AS Resultado, 'Notificacion registrada correctamente.' AS Mensaje;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_pago_aviso]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Registrar pago de un aviso (manual, completo) ---------------------------
CREATE   PROCEDURE [dbo].[sp_registrar_pago_aviso]
    @id_aviso       INT,
    @id_caja        INT,
    @id_metodo_pago INT,
    @monto_recibido DECIMAL(30,2) = NULL,   -- efectivo entregado (para vuelto). NULL = exacto
    @cajero         VARCHAR(150),
    @Resultado      INT           OUTPUT,    -- id_pago generado (>0) | 0 error
    @Mensaje        NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'No hay una caja abierta valida. Abra su caja primero.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM metodo_pago WHERE id_metodo_pago = @id_metodo_pago)
        BEGIN SET @Mensaje = 'Metodo de pago invalido.'; RETURN; END

        DECLARE @total DECIMAL(30,2), @estado VARCHAR(50);
        SELECT @total = a.total_aviso, @estado = e.estado 
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @total IS NULL BEGIN SET @Mensaje = 'Aviso no encontrado.'; RETURN; END
        IF @estado = 'PAGADO'  BEGIN SET @Mensaje = 'El aviso ya esta pagado.'; RETURN; END
        IF @estado = 'ANULADO' BEGIN SET @Mensaje = 'El aviso esta anulado.'; RETURN; END

        -- Guarda de coherencia del desglose.
        -- total_aviso es una foto tomada al generar el aviso. El cierre de ciclo de
        -- mas abajo marca PAGADO *todos* los cargos PENDIENTE del socio+periodo,
        -- dando por hecho que son exactamente los que entraron en esa foto. Si la
        -- suma no cuadra, esa premisa es falsa y cobrar dejaria marcado como pagado
        -- algo que nunca se cobro. Se aborta ANTES de recibir el dinero, que es el
        -- unico momento en que abortar es gratis.
        DECLARE @socio_chk INT, @periodo_chk INT, @consumo_chk DECIMAL(30,2);
        SELECT @socio_chk   = socio_id_socio,
               @periodo_chk = periodo_id_periodo,
               @consumo_chk = total_consumo
        FROM aviso WHERE id_aviso = @id_aviso;

        DECLARE @desglose DECIMAL(30,2) =
              @consumo_chk
            + ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                      WHERE ce.socio_id_socio     = @socio_chk
                        AND ce.periodo_id_periodo = @periodo_chk
                        AND ce.estado             = 'PENDIENTE'), 0)
            + ISNULL((SELECT SUM(ci.monto_pago) FROM credito_inscripcion ci
                      WHERE ci.socio_id_socio     = @socio_chk
                        AND ci.periodo_id_periodo = @periodo_chk
                        AND ci.estado             = 'PENDIENTE'), 0);

        IF @desglose <> @total
        BEGIN
            SET @Mensaje = 'El detalle del aviso no coincide con su total (aviso Bs. ' +
                           CONVERT(VARCHAR, @total) + ' vs. detalle Bs. ' +
                           CONVERT(VARCHAR, @desglose) + '). No se registro ningun cobro. ' +
                           'Anule el aviso y vuelva a generarlo para que el total se recalcule.';
            RETURN;
        END

        DECLARE @recibido DECIMAL(30,2) = ISNULL(@monto_recibido, @total);
        IF @recibido < @total
        BEGIN SET @Mensaje = 'El monto recibido es menor al total del aviso (el pago es completo).'; RETURN; END
        DECLARE @vuelto DECIMAL(30,3) = @recibido - @total;

        DECLARE @id_pagado INT = (SELECT id_estado FROM estado WHERE estado = 'PAGADO');

        BEGIN TRAN;

        -- Si habia un QR pendiente para este aviso, caduca (se cobro en efectivo)
        UPDATE pago SET estado_pago = 'EXPIRADO'
        WHERE aviso_id_aviso = @id_aviso
          AND estado_pago    = 'PENDIENTE'
          AND id_transaccion IS NOT NULL;

        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso,
                          metodo_pago_id_metodo_pago, vuelto, caja_id_caja)
        VALUES (GETDATE(), @total, @cajero, 'APROBADO', @id_aviso,
                @id_metodo_pago, @vuelto, @id_caja);

        DECLARE @id_pago INT = CAST(SCOPE_IDENTITY() AS INT);

        UPDATE aviso
        SET estado_id_estado = @id_pagado
        WHERE id_aviso = @id_aviso;

        -- obtener socio y periodo para cerrar ciclo
        DECLARE @socio_id INT, @periodo_id INT;
        SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo 
        FROM aviso 
        WHERE id_aviso = @id_aviso;

        -- cerrar el ciclo
        UPDATE cargo_extra
        SET estado = 'PAGADO'
        WHERE socio_id_socio = @socio_id 
          AND periodo_id_periodo = @periodo_id 
          AND estado = 'PENDIENTE';

        -- Se sella tambien el pago que la cancelo. Antes solo se cambiaba el
        -- estado y pago_id_pago quedaba NULL, asi que una cuota cobrada via
        -- aviso era indistinguible de la cuota inicial de inscripcion (que
        -- nace CANCELADO con su propio pago sin aviso).
        UPDATE credito_inscripcion
        SET estado       = 'CANCELADO',
            pago_id_pago = @id_pago
        WHERE socio_id_socio = @socio_id 
          AND periodo_id_periodo = @periodo_id 
          AND estado = 'PENDIENTE';

        COMMIT;

        -- RF-27: notificacion automatica al portal del socio (best-effort)
        EXEC dbo.sp_notificar_pago_confirmado @id_pago;

        SET @Resultado = @id_pago;
        SET @Mensaje   = 'Pago registrado correctamente. Vuelto: Bs. ' + CONVERT(VARCHAR, CAST(@vuelto AS DECIMAL(30,2)));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_pago_qr_pendiente]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Registrar pago QR PENDIENTE (despues de registrar la deuda en Libelula) --
CREATE   PROCEDURE [dbo].[sp_registrar_pago_qr_pendiente]
    @id_aviso            INT,
    @id_caja             INT           = NULL,   -- NULL = pago online sin caja
    @cajero              VARCHAR(150),
    @identificador_deuda VARCHAR(100),
    @id_transaccion      VARCHAR(100),
    @url_pasarela        VARCHAR(500)  = NULL,
    @qr_url              VARCHAR(500)  = NULL,
    @Resultado           INT           OUTPUT,   -- id_pago generado (>0) | 0 error
    @Mensaje             NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        DECLARE @total DECIMAL(30,2), @estado VARCHAR(50);
        SELECT @total = a.total_aviso, @estado = e.estado
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @total IS NULL BEGIN SET @Mensaje = 'Aviso no encontrado.'; RETURN; END
        IF @estado = 'PAGADO'  BEGIN SET @Mensaje = 'El aviso ya esta pagado.'; RETURN; END
        IF @estado = 'ANULADO' BEGIN SET @Mensaje = 'El aviso esta anulado.'; RETURN; END

        IF @id_caja IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'No hay una caja abierta valida. Abra su caja primero.'; RETURN; END

        IF EXISTS (SELECT 1 FROM pago WHERE id_transaccion = @id_transaccion)
        BEGIN SET @Mensaje = 'La transaccion ya fue registrada.'; RETURN; END

        DECLARE @id_metodo_qr INT =
            (SELECT TOP 1 id_metodo_pago FROM metodo_pago WHERE metodo = 'QR LIBELULA');
        IF @id_metodo_qr IS NULL
        BEGIN SET @Mensaje = 'Falta el metodo de pago QR LIBELULA.'; RETURN; END

        BEGIN TRAN;

        -- Un solo QR vigente por aviso: los intentos anteriores quedan EXPIRADO
        UPDATE pago SET estado_pago = 'EXPIRADO'
        WHERE aviso_id_aviso = @id_aviso
          AND estado_pago    = 'PENDIENTE'
          AND id_transaccion IS NOT NULL;

        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso,
                          metodo_pago_id_metodo_pago, vuelto, caja_id_caja,
                          identificador_deuda, id_transaccion, url_pasarela, qr_url)
        VALUES (GETDATE(), @total, @cajero, 'PENDIENTE', @id_aviso,
                @id_metodo_qr, NULL, @id_caja,
                @identificador_deuda, @id_transaccion, @url_pasarela, @qr_url);

        SET @Resultado = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT;
        SET @Mensaje = 'QR generado. A la espera de la confirmacion del pago.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP_Socio_Registrar
-- =============================================
CREATE   PROCEDURE [dbo].[sp_registrar_socio]
    @nombre_socio            VARCHAR(255),
    @cliente_id_cliente      INT,
    @rol_socio_id_rol_socio  INT,
    @ubicacion               INT           = NULL,
    @medidor_id_medidor      INT           = NULL,
    @num_casa                INT           = NULL,
    @num_ocupantes           INT           = NULL,
    @tipo_instalacion        VARCHAR(255)  = NULL,
    @dim_instalacion         VARCHAR(255)  = NULL,
    @actividad               VARCHAR(255),
    @categoria               VARCHAR(255),
    @fecha_registro          DATE,
    @ruta_id_ruta            INT,
    @codigo_fijo             INT,
    @estado                  BIT           = 1,
    @Resultado               INT OUTPUT,
    @Mensaje                 NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que el cliente exista
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @cliente_id_cliente)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El cliente seleccionado no existe.';
            RETURN;
        END

        -- Validar que el medidor no esté ya asignado a otro socio (solo si no es NULL)
        IF @medidor_id_medidor IS NOT NULL AND EXISTS (SELECT 1 FROM socio WHERE medidor_id_medidor = @medidor_id_medidor)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El medidor seleccionado ya está asignado a otro socio.';
            RETURN;
        END

        -- Validar código fijo único
        IF EXISTS (SELECT 1 FROM socio WHERE codigo_fijo = @codigo_fijo)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El código fijo ingresado ya existe.';
            RETURN;
        END

        -- Validar que no exista otro socio con el mismo nombre
        IF EXISTS (SELECT 1 FROM socio
                   WHERE LTRIM(RTRIM(nombre_socio)) = LTRIM(RTRIM(@nombre_socio)))
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'Ya existe un socio registrado con ese nombre.';
            RETURN;
        END

        INSERT INTO socio (
            nombre_socio, cliente_id_cliente, rol_socio_id_rol_socio,
            ubicacion, medidor_id_medidor, num_casa, num_ocupantes,
            tipo_instalacion, dim_instalacion, actividad, categoria,
            fecha_registro, ruta_id_ruta, codigo_fijo, estado
        )
        VALUES (
            @nombre_socio, @cliente_id_cliente, @rol_socio_id_rol_socio,
            @ubicacion, @medidor_id_medidor, @num_casa, @num_ocupantes,
            @tipo_instalacion, @dim_instalacion, @actividad, @categoria,
            @fecha_registro, @ruta_id_ruta, @codigo_fijo, @estado
        );

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Socio registrado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_registrar_socio_con_inscripcion]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- sp_registrar_socio_con_inscripcion  (Fase B)
-- Registra un socio nuevo y, en la MISMA transaccion, su credito de inscripcion:
--   * Cuota 1 = pago inicial (entero, min 500), estado CANCELADO, periodo de registro.
--   * Registra ese pago en 'pago' (sin aviso).
--   * Divide el saldo (costo - inicial) en (num_cuotas - 1) cuotas PENDIENTE,
--     enteras, resto a la ultima, en los periodos consecutivos siguientes
--     (creando los periodos que falten).
-- Reglas: total de cuotas 1..4 (1 = pago total). Costo = periodo.costo_inscripcion.
-- @Resultado = id_socio nuevo (>0) | 0 validacion | -1 excepcion.
-- =============================================================================
CREATE   PROCEDURE [dbo].[sp_registrar_socio_con_inscripcion]
    -- datos del socio
    @nombre_socio            VARCHAR(255),
    @cliente_id_cliente      INT,
    @rol_socio_id_rol_socio  INT,
    @ubicacion               INT           = NULL,
    @medidor_id_medidor      INT           = NULL,
    @num_casa                INT           = NULL,
    @num_ocupantes           INT           = NULL,
    @tipo_instalacion        VARCHAR(255)  = NULL,
    @dim_instalacion         VARCHAR(255)  = NULL,
    @actividad               VARCHAR(255),
    @categoria               VARCHAR(255),
    @fecha_registro          DATE,
    @ruta_id_ruta            INT,
    @codigo_fijo             INT,
    -- datos de la inscripcion
    @monto_inicial           DECIMAL(10,2),
    @num_cuotas              INT,            -- total de cuotas (1 a 4). 1 = pago total.
    @id_metodo_pago          INT,
    @id_caja                 INT,
    @cajero                  VARCHAR(150),
    -- salida
    @Resultado               INT           OUTPUT,
    @Mensaje                 NVARCHAR(500) OUTPUT,
    @IdPago                  INT           = NULL OUTPUT   -- id del pago inicial (para el recibo)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    SET @IdPago    = 0;

    DECLARE @MAX_CUOTAS  INT           = 4;
    DECLARE @MIN_INICIAL DECIMAL(10,2) = 500;

    BEGIN TRY
        -- ===== Validaciones del socio =====
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @cliente_id_cliente)
        BEGIN SET @Mensaje = 'El cliente seleccionado no existe.'; RETURN; END

        -- Regla institucional: una persona puede tener como máximo 4 socios (4 medidores)
        IF (SELECT COUNT(*) FROM socio WHERE cliente_id_cliente = @cliente_id_cliente) >= 4
        BEGIN SET @Mensaje = 'Esta persona ya alcanzó el máximo de 4 socios (medidores) permitidos.'; RETURN; END

        IF @medidor_id_medidor IS NOT NULL AND EXISTS (SELECT 1 FROM socio WHERE medidor_id_medidor = @medidor_id_medidor)
        BEGIN SET @Mensaje = 'El medidor seleccionado ya está asignado a otro socio.'; RETURN; END

        IF EXISTS (SELECT 1 FROM socio WHERE codigo_fijo = @codigo_fijo)
        BEGIN SET @Mensaje = 'El código fijo ingresado ya existe.'; RETURN; END

        IF EXISTS (SELECT 1 FROM socio WHERE LTRIM(RTRIM(nombre_socio)) = LTRIM(RTRIM(@nombre_socio)))
        BEGIN SET @Mensaje = 'Ya existe un socio registrado con ese nombre.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM metodo_pago WHERE id_metodo_pago = @id_metodo_pago)
        BEGIN SET @Mensaje = 'El método de pago seleccionado no existe.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'Debe tener una caja abierta para registrar la inscripción.'; RETURN; END

        -- ===== Periodo de registro y costo de inscripcion vigente =====
        DECLARE @baseDate   DATE        = DATEFROMPARTS(YEAR(@fecha_registro), MONTH(@fecha_registro), 1);
        DECLARE @periodoReg VARCHAR(50) = FORMAT(@baseDate, 'MM/yyyy');

        DECLARE @id_periodo_reg INT;
        EXEC dbo.sp_obtener_o_crear_periodo @periodoReg, @id_periodo_reg OUTPUT;

        DECLARE @costo DECIMAL(10,2);
        SELECT @costo = costo_inscripcion FROM periodo WHERE id_periodo = @id_periodo_reg;
        IF @costo IS NULL   -- fallback: ultimo costo configurado
            SELECT TOP 1 @costo = costo_inscripcion FROM periodo
            WHERE costo_inscripcion IS NOT NULL ORDER BY id_periodo DESC;

        IF @costo IS NULL
        BEGIN SET @Mensaje = 'No hay un costo de inscripción configurado en periodo.costo_inscripcion.'; RETURN; END

        -- ===== Validaciones de la inscripcion =====
        IF @monto_inicial <> FLOOR(@monto_inicial)
        BEGIN SET @Mensaje = 'El monto inicial debe ser un número entero (sin decimales).'; RETURN; END

        IF @monto_inicial < @MIN_INICIAL
        BEGIN SET @Mensaje = 'El pago inicial mínimo es Bs. ' + CAST(CAST(@MIN_INICIAL AS INT) AS VARCHAR) + '.'; RETURN; END

        IF @monto_inicial > @costo
        BEGIN SET @Mensaje = 'El pago inicial no puede superar el costo de inscripción (Bs. ' + CAST(CAST(@costo AS INT) AS VARCHAR) + ').'; RETURN; END

        IF @num_cuotas < 1 OR @num_cuotas > @MAX_CUOTAS
        BEGIN SET @Mensaje = 'El número de cuotas debe estar entre 1 y ' + CAST(@MAX_CUOTAS AS VARCHAR) + '.'; RETURN; END

        DECLARE @saldo DECIMAL(10,2) = @costo - @monto_inicial;

        IF @saldo = 0 AND @num_cuotas <> 1
        BEGIN SET @Mensaje = 'Si paga el total, debe registrarse como 1 sola cuota.'; RETURN; END

        IF @saldo > 0 AND @num_cuotas < 2
        BEGIN SET @Mensaje = 'Hay saldo a financiar: elija entre 2 y ' + CAST(@MAX_CUOTAS AS VARCHAR) + ' cuotas.'; RETURN; END

        -- ===== Transaccion =====
        BEGIN TRAN;

        -- 1) Socio
        INSERT INTO socio (
            nombre_socio, cliente_id_cliente, rol_socio_id_rol_socio,
            ubicacion, medidor_id_medidor, num_casa, num_ocupantes,
            tipo_instalacion, dim_instalacion, actividad, categoria,
            fecha_registro, ruta_id_ruta, codigo_fijo, estado
        )
        VALUES (
            @nombre_socio, @cliente_id_cliente, @rol_socio_id_rol_socio,
            @ubicacion, @medidor_id_medidor, @num_casa, @num_ocupantes,
            @tipo_instalacion, @dim_instalacion, @actividad, @categoria,
            @fecha_registro, @ruta_id_ruta, @codigo_fijo, 1
        );
        DECLARE @id_socio INT = SCOPE_IDENTITY();

        -- 2) Registrar el pago inicial (sin aviso, en la caja abierta). Efectivo -> APROBADO.
        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso, metodo_pago_id_metodo_pago, vuelto, caja_id_caja)
        VALUES (@fecha_registro, @monto_inicial, @cajero, 'APROBADO', NULL, @id_metodo_pago, NULL, @id_caja);
        SET @IdPago = CAST(SCOPE_IDENTITY() AS INT);

        -- 3) Cuota inicial: CANCELADO, en el periodo de registro, ligada a su pago
        INSERT INTO credito_inscripcion (monto_pago, estado, num_cuota, socio_id_socio, periodo_id_periodo, pago_id_pago)
        VALUES (@monto_inicial, 'CANCELADO', 1, @id_socio, @id_periodo_reg, @IdPago);

        -- 4) Cuotas financiadas: PENDIENTE, en los periodos siguientes
        IF @saldo > 0
        BEGIN
            DECLARE @financiadas INT = @num_cuotas - 1;
            DECLARE @base INT = CAST(FLOOR(@saldo / @financiadas) AS INT);
            DECLARE @resto INT = CAST(@saldo AS INT) - (@base * @financiadas);

            DECLARE @i          INT = 2;
            DECLARE @perNombre  VARCHAR(50);
            DECLARE @idPer      INT;
            DECLARE @montoCuota INT;

            WHILE @i <= @num_cuotas
            BEGIN
                SET @perNombre = FORMAT(DATEADD(MONTH, @i - 1, @baseDate), 'MM/yyyy');
                SET @idPer     = NULL;   -- evitar id stale entre iteraciones
                EXEC dbo.sp_obtener_o_crear_periodo @perNombre, @idPer OUTPUT;

                SET @montoCuota = @base;
                IF @i = @num_cuotas SET @montoCuota = @base + @resto;   -- la ultima absorbe el resto

                INSERT INTO credito_inscripcion (monto_pago, estado, num_cuota, socio_id_socio, periodo_id_periodo)
                VALUES (@montoCuota, 'PENDIENTE', @i, @id_socio, @idPer);

                SET @i = @i + 1;
            END
        END

        COMMIT;

        SET @Resultado = @id_socio;
        SET @Mensaje   = 'Socio registrado con inscripción en ' + CAST(@num_cuotas AS VARCHAR) + ' cuota(s).';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_caja]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- Modulo REPORTE (HU21 Reporte de Caja, HU22 Reporte de Morosidad).
-- Los permisos 'Generar Reporte Caja' y 'Generar Reporte Morosidad' ya estan
-- sembrados (Login.sql) y asignados al modulo 'Reportes' (Migracion 09).
-- =============================================================================

-- 1. HU21: Reporte de caja por rango de fechas y cajero opcional --------------
--    RS1: detalle de cobros (aviso o inscripcion) APROBADOS del periodo.
--    RS2: totales por metodo de pago.
--    RS3: resumen (cantidad de pagos y total recaudado).
--    Cubre UNICAMENTE el dinero que entro por una caja. Un pago del portal
--    del socio se aprueba sin caja (caja_id_caja NULL) y, al no filtrar por
--    cajero, se colaba aqui mezclado con el efectivo de ventanilla; ahora
--    tiene su propio reporte en sp_reporte_pagos_sistema.
CREATE   PROCEDURE [dbo].[sp_reporte_caja]
    @FechaInicio DATE,
    @FechaFin    DATE,
    @IdCajero    INT = NULL   -- usuario_admin de la caja; NULL = todos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.id_pago,
        p.fecha_pago,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion' ELSE 'Aviso' END AS tipo_cobro,
        ISNULL(s.nombre_socio, si.nombre_socio) AS nombre_socio,
        ISNULL(s.codigo_fijo,  si.codigo_fijo)  AS codigo_fijo,
        mp.metodo AS nombre_metodo,
        p.cajero,
        p.monto_pagado
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN caja  c  ON c.id_caja  = p.caja_id_caja
    LEFT  JOIN aviso a  ON a.id_aviso = p.aviso_id_aviso
    LEFT  JOIN socio s  ON s.id_socio = a.socio_id_socio
    -- pago de inscripcion (sin aviso): el socio via su credito
    OUTER APPLY (
        SELECT TOP 1 s2.nombre_socio, s2.codigo_fijo
        FROM credito_inscripcion ci
        INNER JOIN socio s2 ON s2.id_socio = ci.socio_id_socio
        WHERE ci.pago_id_pago = p.id_pago
    ) si
    WHERE p.estado_pago = 'APROBADO'
      AND p.caja_id_caja IS NOT NULL          -- excluye los pagos del portal
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero)
    ORDER BY p.fecha_pago;

    SELECT
        mp.metodo AS nombre_metodo,
        COUNT(*)  AS cantidad,
        SUM(p.monto_pagado) AS total
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN caja c ON c.id_caja = p.caja_id_caja
    WHERE p.estado_pago = 'APROBADO'
      AND p.caja_id_caja IS NOT NULL          -- excluye los pagos del portal
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero)
    GROUP BY mp.metodo
    ORDER BY total DESC;

    SELECT
        COUNT(*)                     AS cantidad_pagos,
        ISNULL(SUM(p.monto_pagado),0) AS total_recaudado
    FROM pago p
    LEFT JOIN caja c ON c.id_caja = p.caja_id_caja
    WHERE p.estado_pago = 'APROBADO'
      AND p.caja_id_caja IS NOT NULL          -- excluye los pagos del portal
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero);
END

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_morosidad]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. HU22: Reporte de morosidad -----------------------------------------------
--    Avisos VENCIDOS (fecha_vencimiento pasada, ni PAGADO ni ANULADO),
--    agrupados por socio, con dias de mora. Filtros: rango del vencimiento
--    y ruta, ambos opcionales.
--    RS1: detalle por aviso. RS2: resumen (socios, avisos, total adeudado).
CREATE   PROCEDURE [dbo].[sp_reporte_morosidad]
    @FechaInicio DATE = NULL,
    @FechaFin    DATE = NULL,
    @IdRuta      INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.id_socio,
        s.nombre_socio,
        s.codigo_fijo,
        r.ruta AS nombre_ruta,
        per.periodo AS nombre_periodo,
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.deuda_actual AS monto_adeudado,
        DATEDIFF(DAY, a.fecha_vencimiento, GETDATE()) AS dias_mora
    FROM aviso a
    INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
    INNER JOIN socio   s   ON s.id_socio     = a.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN ruta    r   ON r.id_ruta      = s.ruta_id_ruta
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND a.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND (@FechaInicio IS NULL OR a.fecha_vencimiento >= @FechaInicio)
      AND (@FechaFin    IS NULL OR a.fecha_vencimiento <= @FechaFin)
      AND (@IdRuta      IS NULL OR s.ruta_id_ruta = @IdRuta)
    ORDER BY s.nombre_socio, a.fecha_vencimiento;

    SELECT
        COUNT(DISTINCT s.id_socio)     AS cantidad_socios,
        COUNT(*)                       AS cantidad_avisos,
        ISNULL(SUM(a.deuda_actual),0)  AS total_adeudado
    FROM aviso a
    INNER JOIN estado e ON e.id_estado = a.estado_id_estado
    INNER JOIN socio  s ON s.id_socio  = a.socio_id_socio
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND a.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND (@FechaInicio IS NULL OR a.fecha_vencimiento >= @FechaInicio)
      AND (@FechaFin    IS NULL OR a.fecha_vencimiento <= @FechaFin)
      AND (@IdRuta      IS NULL OR s.ruta_id_ruta = @IdRuta);
END

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_pagos_sistema]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 1b. Reporte de PAGOS DEL SISTEMA -------------------------------------------
--     Cobros aprobados que no pasaron por ninguna caja: el socio los pago solo
--     desde el portal con QR. Misma forma que sp_reporte_caja (3 resultsets)
--     para que la vista pueda leerse igual.
--     RS1: detalle.  RS2: totales por metodo.  RS3: resumen + QR sin cobrar.
CREATE   PROCEDURE [dbo].[sp_reporte_pagos_sistema]
    @FechaInicio DATE,
    @FechaFin    DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.id_pago,
        p.fecha_pago,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion' ELSE 'Aviso' END AS tipo_cobro,
        ISNULL(s.nombre_socio, si.nombre_socio) AS nombre_socio,
        ISNULL(s.codigo_fijo,  si.codigo_fijo)  AS codigo_fijo,
        per.periodo        AS nombre_periodo,
        mp.metodo          AS nombre_metodo,
        p.id_transaccion,
        p.codigo_recaudacion,
        p.forma_pago,
        p.monto_pagado
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso   a   ON a.id_aviso    = p.aviso_id_aviso
    LEFT  JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN socio   s   ON s.id_socio    = a.socio_id_socio
    OUTER APPLY (
        SELECT TOP 1 s2.nombre_socio, s2.codigo_fijo
        FROM credito_inscripcion ci
        INNER JOIN socio s2 ON s2.id_socio = ci.socio_id_socio
        WHERE ci.pago_id_pago = p.id_pago
    ) si
    WHERE p.estado_pago  = 'APROBADO'
      AND p.caja_id_caja IS NULL
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
    ORDER BY p.fecha_pago;

    SELECT
        mp.metodo AS nombre_metodo,
        COUNT(*)  AS cantidad,
        SUM(p.monto_pagado) AS total
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.estado_pago  = 'APROBADO'
      AND p.caja_id_caja IS NULL
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY mp.metodo
    ORDER BY total DESC;

    -- Resumen. 'qr_sin_cobrar' son los QR generados en el periodo que nadie
    -- llego a pagar (siguen PENDIENTE o ya vencieron): no son plata, pero
    -- dicen cuanta gente abandono el pago a medio camino.
    SELECT
        COUNT(*)                      AS cantidad_pagos,
        ISNULL(SUM(p.monto_pagado),0) AS total_recaudado,
        (SELECT COUNT(*)
         FROM pago q
         WHERE q.caja_id_caja IS NULL
           AND q.id_transaccion IS NOT NULL
           AND q.estado_pago IN ('PENDIENTE', 'EXPIRADO')
           AND CAST(q.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin)
                                      AS qr_sin_cobrar
    FROM pago p
    WHERE p.estado_pago  = 'APROBADO'
      AND p.caja_id_caja IS NULL
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin;
END

GO
/****** Object:  StoredProcedure [dbo].[SP_Socio_Eliminar]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP_Socio_Eliminar
-- =============================================
CREATE   PROCEDURE [dbo].[SP_Socio_Eliminar]
    @id_socio  INT,
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El socio no existe.';
            RETURN;
        END

        -- Validar que no tenga avisos o créditos asociados
        -- (ajustá los nombres de tabla si son distintos en tu BD)
        IF EXISTS (SELECT 1 FROM credito_inscripcion WHERE socio_id_socio = @id_socio)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'No se puede eliminar: el socio tiene créditos de inscripción asociados.';
            RETURN;
        END

        DELETE FROM socio WHERE id_socio = @id_socio;

        SET @Resultado = 1;
        SET @Mensaje   = 'Socio eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_Socio_ObtenerPorId]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP_Socio_ObtenerPorId
-- =============================================
CREATE   PROCEDURE [dbo].[SP_Socio_ObtenerPorId]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        s.id_socio,
        s.nombre_socio,
        s.cliente_id_cliente,
        c.nombre_completo                  AS nombre_cliente,
        c.ci                               AS ci_cliente,
        s.rol_socio_id_rol_socio,
        rs.rol_socio                       AS nombre_rol_socio,
        s.medidor_id_medidor,
        m.serie                            AS serie_medidor,
        s.ruta_id_ruta,
        r.ruta                             AS nombre_ruta,
        s.ubicacion,
        s.num_casa,
        s.num_ocupantes,
        s.tipo_instalacion,
        s.dim_instalacion,
        s.actividad,
        s.categoria,
        s.fecha_registro,
        s.codigo_fijo,
        s.estado
    FROM socio s
    INNER JOIN cliente      c  ON c.id_cliente      = s.cliente_id_cliente
    INNER JOIN rol_socio    rs ON rs.id_rol_socio   = s.rol_socio_id_rol_socio
    LEFT JOIN  medidor      m  ON m.id_medidor      = s.medidor_id_medidor
    INNER JOIN ruta         r  ON r.id_ruta         = s.ruta_id_ruta
    WHERE s.id_socio = @id_socio;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ultimo_aviso_socio]    Script Date: 7/9/2026 23:07:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 4. sp_ultimo_aviso_socio
--    Devuelve el aviso mas reciente de un socio
--    para el portal cliente.
-- =============================================
CREATE   PROCEDURE [dbo].[sp_ultimo_aviso_socio]
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado  AS estado,
        a.estado_id_estado,
        e.estado  AS nombre_estado,
        p.periodo AS nombre_periodo
    FROM aviso    a
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    WHERE a.socio_id_socio = @id_socio
    ORDER BY a.id_aviso DESC;
END
GO
