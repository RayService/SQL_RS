USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotSluzby]    Script Date: 02.07.2025 8:33:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotSluzby](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NULL,
	[service_type] [nvarchar](50) NOT NULL,
	[service_name] [nvarchar](100) NOT NULL,
	[PodporovanoHeO] [bit] NOT NULL,
	[Distribucni] [bit] NULL,
	[b2a] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotSluzby__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_BalikobotSluzby__KodDopravce__service_type__b2a] UNIQUE NONCLUSTERED 
(
	[KodDopravce] ASC,
	[service_type] ASC,
	[b2a] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotSluzby] ADD  CONSTRAINT [DF__Tabx_BalikobotSluzby__PodporovanoHeO]  DEFAULT ((1)) FOR [PodporovanoHeO]
GO

ALTER TABLE [dbo].[Tabx_BalikobotSluzby] ADD  CONSTRAINT [DF__Tabx_BalikobotSluzby__b2a]  DEFAULT ((0)) FOR [b2a]
GO

ALTER TABLE [dbo].[Tabx_BalikobotSluzby] ADD  CONSTRAINT [DF__Tabx_BalikobotSluzby__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotSluzby] ADD  CONSTRAINT [DF__Tabx_BalikobotSluzby__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

