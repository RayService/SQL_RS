USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_NakladyZakazky]    Script Date: 02.07.2025 9:22:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_NakladyZakazky](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CisloZakazky] [nvarchar](15) NOT NULL,
	[NakladyReal] [numeric](19, 6) NULL,
	[NakladyPlan] [numeric](19, 6) NULL,
	[DatUzavreni] [datetime] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatUzavreni_D]  AS (datepart(day,[DatPorizeni])),
	[DatUzavreni_M]  AS (datepart(month,[DatPorizeni])),
	[DatUzavreni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatUzavreni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatUzavreni_W]  AS (datepart(week,[DatPorizeni])),
	[DatUzavreni_V]  AS (datepart(iso_week,[DatPorizeni])),
	[DatUzavreni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[SouladNakladu]  AS (([NakladyReal]/isnull([NakladyPlan],(0)))*(100)),
 CONSTRAINT [PK__Tabx_RS_NakladyZakazky__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyZakazky] ADD  CONSTRAINT [DF__Tabx_RS_NakladyZakazky__NakladyReal]  DEFAULT ((0)) FOR [NakladyReal]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyZakazky] ADD  CONSTRAINT [DF__Tabx_RS_NakladyZakazky__NakladyPlan]  DEFAULT ((0)) FOR [NakladyPlan]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyZakazky] ADD  CONSTRAINT [DF__Tabx_RS_NakladyZakazky__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyZakazky] ADD  CONSTRAINT [DF__Tabx_RS_NakladyZakazky__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

