USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RAY_EmployeeRating_RatingItem]    Script Date: 02.07.2025 8:47:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDRating] [int] NULL,
	[IDSchemaItem] [int] NULL,
	[KPICoefficient] [float] NULL,
	[Value] [float] NULL,
	[Ordering] [int] NULL,
	[Title] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[Note] [nvarchar](255) NULL,
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
	[IDWagePart] [int] NULL,
 CONSTRAINT [PK__Tabx_RAY_EmployeeRating_RatingItem__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_RatingItem__Ordering]  DEFAULT ((0)) FOR [Ordering]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_RatingItem__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_RatingItem__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_RatingItem__IDRating] FOREIGN KEY([IDRating])
REFERENCES [dbo].[Tabx_RAY_EmployeeRating_Rating] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_RatingItem__IDRating]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_RatingItem__IDSchemaItem] FOREIGN KEY([IDSchemaItem])
REFERENCES [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_RatingItem] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_RatingItem__IDSchemaItem]
GO

