USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_BlokacePlatebFAP]    Script Date: 26.06.2025 13:20:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_BlokacePlatebFAP]
AS

--USE Hcvicna
/*
Vyrobit automat, který 1x týdně (středa) projde všechny neuzavřené neshody  a pomocí vazby na příjemku a na fakturu přijatou vyplní na FAP Blokace platby = 1,
Datum od = aktuální den, zaměstnanec = robot, poznámka = Reklamace+řada a pořadové číslo reklamace.
Údaje vyplnit, pokud dodavatel není Schválený = vždy a pokud je Schválený, tak pouze je-li hodnota faktury (celkem) > 1000 Kč.
*/
IF OBJECT_ID('tempdb..#TabNeshodyFAP') IS NOT NULL DROP TABLE #TabNeshodyFAP
CREATE TABLE #TabNeshodyFAP (ID INT IDENTITY(1,1), IDNesh INT NOT NULL, IDPrij INT NULL, IDFap INT NULL,CisloOrg INT NULL,StavDod NVARCHAR(15) NULL,Hodnota NUMERIC(19,6) NULL,
Blokace_platby BIT NULL,Datum_Od DATETIME NULL,Zamestnanec NVARCHAR(40) NULL, Pozn NVARCHAR(255)
)

INSERT INTO #TabNeshodyFAP(IDNesh)
SELECT
tdz.ID
FROM TabDokladyZbozi tdz
WHERE
((tdz.DruhPohybuZbo=11)AND(tdz.PoradoveCislo>=0)AND(tdz.Splatnost_X IS NULL))
AND((tdz.RadaDokladu like N'925%')OR(tdz.RadaDokladu like N'935%')OR(tdz.RadaDokladu like N'961%'))--MŽ 14.12.2023 přidáno na přání JT řada 961
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

UPDATE t SET t.CisloOrg=tco.CisloOrg,t.StavDod=tcoe._stav_dodavatele,t.Hodnota=tdz.SumaKcBezDPH,t.Blokace_platby=tdze._blokace_platby,
t.Datum_Od=tdze._datum_od,t.Zamestnanec=tdze._zamestnanec,t.Pozn='Reklamace '+CONVERT(NVARCHAR(3),tdzNesh.RadaDokladu)+'/'+CONVERT(NVARCHAR(15),tdzNesh.PoradoveCislo)
FROM #TabNeshodyFAP t
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=t.IDFap
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabDokladyZbozi tdzNesh ON tdzNesh.ID=t.IDNesh

DELETE FROM #TabNeshodyFAP WHERE IDFap IS NULL

SELECT IDFap,StavDod,Hodnota,Blokace_platby,Pozn
FROM #TabNeshodyFAP
GROUP BY IDFap,StavDod,Hodnota,Blokace_platby,Pozn

/*
MERGE TabDokladyZbozi AS TARGET
USING #TabNeshodyFAP AS SOURCE
ON TARGET.ID=SOURCE.IDFap
WHEN MATCHED AND TARGET.DruhPohybuZbo=18 AND ((SOURCE.StavDod=N'Schválený' AND SOURCE.Hodnota>2000.00) OR (SOURCE.StavDod<>N'Schválený') OR (SOURCE.StavDod IS NULL)) THEN
UPDATE SET TARGET.Poznamka=CAST((ISNULL(CAST(TARGET.Poznamka AS NVARCHAR(MAX)),'') +'
'+ SOURCE.Pozn) AS NTEXT);
*/

MERGE TabDokladyZbozi_EXT AS TARGET
USING (SELECT IDFap,StavDod,Hodnota,Blokace_platby,Pozn FROM #TabNeshodyFAP GROUP BY IDFap,StavDod,Hodnota,Blokace_platby,Pozn) AS SOURCE
ON TARGET.ID=SOURCE.IDFap
WHEN MATCHED AND ((SOURCE.StavDod=N'Schválený' AND SOURCE.Hodnota>1000.00) OR (SOURCE.StavDod<>N'Schválený') OR (SOURCE.StavDod IS NULL)) AND (ISNULL(SOURCE.Blokace_platby,0)=0) THEN
UPDATE SET TARGET._blokace_platby=1,TARGET._datum_od=GETDATE(),TARGET._zamestnanec='ROBOT',TARGET._poznamka_blokace=CAST((ISNULL(CAST(TARGET._poznamka_blokace AS NVARCHAR(MAX)),'') +'
'+ SOURCE.Pozn) AS NTEXT)
WHEN NOT MATCHED BY TARGET AND SOURCE.IDFap IS NOT NULL THEN
INSERT (ID,_blokace_platby,_datum_od,_zamestnanec)
VALUES (SOURCE.IDFap,1,GETDATE(),'ROBOT')
;
GO

