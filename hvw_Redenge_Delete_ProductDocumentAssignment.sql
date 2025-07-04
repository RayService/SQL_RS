USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_ProductDocumentAssignment]    Script Date: 04.07.2025 7:36:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_ProductDocumentAssignment] AS 
SELECT Id FROM Redenge_Helios_RedengeKit_Shop_Structures_Documents_DeletedProductDocumentAssignment
GO

