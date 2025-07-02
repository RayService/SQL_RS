USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_OTDExternalPBI]    Script Date: 02.07.2025 9:23:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_OTDExternalPBI](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Week_1_all] [numeric](19, 6) NULL,
	[Week_1_NOK] [numeric](19, 6) NULL,
	[Month_all] [numeric](19, 6) NULL,
	[Month_NOK] [numeric](19, 6) NULL,
	[Month_1_all] [numeric](19, 6) NULL,
	[Month_1_NOK] [numeric](19, 6) NULL,
	[Quarter_all] [numeric](19, 6) NULL,
	[Quarter_NOK] [numeric](19, 6) NULL,
	[Quarter_1_all] [numeric](19, 6) NULL,
	[Quarter_1_NOK] [numeric](19, 6) NULL,
	[Year_all] [numeric](19, 6) NULL,
	[Year_NOK] [numeric](19, 6) NULL,
	[Year_1_all] [numeric](19, 6) NULL,
	[Year_1_NOK] [numeric](19, 6) NULL,
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
	[Type] [int] NOT NULL,
	[Week_1_OTD]  AS (([Week_1_all]-[Week_1_NOK])/[Week_1_all]),
	[Month_OTD]  AS (([Month_all]-[Month_NOK])/[Month_all]),
	[Month_1_OTD]  AS (([Month_1_all]-[Month_1_NOK])/[Month_1_all]),
	[Quarter_OTD]  AS (([Quarter_all]-[Quarter_NOK])/[Quarter_all]),
	[Quarter_1_OTD]  AS (([Quarter_1_all]-[Quarter_1_NOK])/[Quarter_1_all]),
	[Year_OTD]  AS (([Year_all]-[Year_NOK])/[Year_all]),
	[Year_1_OTD]  AS (([Year_1_all]-[Year_1_NOK])/[Year_1_all]),
 CONSTRAINT [PK__Tabx_RS_OTDExternalPBI__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Week_1_all]  DEFAULT ((0)) FOR [Week_1_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Week_1_NOK]  DEFAULT ((0)) FOR [Week_1_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Month_all]  DEFAULT ((0)) FOR [Month_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Month_NOK]  DEFAULT ((0)) FOR [Month_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Month_1_all]  DEFAULT ((0)) FOR [Month_1_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Month_1_NOK]  DEFAULT ((0)) FOR [Month_1_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Quarter_all]  DEFAULT ((0)) FOR [Quarter_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Quarter_NOK]  DEFAULT ((0)) FOR [Quarter_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Quarter_1_all]  DEFAULT ((0)) FOR [Quarter_1_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Quarter_1_NOK]  DEFAULT ((0)) FOR [Quarter_1_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Year_all]  DEFAULT ((0)) FOR [Year_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Year_NOK]  DEFAULT ((0)) FOR [Year_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Year_1_all]  DEFAULT ((0)) FOR [Year_1_all]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Year_1_NOK]  DEFAULT ((0)) FOR [Year_1_NOK]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_OTDExternalPBI] ADD  CONSTRAINT [DF__Tabx_RS_OTDExternalPBI__Type]  DEFAULT ((0)) FOR [Type]
GO

