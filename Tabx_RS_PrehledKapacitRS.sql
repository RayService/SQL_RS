USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PrehledKapacitRS]    Script Date: 02.07.2025 9:39:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PrehledKapacitRS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDPracoviste] [int] NOT NULL,
	[TypKapacity] [int] NOT NULL,
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
	[SkupinaPracoviste] [nvarchar](100) NULL,
	[Quart1]  AS (([Leden]+[Unor])+[Brezen]),
	[Quart2]  AS (([Duben]+[Kveten])+[Cerven]),
	[Quart3]  AS (([Cervenec]+[Srpen])+[Zari]),
	[Quart4]  AS (([Rijen]+[Listopad])+[Prosinec]),
	[Year]  AS ((((((((((([Leden]+[Unor])+[Brezen])+[Duben])+[Kveten])+[Cerven])+[Cervenec])+[Srpen])+[Zari])+[Rijen])+[Listopad])+[Prosinec]),
	[EP] [bit] NULL,
 CONSTRAINT [PK__Tabx_RS_PrehledKapacitRS__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__TypKapacity]  DEFAULT ((0)) FOR [TypKapacity]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Leden]  DEFAULT ((0)) FOR [Leden]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Unor]  DEFAULT ((0)) FOR [Unor]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Brezen]  DEFAULT ((0)) FOR [Brezen]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Duben]  DEFAULT ((0)) FOR [Duben]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Kveten]  DEFAULT ((0)) FOR [Kveten]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Cerven]  DEFAULT ((0)) FOR [Cerven]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Cervenec]  DEFAULT ((0)) FOR [Cervenec]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Srpen]  DEFAULT ((0)) FOR [Srpen]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Zari]  DEFAULT ((0)) FOR [Zari]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Rijen]  DEFAULT ((0)) FOR [Rijen]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Listopad]  DEFAULT ((0)) FOR [Listopad]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Prosinec]  DEFAULT ((0)) FOR [Prosinec]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] ADD  CONSTRAINT [DF__Tabx_RS_PrehledKapacitRS__EP]  DEFAULT ((0)) FOR [EP]
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_PrehledKapacitRS__IDPracoviste] FOREIGN KEY([IDPracoviste])
REFERENCES [dbo].[TabCPraco] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_PrehledKapacitRS] CHECK CONSTRAINT [FK__Tabx_RS_PrehledKapacitRS__IDPracoviste]
GO

