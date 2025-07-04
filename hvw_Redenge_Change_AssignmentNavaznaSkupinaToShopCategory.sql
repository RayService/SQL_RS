USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_AssignmentNavaznaSkupinaToShopCategory]    Script Date: 04.07.2025 7:44:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_AssignmentNavaznaSkupinaToShopCategory] AS 
SELECT ID FROM  Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory
WHERE ISNULL(_Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(_Redenge_LastProcessDate, CAST('1.1.1900' AS DATETIME))
GO

