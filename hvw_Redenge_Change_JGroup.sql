USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_JGroup]    Script Date: 04.07.2025 7:45:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_JGroup] AS 
SELECT s.ID FROM TabSoz s
LEFT JOIN TabSoz_EXT e ON s.ID = e.ID
WHERE (e._Redenge_Discount_LastChangeDate IS NULL) OR
(e._Redenge_Discount_LastChangeDate > e._Redenge_Discount_LastProcessDate)
OR (e._Redenge_Discount_LastChangeDate IS NOT NULL AND e._Redenge_Discount_LastProcessDate IS NULL)
GO

