USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductAttribute]    Script Date: 04.07.2025 7:52:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductAttribute] AS 
SELECT DISTINCT a.Id FROM Redenge_Helios_RedengeKit_Shop_ProductAttribute a
JOIN TabSozNa ON TabSozNa.IDKmenZbo = a.RelationID
JOIN Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory ass ON ass.NavaznaSkupinaZbozi = TabSozNa.IDSoz
WHERE a._Redenge_LastChangeDate IS NULL OR (ISNULL(a._Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(a._Redenge_LastProcessDate, CAST('1.1.1900' AS DATETIME)))
GO

