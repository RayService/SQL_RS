USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_Organization]    Script Date: 04.07.2025 7:48:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_Organization] AS 
SELECT DISTINCT k.Id FROM TabCisOrg k
LEFT JOIN TabCisOrg_EXT e ON e.ID = k.id
LEFT JOIN TabVztahOrgKOs v ON v.IDOrg = k.ID
LEFT JOIN TabVztahOrgKOs_EXT ve ON ve.ID = v.ID
LEFT JOIN TabKontakty kon ON kon.IDVztahKOsOrg = v.id AND kon.IDCisKOs = v.IDCisKOs AND kon.Druh = 6
WHERE (k.BlokovaniEditoru IS NULL AND (ve._Redenge_SendToShop = 1 AND kon.id IS NOT NULL AND
((e._Redenge_LastProcessDate < e._Redenge_LastChangeDate OR e._Redenge_LastProcessDate IS NULL)
OR
(ve._Redenge_LastProcessDate IS NULL OR ve._Redenge_LastChangeDate > ve._Redenge_LastProcessDate)
))
OR (ve._Redenge_SynchronizationDate IS NOT NULL AND ve._Redenge_LastProcessDate < ve._Redenge_LastChangeDate))
OR e._Redenge_LastProcessDate IS NOT NULL AND (e._Redenge_LastChangeDate > e._Redenge_LastProcessDate)
GO

