USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotTrackStatus]    Script Date: 02.07.2025 8:35:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotTrackStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdBalik] [int] NOT NULL,
	[IdZasilky] [int] NULL,
	[Poradi] [int] NOT NULL,
	[Status] [nvarchar](400) NOT NULL,
	[StatusDate] [datetime] NULL,
	[status_id] [int] NULL,
	[status_id_v2] [nvarchar](10) NULL,
	[type] [nvarchar](20) NULL,
	[name_balikobot] [nvarchar](255) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[StatusDate_D]  AS (datepart(day,[StatusDate])),
	[StatusDate_M]  AS (datepart(month,[StatusDate])),
	[StatusDate_Y]  AS (datepart(year,[StatusDate])),
	[StatusDate_Q]  AS (datepart(quarter,[StatusDate])),
	[StatusDate_W]  AS (datepart(week,[StatusDate])),
	[StatusDate_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[StatusDate])))),
	[StatusDate_V]  AS (datepart(iso_week,[StatusDate])),
	[StatusDate_O]  AS (((datepart(weekday,[StatusDate])+@@datefirst)-(2))%(7)+(1)),
 CONSTRAINT [PK__Tabx_BalikobotTrackStatus__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotTrackStatus] ADD  CONSTRAINT [DF__Tabx_BalikobotTrackStatus__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotTrackStatus] ADD  CONSTRAINT [DF__Tabx_BalikobotTrackStatus__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

