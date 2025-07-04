USE [RayService]
GO

/****** Object:  View [dbo].[TabNextDokladView]    Script Date: 04.07.2025 11:31:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabNextDokladView] AS
WITH tempcte (ID, IDDoklad, PoradoveCislo) AS(
SELECT DST.ID, SRC.IDDoklad, DH.PoradoveCislo
FROM TabPohybyZbozi  AS DST
JOIN TabPohybyZbozi  AS SRC ON SRC.ID = DST.IDOldPolozka
JOIN TabDokladyZbozi AS DH  ON DH.ID  = DST.IDDoklad
WHERE DST.IDOldDoklad IS NULL
)
SELECT ID, CAST(
CASE
WHEN ISNULL(TabDokladyZbozi.NavaznyDoklad, 0) <> 0 THEN 1
WHEN ISNULL(TabDokladyZbozi.StornoDoklad,  0) <> 0 THEN 1
WHEN EXISTS(SELECT 1 AS PocetVazeb
FROM   TabZalFak
WHERE  IDZal = TabDokladyZbozi.ID) THEN 1
WHEN EXISTS(SELECT 1 AS PocetVazeb
FROM   TabDosleObjVazbaDok02
WHERE  IDDokZbo = TabDokladyZbozi.ID) THEN 1
WHEN EXISTS(SELECT 1 AS PocetVazeb
FROM TabOZTxtPol AS DST
JOIN TabOZTxtPol AS SRC ON SRC.ID = DST.IDOldPolozka
WHERE SRC.IDDoklad = TabDokladyZbozi.ID
AND DST.IDOldDoklad IS NULL
AND DST.IDCiloveTxtPol IS NULL) THEN 1
WHEN EXISTS(SELECT 1 AS PocetVazeb
FROM   tempcte AS SRC
WHERE  SRC.IDDoklad = TabDokladyZbozi.ID
AND SRC.PoradoveCislo >= 0) THEN 1
WHEN EXISTS(SELECT 1 AS PocetVazeb
FROM   tempcte AS SRC
JOIN TabVStin AS VST ON VST.IDStinPolozka = SRC.ID
JOIN TabPohybyZbozi AS DPO ON DPO.ID = VST.IDPolozka
WHERE  SRC.IDDoklad = TabDokladyZbozi.ID
AND SRC.PoradoveCislo < 0) THEN 1
ELSE 0
END AS BIT) AS NextDoklad
FROM TabDokladyZbozi
GO

