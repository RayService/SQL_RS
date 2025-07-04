USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_ProductDiscount]    Script Date: 04.07.2025 7:35:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_ProductDiscount] AS 
SELECT Id FROM Redenge_Helios_RedengeKit_Shop_Structures_Product_DeletedProductDicsount
GO

