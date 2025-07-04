USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductPackage]    Script Date: 04.07.2025 7:54:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductPackage] AS 
SELECT DISTINCT k.id FROM TabKmenZbozi_EXT k
JOIN TabSozNa n ON k.id = n.IDKmenZbo
JOIN TabSoz s ON s.ID = n.IDSoz
JOIN Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory a ON a.NavaznaSkupinaZbozi = s.Id 
WHERE k._Redenge_Package_LastChangeDate > k._Redenge_Package_LastProcessDate OR k._Redenge_Package_LastProcessDate IS NULL
GO

