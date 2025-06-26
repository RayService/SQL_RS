USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UpsertTabStavSkladu_SAS]    Script Date: 26.06.2025 11:42:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_UpsertTabStavSkladu_SAS]
AS
SET NOCOUNT ON
--nejprve doplníme ID do TabStavSkladu_EXT
INSERT INTO TabStavSkladu_EXT (ID)
SELECT tss.ID
FROM TabStavskladu tss
LEFT OUTER JOIN TabStavSkladu_EXT tsse ON tsse.ID=tss.ID
WHERE tsse.ID IS NULL

UPDATE tsse SET _EXT_RS_mnozstvi_dispozice_12_tydnu=0, _EXT_RS_mnozstvi_dispozice_kmenove_tydny=0
FROM TabStavSkladu tss WITH(NOLOCK)
LEFT OUTER JOIN TabStavSkladu_EXT tsse WITH(NOLOCK) ON tsse.ID=tss.ID
WHERE tss.IDSklad IN ('100','20000280','10000115')

--disponibilní množství 16 týdnů
--nejprve sklad 100
UPDATE tsse SET tsse._EXT_RS_mnozstvi_dispozice_12_tydnu = ISNULL(T.Mno,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=GETDATE()+112)),0)) AS Mno
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='100'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='100'

--pak sklad 20000280
UPDATE tsse SET tsse._EXT_RS_mnozstvi_dispozice_12_tydnu = ISNULL(T.Mno,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '20000280'
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '20000280' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=GETDATE()+112)),0)) AS Mno
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='20000280'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='20000280'

--pak sklad 10000115
UPDATE tsse SET tsse._EXT_RS_mnozstvi_dispozice_12_tydnu = ISNULL(T.Mno,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '10000115'
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '10000115' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=GETDATE()+112)),0)) AS Mno
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='10000115'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='10000115'

--disponibilní množství dle dodací lhůty z kmene (_EXT_RS_dodaci_lhuta_tydny), uložit do _EXT_RS_mnozstvi_dispozice_kmenove_tydny
--MŽ, 19.7.2024 na přání MM přidán "pošltář" 90 dní a vyměněno _EXT_RS_dodaci_lhuta_tydny za _EXT_RS_DodaciLhutaTydnyVyrobce ISNULLem
--nejprve sklad 100
UPDATE tsse SET tsse._EXT_RS_mnozstvi_dispozice_kmenove_tydny = ISNULL(T.Mno,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=(GETDATE()+90+(ISNULL(_EXT_RS_DodaciLhutaTydnyVyrobce,tkze._EXT_RS_dodaci_lhuta_tydny)*7)))),0)) AS Mno
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='100'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='100'

--pak sklad 20000280
UPDATE tsse SET tsse._EXT_RS_mnozstvi_dispozice_kmenove_tydny = ISNULL(T.Mno,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '20000280'
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '20000280' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=(GETDATE()+90+(ISNULL(_EXT_RS_DodaciLhutaTydnyVyrobce,tkze._EXT_RS_dodaci_lhuta_tydny)*7)))),0)) AS Mno
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='20000280'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='20000280'

--pak sklad 10000115
UPDATE tsse SET tsse._EXT_RS_mnozstvi_dispozice_kmenove_tydny = ISNULL(T.Mno,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '10000115'
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '10000115' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=(GETDATE()+90+(ISNULL(_EXT_RS_DodaciLhutaTydnyVyrobce,tkze._EXT_RS_dodaci_lhuta_tydny)*7)))),0)) AS Mno
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='10000115'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='10000115'

--následující výpočty zrušeny pro nadbytečnost, MŽ 5.9.2023
/*
--zásoby k převodu na SAS
--nejprve sklad 100
UPDATE tsse SET tsse._EXT_RS_zasoba_SAS = ISNULL(T.MnoSAS,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
--+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '100'
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '100' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=GETDATE()+112)),0))
---tsk.Mnozstvi
-ISNULL((SELECT ISNULL(SUM(tpz.Mnozstvi - tpz.MnOdebrane),0)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStavSkladu tss ON tpz.IDZboSklad=tss.ID
WHERE
((tdz.RadaDokladu=N'400')OR(tdz.RadaDokladu=N'410')OR(tdz.RadaDokladu=N'411'))AND(tdz.IDSklad=N'100')AND(tdz.Splneno<>1)AND((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tdz.DruhPohybuZbo=9)AND(tss.ID=tsk.ID)
GROUP BY tss.ID),0)
-ISNULL((SELECT ISNULL(SUM(gsu.Mnozstvi),0)
FROM Gatema_StavUmisteni gsu
LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=gsu.IDUmisteni
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=gsu.IDStavSkladu
LEFT OUTER JOIN TabStrom ts ON ts.ID=tss.IDSklad AND tss.IDSklad='100'
WHERE
(gsu.IDStavSkladu=tsk.ID)AND(tue._EXT_RS_PhysicalPlace IS NOT NULL)AND(tss.IDSklad='100')
GROUP BY gsu.IDStavSkladu),0) AS MnoSAS
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='100'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='100'

--pak sklad 200
UPDATE tsse SET tsse._EXT_RS_zasoba_SAS = ISNULL(T.MnoSAS,0)
FROM TabStavSkladu_EXT tsse
JOIN (SELECT
tsk.ID AS ID, tsk.MnozSPrij
-(ISNULL((SELECT ISNULL(PKZ.BlokovanoProVyrobu,0)
FROM  TabParametryKmeneZbozi PKZ WITH(NOLOCK) WHERE tsk.IDKmenZbozi=PKZ.IDKmenZbozi),0)
--+tsk.Rezervace
+ISNULL((SELECT SUM(tppkv.mnoz_zad) 
FROM TabStavSkladu tss
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tss.IDKmenZbozi AND tss.IDSklad = '20000280'
LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
WHERE tkz.ID = tsk.IDKmenZbozi AND tsk.IDSklad = '20000280' AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=GETDATE()+112)),0))
---tsk.Mnozstvi
-ISNULL((SELECT ISNULL(SUM(tpz.Mnozstvi - tpz.MnOdebrane),0)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStavSkladu tss ON tpz.IDZboSklad=tss.ID
WHERE
((tdz.RadaDokladu=N'400')OR(tdz.RadaDokladu=N'410')OR(tdz.RadaDokladu=N'411'))AND(tdz.IDSklad=N'20000280')AND(tdz.Splneno<>1)AND((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tdz.DruhPohybuZbo=9)AND(tss.ID=tsk.ID)
GROUP BY tss.ID),0)
-ISNULL((SELECT ISNULL(SUM(gsu.Mnozstvi),0)
FROM Gatema_StavUmisteni gsu
LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=gsu.IDUmisteni
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=gsu.IDStavSkladu
LEFT OUTER JOIN TabStrom ts ON ts.ID=tss.IDSklad AND tss.IDSklad='20000280'
WHERE
(gsu.IDStavSkladu=tsk.ID)AND(tue._EXT_RS_PhysicalPlace IS NOT NULL)AND(tss.IDSklad='20000280')
GROUP BY gsu.IDStavSkladu),0) AS MnoSAS
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='20000280'
) AS T ON T.ID=tsse.ID
JOIN TabStavSkladu tss ON tss.ID=tsse.ID
WHERE tss.IDSklad='20000280'
*/
/*
--zásoba v SAS
--nejprve sklad 100
UPDATE tsse SET tsse._EXT_RS_stav_skladu_SAS = ISNULL(T.MnoVSAS,0)
FROM TabStavSkladu tss
JOIN (SELECT
tsk.ID AS ID, ISNULL((SELECT ISNULL(SUM(gsu.Mnozstvi),0)
FROM Gatema_StavUmisteni gsu
LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=gsu.IDUmisteni
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=gsu.IDStavSkladu
LEFT OUTER JOIN TabStrom ts ON ts.ID=tss.IDSklad AND tss.IDSklad='100'
WHERE
(gsu.IDStavSkladu=tsk.ID)AND(tue._EXT_RS_PhysicalPlace IS NOT NULL)AND(tss.IDSklad='100')
GROUP BY gsu.IDStavSkladu),0) AS MnoVSAS
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='100'
) AS T ON T.ID=tss.ID
JOIN TabStavSkladu_EXT tsse ON tsse.ID=tss.ID
WHERE tss.IDSklad='100'

--pak sklad 200
UPDATE tsse SET tsse._EXT_RS_stav_skladu_SAS = ISNULL(T.MnoVSAS,0)
FROM TabStavSkladu tss
JOIN (SELECT
tsk.ID AS ID, ISNULL((SELECT ISNULL(SUM(gsu.Mnozstvi),0)
FROM Gatema_StavUmisteni gsu
LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=gsu.IDUmisteni
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=gsu.IDStavSkladu
LEFT OUTER JOIN TabStrom ts ON ts.ID=tss.IDSklad AND tss.IDSklad='20000280'
WHERE
(gsu.IDStavSkladu=tsk.ID)AND(tue._EXT_RS_PhysicalPlace IS NOT NULL)AND(tss.IDSklad='20000280')
GROUP BY gsu.IDStavSkladu),0) AS MnoVSAS
FROM TabStavSkladu tsk
WHERE tsk.IDSklad='20000280'
) AS T ON T.ID=tss.ID
JOIN TabStavSkladu_EXT tsse ON tsse.ID=tss.ID
WHERE tss.IDSklad='20000280'
*/
GO

