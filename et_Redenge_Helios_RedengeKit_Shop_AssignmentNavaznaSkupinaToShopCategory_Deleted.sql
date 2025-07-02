USE [HCvicna]
GO

/****** Object:  Table [dbo].[Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory]    Script Date: 02.07.2025 13:14:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ShopCategoryId] [int] NULL,
	[MultishopId] [int] NULL,
	[_Redenge_LastChangeDate] [datetime] NULL,
	[_Redenge_LastProcessDate] [datetime] NULL,
	[NavaznaSkupinaZbozi] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory]  WITH CHECK ADD  CONSTRAINT [FK_AssignmentNavaznaSkupinaToShopCategory_NavaznaSkupina] FOREIGN KEY([NavaznaSkupinaZbozi])
REFERENCES [dbo].[TabSoz] ([ID])
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory] CHECK CONSTRAINT [FK_AssignmentNavaznaSkupinaToShopCategory_NavaznaSkupina]
GO

