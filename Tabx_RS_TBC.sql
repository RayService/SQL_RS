USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TBC]    Script Date: 02.07.2025 9:56:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TBC](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_Operace] [int] NOT NULL,
	[ID_dilce] [int] NOT NULL,
	[Typ] [int] NULL,
	[SkupZbo] [nvarchar](3) NULL,
	[RegCis] [nvarchar](15) NULL,
	[CisloZbozi] [nvarchar](33) NULL,
	[nazev] [nvarchar](50) NULL,
	[TBC_N] [numeric](19, 6) NULL,
 CONSTRAINT [PK_Tabx_RS_TBC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

