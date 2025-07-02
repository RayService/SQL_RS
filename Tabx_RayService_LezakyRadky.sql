USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RayService_LezakyRadky]    Script Date: 02.07.2025 8:50:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RayService_LezakyRadky](
	[ID] [int] NOT NULL,
	[Rok] [smallint] NOT NULL,
	[Mesic] [tinyint] NOT NULL,
	[M] [numeric](19, 6) NULL,
	[S] [numeric](19, 6) NULL,
	[A] [tinyint] NULL,
 CONSTRAINT [PK__Tabx_RayService_LezakyRadky__ID__Rok__Mesic] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[Rok] ASC,
	[Mesic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

