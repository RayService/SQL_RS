USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_ASOL_HodnoceniZakazek]    Script Date: 02.07.2025 8:21:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZakazka] [int] NULL,
	[Autor] [smallint] NOT NULL,
	[mat_Pl] [numeric](19, 6) NOT NULL,
	[matA_Pl] [numeric](19, 6) NOT NULL,
	[matB_Pl] [numeric](19, 6) NOT NULL,
	[matC_Pl] [numeric](19, 6) NOT NULL,
	[MatRezie_Pl] [numeric](19, 6) NOT NULL,
	[koop_Pl] [numeric](19, 6) NOT NULL,
	[mzda_Pl] [numeric](19, 6) NOT NULL,
	[rezieS_Pl] [numeric](19, 6) NOT NULL,
	[rezieP_Pl] [numeric](19, 6) NOT NULL,
	[ReziePrac_Pl] [numeric](19, 6) NOT NULL,
	[NakladyPrac_Pl] [numeric](19, 6) NOT NULL,
	[OPN_Pl] [numeric](19, 6) NOT NULL,
	[VedProdukt_Pl] [numeric](19, 6) NOT NULL,
	[naradi_Pl] [numeric](19, 6) NOT NULL,
	[mat_P_Pl] [numeric](19, 6) NOT NULL,
	[matA_P_Pl] [numeric](19, 6) NOT NULL,
	[matB_P_Pl] [numeric](19, 6) NOT NULL,
	[matC_P_Pl] [numeric](19, 6) NOT NULL,
	[MatRezie_P_Pl] [numeric](19, 6) NOT NULL,
	[koop_P_Pl] [numeric](19, 6) NOT NULL,
	[Mzda_P_Pl] [numeric](19, 6) NOT NULL,
	[rezieS_P_Pl] [numeric](19, 6) NOT NULL,
	[rezieP_P_Pl] [numeric](19, 6) NOT NULL,
	[ReziePrac_P_Pl] [numeric](19, 6) NOT NULL,
	[NakladyPrac_P_Pl] [numeric](19, 6) NOT NULL,
	[OPN_P_Pl] [numeric](19, 6) NOT NULL,
	[VedProdukt_P_Pl] [numeric](19, 6) NOT NULL,
	[naradi_P_Pl] [numeric](19, 6) NOT NULL,
	[mat] [numeric](19, 6) NOT NULL,
	[matA] [numeric](19, 6) NOT NULL,
	[matB] [numeric](19, 6) NOT NULL,
	[matC] [numeric](19, 6) NOT NULL,
	[MatRezie] [numeric](19, 6) NOT NULL,
	[koop] [numeric](19, 6) NOT NULL,
	[mzda] [numeric](19, 6) NOT NULL,
	[rezieS] [numeric](19, 6) NOT NULL,
	[rezieP] [numeric](19, 6) NOT NULL,
	[ReziePrac] [numeric](19, 6) NOT NULL,
	[NakladyPrac] [numeric](19, 6) NOT NULL,
	[OPN] [numeric](19, 6) NOT NULL,
	[VedProdukt] [numeric](19, 6) NOT NULL,
	[naradi] [numeric](19, 6) NOT NULL,
	[NespecNakl] [numeric](19, 6) NOT NULL,
	[mat_P] [numeric](19, 6) NOT NULL,
	[matA_P] [numeric](19, 6) NOT NULL,
	[matB_P] [numeric](19, 6) NOT NULL,
	[matC_P] [numeric](19, 6) NOT NULL,
	[MatRezie_P] [numeric](19, 6) NOT NULL,
	[koop_P] [numeric](19, 6) NOT NULL,
	[Mzda_P] [numeric](19, 6) NOT NULL,
	[rezieS_P] [numeric](19, 6) NOT NULL,
	[rezieP_P] [numeric](19, 6) NOT NULL,
	[ReziePrac_P] [numeric](19, 6) NOT NULL,
	[NakladyPrac_P] [numeric](19, 6) NOT NULL,
	[OPN_P] [numeric](19, 6) NOT NULL,
	[VedProdukt_P] [numeric](19, 6) NOT NULL,
	[naradi_P] [numeric](19, 6) NOT NULL,
	[cas_Pl] [numeric](19, 6) NOT NULL,
	[cas_Pl_T] [tinyint] NOT NULL,
	[cas_Sk] [numeric](19, 6) NOT NULL,
	[cas_Sk_T] [tinyint] NOT NULL,
	[OdpracovanyCas] [numeric](19, 6) NOT NULL,
	[OdpracovanyCas_T] [tinyint] NOT NULL,
	[ZaplacenyCas] [numeric](19, 6) NOT NULL,
	[ZaplacenyCas_T] [tinyint] NOT NULL,
	[cas_Obsluhy_Pl] [numeric](19, 6) NOT NULL,
	[cas_Obsluhy_Pl_T] [tinyint] NOT NULL,
	[cas_Obsluhy_Sk] [numeric](19, 6) NOT NULL,
	[cas_Obsluhy_Sk_T] [tinyint] NOT NULL,
	[OdpracovanyCas_Obsluhy] [numeric](19, 6) NOT NULL,
	[OdpracovanyCas_Obsluhy_T] [tinyint] NOT NULL,
	[ZaplacenyCas_Obsluhy] [numeric](19, 6) NOT NULL,
	[ZaplacenyCas_Obsluhy_T] [tinyint] NOT NULL,
	[UhradaZmetku] [numeric](19, 6) NOT NULL,
	[Celkem_Pl]  AS (CONVERT([numeric](19,6),((((((((([mat_Pl]+[MatRezie_Pl])+[koop_Pl])+[mzda_Pl])+[rezies_Pl])+[reziep_Pl])+[reziePrac_Pl])+[NakladyPrac_Pl])+[OPN_Pl])-[VedProdukt_Pl])+[naradi_Pl])),
	[Celkem_P_Pl]  AS (CONVERT([numeric](19,6),((((((((([mat_P_Pl]+[MatRezie_P_Pl])+[koop_P_Pl])+[mzda_P_Pl])+[rezies_P_Pl])+[reziep_P_Pl])+[reziePrac_P_Pl])+[NakladyPrac_P_Pl])+[OPN_P_Pl])-[VedProdukt_P_Pl])+[naradi_P_Pl])),
	[Celkem]  AS (CONVERT([numeric](19,6),(((((((((([mat]+[MatRezie])+[koop])+[mzda])+[rezies])+[reziep])+[reziePrac])+[NakladyPrac])+[OPN])-[VedProdukt])+[naradi])+[NespecNakl])),
	[Celkem_P]  AS (CONVERT([numeric](19,6),((((((((([mat_P]+[MatRezie_P])+[koop_P])+[mzda_P])+[rezies_P])+[reziep_P])+[reziePrac_P])+[NakladyPrac_P])+[OPN_P])-[VedProdukt_P])+[naradi_P])),
	[cas_Pl_S]  AS (CONVERT([numeric](19,6),[cas_Pl]*case [cas_Pl_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[cas_Pl_N]  AS (CONVERT([numeric](19,6),case [cas_Pl_T] when (0) then [cas_Pl]/(60.0) when (1) then [cas_Pl] when (2) then (60.0)*[cas_Pl]  end)),
	[cas_Pl_H]  AS (CONVERT([numeric](19,6),[cas_Pl]/case [cas_Pl_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[cas_Sk_S]  AS (CONVERT([numeric](19,6),[cas_Sk]*case [cas_Sk_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[cas_Sk_N]  AS (CONVERT([numeric](19,6),case [cas_Sk_T] when (0) then [cas_Sk]/(60.0) when (1) then [cas_Sk] when (2) then (60.0)*[cas_Sk]  end)),
	[cas_Sk_H]  AS (CONVERT([numeric](19,6),[cas_Sk]/case [cas_Sk_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[OdpracovanyCas_S]  AS (CONVERT([numeric](19,6),[OdpracovanyCas]*case [OdpracovanyCas_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[OdpracovanyCas_N]  AS (CONVERT([numeric](19,6),case [OdpracovanyCas_T] when (0) then [OdpracovanyCas]/(60.0) when (1) then [OdpracovanyCas] when (2) then (60.0)*[OdpracovanyCas]  end)),
	[OdpracovanyCas_H]  AS (CONVERT([numeric](19,6),[OdpracovanyCas]/case [OdpracovanyCas_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[ZaplacenyCas_S]  AS (CONVERT([numeric](19,6),[ZaplacenyCas]*case [ZaplacenyCas_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[ZaplacenyCas_N]  AS (CONVERT([numeric](19,6),case [ZaplacenyCas_T] when (0) then [ZaplacenyCas]/(60.0) when (1) then [ZaplacenyCas] when (2) then (60.0)*[ZaplacenyCas]  end)),
	[ZaplacenyCas_H]  AS (CONVERT([numeric](19,6),[ZaplacenyCas]/case [ZaplacenyCas_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[cas_Obsluhy_Pl_S]  AS (CONVERT([numeric](19,6),[cas_Obsluhy_Pl]*case [cas_Obsluhy_Pl_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[cas_Obsluhy_Pl_N]  AS (CONVERT([numeric](19,6),case [cas_Obsluhy_Pl_T] when (0) then [cas_Obsluhy_Pl]/(60.0) when (1) then [cas_Obsluhy_Pl] when (2) then (60.0)*[cas_Obsluhy_Pl]  end)),
	[cas_Obsluhy_Pl_H]  AS (CONVERT([numeric](19,6),[cas_Obsluhy_Pl]/case [cas_Obsluhy_Pl_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[cas_Obsluhy_Sk_S]  AS (CONVERT([numeric](19,6),[cas_Obsluhy_Sk]*case [cas_Obsluhy_Sk_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[cas_Obsluhy_Sk_N]  AS (CONVERT([numeric](19,6),case [cas_Obsluhy_Sk_T] when (0) then [cas_Obsluhy_Sk]/(60.0) when (1) then [cas_Obsluhy_Sk] when (2) then (60.0)*[cas_Obsluhy_Sk]  end)),
	[cas_Obsluhy_Sk_H]  AS (CONVERT([numeric](19,6),[cas_Obsluhy_Sk]/case [cas_Obsluhy_Sk_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[OdpracovanyCas_Obsluhy_S]  AS (CONVERT([numeric](19,6),[OdpracovanyCas_Obsluhy]*case [OdpracovanyCas_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[OdpracovanyCas_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [OdpracovanyCas_Obsluhy_T] when (0) then [OdpracovanyCas_Obsluhy]/(60.0) when (1) then [OdpracovanyCas_Obsluhy] when (2) then (60.0)*[OdpracovanyCas_Obsluhy]  end)),
	[OdpracovanyCas_Obsluhy_H]  AS (CONVERT([numeric](19,6),[OdpracovanyCas_Obsluhy]/case [OdpracovanyCas_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end)),
	[ZaplacenyCas_Obsluhy_S]  AS (CONVERT([numeric](19,6),[ZaplacenyCas_Obsluhy]*case [ZaplacenyCas_Obsluhy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0)  end)),
	[ZaplacenyCas_Obsluhy_N]  AS (CONVERT([numeric](19,6),case [ZaplacenyCas_Obsluhy_T] when (0) then [ZaplacenyCas_Obsluhy]/(60.0) when (1) then [ZaplacenyCas_Obsluhy] when (2) then (60.0)*[ZaplacenyCas_Obsluhy]  end)),
	[ZaplacenyCas_Obsluhy_H]  AS (CONVERT([numeric](19,6),[ZaplacenyCas_Obsluhy]/case [ZaplacenyCas_Obsluhy_T] when (0) then (3600.0) when (1) then (60.0) when (2) then (1.0)  end))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [cas_Pl_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [cas_Sk_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [OdpracovanyCas_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [ZaplacenyCas_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [cas_Obsluhy_Pl_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [cas_Obsluhy_Sk_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [OdpracovanyCas_Obsluhy_T]
GO

ALTER TABLE [dbo].[Tabx_ASOL_HodnoceniZakazek] ADD  DEFAULT ((1)) FOR [ZaplacenyCas_Obsluhy_T]
GO

