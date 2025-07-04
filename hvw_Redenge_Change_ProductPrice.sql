USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductPrice]    Script Date: 04.07.2025 7:55:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductPrice] AS 
SELECT DISTINCT TabNC.ID FROM TabNC  
LEFT JOIN TabKmenZbozi ON TabNC.IDKmenZbozi = TabKmenZbozi.ID
LEFT JOIN TabNC_EXT ON TabNC.ID = TabNC_EXT.ID
LEFT JOIN TabKmenZbozi_EXT ON TabKmenZbozi_EXT.ID = TabNC.IDKmenZbozi
JOIN TabCisNC ON TabNC.CenovaUroven = TabCisNC.CenovaUroven
LEFT JOIN TabCisNC_EXT ON TabCisNC.ID = TabCisNC_EXT.ID
WHERE TabCisNC_EXT._Redenge_LastProcessDate IS NOT NULL 
AND TabKmenZbozi_EXT._Redenge_LastProcessDate IS NOT NULL
AND ISNULL(TabNC_EXT._Redenge_LastChangeDate,CAST('1.1.1901' AS DATETIME)) > ISNULL(TabNC_EXT._Redenge_LastProcessDate, 
CAST('1.1.1900' AS DATETIME))

GO

