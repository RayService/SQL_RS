USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_AssignmentShopProductToCategory]    Script Date: 04.07.2025 7:30:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_AssignmentShopProductToCategory] AS 
SELECT Id FROM Redenge_Helios_RedengeKit_Shop_DeletedAssignmentShopProductToCategory
GO

