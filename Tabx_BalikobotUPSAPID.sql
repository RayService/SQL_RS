USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotUPSAPID]    Script Date: 02.07.2025 8:35:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotUPSAPID](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AccessPointID] [nvarchar](40) NULL,
	[Name] [nvarchar](100) NULL,
	[City] [nvarchar](100) NULL,
	[Street] [nvarchar](100) NULL,
	[ZIP] [nvarchar](10) NULL,
	[Region] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[Photo_large] [nvarchar](100) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[Opening_sunday] [nvarchar](20) NULL,
	[Opening_monday] [nvarchar](20) NULL,
	[Opening_tuesday] [nvarchar](20) NULL,
	[Opening_wednesday] [nvarchar](20) NULL,
	[Opening_thursday] [nvarchar](20) NULL,
	[Opening_friday] [nvarchar](20) NULL,
	[Opening_saturday] [nvarchar](20) NULL,
	[Autor] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotUPSAPID__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotUPSAPID] ADD  CONSTRAINT [DF__Tabx_BalikobotUPSAPID__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

