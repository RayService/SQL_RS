USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NeaktivniOrgNastaveni]    Script Date: 26.06.2025 13:25:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NeaktivniOrgNastaveni]
AS
IF OBJECT_ID('tempdb..#NeaktivniOrg') IS NOT NULL DROP TABLE #NeaktivniOrg
CREATE TABLE #NeaktivniOrg (ID INT IDENTITY(1,1),IDOrg INT, CisloOrg INT,Nazev NVARCHAR(255),DruhyNazev NVARCHAR(100), Misto NVARCHAR(100), LastDatum DATE, Stav NVARCHAR(15))

;WITH LastDoklad AS (
SELECT tdz.ID,tdz.RadaDokladu,tdz.PoradoveCislo,tdz.Cislo,tdz.CisloOrg,tdz.DatPorizeni,tco.ID AS IDOrg,tcoe._stav_dodavatele, ROW_NUMBER() OVER (PARTITION BY tdz.CisloOrg ORDER BY tdz.DatPorizeni DESC) AS rn
FROM TabCisOrg tco WITH(NOLOCK)
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
WHERE
(tdz.PoradoveCislo>=0)AND(tdz.DruhPohybuZbo=18)AND(tco.JeDodavatel=1)--AND(tco.CisloOrg=148)
)
INSERT INTO #NeaktivniOrg (IDOrg,CisloOrg,LastDatum,Stav)
SELECT IDOrg,CisloOrg,CONVERT(DATE,DatPorizeni),_stav_dodavatele--, DATEDIFF(DAY,DatPorizeni,GETDATE())
FROM LastDoklad
WHERE rn=1 AND DATEDIFF(DAY,DatPorizeni,GETDATE())>1095

/*
SELECT *
FROM #NeaktivniOrg
*/

MERGE #NeaktivniOrg AS TARGET
USING TabCisOrg AS SOURCE
ON TARGET.CisloOrg=SOURCE.CisloOrg
WHEN MATCHED THEN UPDATE SET TARGET.Nazev=SOURCE.Nazev,TARGET.DruhyNazev=SOURCE.DruhyNazev,TARGET.Misto=SOURCE.Misto
;
/*
SELECT *
FROM #NeaktivniOrg
*/
MERGE TabCisOrg_EXT AS TARGET
USING #NeaktivniOrg AS SOURCE
ON TARGET.ID=SOURCE.IDOrg
WHEN MATCHED THEN
	UPDATE SET TARGET._stav_dodavatele='Neaktivní'
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ID,_stav_dodavatele)
	VALUES(IDOrg,'Neaktivní')
;
GO

