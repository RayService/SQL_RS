USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TabVyrDokum_printLog]    Script Date: 02.07.2025 9:55:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TabVyrDokum_printLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[IDVyrDokum] [int] NOT NULL,
	[IDPrikaz] [int] NOT NULL,
	[IndexVyrDokum] [nvarchar](30) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[FairMode] [bit] NULL,
 CONSTRAINT [PK__Tabx_RS_TabVyrDokum_printLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TabVyrDokum_printLog] ADD  CONSTRAINT [DF__Tabx_RS_TabVyrDokum_printLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_TabVyrDokum_printLog] ADD  CONSTRAINT [DF__Tabx_RS_TabVyrDokum_printLog__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_TabVyrDokum_printLog] ADD  CONSTRAINT [DF__Tabx_RS_TabVyrDokum_printLog__FairMode]  DEFAULT ((0)) FOR [FairMode]
GO

