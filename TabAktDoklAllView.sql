USE [RayService]
GO

/****** Object:  View [dbo].[TabAktDoklAllView]    Script Date: 04.07.2025 9:42:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabAktDoklAllView] AS
SELECT ID AS IDDokZbo, NULL AS IDDObj, NULL AS GUIDDObj, DruhPohybuZbo, CONVERT([nvarchar](17), isnull(replicate(N'0',case when [DelkaPorCis] IS NULL then (6) else [DelkaPorCis] end - len([PoradoveCislo])),N'')+CONVERT([nvarchar](11),[PoradoveCislo])) AS PoradoveCislo, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeniSkut))) AS DatumPorizeni, CisloOrg, MistoUrceni, CONVERT(BIT,CASE WHEN (DatRealizace IS NULL) THEN 0 ELSE 1 END) AS Realizovano, CONVERT(BIT,CASE WHEN (DatUctovani IS NULL) THEN 0 ELSE 1 END) AS Uctovano, (SELECT ID FROM TabStrom WHERE Cislo=TabDokladyZbozi.IDSklad) AS IDSklad, (SELECT ID FROM TabNakladovyOkruh WHERE Cislo=TabDokladyZbozi.NOkruhCislo) AS IDNOkruh,(SELECT ID FROM TabCisZam WHERE Cislo=TabDokladyZbozi.CisloZam) AS IDZam, KontaktZam AS IDKontaktZam, KontaktOsoba AS IDKontaktOsoba,CONVERT(TINYINT,0) AS DruhDosleObj, RadaDokladu, CisloZakazky
FROM TabDokladyZbozi
WHERE PoradoveCislo>=0
UNION ALL
SELECT NULL AS IDDokZbo, ID AS IDDObj, GUIDDokladu AS GUIDDObj, CONVERT(TINYINT,53) AS DruhPohybuZbo, Cislo AS PoradoveCislo,CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPripadu))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPorizeni, CisloOrg, MistoUrceni, NULL AS Realizovano, NULL AS Uctovano,IDSklad, IDNOkruh, IDZam, IDKontaktZam, IDKontaktOsoba,CONVERT(TINYINT,2) AS DruhDosleObj, Rada AS RadaDokladu, (SELECT CisloZakazky FROM TabZakazka WHERE ID=TabDosleObjH02.IDZakazka) AS CisloZakazky
FROM TabDosleObjH02
UNION ALL
SELECT NULL AS IDDokZbo, ID AS IDDObj, GUIDDokladu AS GUIDDObj, CONVERT(TINYINT,53) AS DruhPohybuZbo, Cislo AS PoradoveCislo,CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPripadu))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPorizeni, CisloOrg, MistoUrceni, NULL AS Realizovano, NULL AS Uctovano,IDSklad, IDNOkruh, IDZam, IDKontaktZam, IDKontaktOsoba,CONVERT(TINYINT,1) AS DruhDosleObj, Rada AS RadaDokladu, (SELECT CisloZakazky FROM TabZakazka WHERE ID=TabDosleObjH01.IDZakazka) AS CisloZakazky
FROM TabDosleObjH01
UNION ALL
SELECT NULL AS IDDokZbo, ID AS IDDObj, GUIDDokladu AS GUIDDObj, CONVERT(TINYINT,53) AS DruhPohybuZbo, Cislo AS PoradoveCislo,CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPripadu))) AS DatumPripadu, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) AS DatumPorizeni, CisloOrg, MistoUrceni, NULL AS Realizovano, NULL AS Uctovano,IDSklad, IDNOkruh, IDZam, IDKontaktZam, IDKontaktOsoba,CONVERT(TINYINT,3) AS DruhDosleObj, Rada AS RadaDokladu, (SELECT CisloZakazky FROM TabZakazka WHERE ID=TabDosleObjH03.IDZakazka) AS CisloZakazky
FROM TabDosleObjH03
GO

