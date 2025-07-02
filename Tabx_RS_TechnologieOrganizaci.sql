USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TechnologieOrganizaci]    Script Date: 02.07.2025 10:01:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TechnologieOrganizaci](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Technologie] [int] NULL,
	[Archive] [bit] NOT NULL,
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
	[Organizace] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_TechnologieOrganizaci__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci] ADD  CONSTRAINT [DF__Tabx_RS_TechnologieOrganizaci__Archive]  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci] ADD  CONSTRAINT [DF__Tabx_RS_TechnologieOrganizaci__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci] ADD  CONSTRAINT [DF__Tabx_RS_TechnologieOrganizaci__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TechnologieOrganizaci__Organizace] FOREIGN KEY([Organizace])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci] CHECK CONSTRAINT [FK__Tabx_RS_TechnologieOrganizaci__Organizace]
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TechnologieOrganizaci__Technologie] FOREIGN KEY([Technologie])
REFERENCES [dbo].[Tabx_RS_TechnlogiesList] ([Code])
GO

ALTER TABLE [dbo].[Tabx_RS_TechnologieOrganizaci] CHECK CONSTRAINT [FK__Tabx_RS_TechnologieOrganizaci__Technologie]
GO

