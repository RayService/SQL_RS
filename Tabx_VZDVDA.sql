USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDVDA]    Script Date: 02.07.2025 10:46:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDVDA](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[c_komds] [nvarchar](10) NOT NULL,
	[k_bank] [nvarchar](4) NOT NULL,
	[c_komds2] [nvarchar](10) NOT NULL,
	[k_bank2] [nvarchar](4) NOT NULL,
	[pbu] [nvarchar](5) NOT NULL,
	[pbu2] [nvarchar](5) NOT NULL,
	[FinancniUrad] [nvarchar](255) NOT NULL,
	[c_ufo_cil] [nvarchar](4) NOT NULL,
	[d_ins] [datetime] NULL,
	[d_zjist] [datetime] NULL,
	[dokument] [nvarchar](3) NOT NULL,
	[k_uladis] [nvarchar](3) NOT NULL,
	[k_rozl] [nvarchar](2) NULL,
	[vdadpz_typ] [nvarchar](1) NOT NULL,
	[zdobd_od] [datetime] NULL,
	[zdobd_do] [datetime] NULL,
	[kc_dpzii01] [numeric](19, 6) NOT NULL,
	[kc_dpzii02] [numeric](19, 6) NOT NULL,
	[kc_dpzii03] [numeric](19, 6) NOT NULL,
	[kc_dpzii03a] [numeric](19, 6) NOT NULL,
	[kc_dpzii04a] [numeric](19, 6) NOT NULL,
	[kc_dpzii05] [numeric](19, 6) NULL,
	[kc_dpzii06] [numeric](19, 6) NULL,
	[kc_dpzii09] [numeric](19, 6) NOT NULL,
	[poc_zam1] [int] NOT NULL,
	[poc_zam1_kor] [int] NOT NULL,
	[poc_zam10] [int] NOT NULL,
	[poc_zam10_kor] [int] NOT NULL,
	[poc_zam11] [int] NOT NULL,
	[poc_zam11_kor] [int] NOT NULL,
	[poc_zam12] [int] NOT NULL,
	[poc_zam12_kor] [int] NOT NULL,
	[poc_zam2] [int] NOT NULL,
	[poc_zam2_kor] [int] NOT NULL,
	[poc_zam3] [int] NOT NULL,
	[poc_zam3_kor] [int] NOT NULL,
	[poc_zam4] [int] NOT NULL,
	[poc_zam4_kor] [int] NOT NULL,
	[poc_zam5] [int] NOT NULL,
	[poc_zam5_kor] [int] NOT NULL,
	[poc_zam6] [int] NOT NULL,
	[poc_zam6_kor] [int] NOT NULL,
	[poc_zam7] [int] NOT NULL,
	[poc_zam7_kor] [int] NOT NULL,
	[poc_zam8] [int] NOT NULL,
	[poc_zam8_kor] [int] NOT NULL,
	[poc_zam9] [int] NOT NULL,
	[poc_zam9_kor] [int] NOT NULL,
	[uhrndopl] [numeric](19, 6) NOT NULL,
	[uhrndopl_kor] [numeric](19, 6) NOT NULL,
	[uhrnprepl] [numeric](19, 6) NOT NULL,
	[uhrnprepl_kor] [numeric](19, 6) NOT NULL,
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
	[DatumUzavreni] [datetime] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[UzemniPrac] [nvarchar](255) NULL,
	[c_pracufo] [nvarchar](4) NULL,
	[Pobocka] [nvarchar](5) NULL,
	[d_srazky] [datetime] NULL,
	[kc_dpzii08]  AS (CONVERT([numeric](19,6),((((([kc_dpzii01]-[kc_dpzii02])+[kc_dpzii03])-[kc_dpzii03a])+[kc_dpzii04a])-isnull([kc_dpzii05],(0)))+isnull([kc_dpzii06],(0)))),
	[kc_dpzii10]  AS (CONVERT([numeric](19,6),[kc_dpzii09]-(((((([kc_dpzii01]-[kc_dpzii02])+[kc_dpzii03])-[kc_dpzii03a])+[kc_dpzii04a])-[kc_dpzii05])+[kc_dpzii06]))),
 CONSTRAINT [PK__Tabx_VZDVDA__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__c_komds]  DEFAULT ('') FOR [c_komds]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__k_bank]  DEFAULT ('') FOR [k_bank]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__c_komds2]  DEFAULT ('') FOR [c_komds2]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__k_bank2]  DEFAULT ('') FOR [k_bank2]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__pbu]  DEFAULT ('') FOR [pbu]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__pbu2]  DEFAULT ('') FOR [pbu2]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__FinancniUrad]  DEFAULT ('') FOR [FinancniUrad]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__c_ufo_cil]  DEFAULT ('') FOR [c_ufo_cil]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__dokument]  DEFAULT (N'VD6') FOR [dokument]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__k_uladis]  DEFAULT (N'DPZ') FOR [k_uladis]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__vdadpz_typ]  DEFAULT (N'B') FOR [vdadpz_typ]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__kc_dpzii01]  DEFAULT ((0.0)) FOR [kc_dpzii01]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__kc_dpzii02]  DEFAULT ((0.0)) FOR [kc_dpzii02]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__kc_dpzii03]  DEFAULT ((0.0)) FOR [kc_dpzii03]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__kc_dpzii03a]  DEFAULT ((0.0)) FOR [kc_dpzii03a]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__kc_dpzii04a]  DEFAULT ((0.0)) FOR [kc_dpzii04a]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__kc_dpzii09]  DEFAULT ((0.0)) FOR [kc_dpzii09]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam1]  DEFAULT ((0.0)) FOR [poc_zam1]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam1_kor]  DEFAULT ((0.0)) FOR [poc_zam1_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam10]  DEFAULT ((0.0)) FOR [poc_zam10]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam10_kor]  DEFAULT ((0.0)) FOR [poc_zam10_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam11]  DEFAULT ((0.0)) FOR [poc_zam11]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam11_kor]  DEFAULT ((0.0)) FOR [poc_zam11_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam12]  DEFAULT ((0.0)) FOR [poc_zam12]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam12_kor]  DEFAULT ((0.0)) FOR [poc_zam12_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam2]  DEFAULT ((0.0)) FOR [poc_zam2]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam2_kor]  DEFAULT ((0.0)) FOR [poc_zam2_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam3]  DEFAULT ((0.0)) FOR [poc_zam3]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam3_kor]  DEFAULT ((0.0)) FOR [poc_zam3_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam4]  DEFAULT ((0.0)) FOR [poc_zam4]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam4_kor]  DEFAULT ((0.0)) FOR [poc_zam4_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam5]  DEFAULT ((0.0)) FOR [poc_zam5]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam5_kor]  DEFAULT ((0.0)) FOR [poc_zam5_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam6]  DEFAULT ((0.0)) FOR [poc_zam6]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam6_kor]  DEFAULT ((0.0)) FOR [poc_zam6_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam7]  DEFAULT ((0.0)) FOR [poc_zam7]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam7_kor]  DEFAULT ((0.0)) FOR [poc_zam7_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam8]  DEFAULT ((0.0)) FOR [poc_zam8]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam8_kor]  DEFAULT ((0.0)) FOR [poc_zam8_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam9]  DEFAULT ((0.0)) FOR [poc_zam9]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__poc_zam9_kor]  DEFAULT ((0.0)) FOR [poc_zam9_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__uhrndopl]  DEFAULT ((0.0)) FOR [uhrndopl]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__uhrndopl_kor]  DEFAULT ((0.0)) FOR [uhrndopl_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__uhrnprepl]  DEFAULT ((0.0)) FOR [uhrnprepl]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__uhrnprepl_kor]  DEFAULT ((0.0)) FOR [uhrnprepl_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__c_orient]  DEFAULT ('') FOR [c_orient]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__c_pop]  DEFAULT ('') FOR [c_pop]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__dic]  DEFAULT ('') FOR [dic]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__jmeno]  DEFAULT ('') FOR [jmeno]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__naz_obce]  DEFAULT ('') FOR [naz_obce]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__opr_jmeno]  DEFAULT ('') FOR [opr_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__opr_postaveni]  DEFAULT ('') FOR [opr_postaveni]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__opr_prijmeni]  DEFAULT ('') FOR [opr_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__prijmeni]  DEFAULT ('') FOR [prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__psc]  DEFAULT ('') FOR [psc]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__sest_email]  DEFAULT ('') FOR [sest_email]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__sest_jmeno]  DEFAULT ('') FOR [sest_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__sest_prijmeni]  DEFAULT ('') FOR [sest_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__sest_telef]  DEFAULT ('') FOR [sest_telef]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__sest_titul]  DEFAULT ('') FOR [sest_titul]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__titul]  DEFAULT ('') FOR [titul]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__typ_ds]  DEFAULT (N'P') FOR [typ_ds]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__ulice]  DEFAULT ('') FOR [ulice]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__zast_ev_cislo]  DEFAULT ('') FOR [zast_ev_cislo]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__zast_ic]  DEFAULT ('') FOR [zast_ic]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__zast_jmeno]  DEFAULT ('') FOR [zast_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__zast_nazev]  DEFAULT ('') FOR [zast_nazev]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__zast_prijmeni]  DEFAULT ('') FOR [zast_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__zkrobchjm]  DEFAULT ('') FOR [zkrobchjm]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDVDA] ADD  CONSTRAINT [DF__Tabx_VZDVDA__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

