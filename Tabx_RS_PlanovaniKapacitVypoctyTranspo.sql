USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo]    Script Date: 02.07.2025 9:32:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MesicCislo] [int] NOT NULL,
	[MesicNazev] [nvarchar](20) NULL,
	[KLLinkaZak] [numeric](19, 6) NULL,
	[KLLinkaKap] [numeric](19, 6) NULL,
	[KLKusovkaZak] [numeric](19, 6) NULL,
	[KLKusovkaKap] [numeric](19, 6) NULL,
	[KLMaketyZak] [numeric](19, 6) NULL,
	[KLMaketyKap] [numeric](19, 6) NULL,
	[EMLinkaZak] [numeric](19, 6) NULL,
	[EMLinkaKap] [numeric](19, 6) NULL,
	[EMKusovkaZak] [numeric](19, 6) NULL,
	[EMKusovkaKap] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[KLLinkaRoz]  AS ([KLLinkaKap]-[KLLinkaZak]),
	[KLKusovkaRoz]  AS ([KLKusovkaKap]-[KLKusovkaZak]),
	[KLMaketyRoz]  AS ([KLMaketyKap]-[KLMaketyZak]),
	[EMLinkaRoz]  AS ([EMLinkaKap]-[EMLinkaZak]),
	[EMKusovkaRoz]  AS ([EMKusovkaKap]-[EMKusovkaZak]),
 CONSTRAINT [PK__Tabx_RS_PlanovaniKapacitVypoctyTranspo__MesicCislo] PRIMARY KEY CLUSTERED 
(
	[MesicCislo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__KLLinkaZak]  DEFAULT ((0)) FOR [KLLinkaZak]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__KLLinkaKap]  DEFAULT ((0)) FOR [KLLinkaKap]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__KLKusovkaZak]  DEFAULT ((0)) FOR [KLKusovkaZak]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__KLKusovkaKap]  DEFAULT ((0)) FOR [KLKusovkaKap]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__KLMaketyZak]  DEFAULT ((0)) FOR [KLMaketyZak]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__KLMaketyKap]  DEFAULT ((0)) FOR [KLMaketyKap]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__EMLinkaZak]  DEFAULT ((0)) FOR [EMLinkaZak]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__EMLinkaKap]  DEFAULT ((0)) FOR [EMLinkaKap]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__EMKusovkaZak]  DEFAULT ((0)) FOR [EMKusovkaZak]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__EMKusovkaKap]  DEFAULT ((0)) FOR [EMKusovkaKap]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitVypoctyTranspo] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitVypoctyTranspo__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

