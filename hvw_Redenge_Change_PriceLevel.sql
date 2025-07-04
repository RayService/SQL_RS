USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_PriceLevel]    Script Date: 04.07.2025 7:51:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_PriceLevel] AS 
SELECT TabCisNc.ID FROM TabCisNC 
JOIN TabCisNC_EXT on TabCisNC.ID = TabCisNC_EXT.ID
WHERE (TabCisNC_EXT._Redenge_LastChangeDate > TabCisNC_EXT._Redenge_LastProcessDate
AND TabCisNC.CenovaUroven IN (
SELECT TabCisOrg.CenovaUroven FROM TabCisOrg
JOIN TabCisOrg_EXT ON TabCisOrg.ID = TabCisOrg_EXT.ID
WHERE TabCisOrg_EXT._Redenge_LastProcessDate IS NOT NULL AND TabCisOrg.CenovaUroven IS NOT NULL))
OR (
TabCisNC_EXT._Redenge_LastProcessDate IS NULL 
AND TabCisNC.CenovaUroven IN (
SELECT TabCisOrg.CenovaUroven FROM TabCisOrg
JOIN TabCisOrg_EXT ON TabCisOrg.ID = TabCisOrg_EXT.ID
WHERE TabCisOrg_EXT._Redenge_LastProcessDate IS NOT NULL AND TabCisOrg.CenovaUroven IS NOT NULL
))
GO

