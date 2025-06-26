USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_OdBlokacePlatebFAP]    Script Date: 26.06.2025 13:41:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_OdBlokacePlatebFAP]
AS

--úvodní select faktur, které jsou blokovány
/*
SELECT
tdz.ID,tdz.RadaDokladu,tdz.PoradoveCislo,ISNULL(tdze._blokace_platby,0) AS _blokace_platby,tdze._zamestnanec
,tdze._poznamka_blokace
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID
WHERE
((tdz.IDSklad IS NULL)AND(tdz.DruhPohybuZbo BETWEEN 18 AND 19)AND(tdz.PoradoveCislo>=0)AND(ISNULL(tdze._blokace_platby,0)=1)AND(tdze._zamestnanec LIKE N'%robot%')
AND(tdze._poznamka_blokace LIKE N'%Reklamace%')
)
*/

IF OBJECT_ID('tempdb..#TabNeshodyFAP') IS NOT NULL DROP TABLE #TabNeshodyFAP
CREATE TABLE #TabNeshodyFAP (ID INT IDENTITY(1,1), IDNesh INT NOT NULL, IDPrij INT NULL, IDFap INT NULL,CisloOrg INT NULL,StavDod NVARCHAR(15) NULL,Hodnota NUMERIC(19,6) NULL,
Blokace_platby BIT NULL,Datum_Od DATETIME NULL,Zamestnanec NVARCHAR(MAX) NULL, Pozn NVARCHAR(255)
)

INSERT INTO #TabNeshodyFAP(IDNesh)
SELECT
tdz.ID
FROM TabDokladyZbozi tdz
WHERE
((tdz.DruhPohybuZbo=11)AND(tdz.PoradoveCislo>=0)AND(tdz.Splatnost_X IS NOT NULL))
AND((tdz.RadaDokladu like N'925%')OR(tdz.RadaDokladu like N'935%')OR(tdz.RadaDokladu like N'961%'))
AND(tdz.DatPorizeni>'2022-09-01')
ORDER BY tdz.ID

UPDATE t SET t.IDPrij=tpzPr.IDDoklad
FROM #TabNeshodyFAP t
LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDDoklad=t.IDNesh
LEFT OUTER JOIN TabPohybyZbozi tpzPr ON tpzPr.ID=tpz.IDOldPolozka
WHERE tpz.IDDoklad=IDNesh

UPDATE t SET t.IDFap=(SELECT TOP 1 tpz.IDDoklad
FROM TabPohybyZbozi tpz
WHERE tpz.IDOldDoklad=t.IDPrij)
FROM #TabNeshodyFAP t

UPDATE t SET t.Blokace_platby=ISNULL(tdze._blokace_platby,0), t.Zamestnanec=tdze._zamestnanec
FROM #TabNeshodyFAP t
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=t.IDFap
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID

DELETE FROM #TabNeshodyFAP WHERE IDFap IS NULL
DELETE FROM #TabNeshodyFAP WHERE Blokace_platby=0
DELETE FROM #TabNeshodyFAP WHERE Zamestnanec<>'ROBOT'
/*
SELECT IDFap,Zamestnanec,Blokace_platby
FROM #TabNeshodyFAP
GROUP BY IDFap,Zamestnanec,Blokace_platby
*/

MERGE TabDokladyZbozi_EXT AS TARGET
USING (SELECT IDFap,Zamestnanec,Blokace_platby
FROM #TabNeshodyFAP
GROUP BY IDFap,Zamestnanec,Blokace_platby) AS SOURCE
ON TARGET.ID=SOURCE.IDFap
WHEN MATCHED THEN
UPDATE SET TARGET._blokace_platby=0,TARGET._odblokovano=GETDATE()
;
GO

