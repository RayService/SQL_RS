USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_MaticeRoleProcesyPinya]    Script Date: 02.07.2025 9:19:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Role] [nvarchar](100) NULL,
	[Prodavani] [int] NOT NULL,
	[PVaK] [int] NOT NULL,
	[Nakupovani] [int] NOT NULL,
	[Vyrabeni] [int] NOT NULL,
	[PSaE] [int] NOT NULL,
	[VaV] [int] NOT NULL,
	[Neshody] [int] NOT NULL,
	[AnalyzaDat] [int] NOT NULL,
	[RizeniNOPO] [int] NOT NULL,
	[Audity] [int] NOT NULL,
	[PeceoTrh] [int] NOT NULL,
	[HR] [int] NOT NULL,
	[IT] [int] NOT NULL,
	[TI] [int] NOT NULL,
	[Dokumenty] [int] NOT NULL,
	[MeridlaNaradi] [int] NOT NULL,
	[Finance] [int] NOT NULL,
	[CilePlany] [int] NOT NULL,
	[SMK] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny])))),
	[Prodesy] [int] NOT NULL,
 CONSTRAINT [PK__Tabx_RS_MaticeRoleProcesyPinya__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Prodavani]  DEFAULT ((0)) FOR [Prodavani]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__PVaK]  DEFAULT ((0)) FOR [PVaK]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Nakupovani]  DEFAULT ((0)) FOR [Nakupovani]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Vyrabeni]  DEFAULT ((0)) FOR [Vyrabeni]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__PSaE]  DEFAULT ((0)) FOR [PSaE]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__VaV]  DEFAULT ((0)) FOR [VaV]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Neshody]  DEFAULT ((0)) FOR [Neshody]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__AnalyzaDat]  DEFAULT ((0)) FOR [AnalyzaDat]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__RizeniNOPO]  DEFAULT ((0)) FOR [RizeniNOPO]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Audity]  DEFAULT ((0)) FOR [Audity]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__PeceoTrh]  DEFAULT ((0)) FOR [PeceoTrh]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__HR]  DEFAULT ((0)) FOR [HR]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__IT]  DEFAULT ((0)) FOR [IT]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__TI]  DEFAULT ((0)) FOR [TI]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Dokumenty]  DEFAULT ((0)) FOR [Dokumenty]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__MeridlaNaradi]  DEFAULT ((0)) FOR [MeridlaNaradi]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Finance]  DEFAULT ((0)) FOR [Finance]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__CilePlany]  DEFAULT ((0)) FOR [CilePlany]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__SMK]  DEFAULT ((0)) FOR [SMK]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesyPinya] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesyPinya__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

