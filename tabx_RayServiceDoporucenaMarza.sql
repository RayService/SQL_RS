USE [RayService]
GO

/****** Object:  Table [dbo].[tabx_RayServiceDoporucenaMarza]    Script Date: 02.07.2025 8:52:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tabx_RayServiceDoporucenaMarza](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cisloOrg] [int] NOT NULL,
	[skupZbo] [nvarchar](3) NULL,
	[marza] [numeric](19, 6) NULL
) ON [PRIMARY]
GO

