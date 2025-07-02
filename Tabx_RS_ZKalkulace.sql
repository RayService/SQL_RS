USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_ZKalkulace]    Script Date: 02.07.2025 10:17:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_ZKalkulace](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Dilec] [int] NOT NULL,
	[ZmenaOd] [int] NULL,
	[ZmenaDo] [int] NULL,
	[mat] [numeric](19, 6) NOT NULL,
	[koop] [numeric](19, 6) NOT NULL,
	[TAC_KC] [numeric](19, 6) NOT NULL,
	[TBC_KC] [numeric](19, 6) NOT NULL,
	[TEC_KC] [numeric](19, 6) NOT NULL,
	[rezieS] [numeric](19, 6) NOT NULL,
	[rezieP] [numeric](19, 6) NOT NULL,
	[ReziePrac] [numeric](19, 6) NOT NULL,
	[NakladyPrac] [numeric](19, 6) NOT NULL,
	[naradi] [numeric](19, 6) NOT NULL,
	[ID1] [int] NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[OPN] [numeric](19, 6) NOT NULL,
	[VedProdukt] [numeric](19, 6) NOT NULL,
	[MatRezie] [numeric](19, 6) NOT NULL,
	[mat_P] [numeric](19, 6) NOT NULL,
	[MatRezie_P] [numeric](19, 6) NOT NULL,
	[koop_P] [numeric](19, 6) NOT NULL,
	[TAC_KC_P] [numeric](19, 6) NOT NULL,
	[TBC_KC_P] [numeric](19, 6) NOT NULL,
	[TEC_KC_P] [numeric](19, 6) NOT NULL,
	[rezieS_P] [numeric](19, 6) NOT NULL,
	[rezieP_P] [numeric](19, 6) NOT NULL,
	[ReziePrac_P] [numeric](19, 6) NOT NULL,
	[NakladyPrac_P] [numeric](19, 6) NOT NULL,
	[OPN_P] [numeric](19, 6) NOT NULL,
	[VedProdukt_P] [numeric](19, 6) NOT NULL,
	[naradi_P] [numeric](19, 6) NOT NULL,
	[Celkem]  AS (CONVERT([numeric](19,6),((((((((((([mat]+[MatRezie])+[koop])+[tbc_kc])+[tec_kc])+[tac_kc])+[rezies])+[reziep])+[reziePrac])+[NakladyPrac])+[OPN])-[VedProdukt])+[naradi],(0))),
	[Celkem_P]  AS (CONVERT([numeric](19,6),((((((((((([mat_P]+[MatRezie_P])+[koop_P])+[tbc_kc_P])+[tec_kc_P])+[tac_kc_P])+[rezies_P])+[reziep_P])+[reziePrac_P])+[NakladyPrac_P])+[OPN_P])-[VedProdukt_P])+[naradi_P],(0))),
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
	[IDZakazModif] [int] NULL,
	[JeZakazModif]  AS (CONVERT([bit],case when [IDZakazModif] IS NULL then (0) else (1) end,(0))),
	[matA] [numeric](19, 6) NOT NULL,
	[matB] [numeric](19, 6) NOT NULL,
	[matC] [numeric](19, 6) NOT NULL,
	[matA_P] [numeric](19, 6) NOT NULL,
	[matB_P] [numeric](19, 6) NOT NULL,
	[matC_P] [numeric](19, 6) NOT NULL,
	[DavkaVypoctu] [numeric](19, 6) NULL,
	[CisloZakazky] [nvarchar](15) NOT NULL,
	[TAC] [numeric](19, 6) NULL,
	[TAC_T] [tinyint] NULL,
	[TBC] [numeric](19, 6) NULL,
	[TBC_T] [tinyint] NULL,
	[TEC] [numeric](19, 6) NULL,
	[TEC_T] [tinyint] NULL,
	[Davka] [tinyint] NULL,
 CONSTRAINT [PK__Tabx_RS_ZKalkulace__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__mat]  DEFAULT ((0)) FOR [mat]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__koop]  DEFAULT ((0)) FOR [koop]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__TAC_KC]  DEFAULT ((0)) FOR [TAC_KC]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__TBC_KC]  DEFAULT ((0)) FOR [TBC_KC]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__TEC_KC]  DEFAULT ((0)) FOR [TEC_KC]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__rezieS]  DEFAULT ((0)) FOR [rezieS]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__rezieP]  DEFAULT ((0)) FOR [rezieP]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__ReziePrac]  DEFAULT ((0)) FOR [ReziePrac]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__NakladyPrac]  DEFAULT ((0)) FOR [NakladyPrac]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__naradi]  DEFAULT ((0)) FOR [naradi]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__ID1]  DEFAULT ((0)) FOR [ID1]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__OPN]  DEFAULT ((0)) FOR [OPN]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__VedProdukt]  DEFAULT ((0)) FOR [VedProdukt]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__MatRezie]  DEFAULT ((0)) FOR [MatRezie]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__mat_P]  DEFAULT ((0)) FOR [mat_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__MatRezie_P]  DEFAULT ((0)) FOR [MatRezie_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__koop_P]  DEFAULT ((0)) FOR [koop_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__TAC_KC_P]  DEFAULT ((0)) FOR [TAC_KC_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__TBC_KC_P]  DEFAULT ((0)) FOR [TBC_KC_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__TEC_KC_P]  DEFAULT ((0)) FOR [TEC_KC_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__rezieS_P]  DEFAULT ((0)) FOR [rezieS_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__rezieP_P]  DEFAULT ((0)) FOR [rezieP_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__ReziePrac_P]  DEFAULT ((0)) FOR [ReziePrac_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__NakladyPrac_P]  DEFAULT ((0)) FOR [NakladyPrac_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__OPN_P]  DEFAULT ((0)) FOR [OPN_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__VedProdukt_P]  DEFAULT ((0)) FOR [VedProdukt_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__naradi_P]  DEFAULT ((0)) FOR [naradi_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__matA]  DEFAULT ((0)) FOR [matA]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__matB]  DEFAULT ((0)) FOR [matB]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__matC]  DEFAULT ((0)) FOR [matC]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__matA_P]  DEFAULT ((0)) FOR [matA_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__matB_P]  DEFAULT ((0)) FOR [matB_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] ADD  CONSTRAINT [DF__Tabx_RS_ZKalkulace__matC_P]  DEFAULT ((0)) FOR [matC_P]
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_ZKalkulace__Dilec] FOREIGN KEY([Dilec])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_ZKalkulace] CHECK CONSTRAINT [FK__Tabx_RS_ZKalkulace__Dilec]
GO

