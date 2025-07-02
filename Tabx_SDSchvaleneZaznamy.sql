USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDSchvaleneZaznamy]    Script Date: 02.07.2025 10:27:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDSchvaleneZaznamy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Akce] [tinyint] NULL,
	[IdPredpis] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_SDSchvaleneZaznamy__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDSchvaleneZaznamy] ADD  CONSTRAINT [DF__Tabx_SDSchvaleneZaznamy__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SDSchvaleneZaznamy] ADD  CONSTRAINT [DF__Tabx_SDSchvaleneZaznamy__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

