USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_Segmentace]    Script Date: 02.07.2025 9:47:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_Segmentace](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDStavSkladu] [int] NOT NULL,
	[IDKmenZbozi] [int] NOT NULL,
	[MatVydaneVyrPrik] [numeric](19, 6) NULL,
	[MatBlokVyrPrik] [numeric](19, 6) NULL,
	[MatVyrPlan90] [numeric](19, 6) NULL,
	[MatVyrPlan90Mimo] [numeric](19, 6) NULL,
	[MatVyrPlanOver90] [numeric](19, 6) NULL,
	[MatVyrPlanOver90Mimo] [numeric](19, 6) NULL,
	[MatRez] [numeric](19, 6) NULL,
	[MatNekrytySklad] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[PlanVyrobyDnes90]  AS ((([MatVydaneVyrPrik]+[MatBlokVyrPrik])+[MatVyrPlan90])+[MatVyrPlan90Mimo]),
	[ChybejiciPolDnes90]  AS ([MatVyrPlan90Mimo]),
	[SumMatPlanVyrobyOver90]  AS ([MatVyrPlanOver90]+[MatVyrPlanOver90Mimo]),
	[SumMatProEPSkl]  AS ([MatRez]),
	[FinStavSkladu]  AS (((([MatVydaneVyrPrik]+[MatBlokVyrPrik])+[MatVyrPlan90])+[MatVyrPlan90Mimo])+[MatVyrPlanOver90]),
	[SumMatZbyvSkl]  AS ([MatNekrytySklad]),
	[MnozstviSklad] [numeric](19, 6) NULL,
	[FinStavSklad] [numeric](19, 6) NULL,
	[PrumerSklad] [numeric](19, 6) NULL,
	[PlanVyrobyDnes90_dashboard]  AS (((([MatVydaneVyrPrik]+[MatBlokVyrPrik])+[MatVyrPlan90])+[MatVyrPlan90Mimo])-[MatBlokVyrPrik]),
	[PlanVyrobyDnes90_dashboardNEW] [numeric](19, 6) NULL,
	[MatRamcovkyOdb] [numeric](19, 6) NULL,
	[MatVydaneVyrPrikEle] [numeric](19, 6) NULL,
	[MatVydaneVyrPrikKoo] [numeric](19, 6) NULL,
	[MatVydaneVyrPrikOst] [numeric](19, 6) NULL,
	[MatBlokVyrPrikEle] [numeric](19, 6) NULL,
	[MatBlokVyrPrikKoo] [numeric](19, 6) NULL,
	[MatBlokVyrPrikOst] [numeric](19, 6) NULL,
	[MatVyrPlan90Ele] [numeric](19, 6) NULL,
	[MatVyrPlan90Koo] [numeric](19, 6) NULL,
	[MatVyrPlan90Ost] [numeric](19, 6) NULL,
	[MatVyrPlan90MimoEle] [numeric](19, 6) NULL,
	[MatVyrPlan90MimoKoo] [numeric](19, 6) NULL,
	[MatVyrPlan90MimoOst] [numeric](19, 6) NULL,
	[MatVyrPlanOver90Ele] [numeric](19, 6) NULL,
	[MatVyrPlanOver90Koo] [numeric](19, 6) NULL,
	[MatVyrPlanOver90Ost] [numeric](19, 6) NULL,
	[PlanVyrobyDnes90_dashboardEle]  AS (((([MatVydaneVyrPrikEle]+[MatBlokVyrPrikEle])+[MatVyrPlan90Ele])+[MatVyrPlan90MimoEle])-[MatBlokVyrPrikEle]),
	[PlanVyrobyDnes90_dashboardKoo]  AS (((([MatVydaneVyrPrikKoo]+[MatBlokVyrPrikKoo])+[MatVyrPlan90Koo])+[MatVyrPlan90MimoKoo])-[MatBlokVyrPrikKoo]),
	[PlanVyrobyDnes90_dashboardOst]  AS (((([MatVydaneVyrPrikOst]+[MatBlokVyrPrikOst])+[MatVyrPlan90Ost])+[MatVyrPlan90MimoOst])-[MatBlokVyrPrikOst]),
	[ChybejiciPolDnes90Ele]  AS ([MatVyrPlan90MimoEle]),
	[ChybejiciPolDnes90Koo]  AS ([MatVyrPlan90MimoKoo]),
	[ChybejiciPolDnes90Ost]  AS ([MatVyrPlan90MimoOst]),
 CONSTRAINT [PK__Tabx_RS_Segmentace__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVydaneVyrPrik]  DEFAULT ((0)) FOR [MatVydaneVyrPrik]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatBlokVyrPrik]  DEFAULT ((0)) FOR [MatBlokVyrPrik]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90]  DEFAULT ((0)) FOR [MatVyrPlan90]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90Mimo]  DEFAULT ((0)) FOR [MatVyrPlan90Mimo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlanOver90]  DEFAULT ((0)) FOR [MatVyrPlanOver90]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlanOver90Mimo]  DEFAULT ((0)) FOR [MatVyrPlanOver90Mimo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatRez]  DEFAULT ((0)) FOR [MatRez]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatNekrytySklad]  DEFAULT ((0)) FOR [MatNekrytySklad]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MnozstviSklad]  DEFAULT ((0)) FOR [MnozstviSklad]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__FinStavSklad]  DEFAULT ((0)) FOR [FinStavSklad]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__PrumerSklad]  DEFAULT ((0)) FOR [PrumerSklad]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__PlanVyrobyDnes90_dashboardNEW]  DEFAULT ((0)) FOR [PlanVyrobyDnes90_dashboardNEW]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatRamcovkyOdb]  DEFAULT ((0)) FOR [MatRamcovkyOdb]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVydaneVyrPrikEle]  DEFAULT ((0)) FOR [MatVydaneVyrPrikEle]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVydaneVyrPrikKoo]  DEFAULT ((0)) FOR [MatVydaneVyrPrikKoo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVydaneVyrPrikOst]  DEFAULT ((0)) FOR [MatVydaneVyrPrikOst]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatBlokVyrPrikEle]  DEFAULT ((0)) FOR [MatBlokVyrPrikEle]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatBlokVyrPrikKoo]  DEFAULT ((0)) FOR [MatBlokVyrPrikKoo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatBlokVyrPrikOst]  DEFAULT ((0)) FOR [MatBlokVyrPrikOst]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90Ele]  DEFAULT ((0)) FOR [MatVyrPlan90Ele]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90Koo]  DEFAULT ((0)) FOR [MatVyrPlan90Koo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90Ost]  DEFAULT ((0)) FOR [MatVyrPlan90Ost]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90MimoEle]  DEFAULT ((0)) FOR [MatVyrPlan90MimoEle]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90MimoKoo]  DEFAULT ((0)) FOR [MatVyrPlan90MimoKoo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlan90MimoOst]  DEFAULT ((0)) FOR [MatVyrPlan90MimoOst]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlanOver90Ele]  DEFAULT ((0)) FOR [MatVyrPlanOver90Ele]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlanOver90Koo]  DEFAULT ((0)) FOR [MatVyrPlanOver90Koo]
GO

ALTER TABLE [dbo].[Tabx_RS_Segmentace] ADD  CONSTRAINT [DF__Tabx_RS_Segmentace__MatVyrPlanOver90Ost]  DEFAULT ((0)) FOR [MatVyrPlanOver90Ost]
GO

