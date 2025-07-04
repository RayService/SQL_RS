USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductStore]    Script Date: 04.07.2025 7:57:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductStore] AS 
SELECT DISTINCT TabStavSkladu.ID FROM TabStavSkladu
JOIN TabStavSkladu_EXT ON TabStavSkladu.ID = TabStavSkladu_EXT.ID
JOIN TabKmenZbozi ON TabKmenZbozi.ID = TabStavSkladu.IDKmenZbozi
JOIN TabKmenZbozi_EXT ON TabKmenZbozi.ID = TabKmenZbozi_EXT.ID
WHERE TabKmenZbozi_EXT._Redenge_LastProcessDate IS NOT NULL
AND (
TabStavSkladu_EXT._Redenge_LastProcessDate IS NULL OR 
TabStavSkladu_EXT._Redenge_LastChangeDate > TabStavSkladu_EXT._Redenge_LastProcessDate
)
GO

