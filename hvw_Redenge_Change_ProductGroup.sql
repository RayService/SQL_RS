USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductGroup]    Script Date: 04.07.2025 7:53:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductGroup] AS 
SELECT s.Id FROM TabSkupinyZbozi s
LEFT JOIN TabSkupinyZbozi_EXT e ON e.ID = s.id
WHERE s.BlokovaniEditoru IS NULL AND 
((e._Redenge_LastChangeDate > e._Redenge_LastProcessDate) OR (e._Redenge_LastProcessDate IS NULL))
GO

