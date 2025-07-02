USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_NakladyInterniNeshody]    Script Date: 02.07.2025 9:19:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_NakladyInterniNeshody](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Mesic] [int] NOT NULL,
	[Material] [numeric](19, 6) NULL,
	[Viceprace] [numeric](19, 6) NULL,
	[Prijato] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[Stredisko] [nvarchar](30) NULL,
	[Koef]  AS (((isnull([Material],(0))+isnull([Viceprace],(0)))/isnull(nullif([Prijato],(0)),(-1)))*(100)),
	[Koef_mesic] [numeric](19, 6) NULL,
	[Rok] [int] NOT NULL,
 CONSTRAINT [PK__Tabx_RS_NakladyInterniNeshody__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyInterniNeshody] ADD  CONSTRAINT [DF__Tabx_RS_NakladyInterniNeshody__Material]  DEFAULT ((0)) FOR [Material]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyInterniNeshody] ADD  CONSTRAINT [DF__Tabx_RS_NakladyInterniNeshody__Viceprace]  DEFAULT ((0)) FOR [Viceprace]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyInterniNeshody] ADD  CONSTRAINT [DF__Tabx_RS_NakladyInterniNeshody__Prijato]  DEFAULT ((0)) FOR [Prijato]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyInterniNeshody] ADD  CONSTRAINT [DF__Tabx_RS_NakladyInterniNeshody__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_NakladyInterniNeshody] ADD  CONSTRAINT [DF__Tabx_RS_NakladyInterniNeshody__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

