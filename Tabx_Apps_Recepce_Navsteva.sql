USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Apps_Recepce_Navsteva]    Script Date: 02.07.2025 8:20:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Apps_Recepce_Navsteva](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[navstevnikID] [int] NOT NULL,
	[lokalitaID] [int] NOT NULL,
	[AutorPorizeni] [nvarchar](128) NOT NULL,
	[DatOdhlaseni] [datetime] NULL,
	[AutorOdhlaseni] [nvarchar](255) NULL,
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
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni],(0)),(0)),(0))),
 CONSTRAINT [PK__Tabx_Apps_Recepce_Navsteva__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navsteva] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navsteva__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navsteva] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navsteva__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

