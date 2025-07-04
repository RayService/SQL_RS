USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_Product]    Script Date: 04.07.2025 7:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_Product] AS 
SELECT ID FROM TabKmenZbozi_EXT WHERE _Redenge_LastProcessDate IS NOT NULL AND ISNULL(_Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(_Redenge_LastProcessDate, CAST('1.1.1900' AS DATETIME))
GO

