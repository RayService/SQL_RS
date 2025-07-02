USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Apps_Recepce_Navstevnik]    Script Date: 02.07.2025 8:21:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[jmeno] [nvarchar](255) NULL,
	[prijmeni] [nvarchar](255) NULL,
	[spolecnost] [nvarchar](255) NULL,
	[nick] [nvarchar](255) NULL,
	[email] [nvarchar](255) NULL,
	[telefon] [nvarchar](255) NULL,
	[jazyk] [nvarchar](2) NOT NULL,
	[DatPotvrzeniDokumentu] [datetime] NOT NULL,
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
	[Poznamka] [ntext] NULL,
	[celeJmeno] [nvarchar](255) NULL,
	[doprovodPocet] [int] NOT NULL,
 CONSTRAINT [PK__Tabx_Apps_Recepce_Navstevnik__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navstevnik__jazyk]  DEFAULT ('cs') FOR [jazyk]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navstevnik__DatPotvrzeniDokumentu]  DEFAULT (getdate()) FOR [DatPotvrzeniDokumentu]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navstevnik__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navstevnik__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik] ADD  CONSTRAINT [DF__Tabx_Apps_Recepce_Navstevnik__doprovodPocet]  DEFAULT ((0)) FOR [doprovodPocet]
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_Apps_Recepce_Navstevnik__jazyk] CHECK  (([jazyk]='de' OR [jazyk]='en' OR [jazyk]='cs'))
GO

ALTER TABLE [dbo].[Tabx_Apps_Recepce_Navstevnik] CHECK CONSTRAINT [CK__Tabx_Apps_Recepce_Navstevnik__jazyk]
GO

