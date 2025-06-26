USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_PlanKontrolaPokryti_ProcesniDilce]    Script Date: 26.06.2025 12:42:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_PlanKontrolaPokryti_ProcesniDilce]
	@RozhodneMnozstviSklad TINYINT
AS
SET NOCOUNT ON;
-- ===============================================================
-- Author:		MŽ
-- Description:	Kontrola pokrytí procesních dílců pro Výrobní plán
-- ===============================================================

-- zalozeni pracovni docasne tabulku
IF OBJECT_ID('tempdb..#RayService_PlanKontrolaPokryti') IS NOT NULL
	DROP TABLE #RayService_PlanKontrolaPokryti;
CREATE TABLE [#RayService_PlanKontrolaPokryti](
 	[ID] [int] NOT NULL PRIMARY KEY,
	[IDKmenZbozi] [int] NOT NULL,
	[Dilec] [bit] NOT NULL,
	[DatPlan] [datetime] NULL,
	[Potreba] [numeric](19, 6) NOT NULL,
	[VychoziSklad] [nvarchar](30) NULL,
	[Skladem] [numeric](19, 6) NULL,
	[BlokovanoProVyrobu] [numeric](19, 6) NULL,
	[PredchoziPlan] [numeric](19, 6) NULL,
	[Nepokryto] [numeric](19, 6) NULL,
	[Vysledek] [tinyint] NULL);

-- naplaneni pracovni tabulky
INSERT INTO #RayService_PlanKontrolaPokryti(
	ID
	,IDKmenZbozi
	,Dilec
	,DatPlan
	,Potreba
	,VychoziSklad
	,Skladem
	,BlokovanoProVyrobu
	,PredchoziPlan
	,Nepokryto
	,Vysledek)
SELECT
	ID = V.ID
	,IDKmenZbozi = V.nizsi
	,Dilec = 0
	,DatPlan = ISNULL(P.Plan_zadani,GETDATE())
	,Potreba = V.mnoz_zad
	,VychoziSklad = PK.VychoziSklad
	,Skladem = CASE @RozhodneMnozstviSklad
				WHEN 0 THEN S.Mnozstvi			-- Mnozstvi skladem
				WHEN 1 THEN S.MnozBezVyd		-- Mnozstvi po vydeji
				WHEN 2 THEN S.MnozSPrij			-- Mnozstvi po prijmu
				WHEN 3 THEN S.MnozSPrijBezVyd	-- Mnoztvi po prijmu a vydeji
				WHEN 4 THEN S.MnozstviDispo		-- Mnozstvi k dispozici
				WHEN 5 THEN S.MnozDispoBezVyd	-- Mnozstvi k dispozici po vydeji
				WHEN 6 THEN S.MnozDispoSPri		-- Mnozstvi k dispozici po prijmu
				WHEN 7 THEN S.MnozDispoSPrijBezVyd	-- Mnozstvi k dispozici po prijmu a vydeji
			END
	,BlokovanoProVyrobu = PK.BlokovanoProVyrobu
	,PredchoziPlan = CAST(NULL as NUMERIC(19,6))
	,Nepokryto = CAST(NULL as NUMERIC(19,6))
	,Vysledek = CAST(NULL as TINYINT)
FROM TabPlanPrKVazby V
	INNER JOIN #TabExtKomID X ON V.IDPlan = X.ID
	INNER JOIN TabPlan PL ON V.IDPlan = PL.ID
	INNER JOIN TabPlanPrikaz P ON V.IDPlanPrikaz = P.ID
	INNER JOIN TabKmenZbozi K ON V.nizsi = K.ID
	LEFT OUTER JOIN TabParametryKmeneZbozi PK ON V.nizsi = PK.IDKmenZbozi
	LEFT OUTER JOIN TabStavSkladu S ON PK.IDKmenZbozi = S.IDKmenZbozi AND PK.VychoziSklad = S.IDSklad
	LEFT OUTER JOIN TabSortiment SOT ON K.IdSortiment = SOT.ID
WHERE PL.mnozPrev<PL.mnozstvi
		AND (K.SkupZbo LIKE N'93%') 
		AND V.RezijniMat=0;

-- aktualizace PredchoziPlan - mnozstvi z planovanych vyrobnich prikazu
UPDATE C SET
	PredchoziPlan = ISNULL(Z.MnozstviPred,0.)
FROM #RayService_PlanKontrolaPokryti C
	OUTER APPLY (SELECT 
					MnozstviPred = SUM(V.mnoz_zad) 
				FROM TabPlanPrKVazby V
					INNER JOIN TabPlan PL ON V.IDPlan = PL.ID
					INNER JOIN TabRadyPlanu RPL ON PL.Rada = RPL.Rada
					INNER JOIN TabPlanPrikaz P ON V.IDPlanPrikaz = P.ID
				WHERE V.nizsi = C.IDKmenZbozi
					AND RPl.ZahrnoutDoBilancovaniBudPoh = 2 -- Ano včetně rozpadu plánované výroby
					AND PL.mnozPrev <= 0.
					AND (P.Plan_zadani < C.DatPlan OR (P.Plan_zadani = C.DatPlan AND V.ID < C.ID))
					AND V.ID <> C.ID
					) Z
WHERE C.Skladem IS NOT NULL
	AND C.Dilec = 0;

-- stanoveni Nepokryto
UPDATE #RayService_PlanKontrolaPokryti SET
	Nepokryto = Potreba - CASE 
							WHEN Skladem < 1 THEN 0. 
							ELSE  Potreba 
						END;

--Vysledek = 0 (v HEO je to OK), pokud je skladem 1 ks
-- stanoveni Vysledek
UPDATE #RayService_PlanKontrolaPokryti SET
	Vysledek = CASE
				WHEN VychoziSklad IS NULL THEN 2
				WHEN Skladem IS NULL THEN 3
				WHEN Nepokryto > 0 THEN 1
				ELSE 0
			END;
SELECT * FROM #RayService_PlanKontrolaPokryti
--pokračuje se uložením do ENG externích údajů místo do nákupních ext.údajů
MERGE TabPlanPrKVazby_EXT VE
USING #RayService_PlanKontrolaPokryti Z ON VE.ID = Z.ID
WHEN MATCHED THEN
   UPDATE SET --_KontrolaPokryti_Nepokryto = Z.Nepokryto
			--,_KontrolaPokryti_PredchoziPlan = Z.PredchoziPlan,
			_EXT_RS_KontrolaPokryti_Vysledek_ENG = Z.Vysledek
			,_EXT_RS_KontrolaPokryti_DatAktualizace = GETDATE()
			--,_KontrolaPokryti_RozhodneMnozstviSklad = @RozhodneMnozstviSklad
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ID, /*_KontrolaPokryti_Nepokryto, _KontrolaPokryti_PredchoziPlan, */_EXT_RS_KontrolaPokryti_Vysledek_ENG, _EXT_RS_KontrolaPokryti_DatAktualizace/*, _KontrolaPokryti_RozhodneMnozstviSklad*/)
	VALUES (Z.ID, /*Z.Nepokryto, Z.PredchoziPlan,*/ Z.Vysledek, GETDATE()/*, @RozhodneMnozstviSklad*/);


--toto v proceduře smazat, spouštím teď při testu:
IF OBJECT_ID(N'tempdb..#TabExtKomID','U')IS NOT NULL DROP TABLE #TabExtKomID
IF OBJECT_ID(N'tempdb..#TabExtKom','U')IS NOT NULL DROP TABLE #TabExtKom
IF OBJECT_ID(N'tempdb..#TabExtKomSys','U')IS NOT NULL DROP TABLE #TabExtKomSys
IF OBJECT_ID(N'tempdb..#TabExtKomPar','U')IS NOT NULL DROP TABLE #TabExtKomPar
GO

