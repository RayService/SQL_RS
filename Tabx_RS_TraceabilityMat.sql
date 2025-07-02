USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TraceabilityMat]    Script Date: 02.07.2025 10:03:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TraceabilityMat](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDStitku] [int] NOT NULL,
	[IDTabVCPrikaz] [int] NOT NULL,
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
 CONSTRAINT [PK__Tabx_RS_TraceabilityMat__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TraceabilityMat] ADD  CONSTRAINT [DF__Tabx_RS_TraceabilityMat__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_TraceabilityMat] ADD  CONSTRAINT [DF__Tabx_RS_TraceabilityMat__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_TraceabilityMat]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TraceabilityMat__IDTabVCPrikaz] FOREIGN KEY([IDTabVCPrikaz])
REFERENCES [dbo].[TabVyrCisPrikaz] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TraceabilityMat] CHECK CONSTRAINT [FK__Tabx_RS_TraceabilityMat__IDTabVCPrikaz]
GO

