USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Brany]    Script Date: 03.07.2025 14:19:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Brany] AS SELECT * 
, Blokovano= convert(bit, CASE WHEN (EXISTS(SELECT * FROM Gatema_SDDoklady D WHERE D.IDBrana=GTabBrany.ID AND D.DatGenerovani IS NULL))
                               THEN 1 ELSE 0 END)
, AutorBlokovani=(SELECT D.Autor FROM Gatema_SDDoklady D WHERE D.IDBrana=GTabBrany.ID AND D.DatGenerovani IS NULL) 
FROM GTabBrany
GO

