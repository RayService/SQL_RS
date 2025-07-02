USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_NakladyPrikazy]    Script Date: 02.07.2025 9:20:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_NakladyPrikazy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDPrikaz] [int] NOT NULL,
	[CisloZakazky] [nvarchar](15) NULL,
	[NakladyReal] [numeric](19, 6) NULL,
	[NakladyPlan] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[ukonceni] [datetime] NULL,
	[NakladyMatReal] [numeric](19, 6) NULL,
	[NakladyMatPlan] [numeric](19, 6) NULL,
	[ukonceni_D]  AS (datepart(day,[DatPorizeni])),
	[ukonceni_M]  AS (datepart(month,[DatPorizeni])),
	[ukonceni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[ukonceni_Y]  AS (datepart(year,[DatPorizeni])),
	[ukonceni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[ukonceni_V]  AS (datepart(iso_week,[DatPorizeni])),
	[ukonceni_W]  AS (datepart(week,[DatPorizeni])),
	[SouladNakladu]  AS (([NakladyReal]/isnull([NakladyPlan],(0)))*(100)),
	[SouladMatNakladu]  AS (([NakladyMatReal]/isnull([NakladyMatPlan],(0)))*(100)),
 CONSTRAINT [PK__Tabx_RS_NakladyPrikazy__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_NakladyPrikazy__NakladyReal]  DEFAULT ((0)) FOR [NakladyReal]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_NakladyPrikazy__NakladyPlan]  DEFAULT ((0)) FOR [NakladyPlan]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_NakladyPrikazy__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_NakladyPrikazy__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_NakladyPrikazy__NakladyMatReal]  DEFAULT ((0)) FOR [NakladyMatReal]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_NakladyPrikazy__NakladyMatPlan]  DEFAULT ((0)) FOR [NakladyMatPlan]
GO

