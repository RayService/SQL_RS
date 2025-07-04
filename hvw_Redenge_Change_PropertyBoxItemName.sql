USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_PropertyBoxItemName]    Script Date: 04.07.2025 7:59:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_PropertyBoxItemName] AS 
SELECT DISTINCT propertyBoxItemName.Id FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName propertyBoxItemName
JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem propertyBoxItem
ON propertyBoxItem.Id = propertyBoxItemName.PropertyBoxItem
JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox propertyBox
ON propertyBox.Id = propertyBoxItem.PropertyBox
WHERE ((propertyBoxItemName.LastChangeDate > propertyBoxItemName.LastProcessDate) AND propertyBox.Code IS NOT NULL) 
OR ((propertyBoxItemName.LastProcessDate IS NULL) AND propertyBox.Code IS NOT NULL)
GO

