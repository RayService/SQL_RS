USE [RayService]
GO

/****** Object:  View [dbo].[TabPolDONavazVCView]    Script Date: 04.07.2025 11:38:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolDONavazVCView] AS
SELECT r.ID, r.IDZboSklad, n.IDNavazPol, n.DruhPohybuZbo, n.Realizovano, vc.IDVyrCis, vc.Mnozstvi,
CASE WHEN n.DruhPohybuZbo IN (1,3) THEN -vc.MnozstviReal ELSE vc.MnozstviReal END AS MnozstviReal
FROM TabDosleObjR02 r
JOIN TabZajistX            z ON z.IDDObjR02 = r.ID AND z.JeVC = 1
JOIN TabDosleObjNavazDok02 n ON n.IDDoslaObjR = r.ID
JOIN TabVyrCP             vc ON vc.IDPolozkaDokladu = n.IDNavazPol
GO

