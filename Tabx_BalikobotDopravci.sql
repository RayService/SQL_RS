USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotDopravci]    Script Date: 02.07.2025 8:27:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotDopravci](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NOT NULL,
	[NazevDopravce] [nvarchar](100) NOT NULL,
	[PodporovanoAPI] [bit] NOT NULL,
	[PodporovanoHeO] [bit] NOT NULL,
	[Zakoupeno] [bit] NOT NULL,
	[Distribucni] [bit] NULL,
	[Logo] [image] NULL,
	[TrackLink] [nvarchar](400) NULL,
	[PocetStitku] [nvarchar](20) NULL,
	[IdFormTiskStitku] [int] NULL,
	[IdFormTiskStitkuBalik] [int] NULL,
	[IdFormTiskPredavaciArch] [int] NULL,
 CONSTRAINT [PK__Tabx_BalikobotDopravci__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_BalikobotDopravci__KodDopravce] UNIQUE NONCLUSTERED 
(
	[KodDopravce] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotDopravci] ADD  CONSTRAINT [DF__Tabx_BalikobotDopravci__Zakoupeno]  DEFAULT ((0)) FOR [Zakoupeno]
GO

ALTER TABLE [dbo].[Tabx_BalikobotDopravci] ADD  CONSTRAINT [DF__Tabx_BalikobotDopravci__PocetStitku]  DEFAULT ('4') FOR [PocetStitku]
GO

