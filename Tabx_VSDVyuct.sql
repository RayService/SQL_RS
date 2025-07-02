USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VSDVyuct]    Script Date: 02.07.2025 10:38:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VSDVyuct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[c_drp] [nvarchar](3) NOT NULL,
	[FinancniUrad] [nvarchar](255) NOT NULL,
	[c_ufo_cil] [nvarchar](4) NOT NULL,
	[d_ins] [datetime] NULL,
	[d_zjist] [datetime] NULL,
	[dapdps_forma] [nvarchar](1) NOT NULL,
	[dokument] [nvarchar](3) NOT NULL,
	[k_uladis] [nvarchar](3) NOT NULL,
	[k_rozl] [nvarchar](2) NULL,
	[zdobd_od] [datetime] NULL,
	[zdobd_do] [datetime] NULL,
	[kc_dpsii01] [numeric](19, 6) NOT NULL,
	[kc_dpsii02] [numeric](19, 6) NULL,
	[kc_dpsii04] [numeric](19, 6) NOT NULL,
	[lh_odv] [datetime] NULL,
	[c_obce] [int] NULL,
	[c_orient] [nvarchar](4) NOT NULL,
	[c_pop] [nvarchar](6) NOT NULL,
	[dic] [nvarchar](12) NOT NULL,
	[jmeno] [nvarchar](20) NOT NULL,
	[naz_obce] [nvarchar](48) NOT NULL,
	[opr_jmeno] [nvarchar](20) NOT NULL,
	[opr_postaveni] [nvarchar](40) NOT NULL,
	[opr_prijmeni] [nvarchar](36) NOT NULL,
	[prijmeni] [nvarchar](36) NOT NULL,
	[psc] [nvarchar](10) NOT NULL,
	[sest_email] [nvarchar](255) NOT NULL,
	[sest_jmeno] [nvarchar](20) NOT NULL,
	[sest_prijmeni] [nvarchar](36) NOT NULL,
	[sest_telef] [nvarchar](14) NOT NULL,
	[sest_titul] [nvarchar](10) NOT NULL,
	[titul] [nvarchar](10) NOT NULL,
	[typ_ds] [nvarchar](1) NOT NULL,
	[ulice] [nvarchar](38) NOT NULL,
	[zast_dat_nar] [datetime] NULL,
	[zast_ev_cislo] [nvarchar](36) NOT NULL,
	[zast_ic] [nvarchar](10) NOT NULL,
	[zast_jmeno] [nvarchar](20) NOT NULL,
	[zast_kod] [nvarchar](2) NULL,
	[zast_nazev] [nvarchar](36) NOT NULL,
	[zast_prijmeni] [nvarchar](36) NOT NULL,
	[zast_typ] [nvarchar](1) NULL,
	[zkrobchjm] [nvarchar](255) NOT NULL,
	[rok] [int] NOT NULL,
	[fu_pbu1] [nvarchar](6) NOT NULL,
	[fu_c_komds1] [nvarchar](10) NOT NULL,
	[fu_k_bank1] [nvarchar](4) NOT NULL,
	[fu_pbu2] [nvarchar](6) NOT NULL,
	[fu_c_komds2] [nvarchar](10) NOT NULL,
	[fu_k_bank2] [nvarchar](4) NOT NULL,
	[fu_pbu3] [nvarchar](6) NOT NULL,
	[fu_c_komds3] [nvarchar](10) NOT NULL,
	[fu_k_bank3] [nvarchar](4) NOT NULL,
	[DatumUzavreni] [datetime] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[UzemniPrac] [nvarchar](255) NULL,
	[c_pracufo] [nvarchar](4) NULL,
	[Pobocka] [nvarchar](5) NULL,
	[HodnotyPosunuty] [bit] NOT NULL,
	[kc_dpsii03]  AS (CONVERT([numeric](19,6),[kc_dpsii01]-[kc_dpsii02])),
	[kc_dpsii05]  AS (CONVERT([numeric](19,6),[kc_dpsii04]-([kc_dpsii01]-isnull([kc_dpsii02],(0))))),
 CONSTRAINT [PK__Tabx_VSDVyuct__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__c_drp]  DEFAULT (N'771') FOR [c_drp]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__FinancniUrad]  DEFAULT ('') FOR [FinancniUrad]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__c_ufo_cil]  DEFAULT ('') FOR [c_ufo_cil]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__dapdps_forma]  DEFAULT (N'B') FOR [dapdps_forma]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__dokument]  DEFAULT ('VD2') FOR [dokument]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__k_uladis]  DEFAULT ('DPS') FOR [k_uladis]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__kc_dpsii01]  DEFAULT ((0.0)) FOR [kc_dpsii01]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__kc_dpsii04]  DEFAULT ((0.0)) FOR [kc_dpsii04]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__c_orient]  DEFAULT ('') FOR [c_orient]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__c_pop]  DEFAULT ('') FOR [c_pop]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__dic]  DEFAULT ('') FOR [dic]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__jmeno]  DEFAULT ('') FOR [jmeno]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__naz_obce]  DEFAULT ('') FOR [naz_obce]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__opr_jmeno]  DEFAULT ('') FOR [opr_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__opr_postaveni]  DEFAULT ('') FOR [opr_postaveni]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__opr_prijmeni]  DEFAULT ('') FOR [opr_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__prijmeni]  DEFAULT ('') FOR [prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__psc]  DEFAULT ('') FOR [psc]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__sest_email]  DEFAULT ('') FOR [sest_email]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__sest_jmeno]  DEFAULT ('') FOR [sest_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__sest_prijmeni]  DEFAULT ('') FOR [sest_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__sest_telef]  DEFAULT ('') FOR [sest_telef]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__sest_titul]  DEFAULT ('') FOR [sest_titul]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__titul]  DEFAULT ('') FOR [titul]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__typ_ds]  DEFAULT (N'P') FOR [typ_ds]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__ulice]  DEFAULT ('') FOR [ulice]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__zast_ev_cislo]  DEFAULT ('') FOR [zast_ev_cislo]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__zast_ic]  DEFAULT ('') FOR [zast_ic]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__zast_jmeno]  DEFAULT ('') FOR [zast_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__zast_nazev]  DEFAULT ('') FOR [zast_nazev]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__zast_prijmeni]  DEFAULT ('') FOR [zast_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__zkrobchjm]  DEFAULT ('') FOR [zkrobchjm]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_pbu1]  DEFAULT ('') FOR [fu_pbu1]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_c_komds1]  DEFAULT ('') FOR [fu_c_komds1]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_k_bank1]  DEFAULT ('') FOR [fu_k_bank1]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_pbu2]  DEFAULT ('') FOR [fu_pbu2]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_c_komds2]  DEFAULT ('') FOR [fu_c_komds2]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_k_bank2]  DEFAULT ('') FOR [fu_k_bank2]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_pbu3]  DEFAULT ('') FOR [fu_pbu3]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_c_komds3]  DEFAULT ('') FOR [fu_c_komds3]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__fu_k_bank3]  DEFAULT ('') FOR [fu_k_bank3]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_VSDVyuct] ADD  CONSTRAINT [DF__Tabx_VSDVyuct__HodnotyPosunuty]  DEFAULT ((0)) FOR [HodnotyPosunuty]
GO

