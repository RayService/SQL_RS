USE [RayService]
GO

/****** Object:  View [dbo].[TabPlatTRDView]    Script Date: 04.07.2025 11:35:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPlatTRDView] AS
SELECT IDHlavaPP, ID AS IDRadekPP, NULL AS IDDetail, IDBankSpojeni, Castka,
VariabilniSymbol, NULL AS IDDokZbo, NULL AS IDUhrady, IDBankUstavu
FROM TabPlatTuzR
WHERE NOT EXISTS(SELECT*FROM TabPlatTuzRDetail WHERE IDRadekPP=TabPlatTuzR.ID)
UNION ALL
SELECT r.IDHlavaPP, r.ID AS IDRadekPP, d.ID AS IDDetail, r.IDBankSpojeni, d.Castka,
d.VariabilniSymbol, d.IDDokZbo, d.IDUhrady, r.IDBankUstavu
FROM TabPlatTuzRDetail d
JOIN TabPlatTuzR r ON r.ID=d.IDRadekPP
GO

