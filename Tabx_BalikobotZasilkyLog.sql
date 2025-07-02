USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotZasilkyLog]    Script Date: 02.07.2025 8:38:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotZasilkyLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Akce] [tinyint] NOT NULL,
	[IdZasilky] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotZasilkyLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilkyLog] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilkyLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilkyLog] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilkyLog__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

