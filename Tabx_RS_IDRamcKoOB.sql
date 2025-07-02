USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_IDRamcKoOB]    Script Date: 02.07.2025 9:08:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_IDRamcKoOB](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Autor] [nvarchar](128) NULL,
	[IDSession] [int] NULL,
	[IDHlavicka] [int] NULL,
	[IDHlavicka_New] [int] NULL,
	[IDObjednavka] [int] NULL
) ON [PRIMARY]
GO

