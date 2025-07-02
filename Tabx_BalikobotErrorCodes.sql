USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotErrorCodes]    Script Date: 02.07.2025 8:28:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotErrorCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorCodeType] [tinyint] NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorKey] [nvarchar](50) NOT NULL,
	[ErrorMsg] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotErrorCodes__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotErrorCodes] ADD  CONSTRAINT [DF__Tabx_BalikobotErrorCodes__ErrorCodeType]  DEFAULT ((0)) FOR [ErrorCodeType]
GO

