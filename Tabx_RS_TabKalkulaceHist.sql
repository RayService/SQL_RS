USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TabKalkulaceHist]    Script Date: 02.07.2025 9:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TabKalkulaceHist](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZadVyp] [int] NOT NULL,
	[IDZakazka] [int] NULL,
	[Dilec] [int] NOT NULL,
	[mat] [numeric](19, 6) NOT NULL,
	[koop] [numeric](19, 6) NOT NULL,
	[TAC] [numeric](19, 6) NOT NULL,
	[TAC_T] [tinyint] NOT NULL,
	[TBC] [numeric](19, 6) NOT NULL,
	[TBC_T] [tinyint] NOT NULL,
	[TEC] [numeric](19, 6) NOT NULL,
	[TEC_T] [tinyint] NOT NULL,
	[TAC_KC] [numeric](19, 6) NOT NULL,
	[TBC_KC] [numeric](19, 6) NOT NULL,
	[TEC_KC] [numeric](19, 6) NOT NULL,
	[rezieS] [numeric](19, 6) NOT NULL,
	[rezieP] [numeric](19, 6) NOT NULL,
	[ReziePrac] [numeric](19, 6) NOT NULL,
	[NakladyPrac] [numeric](19, 6) NOT NULL,
	[naradi] [numeric](19, 6) NOT NULL,
	[mat_P] [numeric](19, 6) NOT NULL,
	[koop_P] [numeric](19, 6) NOT NULL,
	[TAC_P] [numeric](19, 6) NOT NULL,
	[TAC_P_T] [tinyint] NOT NULL,
	[TBC_P] [numeric](19, 6) NOT NULL,
	[TBC_P_T] [tinyint] NOT NULL,
	[TEC_P] [numeric](19, 6) NOT NULL,
	[TEC_P_T] [tinyint] NOT NULL,
	[TAC_KC_P] [numeric](19, 6) NOT NULL,
	[TBC_KC_P] [numeric](19, 6) NOT NULL,
	[TEC_KC_P] [numeric](19, 6) NOT NULL,
	[rezieS_P] [numeric](19, 6) NOT NULL,
	[rezieP_P] [numeric](19, 6) NOT NULL,
	[ReziePrac_P] [numeric](19, 6) NOT NULL,
	[NakladyPrac_P] [numeric](19, 6) NOT NULL,
	[naradi_P] [numeric](19, 6) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[Skupina] [nvarchar](10) NULL,
	[OPN] [numeric](19, 6) NOT NULL,
	[VedProdukt] [numeric](19, 6) NOT NULL,
	[OPN_P] [numeric](19, 6) NOT NULL,
	[VedProdukt_P] [numeric](19, 6) NOT NULL,
	[IDKalkVzor] [int] NULL,
	[MatRezie] [numeric](19, 6) NOT NULL,
	[MatRezie_P] [numeric](19, 6) NOT NULL,
	[TAC_S]  AS (CONVERT([numeric](19,6),[TAC]*case [TAC_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TAC_N]  AS (CONVERT([numeric](19,6),case [TAC_T] when (0) then [TAC]/(60.0) when (1) then [TAC] when (2) then (60.0)*[TAC]  end,(0))),
	[TAC_H]  AS (CONVERT([numeric](19,6),[TAC]/case [TAC_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TBC_S]  AS (CONVERT([numeric](19,6),[TBC]*case [TBC_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TBC_N]  AS (CONVERT([numeric](19,6),case [TBC_T] when (0) then [TBC]/(60.0) when (1) then [TBC] when (2) then (60.0)*[TBC]  end,(0))),
	[TBC_H]  AS (CONVERT([numeric](19,6),[TBC]/case [TBC_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TEC_S]  AS (CONVERT([numeric](19,6),[TEC]*case [TEC_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TEC_N]  AS (CONVERT([numeric](19,6),case [TEC_T] when (0) then [TEC]/(60.0) when (1) then [TEC] when (2) then (60.0)*[TEC]  end,(0))),
	[TEC_H]  AS (CONVERT([numeric](19,6),[TEC]/case [TEC_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TAC_P_S]  AS (CONVERT([numeric](19,6),[TAC_P]*case [TAC_P_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TAC_P_N]  AS (CONVERT([numeric](19,6),case [TAC_P_T] when (0) then [TAC_P]/(60.0) when (1) then [TAC_P] when (2) then (60.0)*[TAC_P]  end,(0))),
	[TAC_P_H]  AS (CONVERT([numeric](19,6),[TAC_P]/case [TAC_P_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TBC_P_S]  AS (CONVERT([numeric](19,6),[TBC_P]*case [TBC_P_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TBC_P_N]  AS (CONVERT([numeric](19,6),case [TBC_P_T] when (0) then [TBC_P]/(60.0) when (1) then [TBC_P] when (2) then (60.0)*[TBC_P]  end,(0))),
	[TBC_P_H]  AS (CONVERT([numeric](19,6),[TBC_P]/case [TBC_P_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TEC_P_S]  AS (CONVERT([numeric](19,6),[TEC_P]*case [TEC_P_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TEC_P_N]  AS (CONVERT([numeric](19,6),case [TEC_P_T] when (0) then [TEC_P]/(60.0) when (1) then [TEC_P] when (2) then (60.0)*[TEC_P]  end,(0))),
	[TEC_P_H]  AS (CONVERT([numeric](19,6),[TEC_P]/case [TEC_P_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[Celkem]  AS (CONVERT([numeric](19,6),((((((((((([mat]+[MatRezie])+[koop])+[tbc_kc])+[tec_kc])+[tac_kc])+[rezies])+[reziep])+[reziePrac])+[NakladyPrac])+[OPN])-[VedProdukt])+[naradi],(0))),
	[Celkem_P]  AS (CONVERT([numeric](19,6),((((((((((([mat_P]+[MatRezie_P])+[koop_P])+[tbc_kc_P])+[tec_kc_P])+[tac_kc_P])+[rezies_P])+[reziep_P])+[reziePrac_P])+[NakladyPrac_P])+[OPN_P])-[VedProdukt_P])+[naradi_P],(0))),
	[TAC_Obsluhy] [numeric](19, 6) NOT NULL,
	[TAC_Obsluhy_T] [tinyint] NOT NULL,
	[TBC_Obsluhy] [numeric](19, 6) NOT NULL,
	[TBC_Obsluhy_T] [tinyint] NOT NULL,
	[TEC_Obsluhy] [numeric](19, 6) NOT NULL,
	[TEC_Obsluhy_T] [tinyint] NOT NULL,
	[TAC_P_Obsluhy] [numeric](19, 6) NOT NULL,
	[TAC_P_Obsluhy_T] [tinyint] NOT NULL,
	[TBC_P_Obsluhy] [numeric](19, 6) NOT NULL,
	[TBC_P_Obsluhy_T] [tinyint] NOT NULL,
	[TEC_P_Obsluhy] [numeric](19, 6) NOT NULL,
	[TEC_P_Obsluhy_T] [tinyint] NOT NULL,
	[TAC_Obsluhy_S]  AS (CONVERT([numeric](19,6),[TAC_Obsluhy]*case [TAC_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TAC_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [TAC_Obsluhy_T] when (0) then [TAC_Obsluhy]/(60.0) when (1) then [TAC_Obsluhy] when (2) then (60.0)*[TAC_Obsluhy]  end,(0))),
	[TAC_Obsluhy_H]  AS (CONVERT([numeric](19,6),[TAC_Obsluhy]/case [TAC_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TBC_Obsluhy_S]  AS (CONVERT([numeric](19,6),[TBC_Obsluhy]*case [TBC_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TBC_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [TBC_Obsluhy_T] when (0) then [TBC_Obsluhy]/(60.0) when (1) then [TBC_Obsluhy] when (2) then (60.0)*[TBC_Obsluhy]  end,(0))),
	[TBC_Obsluhy_H]  AS (CONVERT([numeric](19,6),[TBC_Obsluhy]/case [TBC_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TEC_Obsluhy_S]  AS (CONVERT([numeric](19,6),[TEC_Obsluhy]*case [TEC_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TEC_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [TEC_Obsluhy_T] when (0) then [TEC_Obsluhy]/(60.0) when (1) then [TEC_Obsluhy] when (2) then (60.0)*[TEC_Obsluhy]  end,(0))),
	[TEC_Obsluhy_H]  AS (CONVERT([numeric](19,6),[TEC_Obsluhy]/case [TEC_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TAC_P_Obsluhy_S]  AS (CONVERT([numeric](19,6),[TAC_P_Obsluhy]*case [TAC_P_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TAC_P_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [TAC_P_Obsluhy_T] when (0) then [TAC_P_Obsluhy]/(60.0) when (1) then [TAC_P_Obsluhy] when (2) then (60.0)*[TAC_P_Obsluhy]  end,(0))),
	[TAC_P_Obsluhy_H]  AS (CONVERT([numeric](19,6),[TAC_P_Obsluhy]/case [TAC_P_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TBC_P_Obsluhy_S]  AS (CONVERT([numeric](19,6),[TBC_P_Obsluhy]*case [TBC_P_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TBC_P_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [TBC_P_Obsluhy_T] when (0) then [TBC_P_Obsluhy]/(60.0) when (1) then [TBC_P_Obsluhy] when (2) then (60.0)*[TBC_P_Obsluhy]  end,(0))),
	[TBC_P_Obsluhy_H]  AS (CONVERT([numeric](19,6),[TBC_P_Obsluhy]/case [TBC_P_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TEC_P_Obsluhy_S]  AS (CONVERT([numeric](19,6),[TEC_P_Obsluhy]*case [TEC_P_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end,(0))),
	[TEC_P_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [TEC_P_Obsluhy_T] when (0) then [TEC_P_Obsluhy]/(60.0) when (1) then [TEC_P_Obsluhy] when (2) then (60.0)*[TEC_P_Obsluhy]  end,(0))),
	[TEC_P_Obsluhy_H]  AS (CONVERT([numeric](19,6),[TEC_P_Obsluhy]/case [TEC_P_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end,(0))),
	[TabID] [int] NULL,
	[RecID] [int] NULL,
	[Mnozstvi] [numeric](19, 6) NOT NULL,
	[matA] [numeric](19, 6) NOT NULL,
	[matB] [numeric](19, 6) NOT NULL,
	[matC] [numeric](19, 6) NOT NULL,
	[matA_P] [numeric](19, 6) NOT NULL,
	[matB_P] [numeric](19, 6) NOT NULL,
	[matC_P] [numeric](19, 6) NOT NULL,
	[IDZakazModif] [int] NULL,
	[JNmat]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [mat]/[Mnozstvi]  end,(0))),
	[JNmatA]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [matA]/[Mnozstvi]  end,(0))),
	[JNmatB]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [matB]/[Mnozstvi]  end,(0))),
	[JNmatC]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [matC]/[Mnozstvi]  end,(0))),
	[JNMatRezie]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [MatRezie]/[Mnozstvi]  end,(0))),
	[JNkoop]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [koop]/[Mnozstvi]  end,(0))),
	[JNTAC_KC]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [TAC_KC]/[Mnozstvi]  end,(0))),
	[JNTBC_KC]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [TBC_KC]/[Mnozstvi]  end,(0))),
	[JNTEC_KC]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [TEC_KC]/[Mnozstvi]  end,(0))),
	[JNrezieS]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [rezieS]/[Mnozstvi]  end,(0))),
	[JNrezieP]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [rezieP]/[Mnozstvi]  end,(0))),
	[JNReziePrac]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [ReziePrac]/[Mnozstvi]  end,(0))),
	[JNNakladyPrac]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [NakladyPrac]/[Mnozstvi]  end,(0))),
	[JNOPN]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [OPN]/[Mnozstvi]  end,(0))),
	[JNVedProdukt]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [VedProdukt]/[Mnozstvi]  end,(0))),
	[JNnaradi]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [Naradi]/[Mnozstvi]  end,(0))),
	[JNCelkem]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then (((((((((((([mat]+[MatRezie])+[koop])+[tbc_kc])+[tec_kc])+[tac_kc])+[rezies])+[reziep])+[reziePrac])+[NakladyPrac])+[OPN])-[VedProdukt])+[naradi])/[Mnozstvi]  end,(0))),
	[JNmat_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [mat_P]/[Mnozstvi]  end,(0))),
	[JNmatA_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [matA_P]/[Mnozstvi]  end,(0))),
	[JNmatB_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [matB_P]/[Mnozstvi]  end,(0))),
	[JNmatC_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [matC_P]/[Mnozstvi]  end,(0))),
	[JNMatRezie_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [MatRezie_P]/[Mnozstvi]  end,(0))),
	[JNkoop_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [koop_P]/[Mnozstvi]  end,(0))),
	[JNTAC_KC_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [TAC_KC_P]/[Mnozstvi]  end,(0))),
	[JNTBC_KC_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [TBC_KC_P]/[Mnozstvi]  end,(0))),
	[JNTEC_KC_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [TEC_KC_P]/[Mnozstvi]  end,(0))),
	[JNrezieS_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [rezieS_P]/[Mnozstvi]  end,(0))),
	[JNrezieP_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [rezieP_P]/[Mnozstvi]  end,(0))),
	[JNReziePrac_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [ReziePrac_P]/[Mnozstvi]  end,(0))),
	[JNNakladyPrac_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [NakladyPrac_P]/[Mnozstvi]  end,(0))),
	[JNOPN_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [OPN_P]/[Mnozstvi]  end,(0))),
	[JNVedProdukt_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [VedProdukt_P]/[Mnozstvi]  end,(0))),
	[JNnaradi_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then [naradi_P]/[Mnozstvi]  end,(0))),
	[JNCelkem_P]  AS (CONVERT([numeric](19,6),case when [Mnozstvi]<>(0.0) then (((((((((((([mat_P]+[MatRezie_P])+[koop_P])+[tbc_kc_P])+[tec_kc_P])+[tac_kc_P])+[rezies_P])+[reziep_P])+[reziePrac_P])+[NakladyPrac_P])+[OPN_P])-[VedProdukt_P])+[naradi_P])/[mnozstvi]  end,(0))),
	[AutorHist] [nvarchar](128) NOT NULL,
	[DatHist] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_RS_TabKalkulaceHist__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TAC_T]  DEFAULT ((1)) FOR [TAC_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TBC_T]  DEFAULT ((1)) FOR [TBC_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TEC_T]  DEFAULT ((1)) FOR [TEC_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TAC_P_T]  DEFAULT ((1)) FOR [TAC_P_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TBC_P_T]  DEFAULT ((1)) FOR [TBC_P_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TEC_P_T]  DEFAULT ((1)) FOR [TEC_P_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TAC_Obsluhy_T]  DEFAULT ((1)) FOR [TAC_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TBC_Obsluhy_T]  DEFAULT ((1)) FOR [TBC_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TEC_Obsluhy_T]  DEFAULT ((1)) FOR [TEC_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TAC_P_Obsluhy_T]  DEFAULT ((1)) FOR [TAC_P_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TBC_P_Obsluhy_T]  DEFAULT ((1)) FOR [TBC_P_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  CONSTRAINT [DF__Tabx_RS_TabKalkulaceHist__TEC_P_Obsluhy_T]  DEFAULT ((1)) FOR [TEC_P_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  DEFAULT (suser_sname()) FOR [AutorHist]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKalkulaceHist] ADD  DEFAULT (getdate()) FOR [DatHist]
GO

