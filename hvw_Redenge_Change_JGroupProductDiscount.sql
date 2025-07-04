USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_JGroupProductDiscount]    Script Date: 04.07.2025 7:46:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_JGroupProductDiscount] AS 
SELECT s.id FROM TabSOZNaSlevy s
LEFT JOIN TabSOZNaSlevy_EXT se ON s.ID = se.ID
JOIN TabSozNa n ON n.ID = s.IDSozNa
JOIN TabSozNa_EXT ne ON ne.ID = n.id
WHERE (ne._Redenge_Discount_LastProcessDate IS NOT NULL)
AND (se._Redenge_Discount_LastProcessDate IS NULL OR
se._Redenge_Discount_LastChangeDate > se._Redenge_Discount_LastProcessDate)
GO

