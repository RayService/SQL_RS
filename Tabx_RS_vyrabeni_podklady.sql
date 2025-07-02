USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_vyrabeni_podklady]    Script Date: 02.07.2025 10:14:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_vyrabeni_podklady](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Odpracovany_cas_group] [numeric](19, 6) NULL,
	[Odpracovany_cas] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NULL,
	[DatPorizeni] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[Skup] [nvarchar](1) NULL,
	[Procento]  AS (([Odpracovany_cas_group]/[Odpracovany_cas])*(100)),
 CONSTRAINT [Tabx_RS_vyrabeni_podklady__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_vyrabeni_podklady] ADD  CONSTRAINT [DF__[Tabx_RS_vyrabeni_podklady__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_vyrabeni_podklady] ADD  CONSTRAINT [DF__[Tabx_RS_vyrabeni_podklady__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

