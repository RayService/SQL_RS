USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductGroupGroupDiscount]    Script Date: 04.07.2025 7:54:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductGroupGroupDiscount] AS 
SELECT s.Id FROM TabSkupZboOrgSlevy s
LEFT JOIN TabSkupZboOrgSlevy_EXT e ON s.ID = e.id
LEFT JOIN TabCisOrg o ON o.CisloOrg = s.CisloOrg
LEFT JOIN TabCisOrg_EXT oe ON oe.ID = o.ID
WHERE (s.CisloOrg IS NULL OR oe._Redenge_LastProcessDate IS NOT NULL) AND
((e._Redenge_LastProcessDate IS NULL ) OR (e._Redenge_LastChangeDate > e._Redenge_LastProcessDate))
GO

