USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PPMExterni]    Script Date: 02.07.2025 9:38:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PPMExterni](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CisloOrg] [int] NOT NULL,
	[PPM1] [int] NULL,
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
	[Reklamace1] [int] NULL,
	[PPM2] [int] NULL,
	[Reklamace2] [int] NULL,
	[Vydeje2] [int] NULL,
	[Vydeje1] [int] NULL,
	[PPM3] [int] NULL,
	[Reklamace3] [int] NULL,
	[Vydeje3] [int] NULL,
	[PPMTotal1] [int] NULL,
	[PPMTotal2] [int] NULL,
	[PPMTotal3] [int] NULL,
	[PPM4] [int] NULL,
	[Reklamace4] [int] NULL,
	[Vydeje4] [int] NULL,
	[PPMTotal4] [int] NULL,
	[PPM5] [int] NULL,
	[PPMTotal5] [int] NULL,
	[Reklamace5] [int] NULL,
	[Vydeje5] [int] NULL,
	[PPM6] [int] NULL,
	[PPMTotal6] [int] NULL,
	[Reklamace6] [int] NULL,
	[Vydeje6] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_PPMExterni__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPM1]  DEFAULT ((0)) FOR [PPM1]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Reklamace1]  DEFAULT ((0)) FOR [Reklamace1]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPM2]  DEFAULT ((0)) FOR [PPM2]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Reklamace2]  DEFAULT ((0)) FOR [Reklamace2]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Vydeje2]  DEFAULT ((0)) FOR [Vydeje2]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Vydeje1]  DEFAULT ((0)) FOR [Vydeje1]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPM3]  DEFAULT ((0)) FOR [PPM3]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Reklamace3]  DEFAULT ((0)) FOR [Reklamace3]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Vydeje3]  DEFAULT ((0)) FOR [Vydeje3]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPMTotal1]  DEFAULT ((0)) FOR [PPMTotal1]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPMTotal2]  DEFAULT ((0)) FOR [PPMTotal2]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPMTotal3]  DEFAULT ((0)) FOR [PPMTotal3]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPM4]  DEFAULT ((0)) FOR [PPM4]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Reklamace4]  DEFAULT ((0)) FOR [Reklamace4]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Vydeje4]  DEFAULT ((0)) FOR [Vydeje4]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPMTotal4]  DEFAULT ((0)) FOR [PPMTotal4]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPM5]  DEFAULT ((0)) FOR [PPM5]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPMTotal5]  DEFAULT ((0)) FOR [PPMTotal5]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Reklamace5]  DEFAULT ((0)) FOR [Reklamace5]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Vydeje5]  DEFAULT ((0)) FOR [Vydeje5]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPM6]  DEFAULT ((0)) FOR [PPM6]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__PPMTotal6]  DEFAULT ((0)) FOR [PPMTotal6]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Reklamace6]  DEFAULT ((0)) FOR [Reklamace6]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] ADD  CONSTRAINT [DF__Tabx_RS_PPMExterni__Vydeje6]  DEFAULT ((0)) FOR [Vydeje6]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_PPMExterni__CisloOrg] FOREIGN KEY([CisloOrg])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[Tabx_RS_PPMExterni] CHECK CONSTRAINT [FK__Tabx_RS_PPMExterni__CisloOrg]
GO

