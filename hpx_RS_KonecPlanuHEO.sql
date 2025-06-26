USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KonecPlanuHEO]    Script Date: 26.06.2025 16:04:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KonecPlanuHEO]
AS
SET NOCOUNT ON;
--toto spustit jako proceduru
--naplánovat do JOBu po ranním uložení JAGGINGu

IF OBJECT_ID('tempdb..#JAG') IS NOT NULL DROP TABLE #JAG
CREATE TABLE #JAG (ID INT IDENTITY(1,1) NOT NULL, IDJag INT NOT NULL, ID_Materialu NVARCHAR(100) NOT NULL, IDKmenZbozi INT, Suma_potreb NUMERIC(19,6), Suma_NO NUMERIC(19,6), Suma_NNO NUMERIC(19,6), Alokovano NUMERIC(19,6), LPST DATETIME)
INSERT INTO #JAG (IDJag, ID_Materialu, Suma_potreb, Suma_NO, Suma_NNO, Alokovano, LPST)
SELECT jag.ID, jag.ID_Materialu, ISNULL(jag.Suma_Potreb,0), ISNULL(jag.Suma_NO,0), ISNULL(jag.Suma_NNO,0), ISNULL(jag.Alokovano,0), jag.LPST
FROM RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERJAGGING jag
WHERE jag.ID_Materialu IS NOT NULL

UPDATE  jag SET jag.IDKmenZbozi=tkz.ID
FROM #JAG jag
LEFT OUTER JOIN RayService.dbo.TabKmenZbozi tkz ON tkz.SkupZbo=LEFT(jag.ID_Materialu,3) AND tkz.RegCis=RIGHT(jag.ID_Materialu, CHARINDEX('|',REVERSE(jag.ID_Materialu))-1)

--tady by chtělo doplnit #JAGImp o kmenové karty, které nejsou v JAGGINGu
MERGE #JAG AS TARGET
USING TabKmenZbozi AS SOURCE
ON TARGET.IDKmenZbozi=SOURCE.ID
WHEN NOT MATCHED BY TARGET THEN
INSERT (IDJag, ID_Materialu, IDKmenZbozi,Suma_potreb, Suma_NO, Suma_NNO, Alokovano)
VALUES (0, 0, SOURCE.ID, 0, 0, 0, 0);

--SELECT *
--FROM #JAG
--WHERE IDKmenZbozi=225421
--ORDER BY ID_Materialu ASC, LPST ASC

--bere se jeden řádek výskytu pro kmenovou kartu a suma pro alokováno
IF OBJECT_ID('tempdb..#JAGImp') IS NOT NULL DROP TABLE #JAGImp
CREATE TABLE #JAGImp (ID INT IDENTITY(1,1) NOT NULL, IDKmenZbozi INT, Suma_potreb NUMERIC(19,6), Suma_NO NUMERIC(19,6), Suma_NNO NUMERIC(19,6), SumaAlokovano NUMERIC(19,6), Disponibilita NUMERIC(19,6))
INSERT INTO #JAGImp (IDKmenZbozi, Suma_potreb, Suma_NO, Suma_NNO, SumaAlokovano, Disponibilita)
SELECT 
DISTINCT IDKmenZbozi,
MAX(Suma_potreb) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
MAX(Suma_NO) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
MAX(Suma_NNO) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
SUM(Alokovano) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
NULL	--disponibilita, tu pak spočítám dále
FROM #JAG
ORDER BY IDKmenZbozi ASC

--SELECT *
--FROM #JAGImp
--WHERE IDKmenZbozi=225421

--do disponibility doplnit množství po příjmu skladu 100, pokud položka má disponibilitu IS NULL
	--MŽ, 6.2.2025 na přání MM změněno z Množstí po příjmu na Množství k dispozici po příjmu a po výdeji
MERGE #JAGImp AS TARGET
USING TabStavSkladu AS SOURCE
ON TARGET.IDKmenZbozi=SOURCE.IDKmenZbozi AND SOURCE.IDSklad='100'
WHEN MATCHED AND TARGET.Disponibilita IS NULL THEN
UPDATE SET TARGET.Disponibilita=SOURCE.MnozDispoSPrijBezVyd
;

--pokud nějaká položka není skladem 100, doplnit nulu
UPDATE #JAGImp SET Disponibilita=0 WHERE Disponibilita IS NULL

--SELECT *
--FROM #JAGImp
--WHERE IDKmenZbozi=225421

--Disponibilní množství 16 týdnů: bere se suma všech výskytů za kmenovou kartu
--Množství po příjmu – (Blokováno pro výrobu + Rezervováno + součet údaje Alokováno z JAGGINGu pro danou položku materiálu, kde LPST je ode dneška (včetně) plus 90 dní + počet týdnů dodání výrobce z kmenové karty (ve dnech))
IF OBJECT_ID('tempdb..#JAGDisp') IS NOT NULL DROP TABLE #JAGDisp
CREATE TABLE #JAGDisp (ID INT IDENTITY(1,1) NOT NULL, IDKmenZbozi INT, Alokace NUMERIC(19,6), Disponibilita NUMERIC(19,6))
INSERT INTO #JAGDisp (IDKmenZbozi, Alokace, Disponibilita)
SELECT 
DISTINCT jag.IDKmenZbozi,
SUM(jag.Alokovano) OVER(PARTITION BY jag.IDKmenZbozi ORDER BY jag.IDKmenZbozi),
tss.MnozDispoSPrijBezVyd-(pkz.BlokovanoProVyrobu)	--MŽ, 6.2.2025 na přání MM změněno z Množstí po příjmu na Množství k dispozici po příjmu a po výdeji
FROM #JAG jag
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=jag.IDKmenZbozi
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabParametryKmeneZbozi pkz ON pkz.IDKmenZbozi=tkz.ID
WHERE jag.LPST<=GETDATE()+91+tkze._EXT_RS_DodaciLhutaTydnyVyrobce*7
ORDER BY IDKmenZbozi ASC

--update Disponibility podle Množství po příjmu – (Blokováno pro výrobu + Rezervováno + součet údaje Alokováno z JAGGINGu pro danou položku materiálu, kde LPST je ode dneška (včetně) plus 90 dní + počet týdnů dodání výrobce z kmenové karty (ve dnech))
MERGE #JAGImp AS TARGET
USING #JAGDisp AS SOURCE
ON TARGET.IDKmenZbozi=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET.Disponibilita=ISNULL(SOURCE.Disponibilita,0)-ISNULL(SOURCE.Alokace,0);

--SELECT *
--FROM #JAGImp
--WHERE IDKmenZbozi=225421

--nejprve promažeme stará data
UPDATE TabKmenZbozi_EXT SET _EXT_RS_SumaNOLPP=0, _EXT_RS_SumaPotrebLPP=0, _EXT_RS_SumaNavrhuNOLPP=0, _EXT_RS_MnozstviPlanovanaVyrobaLPP=0, _EXT_RS_DisponibilniMnoLPP=0

--suma potřeb
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_SumaNOLPP=ISNULL(SOURCE.Suma_NO,0)--, TARGET._EXT_RS_SumaNavrhuNOLPP=SOURCE.Suma_NNO
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_SumaPotrebLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Suma_NO);

--suma NO
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_SumaPotrebLPP=SOURCE.Suma_potreb--, TARGET._EXT_RS_SumaNOLPP=SOURCE.Suma_NO, TARGET._EXT_RS_SumaNavrhuNOLPP=SOURCE.Suma_NNO
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_SumaPotrebLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Suma_potreb);

--suma NNO
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_SumaNavrhuNOLPP=SOURCE.Suma_NNO
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_SumaPotrebLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Suma_NNO);

--Množství - plánovaná výroba LPP: bere se suma všech výskytů za kmenovou kartu
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_MnozstviPlanovanaVyrobaLPP=ISNULL(SOURCE.SumaAlokovano,0)
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_MnozstviPlanovanaVyrobaLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.SumaAlokovano);

--Disponibilní množství 16 týdnů: bere se suma všech výskytů za kmenovou kartu
--Množství - plánovaná výroba LPP: bere se suma všech výskytů za kmenovou kartu
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_DisponibilniMnoLPP=ISNULL(SOURCE.Disponibilita,0)
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_DisponibilniMnoLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Disponibilita);

--původně bylo:
/*
IF OBJECT_ID('tempdb..#JAG') IS NOT NULL DROP TABLE #JAG
CREATE TABLE #JAG (ID INT IDENTITY(1,1) NOT NULL, IDJag INT NOT NULL, ID_Materialu NVARCHAR(100) NOT NULL, IDKmenZbozi INT, Suma_potreb NUMERIC(19,6), Suma_NO NUMERIC(19,6), Suma_NNO NUMERIC(19,6), Alokovano NUMERIC(19,6), LPST DATETIME)
INSERT INTO #JAG (IDJag, ID_Materialu, Suma_potreb, Suma_NO, Suma_NNO, Alokovano, LPST)
SELECT jag.ID, jag.ID_Materialu, ISNULL(jag.Suma_Potreb,0), ISNULL(jag.Suma_NO,0), ISNULL(jag.Suma_NNO,0), ISNULL(jag.Alokovano,0), jag.LPST
FROM RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERJAGGING jag
WHERE jag.ID_Materialu IS NOT NULL

UPDATE  jag SET jag.IDKmenZbozi=tkz.ID
FROM #JAG jag
LEFT OUTER JOIN RayService.dbo.TabKmenZbozi tkz ON tkz.SkupZbo=LEFT(jag.ID_Materialu,3) AND tkz.RegCis=RIGHT(jag.ID_Materialu, CHARINDEX('|',REVERSE(jag.ID_Materialu))-1)

--SELECT *
--FROM #JAG
--WHERE IDKmenZbozi=4889
--ORDER BY ID_Materialu ASC, LPST ASC

--bere se jeden řádek výskytu pro kmenovou kartu a suma pro alokováno
IF OBJECT_ID('tempdb..#JAGImp') IS NOT NULL DROP TABLE #JAGImp
CREATE TABLE #JAGImp (ID INT IDENTITY(1,1) NOT NULL, IDKmenZbozi INT, Suma_potreb NUMERIC(19,6), Suma_NO NUMERIC(19,6), Suma_NNO NUMERIC(19,6), SumaAlokovano NUMERIC(19,6), Disponibilita NUMERIC(19,6))
INSERT INTO #JAGImp (IDKmenZbozi, Suma_potreb, Suma_NO, Suma_NNO, SumaAlokovano, Disponibilita)
SELECT 
DISTINCT IDKmenZbozi,
MAX(Suma_potreb) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
MAX(Suma_NO) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
MAX(Suma_NNO) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
SUM(Alokovano) OVER(PARTITION BY IDKmenZbozi ORDER BY IDKmenZbozi),
0	--disponibilita, tu pak spočítám dále
FROM #JAG
ORDER BY IDKmenZbozi ASC

--Disponibilní množství 16 týdnů: bere se suma všech výskytů za kmenovou kartu
--Množství po příjmu – (Blokováno pro výrobu + Rezervováno + součet údaje Alokováno z JAGGINGu pro danou položku materiálu, kde LPST je ode dneška (včetně) plus 90 dní + počet týdnů dodání výrobce z kmenové karty (ve dnech))
IF OBJECT_ID('tempdb..#JAGDisp') IS NOT NULL DROP TABLE #JAGDisp
CREATE TABLE #JAGDisp (ID INT IDENTITY(1,1) NOT NULL, IDKmenZbozi INT, Alokace NUMERIC(19,6), Disponibilita NUMERIC(19,6))
INSERT INTO #JAGDisp (IDKmenZbozi, Alokace, Disponibilita)
SELECT 
DISTINCT jag.IDKmenZbozi,
SUM(jag.Alokovano) OVER(PARTITION BY jag.IDKmenZbozi ORDER BY jag.IDKmenZbozi),
tss.MnozSPrij-(pkz.BlokovanoProVyrobu+tss.Rezervace)
FROM #JAG jag
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=jag.IDKmenZbozi
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabParametryKmeneZbozi pkz ON pkz.IDKmenZbozi=tkz.ID
WHERE jag.LPST<=GETDATE()+91+tkze._EXT_RS_DodaciLhutaTydnyVyrobce*7
ORDER BY IDKmenZbozi ASC

--SELECT *
--FROM #JAGDisp
--WHERE IDKmenZbozi=4889

--update Disponibility podle Množství po příjmu – (Blokováno pro výrobu + Rezervováno + součet údaje Alokováno z JAGGINGu pro danou položku materiálu, kde LPST je ode dneška (včetně) plus 90 dní + počet týdnů dodání výrobce z kmenové karty (ve dnech))
MERGE #JAGImp AS TARGET
USING #JAGDisp AS SOURCE
ON TARGET.IDKmenZbozi=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET.Disponibilita=SOURCE.Disponibilita-SOURCE.Alokace;

--SELECT *
--FROM #JAGImp
--WHERE IDKmenZbozi=4889

--nejprve promažeme stará data
UPDATE TabKmenZbozi_EXT SET _EXT_RS_SumaNOLPP=0, _EXT_RS_SumaPotrebLPP=0, _EXT_RS_SumaNavrhuNOLPP=0, _EXT_RS_MnozstviPlanovanaVyrobaLPP=0, _EXT_RS_DisponibilniMnoLPP=0

--suma potřeb
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_SumaNOLPP=SOURCE.Suma_NO--, TARGET._EXT_RS_SumaNavrhuNOLPP=SOURCE.Suma_NNO
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_SumaPotrebLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Suma_NO);

--suma NO
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_SumaPotrebLPP=SOURCE.Suma_potreb--, TARGET._EXT_RS_SumaNOLPP=SOURCE.Suma_NO, TARGET._EXT_RS_SumaNavrhuNOLPP=SOURCE.Suma_NNO
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_SumaPotrebLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Suma_potreb);

--suma NNO
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_SumaNavrhuNOLPP=SOURCE.Suma_NNO
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_SumaPotrebLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Suma_NNO);

--Množství - plánovaná výroba LPP: bere se suma všech výskytů za kmenovou kartu
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_MnozstviPlanovanaVyrobaLPP=SOURCE.SumaAlokovano
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_MnozstviPlanovanaVyrobaLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.SumaAlokovano);


--Disponibilní množství 16 týdnů: bere se suma všech výskytů za kmenovou kartu
--Množství - plánovaná výroba LPP: bere se suma všech výskytů za kmenovou kartu
MERGE RayService.dbo.TabKmenZbozi_EXT AS TARGET
USING #JAGImp AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN UPDATE
SET TARGET._EXT_RS_DisponibilniMnoLPP=SOURCE.Disponibilita
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_DisponibilniMnoLPP)
VALUES (SOURCE.IDKmenZbozi,SOURCE.Disponibilita);


--SELECT tkz.ID,tkze._EXT_RS_DisponibilniMnoLPP AS Disponibilita,pkz.BlokovanoProVyrobu AS BlokovanoProVyrobu,tss.MnozSPrij AS MnozstviPoPrijmu,tss.Rezervace AS Rezervovano,tkze._EXT_RS_DodaciLhutaTydnyVyrobce*7 AS LhutaDodavatelDny
--FROM TabKmenZbozi tkz
--LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
--LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID
--LEFT OUTER JOIN TabParametryKmeneZbozi pkz ON pkz.IDKmenZbozi=tkz.ID
--WHERE tkz.ID=4889

*/
GO

