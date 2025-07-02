USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear]    Script Date: 02.07.2025 9:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Leden] [numeric](19, 6) NULL,
	[Unor] [numeric](19, 6) NULL,
	[Brezen] [numeric](19, 6) NULL,
	[Duben] [numeric](19, 6) NULL,
	[Kveten] [numeric](19, 6) NULL,
	[Cerven] [numeric](19, 6) NULL,
	[Cervenec] [numeric](19, 6) NULL,
	[Srpen] [numeric](19, 6) NULL,
	[Zari] [numeric](19, 6) NULL,
	[Rijen] [numeric](19, 6) NULL,
	[Listopad] [numeric](19, 6) NULL,
	[Prosinec] [numeric](19, 6) NULL,
	[TypKapacity] [int] NOT NULL,
	[Konstanta] [int] NULL,
	[Prodano] [int] NULL,
	[TotalKapacity] [numeric](19, 6) NULL,
	[TotalKapacityPercentage] [numeric](19, 6) NULL,
	[KonstantaDisponibility] [int] NULL,
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
 CONSTRAINT [PK__Tabx_RS_PrehledKapacitRSSouhrnNextYear__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Leden]  DEFAULT ((0)) FOR [Leden]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Unor]  DEFAULT ((0)) FOR [Unor]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Brezen]  DEFAULT ((0)) FOR [Brezen]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Duben]  DEFAULT ((0)) FOR [Duben]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Kveten]  DEFAULT ((0)) FOR [Kveten]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Cerven]  DEFAULT ((0)) FOR [Cerven]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Cervenec]  DEFAULT ((0)) FOR [Cervenec]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Srpen]  DEFAULT ((0)) FOR [Srpen]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Zari]  DEFAULT ((0)) FOR [Zari]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Rijen]  DEFAULT ((0)) FOR [Rijen]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Listopad]  DEFAULT ((0)) FOR [Listopad]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Prosinec]  DEFAULT ((0)) FOR [Prosinec]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__TypKapacity]  DEFAULT ((0)) FOR [TypKapacity]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Konstanta]  DEFAULT ((0)) FOR [Konstanta]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Prodano]  DEFAULT ((0)) FOR [Prodano]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__TotalKapacity]  DEFAULT ((0)) FOR [TotalKapacity]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__TotalKapacityPercentage]  DEFAULT ((0)) FOR [TotalKapacityPercentage]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__KonstantaDisponibility]  DEFAULT ((0)) FOR [KonstantaDisponibility]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRSSouhrnNextYear] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRSSouhrnNextYear__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

