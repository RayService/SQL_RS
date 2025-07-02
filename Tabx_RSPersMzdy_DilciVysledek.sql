USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RSPersMzdy_DilciVysledek]    Script Date: 02.07.2025 10:17:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RSPersMzdy_DilciVysledek](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[Vypocet] [smallint] NOT NULL,
	[Kategorie] [smallint] NOT NULL,
	[Uroven] [smallint] NULL,
	[PP_Vysledek] [numeric](19, 6) NULL,
	[Z_Vysledek] [numeric](19, 6) NULL,
	[Vysledek] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RSPersMzdy_DilciVysledek__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

