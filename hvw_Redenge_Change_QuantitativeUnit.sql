USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_QuantitativeUnit]    Script Date: 04.07.2025 8:01:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_QuantitativeUnit] AS 
SELECT TabMJ.ID FROM TabMJ 
LEFT JOIN TabMJ_EXT ON TabMJ.ID = TabMJ_EXT.ID 
WHERE ISNULL(TabMJ_EXT._Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(TabMJ_EXT._Redenge_LastProcessDate, CAST('1.1.1900' AS DATETIME))
GO

