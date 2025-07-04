USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_VztahNavazneSkupinyKeZboziSluzbe]    Script Date: 04.07.2025 8:02:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_VztahNavazneSkupinyKeZboziSluzbe] AS 
SELECT DISTINCT TabSozNa.ID FROM TabSozNa 
JOIN Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory
ON TabSozNa.IDSoz = Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory.NavaznaSkupinaZbozi
JOIN TabSozNa_EXT ON TabSozNa.ID = TabSozNa_EXT.ID
WHERE ISNULL(TabSozNa_EXT._Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(TabSozNa_EXT._Redenge_LastProcessDate, CAST('1.1.1900' AS DATETIME))
GO

