USE [COSPABIRL1]
GO
/****** Object:  Table [dbo].[aviso]    Script Date: 27/6/2026 08:09:34 ******/
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
	[estado] [varchar](50) NOT NULL,
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
/****** Object:  Table [dbo].[bitacora]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[caja]    Script Date: 27/6/2026 08:09:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[caja](
	[id_caja] [int] IDENTITY(1,1) NOT NULL,
	[fecha] [date] NOT NULL,
	[hora_apertura] [datetime] NOT NULL,
	[hora_cierre] [datetime] NULL,
	[monto_cobrado] [decimal](30, 3) NOT NULL,
	[usuario_admin_id_usuario_admin] [int] NOT NULL,
	[estado] [bit] NOT NULL,
	[monto_apertura] [decimal](30, 2) NOT NULL,
 CONSTRAINT [caja_PK] PRIMARY KEY CLUSTERED 
(
	[id_caja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cargo_extra]    Script Date: 27/6/2026 08:09:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cargo_extra](
	[id_carga_extra] [int] IDENTITY(1,1) NOT NULL,
	[monto] [decimal](30, 2) NOT NULL,
	[descripcion] [varchar](150) NOT NULL,
	[fecha_registro] [date] NOT NULL,
	[estado] [varchar](150) NOT NULL,
	[tipo_cargo_id_tipo] [int] NOT NULL,
	[socio_id_socio] [int] NOT NULL,
	[periodo_id_periodo] [int] NOT NULL,
	[aviso_id_aviso] [int] NULL,
 CONSTRAINT [cargo_extra_PK] PRIMARY KEY CLUSTERED 
(
	[id_carga_extra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cliente]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[credito_inscripcion]    Script Date: 27/6/2026 08:09:35 ******/
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
	[aviso_id_aviso] [int] NULL,
 CONSTRAINT [credito_inscripcion_PK] PRIMARY KEY CLUSTERED 
(
	[id_credito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cuenta_socio]    Script Date: 27/6/2026 08:09:35 ******/
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
 CONSTRAINT [cuenta_socio_PK] PRIMARY KEY CLUSTERED 
(
	[id_cuenta_socio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[estado]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[lectura]    Script Date: 27/6/2026 08:09:35 ******/
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
	[observacion] [varchar](255) NOT NULL,
	[usuario_admin_id_usuario_admin] [int] NOT NULL,
	[medidor_id_medidor] [int] NOT NULL,
	[periodo_id_periodo] [int] NOT NULL,
	[consumo_m3] [decimal](30, 2) NOT NULL,
	[ruta_id_ruta] [int] NOT NULL,
 CONSTRAINT [lectura_PK] PRIMARY KEY CLUSTERED 
(
	[id_lectura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[medidor]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[metodo_pago]    Script Date: 27/6/2026 08:09:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[metodo_pago](
	[id_metodo_pago] [int] IDENTITY(1,1) NOT NULL,
	[metodo] [varchar](150) NOT NULL,
	[referencia] [varchar](255) NOT NULL,
 CONSTRAINT [metodo_pago_PK] PRIMARY KEY CLUSTERED 
(
	[id_metodo_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notificacion]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[notificacion_socio]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[pago]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[periodo]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[permiso]    Script Date: 27/6/2026 08:09:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[permiso](
	[id_permiso] [int] IDENTITY(1,1) NOT NULL,
	[accion] [varchar](150) NOT NULL,
	[descripcion] [varchar](150) NULL,
 CONSTRAINT [permiso_PK] PRIMARY KEY CLUSTERED 
(
	[id_permiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rol]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[rol_permiso]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[rol_socio]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[ruta]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[socio]    Script Date: 27/6/2026 08:09:35 ******/
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
	[medidor_id_medidor] [int] NOT NULL,
	[num_casa] [int] NULL,
	[num_ocupantes] [int] NULL,
	[tipo_instalacion] [varchar](255) NULL,
	[dim_instalacion] [varchar](255) NULL,
	[actividad] [varchar](255) NOT NULL,
	[categoria] [varchar](255) NOT NULL,
	[fecha_registro] [date] NOT NULL,
	[ruta_id_ruta] [int] NOT NULL,
	[codigo_fijo] [int] NOT NULL,
 CONSTRAINT [socio_PK] PRIMARY KEY CLUSTERED 
(
	[id_socio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tarifa]    Script Date: 27/6/2026 08:09:35 ******/
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
/****** Object:  Table [dbo].[tipo_cargo]    Script Date: 27/6/2026 08:09:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tipo_cargo](
	[id_tipo] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](150) NOT NULL,
	[monto] [decimal](30, 3) NOT NULL,
	[estado] [bit] NOT NULL,
 CONSTRAINT [tipo_cargo_PK] PRIMARY KEY CLUSTERED 
(
	[id_tipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[usuario_admin]    Script Date: 27/6/2026 08:09:35 ******/
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
 CONSTRAINT [usuario_admin_PK] PRIMARY KEY CLUSTERED 
(
	[id_usuario_admin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[caja] ADD  CONSTRAINT [DF_caja_monto_apertura]  DEFAULT ((0)) FOR [monto_apertura]
GO
ALTER TABLE [dbo].[pago] ADD  CONSTRAINT [DF_pago_estado_pago]  DEFAULT ('APROBADO') FOR [estado_pago]
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
ALTER TABLE [dbo].[cargo_extra]  WITH CHECK ADD  CONSTRAINT [cargo_extra_aviso_FK] FOREIGN KEY([aviso_id_aviso])
REFERENCES [dbo].[aviso] ([id_aviso])
GO
ALTER TABLE [dbo].[cargo_extra] CHECK CONSTRAINT [cargo_extra_aviso_FK]
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
ALTER TABLE [dbo].[credito_inscripcion]  WITH CHECK ADD  CONSTRAINT [credito_inscripcion_aviso_FK] FOREIGN KEY([aviso_id_aviso])
REFERENCES [dbo].[aviso] ([id_aviso])
GO
ALTER TABLE [dbo].[credito_inscripcion] CHECK CONSTRAINT [credito_inscripcion_aviso_FK]
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
ALTER TABLE [dbo].[lectura]  WITH CHECK ADD  CONSTRAINT [lectura_ruta_FK] FOREIGN KEY([ruta_id_ruta])
REFERENCES [dbo].[ruta] ([id_ruta])
GO
ALTER TABLE [dbo].[lectura] CHECK CONSTRAINT [lectura_ruta_FK]
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
