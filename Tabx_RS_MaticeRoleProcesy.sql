USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_MaticeRoleProcesy]    Script Date: 02.07.2025 9:18:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_MaticeRoleProcesy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Role] [nvarchar](100) NULL,
	[Prodavani] [bit] NULL,
	[PVaK] [bit] NULL,
	[Nakupovani] [bit] NULL,
	[Vyrabeni] [bit] NULL,
	[PSaE] [bit] NULL,
	[VaV] [bit] NULL,
	[Neshody] [bit] NULL,
	[AnalyzaDat] [bit] NULL,
	[RizeniNOPO] [bit] NULL,
	[Audity] [bit] NULL,
	[PeceoTrh] [bit] NULL,
	[HR] [bit] NULL,
	[IT] [bit] NULL,
	[TI] [bit] NULL,
	[Dokumenty] [bit] NULL,
	[MeridlaNaradi] [bit] NULL,
	[Finance] [bit] NULL,
	[CilePlany] [bit] NULL,
	[SMK] [bit] NULL,
	[Procesy] [bit] NULL,
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
	[LoginName] [nvarchar](128) NULL,
	[FUllName] [nvarchar](255) NOT NULL,
	[IDZam] [int] NULL,
	[Vyroba] [bit] NULL,
	[Sklad] [bit] NULL,
	[FeedbackRole] [int] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK__Tabx_RS_MaticeRoleProcesy__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Prodavani]  DEFAULT ((0)) FOR [Prodavani]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__PVaK]  DEFAULT ((0)) FOR [PVaK]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Nakupovani]  DEFAULT ((0)) FOR [Nakupovani]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Vyrabeni]  DEFAULT ((0)) FOR [Vyrabeni]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__PSaE]  DEFAULT ((0)) FOR [PSaE]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__VaV]  DEFAULT ((0)) FOR [VaV]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Neshody]  DEFAULT ((0)) FOR [Neshody]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__AnalyzaDat]  DEFAULT ((0)) FOR [AnalyzaDat]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__RizeniNOPO]  DEFAULT ((0)) FOR [RizeniNOPO]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Audity]  DEFAULT ((0)) FOR [Audity]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__PeceoTrh]  DEFAULT ((0)) FOR [PeceoTrh]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__HR]  DEFAULT ((0)) FOR [HR]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__IT]  DEFAULT ((0)) FOR [IT]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__TI]  DEFAULT ((0)) FOR [TI]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Dokumenty]  DEFAULT ((0)) FOR [Dokumenty]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__MeridlaNaradi]  DEFAULT ((0)) FOR [MeridlaNaradi]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Finance]  DEFAULT ((0)) FOR [Finance]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__CilePlany]  DEFAULT ((0)) FOR [CilePlany]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__SMK]  DEFAULT ((0)) FOR [SMK]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Procesy]  DEFAULT ((0)) FOR [Procesy]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Vyroba]  DEFAULT ((0)) FOR [Vyroba]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Sklad]  DEFAULT ((0)) FOR [Sklad]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__FeedbackRole]  DEFAULT ((0)) FOR [FeedbackRole]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeRoleProcesy] ADD  CONSTRAINT [DF__Tabx_RS_MaticeRoleProcesy__Active]  DEFAULT ((1)) FOR [Active]
GO

