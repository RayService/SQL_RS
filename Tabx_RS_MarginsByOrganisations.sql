USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_MarginsByOrganisations]    Script Date: 02.07.2025 9:14:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_MarginsByOrganisations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CisloOrg] [int] NOT NULL,
	[SalesType] [int] NOT NULL,
	[Leden] [numeric](5, 2) NULL,
	[Unor] [numeric](5, 2) NULL,
	[Brezen] [numeric](5, 2) NULL,
	[Duben] [numeric](5, 2) NULL,
	[Kveten] [numeric](5, 2) NULL,
	[Cerven] [numeric](5, 2) NULL,
	[Cervenec] [numeric](5, 2) NULL,
	[Srpen] [numeric](5, 2) NULL,
	[Zari] [numeric](5, 2) NULL,
	[Rijen] [numeric](5, 2) NULL,
	[Listopad] [numeric](5, 2) NULL,
	[Prosinec] [numeric](5, 2) NULL,
	[Q1] [numeric](5, 2) NULL,
	[Q2] [numeric](5, 2) NULL,
	[Q3] [numeric](5, 2) NULL,
	[Q4] [numeric](5, 2) NULL,
	[YearSum] [numeric](5, 2) NULL,
	[Year] [int] NOT NULL,
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
	[LedenCena] [numeric](19, 6) NULL,
	[UnorCena] [numeric](19, 6) NULL,
	[BrezenCena] [numeric](19, 6) NULL,
	[DubenCena] [numeric](19, 6) NULL,
	[KvetenCena] [numeric](19, 6) NULL,
	[CervenCena] [numeric](19, 6) NULL,
	[CervenecCena] [numeric](19, 6) NULL,
	[SrpenCena] [numeric](19, 6) NULL,
	[ZariCena] [numeric](19, 6) NULL,
	[RijenCena] [numeric](19, 6) NULL,
	[ListopadCena] [numeric](19, 6) NULL,
	[ProsinecCena] [numeric](19, 6) NULL,
	[Q1Cena] [numeric](19, 6) NULL,
	[Q2Cena] [numeric](19, 6) NULL,
	[Q3Cena] [numeric](19, 6) NULL,
	[Q4Cena] [numeric](19, 6) NULL,
	[YearSumCena] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RS_MarginsByOrganisations__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Leden]  DEFAULT ((0)) FOR [Leden]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Unor]  DEFAULT ((0)) FOR [Unor]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Brezen]  DEFAULT ((0)) FOR [Brezen]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Duben]  DEFAULT ((0)) FOR [Duben]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Kveten]  DEFAULT ((0)) FOR [Kveten]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Cerven]  DEFAULT ((0)) FOR [Cerven]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Cervenec]  DEFAULT ((0)) FOR [Cervenec]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Srpen]  DEFAULT ((0)) FOR [Srpen]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Zari]  DEFAULT ((0)) FOR [Zari]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Rijen]  DEFAULT ((0)) FOR [Rijen]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Listopad]  DEFAULT ((0)) FOR [Listopad]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Prosinec]  DEFAULT ((0)) FOR [Prosinec]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q1]  DEFAULT ((0)) FOR [Q1]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q2]  DEFAULT ((0)) FOR [Q2]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q3]  DEFAULT ((0)) FOR [Q3]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q4]  DEFAULT ((0)) FOR [Q4]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__YearSum]  DEFAULT ((0)) FOR [YearSum]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__LedenCena]  DEFAULT ((0)) FOR [LedenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__UnorCena]  DEFAULT ((0)) FOR [UnorCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__BrezenCena]  DEFAULT ((0)) FOR [BrezenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__DubenCena]  DEFAULT ((0)) FOR [DubenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__KvetenCena]  DEFAULT ((0)) FOR [KvetenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__CervenCena]  DEFAULT ((0)) FOR [CervenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__CervenecCena]  DEFAULT ((0)) FOR [CervenecCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__SrpenCena]  DEFAULT ((0)) FOR [SrpenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__ZariCena]  DEFAULT ((0)) FOR [ZariCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__RijenCena]  DEFAULT ((0)) FOR [RijenCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__ListopadCena]  DEFAULT ((0)) FOR [ListopadCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__ProsinecCena]  DEFAULT ((0)) FOR [ProsinecCena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q1Cena]  DEFAULT ((0)) FOR [Q1Cena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q2Cena]  DEFAULT ((0)) FOR [Q2Cena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q3Cena]  DEFAULT ((0)) FOR [Q3Cena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__Q4Cena]  DEFAULT ((0)) FOR [Q4Cena]
GO

ALTER TABLE [dbo].[Tabx_RS_MarginsByOrganisations] ADD  CONSTRAINT [DF__Tabx_RS_MarginsByOrganisations__YearSumCena]  DEFAULT ((0)) FOR [YearSumCena]
GO

