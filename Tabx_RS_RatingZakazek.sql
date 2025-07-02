USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_RatingZakazek]    Script Date: 02.07.2025 9:43:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_RatingZakazek](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Rating] [nvarchar](50) NULL,
	[Parametr] [nvarchar](30) NULL,
	[Vaha] [numeric](19, 2) NULL,
	[Poradi] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_RatingZakazek__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

