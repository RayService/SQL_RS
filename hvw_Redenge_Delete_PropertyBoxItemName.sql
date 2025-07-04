USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_PropertyBoxItemName]    Script Date: 04.07.2025 7:41:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_PropertyBoxItemName] AS 
SELECT ID FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedPropertyBoxItemName
GO

