USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_location_counterparts]    Script Date: 02.07.2025 9:12:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_location_counterparts](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDLocation] [int] NULL,
	[IDProtikus] [int] NULL,
	[IDSerialNumber] [int] NULL,
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
 CONSTRAINT [PK__Tabx_RS_location_counterparts__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_location_counterparts] ADD  CONSTRAINT [DF__Tabx_RS_location_counterparts__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_location_counterparts] ADD  CONSTRAINT [DF__Tabx_RS_location_counterparts__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_location_counterparts]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_location_counterparts__IDLocation] FOREIGN KEY([IDLocation])
REFERENCES [dbo].[TabUmisteni] ([Id])
GO

ALTER TABLE [dbo].[Tabx_RS_location_counterparts] CHECK CONSTRAINT [FK__Tabx_RS_location_counterparts__IDLocation]
GO

ALTER TABLE [dbo].[Tabx_RS_location_counterparts]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_location_counterparts__IDProtikus] FOREIGN KEY([IDProtikus])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_location_counterparts] CHECK CONSTRAINT [FK__Tabx_RS_location_counterparts__IDProtikus]
GO

