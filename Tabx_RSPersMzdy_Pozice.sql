USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RSPersMzdy_Pozice]    Script Date: 02.07.2025 10:18:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RSPersMzdy_Pozice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Kod] [nvarchar](3) NOT NULL,
	[Poradi] [tinyint] NOT NULL,
	[Nazev] [nvarchar](100) NOT NULL,
	[TK_Od] [numeric](19, 6) NOT NULL,
	[TK_Do] [numeric](19, 6) NOT NULL,
	[THP_MzdaFix] [numeric](19, 6) NOT NULL,
	[THP_MzdaPohyb] [numeric](19, 6) NOT NULL,
	[THP_MzdaOdmena] [numeric](19, 6) NOT NULL,
	[TPV_KS] [numeric](19, 6) NOT NULL,
	[TPV_EL] [numeric](19, 6) NOT NULL,
	[TPV_MD] [numeric](19, 6) NOT NULL,
	[Hodnoceni_Body] [tinyint] NOT NULL,
	[Hodnoceni_U1] [numeric](5, 2) NOT NULL,
	[Hodnoceni_U2] [numeric](5, 2) NOT NULL,
	[Hodnoceni_U3] [numeric](5, 2) NOT NULL,
	[Hodnoceni_U4] [numeric](5, 2) NOT NULL,
	[Podminka_K1] [nvarchar](30) NULL,
	[Podminka_K2] [nvarchar](30) NULL,
	[Podminka_K3] [nvarchar](30) NULL,
	[Podminka_K4] [nvarchar](30) NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
 CONSTRAINT [PK__Tabx_RSPersMzdy_Pozice__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__Nazev]  DEFAULT (N'') FOR [Nazev]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__TK_Od]  DEFAULT ((0.0)) FOR [TK_Od]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__TK_Do]  DEFAULT ((0.0)) FOR [TK_Do]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__THP_MzdyFix]  DEFAULT ((0.0)) FOR [THP_MzdaFix]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__THP_MzdaPohyb]  DEFAULT ((0.0)) FOR [THP_MzdaPohyb]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__THP_MzdaOdmena]  DEFAULT ((0.0)) FOR [THP_MzdaOdmena]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__TPV_KS]  DEFAULT ((0.0)) FOR [TPV_KS]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__TPV_EL]  DEFAULT ((0.0)) FOR [TPV_EL]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__TPV_MD]  DEFAULT ((0.0)) FOR [TPV_MD]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__Hod_Body]  DEFAULT ((0)) FOR [Hodnoceni_Body]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__Hod_U1]  DEFAULT ((0.0)) FOR [Hodnoceni_U1]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__Hod_U2]  DEFAULT ((0.0)) FOR [Hodnoceni_U2]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__Hod_U3]  DEFAULT ((0.0)) FOR [Hodnoceni_U3]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Pozice] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Pozice__Hod_U4]  DEFAULT ((0.0)) FOR [Hodnoceni_U4]
GO

