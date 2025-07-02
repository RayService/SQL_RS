USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_KalkulaceKonfig]    Script Date: 02.07.2025 9:09:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_KalkulaceKonfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NasMinCena] [numeric](5, 2) NULL,
	[NasOptCena] [numeric](5, 2) NULL,
	[DnyHistorie] [int] NULL,
	[IDSklad] [nvarchar](30) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_RS_KalkulaceKonfig__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceKonfig] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceKonfig__NasMinCena]  DEFAULT ((0)) FOR [NasMinCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceKonfig] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceKonfig__NasOptCena]  DEFAULT ((0)) FOR [NasOptCena]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceKonfig] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceKonfig__DnyHistorie]  DEFAULT ((365)) FOR [DnyHistorie]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceKonfig] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceKonfig__IDSklad]  DEFAULT ((200)) FOR [IDSklad]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceKonfig] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceKonfig__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_KalkulaceKonfig] ADD  CONSTRAINT [DF__Tabx_RS_KalkulaceKonfig__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

