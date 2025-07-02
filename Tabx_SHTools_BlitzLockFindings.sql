USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SHTools_BlitzLockFindings]    Script Date: 02.07.2025 10:29:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SHTools_BlitzLockFindings](
	[ServerName] [nvarchar](256) NULL,
	[check_id] [int] NULL,
	[database_name] [nvarchar](256) NULL,
	[object_name] [nvarchar](1000) NULL,
	[finding_group] [nvarchar](100) NULL,
	[finding] [nvarchar](4000) NULL
) ON [PRIMARY]
GO

