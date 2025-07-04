USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAVStornoPreuctView]    Script Date: 04.07.2025 10:47:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAVStornoPreuctView] (IdPrim,ID,Preuct,IdObdobi,IdFIAPreuctovaniRezii,IdFIARozpusteniRezii)
AS
SELECT DISTINCT 0,TabFIAVStornoPreuct.IdSec,TabFIAVStornoPreuct.Preuct,TabDenik.IdObdobi,TabFIAVStornoPreuct.IdFIAPreuctovaniRezii,TabFIAVStornoPreuct.IdFIARozpusteniRezii FROM TabFIAVStornoPreuct
LEFT JOIN TabDenik ON TabDenik.ID=TabFIAVStornoPreuct.IdSec WHERE TabFIAVStornoPreuct.Preuct=0
UNION ALL
SELECT TabFIAVStornoPreuct.IdPrim,TabFIAVStornoPreuct.IdSec,TabFIAVStornoPreuct.Preuct,TabDenik.IdObdobi,TabFIAVStornoPreuct.IdFIAPreuctovaniRezii,TabFIAVStornoPreuct.IdFIARozpusteniRezii FROM TabFIAVStornoPreuct
LEFT JOIN TabDenik ON TabDenik.ID=TabFIAVStornoPreuct.IdSec WHERE TabFIAVStornoPreuct.Preuct=1
GO

