USE [RayService]
GO

/****** Object:  View [dbo].[TabZajistXZpusobZajView]    Script Date: 04.07.2025 13:07:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabZajistXZpusobZajView] AS
SELECT TabZajistX.ID, TabZajistX.DruhZajDok,
( SELECT CAST( ISNULL( n.JeVyrobaOd2007, ISNULL( p.ZpusobZaj, CASE WHEN TabZajistX.DruhZajDok = 1 THEN 0 ELSE VTabZajistXTabKmenZbozi.Dilec END )) AS TINYINT)
FROM TabOZDONastaveni n
LEFT OUTER JOIN TabKmenZbozi VTabZajistXTabKmenZbozi ON
( TabZajistX.DruhZajDok = 0 AND
TabZajistX.IDDObjR02 IS NOT NULL AND
VTabZajistXTabKmenZbozi.ID = ( SELECT S.IDKmenZbozi
FROM TabStavSkladu AS S
JOIN TabDosleObjR02 AS R ON S.ID = R.IDZboSklad
WHERE R.ID = TabZajistX.IDDObjR02 )) OR
( TabZajistX.DruhZajDok = 1 AND
TabZajistX.IDGPrUMZ  IS NOT NULL AND
VTabZajistXTabKmenZbozi.ID = ( SELECT k.ID
FROM TabGprUlohyMatZdroje m
JOIN TabKmenZbozi k ON k.ID = m.IDMatZdroje
WHERE m.ID = TabZajistX.IDGPrUMZ )) OR
( TabZajistX.DruhZajDok = 5 AND
TabZajistX.IDPrKVaz  IS NOT NULL AND
VTabZajistXTabKmenZbozi.ID = ( SELECT S.IDKmenZbozi
FROM TabStavSkladu AS S
JOIN TabKmenZbozi K ON k.ID = S.IDKmenZbozi AND ((K.Material = 1) OR ((K.Dilec = 1) AND (SELECT PovolitZajisteniDilcu FROM TabHGlob) = 1))
JOIN TabPrKVazby AS PRK ON S.IDSklad = PRK.Sklad AND S.IDKmenZbozi = PRK.Nizsi
WHERE PRK.ID1 = TabZajistX.IDPrKVaz AND PRK.IDOdchylkyDo IS NULL))
LEFT OUTER JOIN TabZajistPriX p ON p.IDZajist = TabZajistX.ID ) AS ZpusobZaj
FROM TabZajistX
GO

