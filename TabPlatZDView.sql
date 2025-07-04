USE [RayService]
GO

/****** Object:  View [dbo].[TabPlatZDView]    Script Date: 04.07.2025 11:36:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPlatZDView] AS
SELECT ID AS IDHlavaPPZ, NULL AS IDDetail, IDBankSpojeniPrijemce AS IDBankSpojeni, Castka, PopisPlatby1 AS VariabilniSymbol
FROM TabPlatZahr
WHERE PopisPlatby1 <> '' AND IDBankSpojeniPrijemce IS NOT NULL
AND NOT EXISTS(SELECT*FROM TabPlatZahrDetail WHERE IDHlavaPPZ=TabPlatZahr.ID)
UNION ALL
SELECT h.ID AS IDHlavaPPZ, d.ID AS IDDetail, h.IDBankSpojeniPrijemce AS IDBankSpojeni, d.Castka, d.VariabilniSymbol
FROM TabPlatZahrDetail d
JOIN TabPlatZahr h ON h.ID=d.IDHlavaPPZ
WHERE d.VariabilniSymbol <> '' AND h.IDBankSpojeniPrijemce IS NOT NULL AND d.IDDokZbo IS NULL

 
GO

