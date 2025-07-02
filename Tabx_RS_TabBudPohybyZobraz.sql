USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TabBudPohybyZobraz]    Script Date: 02.07.2025 9:50:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Generuj] [bit] NOT NULL,
	[IDPohyb] [int] NULL,
	[IDPlan] [int] NULL,
	[IDPredPlan] [int] NULL,
	[PrKVDoklad] [int] NULL,
	[PrVPVDoklad] [int] NULL,
	[IDPlanPrikaz] [int] NULL,
	[IDPrikaz] [int] NULL,
	[IDGprUlohyMatZdroje] [int] NULL,
	[Oblast] [tinyint] NOT NULL,
	[Sklad] [nvarchar](30) NULL,
	[IDKmeneZbozi] [int] NOT NULL,
	[DatumPohybu_Pl] [datetime] NULL,
	[DatumPohybu] [datetime] NOT NULL,
	[PoradiPohybu] [int] NOT NULL,
	[MnozstviNaSklade] [numeric](19, 6) NOT NULL,
	[Mnozstvi_Pl] [numeric](19, 6) NOT NULL,
	[Mnozstvi] [numeric](19, 6) NOT NULL,
	[Dodavatel] [int] NULL,
	[Objednat] [numeric](19, 6) NOT NULL,
	[generovano] [numeric](19, 6) NOT NULL,
	[IDZakazka] [int] NULL,
	[DodaciLhuta] [int] NOT NULL,
	[TypDodaciLhuty] [tinyint] NOT NULL,
	[LhutaNaskladneni] [int] NOT NULL,
	[KumulovatObjKeDni] [int] NULL,
	[DatumPohybu_Pl_D]  AS (datepart(day,[DatumPohybu_Pl])),
	[DatumPohybu_Pl_M]  AS (datepart(month,[DatumPohybu_Pl])),
	[DatumPohybu_Pl_Y]  AS (datepart(year,[DatumPohybu_Pl])),
	[DatumPohybu_Pl_Q]  AS (datepart(quarter,[DatumPohybu_Pl])),
	[DatumPohybu_Pl_W]  AS (datepart(week,[DatumPohybu_Pl])),
	[DatumPohybu_Pl_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumPohybu_Pl])))),
	[DatumPohybu_D]  AS (datepart(day,[DatumPohybu])),
	[DatumPohybu_M]  AS (datepart(month,[DatumPohybu])),
	[DatumPohybu_Y]  AS (datepart(year,[DatumPohybu])),
	[DatumPohybu_Q]  AS (datepart(quarter,[DatumPohybu])),
	[DatumPohybu_W]  AS (datepart(week,[DatumPohybu])),
	[DatumPohybu_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumPohybu])))),
	[ZmenaDatumuPohybu]  AS (CONVERT([bit],case when isnull([DatumPohybu],(0))=isnull([DatumPohybu_Pl],(0)) then (0) else (1) end)),
	[ZmenaMnozstvi]  AS (CONVERT([bit],case when [Mnozstvi]=[Mnozstvi_Pl] then (0) else (1) end)),
	[DatumObjednani]  AS (case [TypDodaciLhuty] when (0) then dateadd(day, -((1)*[DodaciLhuta]),([DatumPohybu]-[LhutaNaskladneni])-case when [KumulovatObjKeDni] IS NULL then (0) else ((datepart(weekday,[DatumPohybu]-[LhutaNaskladneni])+(7))-[KumulovatObjKeDni])%(7) end) when (1) then dateadd(month, -((1)*[DodaciLhuta]),([DatumPohybu]-[LhutaNaskladneni])-case when [KumulovatObjKeDni] IS NULL then (0) else ((datepart(weekday,[DatumPohybu]-[LhutaNaskladneni])+(7))-[KumulovatObjKeDni])%(7) end) when (2) then dateadd(year, -((1)*[DodaciLhuta]),([DatumPohybu]-[LhutaNaskladneni])-case when [KumulovatObjKeDni] IS NULL then (0) else ((datepart(weekday,[DatumPohybu]-[LhutaNaskladneni])+(7))-[KumulovatObjKeDni])%(7) end)  end),
	[PozadDatDod]  AS (([DatumPohybu]-[LhutaNaskladneni])-case when [KumulovatObjKeDni] IS NULL then (0) else ((datepart(weekday,[DatumPohybu]-[LhutaNaskladneni])+(7))-[KumulovatObjKeDni])%(7) end),
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
	[NavrhPosunu] [int] NULL,
	[DatumPohybuNew] [datetime] NULL,
 CONSTRAINT [PK__Tabx_RS_TabBudPohybyZobraz__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__Generuj]  DEFAULT ((1)) FOR [Generuj]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__PoradiPohybu]  DEFAULT ((1)) FOR [PoradiPohybu]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__MnozstviNaSklade]  DEFAULT ((0)) FOR [MnozstviNaSklade]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__Objednat]  DEFAULT ((0)) FOR [Objednat]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__generovano]  DEFAULT ((0)) FOR [generovano]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__DodaciLhuta]  DEFAULT ((0)) FOR [DodaciLhuta]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__TypDodaciLhuty]  DEFAULT ((0)) FOR [TypDodaciLhuty]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__LhutaNaskladneni]  DEFAULT ((0)) FOR [LhutaNaskladneni]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_TabBudPohybyZobraz] ADD  CONSTRAINT [DF__Tabx_RS_TabBudPohybyZobraz__NavrhPosunu]  DEFAULT ((0)) FOR [NavrhPosunu]
GO

