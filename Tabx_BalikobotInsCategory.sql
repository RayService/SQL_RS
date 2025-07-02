USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotInsCategory]    Script Date: 02.07.2025 8:29:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotInsCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NULL,
	[Zkratka] [nvarchar](3) NOT NULL,
	[Popis] [nvarchar](255) NULL,
 CONSTRAINT [PK__Tabx_BalikobotInsCategory__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

