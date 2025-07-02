USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage]    Script Date: 02.07.2025 8:49:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDTarif] [int] NULL,
	[Base] [int] NULL,
	[PctA] [int] NULL,
	[PctB] [int] NULL,
	[PctC] [int] NULL,
	[PctD] [int] NULL,
	[PctBaseMax] [int] NULL,
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
	[RatingFrequency] [int] NOT NULL,
	[PctBaseForVariableWage] [int] NULL,
	[VariableWage] [int] NULL,
	[ValueA] [int] NULL,
	[ValueB] [int] NULL,
	[ValueC] [int] NULL,
	[ValueD] [int] NULL,
 CONSTRAINT [PK__Tabx_RAY_EmployeeRatingPSxPercentage__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRatingPSxPercentage__Base]  DEFAULT ((0)) FOR [Base]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRatingPSxPercentage__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRatingPSxPercentage__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRatingPSxPercentage__IDTarif] FOREIGN KEY([IDTarif])
REFERENCES [dbo].[TabMzdTar] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRatingPSxPercentage] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRatingPSxPercentage__IDTarif]
GO

