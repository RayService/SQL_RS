USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaDochazky]    Script Date: 30.06.2025 8:55:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaDochazky]
AS
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#TabPruchod') IS NOT NULL DROP TABLE #TabPruchod
CREATE TABLE #TabPruchod (ID INT IDENTITY(1,1) NOT NULL, IDPruchod INT, DatumACasPruchodu DATETIME, DatumPruchodu DATE, DatumACasPredchPruchodu DATETIME, DobaHod NUMERIC(5,2), OdpracDobaMin INT, TypPruchodu INT, CisloVztah INT, Prichod BIT, CisloZam INT)

IF OBJECT_ID('tempdb..#TabPruchodUpr') IS NOT NULL DROP TABLE #TabPruchodUpr
CREATE TABLE #TabPruchodUpr (ID INT IDENTITY(1,1) NOT NULL, DatumDochazky DATE, DatumPrichod DATETIME, DatumOdchod DATETIME, CasZDochazky NUMERIC(5,2), CisloVztah INT)

IF OBJECT_ID('tempdb..#TabPruchodUprII') IS NOT NULL DROP TABLE #TabPruchodUprII
CREATE TABLE #TabPruchodUprII (ID INT IDENTITY(1,1) NOT NULL, DatumDochazky DATE, DatumPrichod DATETIME, DatumOdchod DATETIME, CasZDochazky NUMERIC(5,2), CisloVztah INT)


INSERT INTO #TabPruchod (IDPruchod, DatumACasPruchodu, DatumPruchodu, DatumACasPredchPruchodu, OdpracDobaMin, TypPruchodu, CisloVztah, Prichod, CisloZam)
SELECT
pru.dpuIDDochazkaPruchodUpraveny AS IDPruchod
,CONVERT(DATETIME,pru.dpuDatumACas) AS DatumACasPruchodu
,CONVERT(DATE,pru.dpuDatumACas) AS DatumPruchodu
,LAG(CONVERT(DATETIME,pru.dpuDatumACas)) OVER (PARTITION BY ov.ov_CisloVztahu, CONVERT(DATE,pru.dpuDatumACas) ORDER BY pru.dpuDatumACas ASC) AS DatumACasPredchPruchodu
,DATEDIFF(MINUTE,LAG(CONVERT(DATETIME,pru.dpuDatumACas)) OVER (PARTITION BY ov.ov_CisloVztahu, CONVERT(DATE,pru.dpuDatumACas) ORDER BY pru.dpuDatumACas ASC),CONVERT(DATETIME,pru.dpuDatumACas)) OdpracDobaMin
,pru.dpuIDTypPruchodu AS TypPruchodu
,ov.ov_CisloVztahu AS CisloVztah
,tp.tp_Prichod AS Prichod
,tcz.Cislo AS CisloZam
FROM DOCHAZKASQL.DC3.dbo.DochazkaPruchodUpraveny pru
INNER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztah ov ON ov.ov_IDZakaznik=pru.dpuIDZakaznik AND ov.ov_IDOsobaVztah=pru.dpuIDOsobaVztah
INNER JOIN DOCHAZKASQL.DC3.dbo.Osoba os ON ov.ov_IDZakaznik = os.osoIDZakaznik AND ov.ov_IDOsoba = os.osoIDOsoba
LEFT OUTER JOIN DOCHAZKASQL.DC3.dbo.TypPruchodu tp ON tp.tp_IDTypPruchodu=pru.dpuIDTypPruchodu
LEFT OUTER JOIN RayService.dbo.TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=ov.ov_CisloVztahu
WHERE pru.dpuIgnorovat=0
--AND ov.ov_CisloVztahu=600
AND CONVERT(DATE,pru.dpuDatumACas)<CONVERT(DATE,GETDATE()-1)
--AND CONVERT(DATE,pru.dpuDatumACas)>='2025-01-01'
--cvičně dávám od 1.5.2025
AND CONVERT(DATE,pru.dpuDatumACas)>='2025-05-01'

DELETE FROM #TabPruchod WHERE CisloVztah IN (SELECT DISTINCT tcz.Cislo
											FROM TabZamMzd
											LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=TabZamMzd.ZamestnanecId
											WHERE (TabZamMzd.IdObdobi=(SELECT ID FROM TabMzdObd WHERE Rok=DATEPART(YEAR,GETDATE()) AND Mesic=DATEPART(MONTH,GETDATE())))
											AND(TabZamMzd.DruhMzdyMesHod=0)AND(TabZamMzd.StavES<>3)
											AND(tcz.Zakazka<>'Prakovce')
											)

DELETE FROM #TabPruchod WHERE CisloZam IS NULL

UPDATE #TabPruchod SET DobaHod=ROUND(CONVERT(NUMERIC(19,6),OdpracDobaMin)/60,2) WHERE OdpracDobaMin IS NOT NULL

DELETE FROM #TabPruchod WHERE Prichod=1

--SELECT *
--FROM #TabPruchod
--WHERE CisloVztah=999693

INSERT INTO #TabPruchodUpr (DatumDochazky, DatumOdchod, DatumPrichod, CasZDochazky, CisloVztah)
SELECT
DatumPruchodu AS DatumDochazky,
MAX(DatumACasPruchodu) OVER (PARTITION BY DatumPruchodu, CisloVztah) AS DatumOdchod,
MIN(DatumACasPredchPruchodu) OVER (PARTITION BY DatumPruchodu, CisloVztah) AS DatumPrichod,
SUM(DobaHod) OVER (PARTITION BY DatumPruchodu, CisloVztah) AS CasZDochazky,
CisloVztah
FROM #TabPruchod
--WHERE --CisloVztah=600 AND
--DATEPART(YEAR,DatumPruchodu)=DATEPART(YEAR,GETDATE())
--AND DATEPART(MONTH,DatumPruchodu)=5
ORDER BY CisloVztah ASC, DatumPruchodu ASC, DatumACasPruchodu ASC

--SELECT *
--FROM #TabPruchodUpr

INSERT INTO #TabPruchodUprII (DatumDochazky, DatumPrichod, DatumOdchod, CasZDochazky, CisloVztah)
SELECT
DatumDochazky AS DatumDochazky,
MIN(DatumPrichod) AS DatumPrichod,
MAX(DatumOdchod) AS DatumOdchod,
MIN(CasZDochazky) AS CasZDochazky,
CisloVztah AS CisloVztah
FROM #TabPruchodUpr
GROUP BY CisloVztah, DatumDochazky

--SELECT *
--FROM #TabPruchodUprII
--ORDER BY CisloVztah ASC

--nejprve vymažeme tabulku Tabx_RS_KontrolaDochazky
TRUNCATE TABLE Tabx_RS_KontrolaDochazky

MERGE RayService.dbo.Tabx_RS_KontrolaDochazky AS TARGET
USING #TabPruchodUprII AS SOURCE
ON TARGET.Cislo=SOURCE.CisloVztah AND TARGET.DatumDochazky=SOURCE.DatumDochazky AND TARGET.DatumOdchod=SOURCE.DatumOdchod AND TARGET.DatumPrichod=SOURCE.DatumPrichod
WHEN MATCHED THEN UPDATE SET
TARGET.CasZDochazky=SOURCE.CasZDochazky
WHEN NOT MATCHED BY TARGET THEN
INSERT (Cislo, DatumDochazky, DatumOdchod, DatumPrichod, CasZDochazky)
VALUES (CisloVztah, DatumDochazky, DatumOdchod, DatumPrichod, CasZDochazky)
;

--úprava o přestávky
UPDATE Tabx_RS_KontrolaDochazky SET CasZDochazky=CASE WHEN CasZDochazky>6.00 THEN CasZDochazky-0.5 WHEN CasZDochazky=0.0 THEN 0.0 ELSE CasZDochazky-0.17 END

--odpracovaná doba
IF OBJECT_ID('tempdb..#TabOdpracDoba') IS NOT NULL DROP TABLE #TabOdpracDoba
CREATE TABLE #TabOdpracDoba (ID INT IDENTITY(1,1) NOT NULL, DatumDochazky DATETIME, OdpracDobaHod NUMERIC(19,2), CisloZam INT, FirstZahajeni DATETIME, LastUkonceni DATETIME)

INSERT INTO #TabOdpracDoba (DatumDochazky,CisloZam,OdpracDobaHod,FirstZahajeni,LastUkonceni)
SELECT tpmz.datum_X AS DatumDochazky,
tcz.Cislo AS CisloZam,
ROUND(SUM(tpmz.Sk_cas_Obsluhy_H),2) AS OdpracDobaHod,
MIN(tpmz.DatumZahajeniOp) AS FirstZahajeni,-- OVER (PARTITION BY tcz.Cislo, tpmz.datum_x) AS FirstZahajeni,
MAX(tpmz.DatumUkonceniOp) AS LastUkonceni-- OVER (PARTITION BY tcz.Cislo, tpmz.datum_x) AS LastUkonceni
FROM TabPrikazMzdyAZmetky tpmz WITH(NOLOCK)
LEFT OUTER JOIN TabCisZam tcz WITH(NOLOCK) ON tpmz.Zamestnanec=tcz.ID
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=tpmz.IDPrikaz
LEFT OUTER JOIN TabPrPostup prp WITH(NOLOCK) ON tpmz.IDPrikaz=prp.IDPrikaz AND tpmz.DokladPrPostup=prp.Doklad AND tpmz.AltPrPostup=prp.Alt AND prp.IDOdchylkyDo IS NULL
WHERE
(tpmz.TypMzdy<>2)AND
--(tcz.Cislo=600)AND
(tpmz.datum_X>='2025-05-01')AND
(tpmz.datum_X<GETDATE()-1)
GROUP BY tcz.Cislo, tpmz.datum_X

--SELECT *
--FROM #TabOdpracDoba

MERGE RayService.dbo.Tabx_RS_KontrolaDochazky AS TARGET
USING #TabOdpracDoba AS SOURCE
ON TARGET.Cislo=SOURCE.CisloZam AND TARGET.DatumDochazky=SOURCE.DatumDochazky
WHEN MATCHED THEN UPDATE SET
TARGET.OdpracDobaHod=SOURCE.OdpracDobaHod,TARGET.FirstZahajeni=SOURCE.FirstZahajeni,TARGET.LastUkonceni=SOURCE.LastUkonceni
WHEN NOT MATCHED BY TARGET THEN
INSERT (Cislo, DatumDochazky, OdpracDobaHod,FirstZahajeni,LastUkonceni)
VALUES (CisloZam, DatumDochazky,OdpracDobaHod,FirstZahajeni,LastUkonceni)
;
GO

