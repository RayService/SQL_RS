USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductDiscount]    Script Date: 04.07.2025 7:52:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductDiscount] AS 
SELECT sl.id FROM TabSlZbo sl
LEFT JOIN TabSlZbo_EXT sle ON sl.ID = sle.ID
JOIN TabKmenZbozi_EXT k ON k.Id = sl.IDZbo
WHERE DruhSlevy = 0 AND k._Redenge_LastProcessDate IS NOT NULL AND
ISNULL(sle._Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(sle._Redenge_LastProcessDate, CAST('1.1.1900' AS DATETIME))
GO

