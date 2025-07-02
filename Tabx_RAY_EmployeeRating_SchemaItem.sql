USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RAY_EmployeeRating_SchemaItem]    Script Date: 02.07.2025 8:48:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDRoot] [int] NULL,
	[Title] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[MaxValue] [int] NULL,
	[PctOfVariableWage] [int] NULL,
	[PaymentFrequency] [int] NOT NULL,
	[IDKPI] [int] NULL,
	[Ordering] [int] NOT NULL,
	[IDSchema] [int] NULL,
	[IDChangeFrom] [int] NULL,
	[IDChangeTo] [int] NULL,
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
	[MaxPctOfFixWage] [int] NULL,
	[Disabled] [bit] NOT NULL,
	[PctValue] [int] NULL,
	[WagePartNr] [int] NULL,
	[Workflow] [nvarchar](20) NULL,
 CONSTRAINT [PK__Tabx_RAY_EmployeeRating_SchemaItem__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__Title]  DEFAULT ('') FOR [Title]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__PaymentFrequency]  DEFAULT ((1)) FOR [PaymentFrequency]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__Ordering]  DEFAULT ((0)) FOR [Ordering]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__Disabled]  DEFAULT ((0)) FOR [Disabled]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] ADD  CONSTRAINT [DF__Tabx_RAY_EmployeeRating_SchemaItem__PctValue]  DEFAULT ((0)) FOR [PctValue]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_SchemaItem__IDChangeFrom] FOREIGN KEY([IDChangeFrom])
REFERENCES [dbo].[Tabx_RAY_EmployeeRating_Change] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_SchemaItem__IDChangeFrom]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_SchemaItem__IDChangeTo] FOREIGN KEY([IDChangeTo])
REFERENCES [dbo].[Tabx_RAY_EmployeeRating_Change] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_SchemaItem__IDChangeTo]
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RAY_EmployeeRating_SchemaItem__IDSchema] FOREIGN KEY([IDSchema])
REFERENCES [dbo].[Tabx_RAY_EmployeeRating_Schema] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RAY_EmployeeRating_SchemaItem] CHECK CONSTRAINT [FK__Tabx_RAY_EmployeeRating_SchemaItem__IDSchema]
GO

