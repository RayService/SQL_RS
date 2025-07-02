USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PlneniNoremPracovisteDenni]    Script Date: 02.07.2025 9:34:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PlneniNoremPracovisteDenni](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WorkplaceID] [int] NOT NULL,
	[WorkplacePercentage] [numeric](19, 6) NULL,
	[BasePercentage] [numeric](19, 6) NULL,
	[Datum] [datetime] NULL,
	[Datum_D]  AS (datepart(day,[Datum])),
	[Datum_M]  AS (datepart(month,[Datum])),
	[Datum_Y]  AS (datepart(year,[Datum])),
	[Datum_Q]  AS (datepart(quarter,[Datum])),
	[Datum_W]  AS (datepart(week,[Datum])),
	[Datum_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[Datum])))),
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
	[PlanCas] [numeric](19, 6) NULL,
	[OdpracCas] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RS_PlneniNoremPracovisteDenni__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PlneniNoremPracovisteDenni] ADD  CONSTRAINT [DF__Tabx_RS_PlneniNoremPracovisteDenni__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PlneniNoremPracovisteDenni] ADD  CONSTRAINT [DF__Tabx_RS_PlneniNoremPracovisteDenni__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

