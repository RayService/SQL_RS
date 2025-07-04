USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_JGroup]    Script Date: 04.07.2025 7:30:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_JGroup] AS 
SELECT ID FROM Redenge_Helios_RedengeKit_Shop_Structures_JGroup_DeletedJGroup
GO

