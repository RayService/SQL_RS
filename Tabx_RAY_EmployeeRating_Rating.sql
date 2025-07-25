USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RAY_EmployeeRating_Rating]    Script Date: 02.07.2025 8:47:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NOT NULL,
	[IDRatedEmployee] [int] NULL,
	[IDRatingEmployee] [int] NULL,
	[IDPeriod] [int] NULL,
	[IDWagePartSalary] [int] NULL,
	[IDWagePartBenefitSystem] [int] NULL,
	[ValueTotal] [float] NULL,
	[ValueToSalary] [float] NULL,
	[ValueToBenefitSystem] [float] NULL,
	[Note] [nvarchar](255) NULL,
	[NotRated] [bit] NULL,
	[NotRatedReason] [varchar](255) NULL,
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
 CONSTRAINT [PK__Tabx_RAY_EmployeeRating_Rating__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_Rating__Status]  DEFAULT ((10)) FOR [Status]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_Rating__NotRated]  DEFAULT ((0)) FOR [NotRated]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_Rating__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_Rating__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_Rating__IDPeriod] FOREIGN KEY([IDPeriod])
REFERENCES [dbo].[TabMzdObd] ([IdObdobi])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_Rating__IDPeriod]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_Rating__IDRatedEmployee] FOREIGN KEY([IDRatedEmployee])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_Rating__IDRatedEmployee]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_Rating__IDRatingEmployee] FOREIGN KEY([IDRatingEmployee])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_Rating] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_Rating__IDRatingEmployee]
GO

