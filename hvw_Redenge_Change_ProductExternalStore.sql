USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductExternalStore]    Script Date: 04.07.2025 7:53:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductExternalStore] AS 
SELECT DISTINCT TabKmenZbozi_EXT.ID FROM TabKmenZbozi_EXT 
INNER JOIN TabKmenZbozi ON TabKmenZbozi.ID = TabKmenZbozi_EXT.ID 
WHERE TabKmenZbozi_EXT._Redenge_LastProcessDate IS NOT NULL
AND (
TabKmenZbozi_EXT._Redenge_ExternalStore_LastProcessDate IS NULL OR 
TabKmenZbozi_EXT._Redenge_ExternalStore_LastChangeDate > TabKmenZbozi_EXT._Redenge_ExternalStore_LastProcessDate
)
GO

