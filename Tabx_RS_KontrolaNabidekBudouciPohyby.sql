USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_KontrolaNabidekBudouciPohyby]    Script Date: 02.07.2025 9:11:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_KontrolaNabidekBudouciPohyby](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDBudPoh] [int] NOT NULL,
	[IDZakazka] [int] NULL,
	[IDKmeneZbozi] [int] NOT NULL,
	[CisloZakazky] [nvarchar](15) NULL,
	[Nabidka] [bit] NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[NabidkaPuv] [bit] NULL,
	[CisloZakazkyPuv] [nvarchar](15) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaNabidekBudouciPohyby] ADD  CONSTRAINT [DF__Tabx_RS_KontrolaNabidekBudouciPohyby__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaNabidekBudouciPohyby] ADD  CONSTRAINT [DF__Tabx_RS_KontrolaNabidekBudouciPohyby__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

