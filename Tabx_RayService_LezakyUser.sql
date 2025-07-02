USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RayService_LezakyUser]    Script Date: 02.07.2025 8:51:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RayService_LezakyUser](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDStavSkladu] [int] NOT NULL,
	[LoginName] [nvarchar](128) NOT NULL,
	[M] [numeric](19, 6) NULL,
	[S] [numeric](19, 6) NULL,
	[A] [tinyint] NULL,
	[M_PS] [numeric](19, 6) NULL,
	[M_Vydej] [numeric](19, 6) NULL,
	[DatumDo] [datetime] NOT NULL,
	[PocetMesicu] [smallint] NOT NULL,
	[ProcentoVydej] [numeric](5, 2) NOT NULL,
	[Podminky] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[Datum] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_RayService_LezakyUser__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_RayService_LezakyUser__IDStavSkladu_LoginName] UNIQUE NONCLUSTERED 
(
	[IDStavSkladu] ASC,
	[LoginName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RayService_LezakyUser] ADD  CONSTRAINT [DF__Tabx_RayService_LezakyUser__LoginName]  DEFAULT (suser_sname()) FOR [LoginName]
GO

ALTER TABLE [dbo].[Tabx_RayService_LezakyUser] ADD  CONSTRAINT [DF__Tabx_RayService_LezakyUser__Podminky]  DEFAULT ((0)) FOR [Podminky]
GO

ALTER TABLE [dbo].[Tabx_RayService_LezakyUser] ADD  CONSTRAINT [DF__Tabx_RayService_LezakyUser__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RayService_LezakyUser] ADD  CONSTRAINT [DF__Tabx_RayService_LezakyUser__Datum]  DEFAULT (getdate()) FOR [Datum]
GO

