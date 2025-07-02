USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Apps_QaDefectReport]    Script Date: 02.07.2025 8:17:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Apps_QaDefectReport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[defectType] [nvarchar](10) NOT NULL,
	[productionOrderId] [int] NULL,
	[operationId] [int] NULL,
	[finalReportId] [int] NULL,
	[unitsCount] [float] NOT NULL,
	[description] [ntext] NULL,
	[comment] [ntext] NULL,
	[statusId] [int] NOT NULL,
	[resolveTypeId] [int] NULL,
	[Autor] [int] NOT NULL,
	[Zmenil] [int] NULL,
	[Vyresil] [int] NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[DatZmeny] [datetime] NULL,
	[DatVyreseni] [datetime] NULL,
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
	[DatVyreseni_D]  AS (datepart(day,[DatVyreseni])),
	[DatVyreseni_M]  AS (datepart(month,[DatVyreseni])),
	[DatVyreseni_Y]  AS (datepart(year,[DatVyreseni])),
	[DatVyreseni_Q]  AS (datepart(quarter,[DatVyreseni])),
	[DatVyreseni_W]  AS (datepart(week,[DatVyreseni])),
	[DatVyreseni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatVyreseni],(0)),(0)),(0))),
 CONSTRAINT [PK__Tabx_Apps_QaDefectReport__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] ADD  CONSTRAINT [DF__Tabx_Apps_QaDefectReport__StatusId]  DEFAULT ('defect') FOR [defectType]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] ADD  CONSTRAINT [DF__Tabx_Apps_QaDefectReport__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__autor] FOREIGN KEY([Autor])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__autor]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__finalReportId] FOREIGN KEY([finalReportId])
REFERENCES [dbo].[B2A_qa_report] ([id])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__finalReportId]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__operationId] FOREIGN KEY([operationId])
REFERENCES [dbo].[TabPrPostup] ([ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__operationId]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__productionOrderId] FOREIGN KEY([productionOrderId])
REFERENCES [dbo].[TabPrikaz] ([ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__productionOrderId]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__resolveTypeId] FOREIGN KEY([resolveTypeId])
REFERENCES [dbo].[Tabx_Apps_QaDefectReportResolveType] ([ID])
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__resolveTypeId]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__statusId] FOREIGN KEY([statusId])
REFERENCES [dbo].[Tabx_Apps_QaDefectReportStatus] ([ID])
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__statusId]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__vyresil] FOREIGN KEY([Vyresil])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__vyresil]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReport__zmenil] FOREIGN KEY([Zmenil])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReport__zmenil]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_Apps_QaDefectReport__defectType] CHECK  (([defectType]='defect' OR [defectType]='difference'))
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReport] CHECK CONSTRAINT [CK__Tabx_Apps_QaDefectReport__defectType]
GO

