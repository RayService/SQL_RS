USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_ReseniHeO_CisBrowse]    Script Date: 02.07.2025 8:53:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_ReseniHeO_CisBrowse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BID] [int] NOT NULL,
	[BrowseName] [nvarchar](255) NOT NULL,
	[BrowseTxt]  AS (right(replicate(char((32)),(6))+CONVERT([nvarchar],[BID],(0)),(6))+isnull(N'_'+[BrowseName],N'')),
	[TableName] [nvarchar](255) NULL,
	[SysTableName] [nvarchar](255) NULL,
	[Soudecek] [nvarchar](255) NULL,
 CONSTRAINT [PK__Tabx_ReseniHeO_CisBrowse__BID] PRIMARY KEY CLUSTERED 
(
	[BID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_ReseniHeO_CisBrowse__ID] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_ReseniHeO_CisBrowse] ADD  CONSTRAINT [DF__Tabx_ReseniHeO_CisBrowse__BrowseName]  DEFAULT (N'') FOR [BrowseName]
GO

