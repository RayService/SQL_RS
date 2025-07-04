USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_AccountManager]    Script Date: 04.07.2025 7:27:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_AccountManager] AS 
SELECT ID FROM Redenge_Helios_RedengeKit_Shop_Structures_Organization_DeletedAccountManager
GO

