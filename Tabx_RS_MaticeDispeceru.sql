USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_MaticeDispeceru]    Script Date: 02.07.2025 9:16:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_MaticeDispeceru](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VedouciVyr] [int] NULL,
	[Dispecer] [int] NULL,
	[Lokace] [nvarchar](30) NOT NULL,
	[KvalDil] [nvarchar](10) NULL,
	[Rada] [nvarchar](10) NULL,
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
 CONSTRAINT [PK__Tabx_RS_MaticeDispeceru__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] ADD  CONSTRAINT [DF__Tabx_RS_MaticeDispeceru__Lokace]  DEFAULT ((20021000)) FOR [Lokace]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] ADD  CONSTRAINT [DF__Tabx_RS_MaticeDispeceru__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] ADD  CONSTRAINT [DF__Tabx_RS_MaticeDispeceru__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__Dispecer] FOREIGN KEY([Dispecer])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] CHECK CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__Dispecer]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__Lokace] FOREIGN KEY([Lokace])
REFERENCES [dbo].[TabStrom] ([Cislo])
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] CHECK CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__Lokace]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__Rada] FOREIGN KEY([Rada])
REFERENCES [dbo].[TabRadyPrikazu] ([Rada])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] CHECK CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__Rada]
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__VedouciVyr] FOREIGN KEY([VedouciVyr])
REFERENCES [dbo].[TabCisZam] ([ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Tabx_RS_MaticeDispeceru] CHECK CONSTRAINT [FK__Tabx_RS_MaticeDispeceru__VedouciVyr]
GO

