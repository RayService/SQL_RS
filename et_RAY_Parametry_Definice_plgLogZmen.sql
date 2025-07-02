USE [HCvicna]
GO

/****** Object:  Table [dbo].[RAY_Parametry_Definice]    Script Date: 02.07.2025 13:09:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RAY_Parametry_Definice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Parametr] [nvarchar](128) NULL,
	[Vyporadani_premioveho_koef] [numeric](19, 6) NULL,
	[Premiovy_koef_od] [numeric](19, 6) NULL,
	[Premiovy_koef_do] [numeric](19, 6) NULL,
	[Koef_1_od] [numeric](19, 6) NULL,
	[Koef_1_do] [numeric](19, 6) NULL,
	[Koef_08_od] [numeric](19, 6) NULL,
	[Koef_08_do] [numeric](19, 6) NULL,
	[Koef_06_od] [numeric](19, 6) NULL,
	[Koef_06_do] [numeric](19, 6) NULL,
	[Koef_0_od] [numeric](19, 6) NULL,
	[Koef_0_do] [numeric](19, 6) NULL,
	[Cetnost] [tinyint] NULL,
	[Majitel] [nvarchar](128) NULL,
	[Poznamka] [ntext] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni],(0)),(0)),(0))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny],(0)),(0)),(0))),
	[Vyhodnoceni] [tinyint] NULL,
	[Ukazatel] [tinyint] NULL,
	[Vyhodnocuje] [nvarchar](128) NULL,
	[parameter_inclusion] [varchar](50) NULL,
	[upper_lever1_param] [int] NULL,
	[upper_lever2_param] [int] NULL,
	[Archive] [bit] NULL,
	[KPI] [bit] NOT NULL,
 CONSTRAINT [PK_RayService_Parametry_Definice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[RAY_Parametry_Definice] ADD  CONSTRAINT [DF__RAY_Parametry_Definice__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[RAY_Parametry_Definice] ADD  CONSTRAINT [DF__RAY_Parametry_Definice__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[RAY_Parametry_Definice] ADD  DEFAULT ((0)) FOR [KPI]
GO

