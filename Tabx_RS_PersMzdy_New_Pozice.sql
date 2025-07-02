USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PersMzdy_New_Pozice]    Script Date: 02.07.2025 9:27:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PersMzdy_New_Pozice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Kod] [nvarchar](4) NULL,
	[Poradi] [tinyint] NULL,
	[Nazev] [nvarchar](100) NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
 CONSTRAINT [PK__Tabx_RS_PersMzdy_New_Pozice__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PersMzdy_New_Pozice] ADD  CONSTRAINT [DF__Tabx_RS_PersMzdy_New_Pozice__Nazev]  DEFAULT (N'') FOR [Nazev]
GO

