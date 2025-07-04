USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_AccountManager]    Script Date: 04.07.2025 7:43:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_AccountManager] AS 
SELECT z.ID FROM TabCisZam z
JOIN TabCisZam_EXT e ON z.ID = e.ID
WHERE e._Redenge_LastProcessDate IS NOT NULL AND
ISNULL(e._Redenge_LastChangeDate, -1) > ISNULL(e._Redenge_LastProcessDate, -1)
GO

