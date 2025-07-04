USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_AssignmentProductToMultishopChanges]    Script Date: 04.07.2025 7:29:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_AssignmentProductToMultishopChanges] AS 
SELECT DISTINCT d.ProductCode, d.MultiShopId
FROM Redenge_Helios_RedengeKit_Shop_DeletedAssignmentShopProductToCategory d 
INNER JOIN Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory a 
ON d.NavaznaSkupinaZbozi = a.NavaznaSkupinaZbozi AND d.MultishopId = a.MultishopId
WHERE a.Id IS NULL
GO

