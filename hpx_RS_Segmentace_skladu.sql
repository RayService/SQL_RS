USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_Segmentace_skladu]    Script Date: 26.06.2025 12:39:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_Segmentace_skladu]
AS

DELETE FROM Tabx_RS_Segmentace
--úvodní insert pro zobrazení
INSERT INTO Tabx_RS_Segmentace (IDStavSkladu,IDKmenZbozi,FinStavSklad)
SELECT tss.ID,tss.IDKmenZbozi,tss.StavSkladu
FROM TabStavSkladu tss
WHERE tss.IDSklad='100'
--dočasná tabule pro plnění řádků
IF OBJECT_ID('tempdb..#TabSegmentace') IS NOT NULL DROP TABLE #TabSegmentace
CREATE TABLE #TabSegmentace (
ID INT IDENTITY(1,1) NOT NULL,
IDStavSkladu INT NOT NULL,
Mnozstvi NUMERIC(19,6) NULL
)

--1.Materiály, které jsou již vydané ve výrobních příkazech ( již nefigurují na stavu skladu 100)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID AS IDSklad, SUM(prkv.Cena_real) AS 'Cena_mat'
FROM TabPrKVazby prkv
LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
GROUP BY prkv.nizsi,tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVydaneVyrPrik=SOURCE.Mnozstvi;

--1elektro.Materiály, které jsou již vydané ve výrobních příkazech ( již nefigurují na stavu skladu 100)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID AS IDSklad, SUM(prkv.Cena_real) AS 'Cena_mat'
FROM TabPrKVazby prkv
LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tp.IDTabKmen
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo IN(830,840))AND(tp.Rada NOT IN (801,802,803))
GROUP BY prkv.nizsi,tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVydaneVyrPrikEle=SOURCE.Mnozstvi;

--1kooperace.Materiály, které jsou již vydané ve výrobních příkazech ( již nefigurují na stavu skladu 100)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID AS IDSklad, SUM(prkv.Cena_real) AS 'Cena_mat'
FROM TabPrKVazby prkv
LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tp.Rada IN (801,802,803))
GROUP BY prkv.nizsi,tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVydaneVyrPrikKoo=SOURCE.Mnozstvi;

--1ostatní.Materiály, které jsou již vydané ve výrobních příkazech ( již nefigurují na stavu skladu 100)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID AS IDSklad, SUM(prkv.Cena_real) AS 'Cena_mat'
FROM TabPrKVazby prkv
LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tp.IDTabKmen
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo NOT IN(830,840))AND(tp.Rada NOT IN (801,802,803))
GROUP BY prkv.nizsi,tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVydaneVyrPrikOst=SOURCE.Mnozstvi;

--2.Materiály, které jsou blokované ve výrobních příkazech
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(prkv.mnoz_Nevydane*ISNULL(tss.Prumer,0)) AS 'Cena_mat'
FROM TabPrKVazby prkv
  LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
  LEFT OUTER JOIN TabStavSkladu tss ON prkv.Sklad=tss.IDSklad AND prkv.nizsi=tss.IDKmenZbozi
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tkz.SkupZbo NOT LIKE N'8%')AND(prkv.Splneno=0)
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatBlokVyrPrik=SOURCE.Mnozstvi;

--2elektro.Materiály, které jsou blokované ve výrobních příkazech
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(prkv.mnoz_Nevydane*ISNULL(tss.Prumer,0)) AS 'Cena_mat'
FROM TabPrKVazby prkv
  LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
  LEFT OUTER JOIN TabStavSkladu tss ON prkv.Sklad=tss.IDSklad AND prkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tp.IDTabKmen
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tkz.SkupZbo NOT LIKE N'8%')AND(prkv.Splneno=0)
AND(tkzv.SkupZbo IN(830,840))AND(tp.Rada NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatBlokVyrPrikEle=SOURCE.Mnozstvi;

--2kooperace.Materiály, které jsou blokované ve výrobních příkazech
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(prkv.mnoz_Nevydane*ISNULL(tss.Prumer,0)) AS 'Cena_mat'
FROM TabPrKVazby prkv
  LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
  LEFT OUTER JOIN TabStavSkladu tss ON prkv.Sklad=tss.IDSklad AND prkv.nizsi=tss.IDKmenZbozi
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tkz.SkupZbo NOT LIKE N'8%')AND(prkv.Splneno=0)
AND(tp.Rada IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatBlokVyrPrikKoo=SOURCE.Mnozstvi;

--2ostatní.Materiály, které jsou blokované ve výrobních příkazech
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(prkv.mnoz_Nevydane*ISNULL(tss.Prumer,0)) AS 'Cena_mat'
FROM TabPrKVazby prkv
  LEFT OUTER JOIN TabKmenZbozi tkz ON prkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPrikaz tp ON prkv.IDPrikaz=tp.ID
  LEFT OUTER JOIN TabStavSkladu tss ON prkv.Sklad=tss.IDSklad AND prkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tp.IDTabKmen
WHERE
(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.Sklad=N'100')AND(tp.StavPrikazu<=40)AND(prkv.RezijniMat=0)AND(tss.ID IS NOT NULL)
AND(tkz.SkupZbo NOT LIKE N'8%')AND(prkv.Splneno=0)
AND(tkzv.SkupZbo NOT IN(830,840))AND(tp.Rada NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatBlokVyrPrikOst=SOURCE.Mnozstvi;


--3.Výrobní plán, materiály, které jsou skladem na dnes + 3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90=SOURCE.Mnozstvi;

--3elektro.Výrobní plán, materiály, které jsou skladem na dnes + 3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tpl.IDTabKmen
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo IN(830,840))AND(ParKmZ.RadaVyrPrikazu NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90Ele=SOURCE.Mnozstvi;

--3kooperace.Výrobní plán, materiály, které jsou skladem na dnes + 3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
AND(ParKmZ.RadaVyrPrikazu IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90Koo=SOURCE.Mnozstvi;

--3ostatní.Výrobní plán, materiály, které jsou skladem na dnes + 3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tpl.IDTabKmen
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo NOT IN(830,840))AND(ParKmZ.RadaVyrPrikazu NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90Ost=SOURCE.Mnozstvi;

--4.Výrobní plán, materiály, které NEjsou skladem na dnes +3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=1)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90Mimo=SOURCE.Mnozstvi;

--4elektro.Výrobní plán, materiály, které NEjsou skladem na dnes +3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tpl.IDTabKmen
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=1)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo IN(830,840))AND(ParKmZ.RadaVyrPrikazu NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90MimoEle=SOURCE.Mnozstvi;

--4kooperace.Výrobní plán, materiály, které NEjsou skladem na dnes +3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=1)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
AND(ParKmZ.RadaVyrPrikazu IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90MimoKoo=SOURCE.Mnozstvi;

--4ostatní.Výrobní plán, materiály, které NEjsou skladem na dnes +3 měsíce (DMR200 je nejvíce dnes+90 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tpl.IDTabKmen
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=1)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13<=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+90)
AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo NOT IN(830,840))AND(ParKmZ.RadaVyrPrikazu NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlan90MimoOst=SOURCE.Mnozstvi;

--5.Výrobní plán, materiály, které jsou skladem nad dnes+ 3 měsíce (DMR200 je alespoň Dnes+91 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13>=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+91)
AND(tss.ID IS NOT NULL)
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlanOver90=SOURCE.Mnozstvi;

--5elektro.Výrobní plán, materiály, které jsou skladem nad dnes+ 3 měsíce (DMR200 je alespoň Dnes+91 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tpl.IDTabKmen
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13>=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+91)
AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo IN(830,840))AND(ParKmZ.RadaVyrPrikazu NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlanOver90Ele=SOURCE.Mnozstvi;

--5kooperace.Výrobní plán, materiály, které jsou skladem nad dnes+ 3 měsíce (DMR200 je alespoň Dnes+91 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13>=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+91)
AND(tss.ID IS NOT NULL)
AND(ParKmZ.RadaVyrPrikazu IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlanOver90Koo=SOURCE.Mnozstvi;

--5ostatní.Výrobní plán, materiály, které jsou skladem nad dnes+ 3 měsíce (DMR200 je alespoň Dnes+91 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
  LEFT OUTER JOIN TabParKmZ ParKmZ ON tpl.IDTabKmen=ParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabKmenZbozi tkzv ON tkzv.ID=tpl.IDTabKmen
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=0)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13>=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+91)
AND(tss.ID IS NOT NULL)
AND(tkzv.SkupZbo NOT IN(830,840))AND(ParKmZ.RadaVyrPrikazu NOT IN (801,802,803))
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlanOver90Ost=SOURCE.Mnozstvi;

--6.Výrobní plán, materiály, které jsou skladem nad dnes+ 3 měsíce (DMR200 je alespoň Dnes+91 dní)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tss.ID,SUM(plkv.mnoz_zad*tss.Prumer)
FROM TabPlanPrKVazby plkv
  LEFT OUTER JOIN TabPlanPrKVazby_EXT plkv_EXT ON plkv_EXT.ID=plkv.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON plkv.nizsi=tkz.ID
  LEFT OUTER JOIN TabPlanPrikaz plpr ON plkv.IDPlanPrikaz=plpr.ID
  LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plkv.IDPlan
  LEFT OUTER JOIN TabRadyPlanu trpl ON trpl.Rada=tpl.Rada
  LEFT OUTER JOIN TabStavSkladu tss ON plkv.Sklad=tss.IDSklad AND plkv.nizsi=tss.IDKmenZbozi
WHERE
(plkv_EXT._KontrolaPokryti_Vysledek=1)AND(tkz.SkupZbo NOT LIKE N'8%')
AND(tpl.zadano=0)AND(tpl.uzavreno=0)AND(trpl.ZahrnoutDoBilancovaniBudPoh=2)AND(plkv.Sklad=N'100')
AND(plpr.Plan_zadani_X-13>=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))+91)
AND(tss.ID IS NOT NULL)
GROUP BY tss.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatVyrPlanOver90Mimo=SOURCE.Mnozstvi;

--7.Rezervace materiálu
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT tsk.ID AS IDStavSkladu, CASE WHEN 
(SELECT tsk.Mnozstvi-ISNULL(tpkz.BlokovanoProVyrobu,0)-(SELECT ISNULL(SUM(tppkv.mnoz_zad),0) 
										FROM TabStavSkladu tss WITH(NOLOCK)
										LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
										LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
										LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
										WHERE tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND tss.ID=tsk.ID
										)
)>ISNULL(tsk.Rezervace,0)
THEN tsk.Rezervace*tsk.Prumer
WHEN
(SELECT
tsk.Mnozstvi-ISNULL(tpkz.BlokovanoProVyrobu,0)-(SELECT ISNULL(SUM(tppkv.mnoz_zad),0) 
										FROM TabStavSkladu tss WITH(NOLOCK)
										LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
										LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
										LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
										WHERE tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND tss.ID=tsk.ID
										)
) BETWEEN 0 AND ISNULL(tsk.Rezervace,0)
THEN 
(SELECT
tsk.Mnozstvi-ISNULL(tpkz.BlokovanoProVyrobu,0)-(SELECT ISNULL(SUM(tppkv.mnoz_zad),0) 
										FROM TabStavSkladu tss WITH(NOLOCK)
										LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
										LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
										LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
										WHERE tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND tss.ID=tsk.ID
										)
)*tsk.Prumer
ELSE 0 END
+
((SELECT
ISNULL(SUM(tpz.Mnozstvi),0)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=tpz.IDZboSklad
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE (tdz.DruhPohybuZbo=2)AND(tdz.RadaDokladu IN (N'601',N'602'))AND(tdz.Realizovano=0)AND(tss.IDSklad='100')AND(tss.ID=tsk.ID))*tsk.Prumer) AS 'Rezervace_mat'
FROM TabStavSkladu tsk WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tsk.IDKmenZbozi AND tsk.IDSklad='100'
LEFT OUTER JOIN TabParametryKmeneZbozi tpkz WITH(NOLOCK) ON tsk.IDKmenZbozi=tpkz.IDKmenZbozi
WHERE tsk.IDSklad='100'

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatRez=SOURCE.Mnozstvi;

--8.Nekrytý stav skladu – finanční hodnota ( není blokováno, plánováno, rezervováno)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT
tsk.ID,
(SELECT CASE WHEN 
(SELECT
tss.Mnozstvi-ISNULL(tpkz.BlokovanoProVyrobu,0)-(SELECT ISNULL(SUM(tppkv.mnoz_zad),0) 
										FROM TabStavSkladu tss WITH(NOLOCK)
										LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
										LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
										LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
										WHERE tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND tss.ID=tsk.ID
										)
-ISNULL(tss.Rezervace,0))>0
THEN 
(SELECT
tss.Mnozstvi-ISNULL(tpkz.BlokovanoProVyrobu,0)-(SELECT ISNULL(SUM(tppkv.mnoz_zad),0) 
										FROM TabStavSkladu tss WITH(NOLOCK)
										LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
										LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
										LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
										WHERE tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND tss.ID=tsk.ID
										)
-ISNULL(tss.Rezervace,0)
)*tss.Prumer
ELSE 0 END
FROM TabStavSkladu tss WITH(NOLOCK)
LEFT OUTER JOIN TabParametryKmeneZbozi tpkz WITH(NOLOCK) ON tss.IDKmenZbozi=tpkz.IDKmenZbozi
WHERE
(tss.IDSklad='100')AND(tss.ID=tsk.ID)
)
-
((SELECT
ISNULL(SUM(tpz.Mnozstvi),0)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=tpz.IDZboSklad
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE (tdz.DruhPohybuZbo=2)AND(tdz.RadaDokladu IN (N'601',N'602'))AND(tdz.Realizovano=0)AND(tss.IDSklad='100')AND(tss.ID=tsk.ID))*tsk.Prumer) AS Nekryty_stav_skladu
FROM TabStavSkladu tsk
  LEFT OUTER JOIN TabKmenZbozi tkz ON tsk.IDKmenZbozi=tkz.ID
  LEFT OUTER JOIN TabParametryKmeneZbozi tpkz ON tsk.IDKmenZbozi=tpkz.IDKmenZbozi
WHERE (tsk.IDSklad='100')

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatNekrytySklad=SOURCE.Mnozstvi;

--Neuzavřené zákaznické rámcovky – finanční hodnota (nabídky 382,385, není vyplněno datum uzavření)
DELETE FROM #TabSegmentace
INSERT INTO #TabSegmentace (IDStavSkladu,Mnozstvi)
SELECT T.ID, SUM(T.Cena_zbyva)
FROM (SELECT
tss.ID,
(tpz.Mnozstvi-(SELECT ISNULL(SUM(P.Mnozstvi),0) FROM TabPohybyZbozi P WITH(NOLOCK)
WHERE P.IDOldPolozka = tpz.ID))*tss.Prumer AS Cena_zbyva
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStavSkladu tss ON tpz.IDZboSklad=tss.ID
WHERE (tdz.RadaDokladu IN (N'382',N'385'))AND(tdz.DruhPohybuZbo=11)AND(tdz.IDSklad='100')
AND(tdz.Splatnost IS NULL)
AND(tpz.Mnozstvi-(SELECT ISNULL(SUM(P.Mnozstvi),0) FROM TabPohybyZbozi P WITH(NOLOCK)
WHERE P.IDOldPolozka = tpz.ID))>0
AND tss.Mnozstvi>0
AND tss.ID IS NOT NULL) AS T
GROUP BY T.ID

MERGE Tabx_RS_Segmentace AS TARGET
USING #TabSegmentace AS SOURCE
ON TARGET.IDStavSkladu=SOURCE.IDStavSkladu
WHEN MATCHED THEN
UPDATE SET TARGET.MatRamcovkyOdb=SOURCE.Mnozstvi;



GO

