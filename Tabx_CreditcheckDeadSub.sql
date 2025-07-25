USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_CreditcheckDeadSub]    Script Date: 02.07.2025 8:40:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_CreditcheckDeadSub](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ICO] [nvarchar](20) NULL,
 CONSTRAINT [PK__Tabx_CreditcheckDeadSub__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

