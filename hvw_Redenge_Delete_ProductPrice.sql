USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_ProductPrice]    Script Date: 04.07.2025 7:38:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_ProductPrice] AS 
SELECT Id FROM Redenge_Helios_RedengeKit_Shop_Structures_Prices_DeletedProductPrice
GO

