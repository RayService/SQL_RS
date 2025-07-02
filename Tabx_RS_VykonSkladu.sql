USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_VykonSkladu]    Script Date: 02.07.2025 10:13:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_VykonSkladu](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[DatPorizeniPolozky] [datetime] NOT NULL,
	[DatPorizeniPolozky_D]  AS (datepart(day,[DatPorizeniPolozky])),
	[DatPorizeniPolozky_M]  AS (datepart(month,[DatPorizeniPolozky])),
	[DatPorizeniPolozky_Y]  AS (datepart(year,[DatPorizeniPolozky])),
	[DatPorizeniPolozky_Q]  AS (datepart(quarter,[DatPorizeniPolozky])),
	[DatPorizeniPolozky_W]  AS (datepart(week,[DatPorizeniPolozky])),
	[DatPorizeniPolozky_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeniPolozky])))),
	[Mnozstvi] [numeric](19, 6) NULL,
	[DS_RS_DobaVyskladneniPol] [numeric](19, 6) NULL,
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
	[PocPol] [int] NULL,
	[DS_RS_AVGDobaVyskladneniPol] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RS_VykonSkladu__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] ADD  CONSTRAINT [DF__Tabx_RS_VykonSkladu__Mnozstvi]  DEFAULT ((0)) FOR [Mnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] ADD  CONSTRAINT [DF__Tabx_RS_VykonSkladu__DS_RS_DobaVyskladneniPol]  DEFAULT ((0)) FOR [DS_RS_DobaVyskladneniPol]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] ADD  CONSTRAINT [DF__Tabx_RS_VykonSkladu__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] ADD  CONSTRAINT [DF__Tabx_RS_VykonSkladu__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] ADD  CONSTRAINT [DF__Tabx_RS_VykonSkladu__PocPol]  DEFAULT ((0)) FOR [PocPol]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] ADD  CONSTRAINT [DF__Tabx_RS_VykonSkladu__DS_RS_AVGDobaVyskladneniPol]  DEFAULT ((0)) FOR [DS_RS_AVGDobaVyskladneniPol]
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_VykonSkladu__IDZam] FOREIGN KEY([IDZam])
REFERENCES [dbo].[TabCisZam] ([ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Tabx_RS_VykonSkladu] CHECK CONSTRAINT [FK__Tabx_RS_VykonSkladu__IDZam]
GO

