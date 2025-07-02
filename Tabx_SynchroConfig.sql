USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SynchroConfig]    Script Date: 02.07.2025 10:35:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SynchroConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdentDB] [nvarchar](2) NULL,
	[DBName] [sysname] NULL,
	[DBVerName] [nvarchar](100) NULL,
	[ServerName] [sysname] NULL,
	[CisloOrg] [int] NULL,
 CONSTRAINT [PK__Tabx_SynchroConfig__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

