USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RSPersMzdy_PoziceStredisko]    Script Date: 02.07.2025 10:19:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RSPersMzdy_PoziceStredisko](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Poradi] [tinyint] NOT NULL,
	[Stredisko] [nvarchar](30) NOT NULL,
	[Hodnoceni_Body] [tinyint] NOT NULL,
	[Hodnoceni_U1] [numeric](5, 2) NOT NULL,
	[Hodnoceni_U2] [numeric](5, 2) NOT NULL,
	[Hodnoceni_U3] [numeric](5, 2) NOT NULL,
	[Hodnoceni_U4] [numeric](5, 2) NOT NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
 CONSTRAINT [PK__Tabx_RSPersMzdy_PoziceStredisko__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceStredisko] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceStredisko__Hod_Body]  DEFAULT ((0)) FOR [Hodnoceni_Body]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceStredisko] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceStredisko__Hod_U1]  DEFAULT ((0.0)) FOR [Hodnoceni_U1]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceStredisko] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceStredisko__Hod_U2]  DEFAULT ((0.0)) FOR [Hodnoceni_U2]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceStredisko] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceStredisko__Hod_U3]  DEFAULT ((0.0)) FOR [Hodnoceni_U3]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceStredisko] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceStredisko__Hod_U4]  DEFAULT ((0.0)) FOR [Hodnoceni_U4]
GO

