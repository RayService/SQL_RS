USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TAC]    Script Date: 02.07.2025 9:56:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TAC](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_dilce] [int] NOT NULL,
 CONSTRAINT [PK_Tabx_RS_TAC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

