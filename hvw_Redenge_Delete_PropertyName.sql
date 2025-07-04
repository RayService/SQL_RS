USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_PropertyName]    Script Date: 04.07.2025 7:42:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_PropertyName] AS 
SELECT ID FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedPropertyName
GO

