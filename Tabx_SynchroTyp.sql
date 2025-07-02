USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SynchroTyp]    Script Date: 02.07.2025 10:36:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SynchroTyp](
	[TypSynchro] [tinyint] NOT NULL,
	[Nazev] [nvarchar](100) NOT NULL,
	[DBZdroj] [nvarchar](2) NOT NULL,
	[DBCil] [nvarchar](2) NOT NULL,
	[IDSkladCil] [nvarchar](30) NULL,
	[TypSynchroKmen] [tinyint] NULL,
	[TypSynchroOrg] [tinyint] NULL,
	[RadaDokladuCil] [nvarchar](3) NULL,
 CONSTRAINT [PK__Tabx_SynchroTyp__TypSynchro] PRIMARY KEY CLUSTERED 
(
	[TypSynchro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SynchroTyp] ADD  CONSTRAINT [DF__Tabx_SynchroTyp__Nazev]  DEFAULT (N'') FOR [Nazev]
GO

