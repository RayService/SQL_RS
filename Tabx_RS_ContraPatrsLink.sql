USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_ContraPatrsLink]    Script Date: 02.07.2025 9:03:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_ContraPatrsLink](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDRow] [int] NOT NULL,
	[IDHlavicka] [int] NOT NULL,
	[IDZmeny] [int] NULL,
	[SPID] [int] NOT NULL
) ON [PRIMARY]
GO

