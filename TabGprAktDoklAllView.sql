USE [RayService]
GO

/****** Object:  View [dbo].[TabGprAktDoklAllView]    Script Date: 04.07.2025 11:06:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprAktDoklAllView] AS
SELECT NULL as QMSAgenda, NULL AS IDKonJed, NULL AS IDPokladna, ID AS IDDokZbo, 
NULL AS IDDObj, NULL AS GUIDDObj, DruhPohybuZbo, CONVERT(NVARCHAR(17),REPLICATE('0', 6-LEN(CONVERT(NVARCHAR(17),PoradoveCislo)))+CONVERT(NVARCHAR(17),PoradoveCislo)) AS PoradoveCislo, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeniSkut))) AS DatumPorizeni, CisloOrg, MistoUrceni, CONVERT(BIT,CASE WHEN (DatRealizace IS NULL) THEN 0 ELSE 1 END) AS Realizovano, CONVERT(BIT,CASE WHEN (DatUctovani IS NULL) THEN 0 ELSE 1 END) AS Uctovano, (SELECT ID FROM TabStrom WHERE Cislo=TabDokladyZbozi.IDSklad) AS IDSklad, (SELECT ID FROM TabNakladovyOkruh WHERE Cislo=TabDokladyZbozi.NOkruhCislo) AS IDNOkruh,(SELECT ID FROM TabCisZam WHERE Cislo=TabDokladyZbozi.CisloZam) AS IDZam, KontaktZam AS IDKontaktZam, KontaktOsoba AS IDKontaktOsoba,CONVERT(TINYINT,0) AS DruhDosleObj, RadaDokladu, CisloZakazky
FROM TabDokladyZbozi
WHERE PoradoveCislo>=0
UNION ALL
SELECT NULL as QMSAgenda, NULL AS IDKonJed, NULL AS IDPokladna, NULL AS IDDokZbo, ID AS IDDObj, GUIDDokladu AS GUIDDObj, CONVERT(TINYINT,53) AS DruhPohybuZbo, Cislo AS PoradoveCislo,CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPripadu))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPorizeni, CisloOrg, MistoUrceni, NULL AS Realizovano, NULL AS Uctovano,IDSklad, IDNOkruh, IDZam, IDKontaktZam, IDKontaktOsoba,CONVERT(TINYINT,2) AS DruhDosleObj, Rada AS RadaDokladu, (SELECT CisloZakazky FROM TabZakazka WHERE ID=TabDosleObjH02.IDZakazka) AS CisloZakazky
FROM TabDosleObjH02
UNION ALL
SELECT NULL as QMSAgenda, NULL AS IDKonJed, NULL AS IDPokladna, NULL AS IDDokZbo, ID AS IDDObj, GUIDDokladu AS GUIDDObj, CONVERT(TINYINT,53) AS DruhPohybuZbo, Cislo AS PoradoveCislo,CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPripadu))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPorizeni, CisloOrg, MistoUrceni, NULL AS Realizovano, NULL AS Uctovano,IDSklad, IDNOkruh, IDZam, IDKontaktZam, IDKontaktOsoba,CONVERT(TINYINT,1) AS DruhDosleObj, Rada AS RadaDokladu, (SELECT CisloZakazky FROM TabZakazka WHERE ID=TabDosleObjH01.IDZakazka) AS CisloZakazky
FROM TabDosleObjH01
UNION ALL
SELECT NULL as QMSAgenda, NULL AS IDKonJed, NULL AS IDPokladna, NULL AS IDDokZbo, ID AS IDDObj, GUIDDokladu AS GUIDDObj, CONVERT(TINYINT,53) AS DruhPohybuZbo, Cislo AS PoradoveCislo,CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPripadu))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPorizeni, CisloOrg, MistoUrceni, NULL AS Realizovano, NULL AS Uctovano,IDSklad, IDNOkruh, IDZam, IDKontaktZam, IDKontaktOsoba,CONVERT(TINYINT,3) AS DruhDosleObj, Rada AS RadaDokladu, (SELECT CisloZakazky FROM TabZakazka WHERE ID=TabDosleObjH03.IDZakazka) AS CisloZakazky
FROM TabDosleObjH03
UNION ALL
SELECT CONVERT(TINYINT, kkj.QMSAgenda,2) as QMSAgenda, TabKontaktJednani.ID AS IDKonJed, NULL AS IDPokladna, NULL AS IDDokZbo, NULL AS IDDObj, NULL AS GUIDDObj, NULL AS DruhPohybuZbo, 
CONVERT(NVARCHAR(17),REPLICATE('0', 6-LEN(CONVERT(NVARCHAR(17),TabKontaktJednani.PoradoveCislo)))+CONVERT(NVARCHAR(17),TabKontaktJednani.PoradoveCislo)) AS PoradoveCislo, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,TabKontaktJednani.DatPorizeni))) AS DatumPripadu, NULL AS DatumPorizeni, TabKontaktJednani.CisloOrg, TabKontaktJednani.MistoUrceni, NULL AS Realizovano, convert(bit, 0) AS Uctovano, NULL AS IDSklad, NULL AS IDNOkruh,NULL AS IDZam, NULL AS IDKontaktZam, NULL AS IDKontaktOsoba,CONVERT(TINYINT,0) AS DruhDosleObj, TabKontaktJednani.Kategorie as  RadaDokladu, TabKontaktJednani.CisloZakazky
FROM TabKontaktJednani
LEFT JOIN TabKategKontJed kkj on kkj.Cislo=TabKontaktJednani.Kategorie
WHERE EXISTS(SELECT * FROM TabKategKontJed KTG WHERE TabKontaktJednani.Kategorie=KTG.Cislo AND (KTG.QMSAgenda IS NULL OR KTG.QMSAgenda in (2,3,9,11)))
      AND TabKontaktJednani.Kategorie IN  
(
SELECT kj.Cislo
FROM TabKategKontJed kj
WHERE
(((EXISTS(
SELECT*FROM TabPravaKategorieKJ p WHERE p.CisloKategKJ=kj.Cislo 
AND p.LoginName=SUSER_SNAME() AND p.ReadOnly<>2) 
OR ( NOT EXISTS(SELECT*FROM TabPravaKategorieKJ p WHERE p.CisloKategKJ=kj.Cislo AND p.LoginName=SUSER_SNAME()) 
     AND ( NOT EXISTS(SELECT*FROM TabPravaKategorieKJ p JOIN TabRoleUzivView u ON u.IDRole=p.IDRole WHERE p.CisloKategKJ=kj.Cislo 
     AND u.LoginName=SUSER_SNAME()) 
     OR EXISTS(SELECT*FROM TabPravaKategorieKJ p JOIN TabRoleUzivView u ON u.IDRole=p.IDRole WHERE p.CisloKategKJ=kj.Cislo 
     AND u.LoginName=SUSER_SNAME() AND p.ReadOnly<>2)))))
     )
)
UNION ALL
SELECT NULL as QMSAgenda, NULL AS IDKonJed, ID AS IDPokladna, NULL AS IDDokZbo, NULL AS IDDObj, NULL AS GUIDDObj, 
DruhPohybuZbo = null  /*TypDokladu*/, CONVERT(NVARCHAR(17),REPLICATE('0', 6-LEN(CONVERT(NVARCHAR(17),PoradoveCislo)))+CONVERT(NVARCHAR(17),PoradoveCislo)) AS PoradoveCislo, 
CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPripadu, NULL AS DatumPorizeni, CisloOrg, NULL AS MistoUrceni, NULL /*CONVERT(BIT,CASE WHEN (DatRealizace IS NULL) THEN 0 ELSE 1 END) AS Realizovano*/, CONVERT(BIT,CASE WHEN (DatUctovani IS NULL) THEN 0 ELSE 1 END) AS Uctovano, 

(SELECT ID FROM TabStrom WHERE Cislo=TabPokladna.IDSklad) AS IDSklad, (SELECT ID FROM TabNakladovyOkruh WHERE TabPokladna.CisloNakladovyOkruh = Cislo) AS IDNOkruh,
(SELECT ID FROM TabCisZam WHERE Cislo=TabPokladna.CisloZam) AS IDZam, NULL AS IDKontaktZam, KontaktOsoba AS IDKontaktOsoba,

CONVERT(TINYINT,0) AS DruhDosleObj, RadaDokladu = TabPokladna.RadaDokladuPokl, 
CisloZakazky
FROM TabPokladna
WHERE Modul=0
GO

