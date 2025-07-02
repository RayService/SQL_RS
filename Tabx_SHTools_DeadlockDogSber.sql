USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SHTools_DeadlockDogSber]    Script Date: 02.07.2025 10:33:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SHTools_DeadlockDogSber](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatumOd] [datetime] NOT NULL,
	[DatumDo] [datetime] NOT NULL,
	[Chyba] [nvarchar](max) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatumOd_D]  AS (datepart(day,[DatumOd])),
	[DatumOd_M]  AS (datepart(month,[DatumOd])),
	[DatumOd_Y]  AS (datepart(year,[DatumOd])),
	[DatumOd_Q]  AS (datepart(quarter,[DatumOd])),
	[DatumOd_W]  AS (datepart(week,[DatumOd])),
	[DatumOd_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumOd])))),
 CONSTRAINT [PK__Tabx_SHTools_DeadlockDogSber__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SHTools_DeadlockDogSber] ADD  CONSTRAINT [DF__Tabx_SHTools_DeadlockDogSber__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SHTools_DeadlockDogSber] ADD  CONSTRAINT [DF__Tabx_SHTools_DeadlockDogSber__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

