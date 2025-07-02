USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TracePrijemka]    Script Date: 02.07.2025 10:04:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TracePrijemka](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [ntext] NULL,
	[SPID] [int] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[ObjectName] [nvarchar](128) NULL,
	[Duration] [bigint] NULL,
	[Reads] [bigint] NULL,
	[CPU] [int] NULL,
	[Writes] [bigint] NULL,
	[RowCounts] [bigint] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[LoginName] [nvarchar](128) NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[HostName] [nvarchar](128) NULL,
	[BinaryData] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

