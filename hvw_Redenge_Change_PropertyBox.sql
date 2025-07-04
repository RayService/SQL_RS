USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_PropertyBox]    Script Date: 04.07.2025 7:58:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_PropertyBox] AS 
SELECT propertyBox.Id FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox propertyBox
WHERE ((propertyBox.LastChangeDate > propertyBox.LastProcessDate) AND propertyBox.Code IS NOT NULL) 
OR ((propertyBox.LastProcessDate IS NULL) AND propertyBox.Code IS NOT NULL)
GO

