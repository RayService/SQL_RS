USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_RozsahPoctuKusu]    Script Date: 02.07.2025 9:45:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_RozsahPoctuKusu](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KusyOd] [int] NOT NULL,
	[KusyDo] [int] NOT NULL,
	[NasobitelMzdy] [numeric](5, 2) NULL,
	[NasobitelRezie] [numeric](5, 2) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatPorizeni_V]  AS (datepart(iso_week,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
 CONSTRAINT [PK__Tabx_RS_RozsahPoctuKusu__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_RozsahPoctuKusu] ADD  CONSTRAINT [DF__Tabx_RS_RozsahPoctuKusu__KusyOd]  DEFAULT ((0)) FOR [KusyOd]
GO

ALTER TABLE [dbo].[Tabx_RS_RozsahPoctuKusu] ADD  CONSTRAINT [DF__Tabx_RS_RozsahPoctuKusu__KusyDo]  DEFAULT ((0)) FOR [KusyDo]
GO

ALTER TABLE [dbo].[Tabx_RS_RozsahPoctuKusu] ADD  CONSTRAINT [DF__Tabx_RS_RozsahPoctuKusu__NasobitelMzdy]  DEFAULT ((0)) FOR [NasobitelMzdy]
GO

ALTER TABLE [dbo].[Tabx_RS_RozsahPoctuKusu] ADD  CONSTRAINT [DF__Tabx_RS_RozsahPoctuKusu__NasobitelRezie]  DEFAULT ((0)) FOR [NasobitelRezie]
GO

ALTER TABLE [dbo].[Tabx_RS_RozsahPoctuKusu] ADD  CONSTRAINT [DF__Tabx_RS_RozsahPoctuKusu__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_RozsahPoctuKusu] ADD  CONSTRAINT [DF__Tabx_RS_RozsahPoctuKusu__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

