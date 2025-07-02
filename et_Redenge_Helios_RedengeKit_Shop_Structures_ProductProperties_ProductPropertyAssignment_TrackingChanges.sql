USE [HCvicna]
GO

/****** Object:  Table [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedProductPropertyAssignment]    Script Date: 02.07.2025 14:01:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedProductPropertyAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductCode] [nvarchar](100) NULL,
	[PropertyCode] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

