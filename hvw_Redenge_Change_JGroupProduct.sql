USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_JGroupProduct]    Script Date: 04.07.2025 7:45:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_JGroupProduct] AS 
SELECT n.Id FROM TabSozNa n
LEFT JOIN TabSozNa_EXT ne ON ne.ID = n.ID
JOIN TabKmenZbozi k ON k.ID = n.IDKmenZbo
LEFT JOIN TabKmenZbozi_EXT ke ON ke.ID = k.ID
WHERE ke._Redenge_LastProcessDate IS NOT NULL AND
((ne._Redenge_Discount_LastProcessDate IS NULL) OR
(ne._Redenge_Discount_LastProcessDate < ne._Redenge_Discount_LastChangeDate))
GO

