USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PohybyPotvrzDat]    Script Date: 02.07.2025 9:37:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PohybyPotvrzDat](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDPohyb] [int] NOT NULL,
	[PotvrzDat] [datetime] NULL,
	[PotvrzDat_D]  AS (datepart(day,[PotvrzDat])),
	[PotvrzDat_M]  AS (datepart(month,[PotvrzDat])),
	[PotvrzDat_Y]  AS (datepart(year,[PotvrzDat])),
	[PotvrzDat_Q]  AS (datepart(quarter,[PotvrzDat])),
	[PotvrzDat_W]  AS (datepart(week,[PotvrzDat])),
	[PotvrzDat_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[PotvrzDat])))),
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
	[Archive] [bit] NULL,
 CONSTRAINT [PK__Tabx_RS_PohybyPotvrzDat__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PohybyPotvrzDat] ADD  CONSTRAINT [DF__Tabx_RS_PohybyPotvrzDat__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PohybyPotvrzDat] ADD  CONSTRAINT [DF__Tabx_RS_PohybyPotvrzDat__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

