USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDSUCizinci]    Script Date: 02.07.2025 10:43:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDSUCizinci](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[m_c_pasu] [nvarchar](16) NOT NULL,
	[m_c_pop_or] [nvarchar](10) NOT NULL,
	[m_d_naroz] [datetime] NULL,
	[m_dic] [nvarchar](20) NOT NULL,
	[m_jmeno] [nvarchar](20) NOT NULL,
	[m_k_stat] [nvarchar](2) NOT NULL,
	[m_kc_pojistne] [numeric](19, 6) NOT NULL,
	[m_kc_prijmy] [numeric](19, 6) NOT NULL,
	[m_kc_zakldane] [numeric](19, 6) NOT NULL,
	[m_kc_zalohy] [numeric](19, 6) NOT NULL,
	[m_mes_zuct1] [bit] NOT NULL,
	[m_mes_zuct10] [bit] NOT NULL,
	[m_mes_zuct11] [bit] NOT NULL,
	[m_mes_zuct12] [bit] NOT NULL,
	[m_mes_zuct2] [bit] NOT NULL,
	[m_mes_zuct3] [bit] NOT NULL,
	[m_mes_zuct4] [bit] NOT NULL,
	[m_mes_zuct5] [bit] NOT NULL,
	[m_mes_zuct6] [bit] NOT NULL,
	[m_mes_zuct7] [bit] NOT NULL,
	[m_mes_zuct8] [bit] NOT NULL,
	[m_mes_zuct9] [bit] NOT NULL,
	[m_naz_obce] [nvarchar](48) NOT NULL,
	[m_prijmeni] [nvarchar](36) NOT NULL,
	[m_psc] [nvarchar](10) NOT NULL,
	[m_rod_c] [nvarchar](20) NOT NULL,
	[m_ulice] [nvarchar](38) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_VZDSUCizinci__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_c_pasu]  DEFAULT ('') FOR [m_c_pasu]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_c_pop_or]  DEFAULT ('') FOR [m_c_pop_or]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_dic]  DEFAULT ('') FOR [m_dic]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_jmeno]  DEFAULT ('') FOR [m_jmeno]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_k_stat]  DEFAULT ('') FOR [m_k_stat]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_kc_pojistne]  DEFAULT ((0.0)) FOR [m_kc_pojistne]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_kc_prijmy]  DEFAULT ((0.0)) FOR [m_kc_prijmy]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_kc_zakldane]  DEFAULT ((0.0)) FOR [m_kc_zakldane]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_kc_zalohy]  DEFAULT ((0.0)) FOR [m_kc_zalohy]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct1]  DEFAULT ((0)) FOR [m_mes_zuct1]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct10]  DEFAULT ((0)) FOR [m_mes_zuct10]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct11]  DEFAULT ((0)) FOR [m_mes_zuct11]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct12]  DEFAULT ((0)) FOR [m_mes_zuct12]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct2]  DEFAULT ((0)) FOR [m_mes_zuct2]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct3]  DEFAULT ((0)) FOR [m_mes_zuct3]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct4]  DEFAULT ((0)) FOR [m_mes_zuct4]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct5]  DEFAULT ((0)) FOR [m_mes_zuct5]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct6]  DEFAULT ((0)) FOR [m_mes_zuct6]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct7]  DEFAULT ((0)) FOR [m_mes_zuct7]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct8]  DEFAULT ((0)) FOR [m_mes_zuct8]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_mes_zuct9]  DEFAULT ((0)) FOR [m_mes_zuct9]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_naz_obce]  DEFAULT ('') FOR [m_naz_obce]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_prijmeni]  DEFAULT ('') FOR [m_prijmeni]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_psc]  DEFAULT ('') FOR [m_psc]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_rod_c]  DEFAULT ('') FOR [m_rod_c]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__m_ulice]  DEFAULT ('') FOR [m_ulice]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDSUCizinci] ADD  CONSTRAINT [DF__Tabx_VZDSUCizinci__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

