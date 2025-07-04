USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_BlockedUser]    Script Date: 04.07.2025 7:45:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_BlockedUser] AS 
SELECT o.id FROM TabCisOrg o
JOIN TabVztahOrgKOs v ON v.IDOrg = o.id
JOIN TabVztahOrgKOs_EXT e ON e.ID = v.ID
WHERE v.ZamestnanDo < GETDATE() AND e._Redenge_LastProcessDate IS NOT NULL AND (e._Redenge_Blocked = 0 OR e._Redenge_Blocked IS null)
GO

