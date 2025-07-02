USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_KontrolaDochazky]    Script Date: 02.07.2025 9:10:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_KontrolaDochazky](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Cislo] [int] NOT NULL,
	[DatumDochazky] [datetime] NULL,
	[DatumDochazky_D]  AS (datepart(day,[DatumDochazky])),
	[DatumDochazky_M]  AS (datepart(month,[DatumDochazky])),
	[DatumDochazky_Y]  AS (datepart(year,[DatumDochazky])),
	[DatumDochazky_Q]  AS (datepart(quarter,[DatumDochazky])),
	[DatumDochazky_W]  AS (datepart(week,[DatumDochazky])),
	[DatumDochazky_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumDochazky])))),
	[DatumOdchod] [datetime] NULL,
	[DatumOdchod_D]  AS (datepart(day,[DatumOdchod])),
	[DatumOdchod_M]  AS (datepart(month,[DatumOdchod])),
	[DatumOdchod_Y]  AS (datepart(year,[DatumOdchod])),
	[DatumOdchod_Q]  AS (datepart(quarter,[DatumOdchod])),
	[DatumOdchod_W]  AS (datepart(week,[DatumOdchod])),
	[DatumOdchod_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumOdchod])))),
	[DatumPrichod] [datetime] NULL,
	[DatumPrichod_D]  AS (datepart(day,[DatumPrichod])),
	[DatumPrichod_M]  AS (datepart(month,[DatumPrichod])),
	[DatumPrichod_Y]  AS (datepart(year,[DatumPrichod])),
	[DatumPrichod_Q]  AS (datepart(quarter,[DatumPrichod])),
	[DatumPrichod_W]  AS (datepart(week,[DatumPrichod])),
	[DatumPrichod_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumPrichod])))),
	[OdpracDobaHod] [numeric](19, 6) NULL,
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
	[CasZDochazky] [numeric](5, 2) NULL,
	[PomerDobyProc]  AS (([OdpracDobaHod]/isnull(nullif([CasZDochazky],(0)),(1)))*(100)),
	[FirstZahajeni] [datetime] NULL,
	[FirstZahajeni_D]  AS (datepart(day,[FirstZahajeni])),
	[FirstZahajeni_M]  AS (datepart(month,[FirstZahajeni])),
	[FirstZahajeni_Y]  AS (datepart(year,[FirstZahajeni])),
	[FirstZahajeni_Q]  AS (datepart(quarter,[FirstZahajeni])),
	[FirstZahajeni_W]  AS (datepart(week,[FirstZahajeni])),
	[FirstZahajeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[FirstZahajeni])))),
	[LastUkonceni] [datetime] NULL,
	[LastUkonceni_D]  AS (datepart(day,[LastUkonceni])),
	[LastUkonceni_M]  AS (datepart(month,[LastUkonceni])),
	[LastUkonceni_Y]  AS (datepart(year,[LastUkonceni])),
	[LastUkonceni_Q]  AS (datepart(quarter,[LastUkonceni])),
	[LastUkonceni_W]  AS (datepart(week,[LastUkonceni])),
	[LastUkonceni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[LastUkonceni])))),
 CONSTRAINT [PK__Tabx_RS_KontrolaDochazky__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaDochazky] ADD  CONSTRAINT [DF__Tabx_RS_KontrolaDochazky__OdpracDobaHod]  DEFAULT ((0)) FOR [OdpracDobaHod]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaDochazky] ADD  CONSTRAINT [DF__Tabx_RS_KontrolaDochazky__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaDochazky] ADD  CONSTRAINT [DF__Tabx_RS_KontrolaDochazky__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaDochazky] ADD  CONSTRAINT [DF__Tabx_RS_KontrolaDochazky__CasZDochazky]  DEFAULT ((0)) FOR [CasZDochazky]
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaDochazky]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_KontrolaDochazky__Cislo] FOREIGN KEY([Cislo])
REFERENCES [dbo].[TabCisZam] ([Cislo])
GO

ALTER TABLE [dbo].[Tabx_RS_KontrolaDochazky] CHECK CONSTRAINT [FK__Tabx_RS_KontrolaDochazky__Cislo]
GO

