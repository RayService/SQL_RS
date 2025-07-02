USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Mon_HeliosStoji]    Script Date: 02.07.2025 8:45:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Mon_HeliosStoji](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SPID] [smallint] NOT NULL,
	[DateStart] [datetime] NOT NULL,
	[DateStop] [datetime] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[IDVer]  AS ([ID]),
	[Stav] [tinyint] NULL,
	[DalsiKrok] [tinyint] NULL,
	[Analyza] [ntext] NULL,
	[KomentarUziv] [ntext] NULL,
	[Navrh] [ntext] NULL,
	[Schvaleno] [tinyint] NULL,
 CONSTRAINT [PK__Tabx_Mon_HeliosStoji__SPID__ID] PRIMARY KEY CLUSTERED 
(
	[SPID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Mon_HeliosStoji] ADD  CONSTRAINT [DF__Tabx_Mon_HeliosStoji__SPID]  DEFAULT (@@spid) FOR [SPID]
GO

ALTER TABLE [dbo].[Tabx_Mon_HeliosStoji] ADD  CONSTRAINT [DF__Tabx_Mon_HeliosStoji__DateStart]  DEFAULT (getdate()) FOR [DateStart]
GO

ALTER TABLE [dbo].[Tabx_Mon_HeliosStoji] ADD  CONSTRAINT [DF__Tabx_Mon_HeliosStoji__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_Mon_HeliosStoji] ADD  CONSTRAINT [DF__Tabx_Mon_HeliosStoji__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

