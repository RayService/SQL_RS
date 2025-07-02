USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDSUCizinci2016]    Script Date: 02.07.2025 10:44:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDSUCizinci2016](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[h_k_stat] [nvarchar](2) NOT NULL,
	[h_prijmeni] [nvarchar](36) NOT NULL,
	[h_jmeno] [nvarchar](20) NOT NULL,
	[h_d_naroz] [datetime] NULL,
	[h_naz_obce] [nvarchar](48) NOT NULL,
	[h_ulice] [nvarchar](38) NOT NULL,
	[h_c_pop_or] [nvarchar](10) NOT NULL,
	[h_psc] [nvarchar](10) NOT NULL,
	[h_dic] [nvarchar](20) NOT NULL,
	[h_typ_dic] [nvarchar](40) NOT NULL,
	[h_c_pasu] [nvarchar](16) NOT NULL,
	[h_typ_pasu] [nvarchar](39) NOT NULL,
	[h_k_stat_pasu] [nvarchar](2) NOT NULL,
	[h_kc_prijmy] [numeric](19, 6) NOT NULL,
	[h_kc_mzdy] [numeric](19, 6) NOT NULL,
	[h_kc_odmeny] [numeric](19, 6) NOT NULL,
	[h_kc_zalohy] [numeric](19, 6) NOT NULL,
	[h_sraz_dan] [numeric](19, 6) NOT NULL,
	[h_delka_vyk] [numeric](19, 6) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_VZDSUCizinci2016__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_k_stat]  DEFAULT ('') FOR [h_k_stat]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_prijmeni]  DEFAULT ('') FOR [h_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_jmeno]  DEFAULT ('') FOR [h_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_naz_obce]  DEFAULT ('') FOR [h_naz_obce]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_ulice]  DEFAULT ('') FOR [h_ulice]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_c_pop_or]  DEFAULT ('') FOR [h_c_pop_or]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_psc]  DEFAULT ('') FOR [h_psc]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_dic]  DEFAULT ('') FOR [h_dic]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_typ_dic]  DEFAULT ('R') FOR [h_typ_dic]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_c_pasu]  DEFAULT ('') FOR [h_c_pasu]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_typ_pasu]  DEFAULT ('P') FOR [h_typ_pasu]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_k_stat_pasu]  DEFAULT ('') FOR [h_k_stat_pasu]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_kc_prijmy]  DEFAULT ((0.0)) FOR [h_kc_prijmy]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_kc_mzdy]  DEFAULT ((0.0)) FOR [h_kc_mzdy]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_kc_odmeny]  DEFAULT ((0.0)) FOR [h_kc_odmeny]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_kc_zalohy]  DEFAULT ((0.0)) FOR [h_kc_zalohy]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_sraz_dan]  DEFAULT ((0.0)) FOR [h_sraz_dan]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__h_delka_vyk]  DEFAULT ((0.0)) FOR [h_delka_vyk]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci2016] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci2016__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

