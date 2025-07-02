USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TabPlanPrKVazby]    Script Date: 02.07.2025 9:53:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TabPlanPrKVazby](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_orig] [int] NOT NULL,
	[IDPlan] [int] NOT NULL,
	[IDPlanPrikaz] [int] NOT NULL,
	[Doklad] [int] NOT NULL,
	[Sklad] [nvarchar](30) NULL,
	[mnoz_zad] [numeric](19, 6) NOT NULL,
	[vyssi] [int] NOT NULL,
	[nizsi] [int] NOT NULL,
	[pozice] [nvarchar](100) NULL,
	[Operace] [nchar](4) NULL,
	[RezijniMat] [bit] NOT NULL,
	[Poznamka] [ntext] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni],(0)),(0)),(0))),
	[DavkaTPV] [numeric](19, 6) NOT NULL,
	[FixniMnozstvi] [numeric](19, 6) NOT NULL,
	[mnozstvi] [numeric](19, 6) NOT NULL,
	[ProcZtrat] [numeric](5, 2) NOT NULL,
	[mnozstviSeZtratou] [numeric](19, 6) NOT NULL,
	[VychoziSklad] [nvarchar](30) NULL,
	[Prirez] [numeric](19, 6) NOT NULL,
	[SpotRozmer] [nvarchar](100) NULL,
	[_DatZajMat] [datetime] NULL,
	[_KontrolaPokryti_Nepokryto] [numeric](19, 6) NULL,
	[_KontrolaPokryti_Vysledek] [smallint] NULL,
	[Datum_ulozeni] [datetime] NULL,
 CONSTRAINT [PK__TabPlanPrKVazby_new__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TabPlanPrKVazby] ADD  DEFAULT (getdate()) FOR [Datum_ulozeni]
GO

