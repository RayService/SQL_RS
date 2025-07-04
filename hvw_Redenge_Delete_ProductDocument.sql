USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_ProductDocument]    Script Date: 04.07.2025 7:35:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_ProductDocument] AS 
SELECT DISTINCT TabDokumenty.ID FROM TabDokumenty
JOIN TabDokumenty_EXT ON TabDokumenty.ID = TabDokumenty_EXT.ID
JOIN TabDokumVazba ON TabDokumVazba.IdDok = TabDokumenty.ID 
JOIN TabKmenZbozi ON TabKmenZbozi.ID = TabDokumVazba.IdTab   
JOIN TabKmenZbozi_EXT ON TabKmenZbozi.ID = TabKmenZbozi_EXT.ID 
WHERE
TabKmenZbozi_EXT._Redenge_LastProcessDate IS NOT NULL AND (
(TabDokumenty_EXT._Redenge_LastProcessDate IS NULL) OR
(TabDokumenty_EXT._Redenge_LastChangeDate > TabDokumenty_EXT._Redenge_LastProcessDate)
)
GO

