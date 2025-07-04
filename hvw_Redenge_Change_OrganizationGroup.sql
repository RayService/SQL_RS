USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_OrganizationGroup]    Script Date: 04.07.2025 7:48:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_OrganizationGroup] AS 
SELECT s.id FROM TabSkupOrg s
LEFT JOIN TabSkupOrg_EXT e ON s.ID = e.ID
WHERE (e._Redenge_LastChangeDate > e._Redenge_LastProcessDate) OR (e._Redenge_LastProcessDate IS NULL)
GO

