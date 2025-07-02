USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_KalkulaceObchodni]    Script Date: 02.07.2025 9:10:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_KalkulaceObchodni](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Dilec] [int] NOT NULL,
	[MnozstviPoz] [numeric](19, 6) NOT NULL,
	[IDZakazka] [int] NOT NULL,
	[NakladovaCena] [numeric](19, 6) NULL,
	[MinCena] [numeric](19, 6) NULL,
	[KalkCena] [numeric](19, 6) NULL,
	[OptCena] [numeric](19, 6) NULL,
	[VyslNabCena] [numeric](19, 6) NULL,
	[EvidCena] [numeric](19, 6) NULL,
	[HistProdCenaObd] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[KalkKurzVal] [numeric](19, 6) NULL,
	[KalkSazba] [numeric](19, 6) NOT NULL,
	[KalkPriraz] [int] NOT NULL,
	[KoefObch] [numeric](19, 6) NOT NULL,
	[TerminDodani] [numeric](19, 6) NULL,
	[ProcMarze]  AS ((([VyslNabCena]-[NakladovaCena])/nullif([VyslNabCena],(0)))*(100)),
	[RozdilHistCeny]  AS ((([NakladovaCena]-[EvidCena])/nullif([EvidCena],(0)))*(100)),
	[RozdilProdCeny]  AS ((([VyslNabCena]-[HistProdCenaObd])/nullif([HistProdCenaObd],(0)))*(100)),
	[RealKoefObch]  AS ([VyslNabCena]/nullif([OptCena],(0))),
	[Material] [numeric](19, 6) NULL,
	[TAC] [numeric](19, 6) NULL,
	[TBC] [numeric](19, 6) NULL,
	[IDPozadavku] [int] NULL,
	[RealHodSazbaEUR]  AS ((([VyslNabCena]-[Material])/nullif([TAC]+[TBC],(0)))/nullif([KalkKurzVal],(0))),
	[Poznamka1] [ntext] NULL,
	[Poznamka2] [ntext] NULL,
	[Poznamka3] [ntext] NULL,
	[Poznamka4] [ntext] NULL,
	[KalkCenaVal]  AS ([KalkCena]/[KalkKurzVal]),
	[OptCenaVal]  AS ([OptCena]/[KalkKurzVal]),
	[VyslNabCenaVal]  AS ([VyslNabCena]/[KalkKurzVal]),
	[HistProdCenaObdVal]  AS ([HistProdCenaObd]/[KalkKurzVal]),
	[NasMinCena] [numeric](5, 2) NULL,
	[NasOptCena] [numeric](5, 2) NULL,
	[DnyHistorie] [int] NULL,
	[IDSklad] [nvarchar](30) NULL,
	[NasobitelMzdy] [numeric](5, 2) NULL,
	[NasobitelRezie] [numeric](5, 2) NULL,
	[PodilMatKalkMask]  AS (([Material]/nullif([VyslNabCena],(0)))*(100)),
	[MzdaCista] [numeric](19, 6) NULL,
	[RezieCista] [numeric](19, 6) NULL,
	[PodilPraceKalkMask]  AS ((([MzdaCista]*[NasobitelMzdy]+[RezieCista]*[NasobitelRezie])/nullif([VyslNabCena],(0)))*(100)),
 CONSTRAINT [PK__Tabx_RS_KalkulaceObchodni__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__MnozstviPoz]  DEFAULT ((0)) FOR [MnozstviPoz]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__NakladovaCena]  DEFAULT ((0)) FOR [NakladovaCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__MinCena]  DEFAULT ((0)) FOR [MinCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__KalkCena]  DEFAULT ((0)) FOR [KalkCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__OptCena]  DEFAULT ((0)) FOR [OptCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__VyslNabCena]  DEFAULT ((0)) FOR [VyslNabCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__EvidCena]  DEFAULT ((0)) FOR [EvidCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__HistProdCenaObd]  DEFAULT ((0)) FOR [HistProdCenaObd]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__KalkKurzVal]  DEFAULT ((0)) FOR [KalkKurzVal]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__KalkSazba]  DEFAULT ((0)) FOR [KalkSazba]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__KalkPriraz]  DEFAULT ((0)) FOR [KalkPriraz]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__KoefObch]  DEFAULT ((0)) FOR [KoefObch]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__Material]  DEFAULT ((0)) FOR [Material]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__TAC]  DEFAULT ((0)) FOR [TAC]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__TBC]  DEFAULT ((0)) FOR [TBC]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__NasMinCena]  DEFAULT ((0)) FOR [NasMinCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__NasOptCena]  DEFAULT ((0)) FOR [NasOptCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__DnyHistorie]  DEFAULT ((0)) FOR [DnyHistorie]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__NasobitelMzdy]  DEFAULT ((0)) FOR [NasobitelMzdy]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceObchodni] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceObchodni__NasobitelRezie]  DEFAULT ((0)) FOR [NasobitelRezie]
GO

