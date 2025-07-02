USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDPredpisy]    Script Date: 02.07.2025 10:25:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDPredpisy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GUID] [binary](16) NOT NULL,
	[Nazev] [nvarchar](50) NOT NULL,
	[Popis] [ntext] NULL,
	[Kopie] [bit] NOT NULL,
	[IdDoklad] [int] NULL,
	[TypDokladu] [tinyint] NOT NULL,
	[StavSchvaleni] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[Popis_255]  AS (substring(replace(substring([Popis],(1),(255)),nchar((13))+nchar((10)),nchar((32))),(1),(255))),
	[Popis_All]  AS ([Popis]),
	[GUIDText]  AS (CONVERT([nvarchar](36),CONVERT([uniqueidentifier],[GUID],0),0)),
	[IdPredpisZdroj] [int] NULL,
	[Skupina] [nvarchar](30) NULL,
	[Rezim] [tinyint] NOT NULL,
 CONSTRAINT [PK__Tabx_SDPredpisy__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__GUID]  DEFAULT (newid()) FOR [GUID]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__Nazev]  DEFAULT ('') FOR [Nazev]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__Kopie]  DEFAULT ((0)) FOR [Kopie]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__TypDokladu]  DEFAULT ((0)) FOR [TypDokladu]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] ADD  CONSTRAINT [DF__Tabx_SDPredpisy__Rezim]  DEFAULT ((0)) FOR [Rezim]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_SDPredpisy__TypDokladu] CHECK  (([TypDokladu]>=(0) AND [TypDokladu]<=(4)))
GO

ALTER TABLE [dbo].[Tabx_SDPredpisy] CHECK CONSTRAINT [CK__Tabx_SDPredpisy__TypDokladu]
GO

