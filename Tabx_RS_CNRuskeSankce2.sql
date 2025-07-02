USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_CNRuskeSankce2]    Script Date: 02.07.2025 9:01:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_CNRuskeSankce2](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CN] [nvarchar](10) NOT NULL,
	[Archive] [bit] NULL,
	[DatArchive] [datetime] NULL,
	[DatArchive_D]  AS (datepart(day,[DatArchive])),
	[DatArchive_M]  AS (datepart(month,[DatArchive])),
	[DatArchive_Y]  AS (datepart(year,[DatArchive])),
	[DatArchive_Q]  AS (datepart(quarter,[DatArchive])),
	[DatArchive_W]  AS (datepart(week,[DatArchive])),
	[DatArchive_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatArchive])))),
	[AuthorArchive] [nvarchar](128) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny])))),
 CONSTRAINT [PK__Tabx_RS_CNRuskeSankce2__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_CNRuskeSankce2] ADD  CONSTRAINT [DF__Tabx_RS_CNRuskeSankce2__Archive]  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[Tabx_RS_CNRuskeSankce2] ADD  CONSTRAINT [DF__Tabx_RS_CNRuskeSankce2__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_CNRuskeSankce2] ADD  CONSTRAINT [DF__Tabx_RS_CNRuskeSankce2__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

