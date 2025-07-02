USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Apps_QaDefectReportStatus]    Script Date: 02.07.2025 8:19:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Apps_QaDefectReportStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[code] [nvarchar](100) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[active] [bit] NULL,
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
 CONSTRAINT [PK__Tabx_Apps_QaDefectReportStatus__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReportStatus] ADD  CONSTRAINT [DF__Tabx_Apps_QaDefectReportStatus__active]  DEFAULT ((1)) FOR [active]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReportStatus] ADD  CONSTRAINT [DF__Tabx_Apps_QaDefectReportStatus__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReportStatus] ADD  CONSTRAINT [DF__Tabx_Apps_QaDefectReportStatus__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

