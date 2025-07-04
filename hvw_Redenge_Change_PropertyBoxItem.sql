USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_PropertyBoxItem]    Script Date: 04.07.2025 7:58:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_PropertyBoxItem] AS 
SELECT DISTINCT(propertyBoxItem.Id) FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem propertyBoxItem
JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox propertyBox
ON propertyBox.Id = propertyBoxItem.PropertyBox
WHERE ((propertyBoxItem.LastChangeDate > propertyBoxItem.LastProcessDate) AND propertyBox.Code IS NOT NULL) 
OR ((propertyBoxItem.LastProcessDate IS NULL) AND propertyBox.Code IS NOT NULL)
GO

