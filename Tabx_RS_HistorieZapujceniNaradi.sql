USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_HistorieZapujceniNaradi]    Script Date: 02.07.2025 9:07:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDNaradi] [int] NOT NULL,
	[IDZam] [int] NOT NULL,
	[DatumZapujceni] [datetime] NULL,
	[DatumZapujceni_D]  AS (datepart(day,[DatumZapujceni])),
	[DatumZapujceni_M]  AS (datepart(month,[DatumZapujceni])),
	[DatumZapujceni_Y]  AS (datepart(year,[DatumZapujceni])),
	[DatumZapujceni_Q]  AS (datepart(quarter,[DatumZapujceni])),
	[DatumZapujceni_W]  AS (datepart(week,[DatumZapujceni])),
	[DatumZapujceni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumZapujceni])))),
	[DatumVraceni] [datetime] NULL,
	[DatumVraceni_D]  AS (datepart(day,[DatumVraceni])),
	[DatumVraceni_M]  AS (datepart(month,[DatumVraceni])),
	[DatumVraceni_Y]  AS (datepart(year,[DatumVraceni])),
	[DatumVraceni_Q]  AS (datepart(quarter,[DatumVraceni])),
	[DatumVraceni_W]  AS (datepart(week,[DatumVraceni])),
	[DatumVraceni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumVraceni])))),
	[DobaZapujcky]  AS ([DatumVraceni]-[DatumZapujceni]),
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
 CONSTRAINT [PK__Tabx_RS_HistorieZapujceniNaradi__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi] ADD  CONSTRAINT [DF__Tabx_RS_HistorieZapujceniNaradi__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi] ADD  CONSTRAINT [DF__Tabx_RS_HistorieZapujceniNaradi__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_HistorieZapujceniNaradi__IDNaradi] FOREIGN KEY([IDNaradi])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi] CHECK CONSTRAINT [FK__Tabx_RS_HistorieZapujceniNaradi__IDNaradi]
GO

ALTER TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_HistorieZapujceniNaradi__IDZam] FOREIGN KEY([IDZam])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_HistorieZapujceniNaradi] CHECK CONSTRAINT [FK__Tabx_RS_HistorieZapujceniNaradi__IDZam]
GO

