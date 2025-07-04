USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_JGroupProductOrganization]    Script Date: 04.07.2025 7:47:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_JGroupProductOrganization] AS 
SELECT o.id FROM TabCisOrg o
LEFT JOIN TabCisOrg_EXT oe ON o.ID = oe.ID
WHERE o.IDSOZsleva IS NOT NULL AND oe._Redenge_LastProcessDate IS NOT NULL AND (oe._Redenge_Discount_LastProcessDate IS NULL OR (oe._Redenge_Discount_LastChangeDate > oe._Redenge_Discount_LastProcessDate))
GO

