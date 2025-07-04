USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductPropertyItem]    Script Date: 04.07.2025 7:56:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductPropertyItem] AS 
SELECT pai.Id FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem pai
JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment pa ON pai.ProductPropertyAssignment = pa.Id 
WHERE pa.LastProcessDate IS NOT NULL AND ((pai.LastChangeDate > pai.LastProcessDate) OR (pai.LastProcessDate IS NULL))
GO

