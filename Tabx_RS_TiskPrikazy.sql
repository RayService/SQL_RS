USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TiskPrikazy]    Script Date: 02.07.2025 10:02:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TiskPrikazy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDPrikaz] [int] NOT NULL,
	[DatTisku] [datetime] NULL,
	[AutorTisku] [nvarchar](128) NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TiskPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_TiskPrikazy__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_TiskPrikazy] ADD  CONSTRAINT [DF__Tabx_RS_TiskPrikazy__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

