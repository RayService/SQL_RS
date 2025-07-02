USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Apps_Recepce_Lokalita]    Script Date: 02.07.2025 8:20:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Apps_Recepce_Lokalita](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[nazev] [nvarchar](255) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_Apps_Recepce_Lokalita__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Lokalita] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Lokalita__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Lokalita] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Lokalita__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

