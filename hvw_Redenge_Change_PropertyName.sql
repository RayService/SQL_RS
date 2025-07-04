USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_PropertyName]    Script Date: 04.07.2025 8:01:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_PropertyName] AS 
SELECT Id FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName
WHERE (LastChangeDate > LastProcessDate) OR (LastProcessDate IS NULL)
GO

