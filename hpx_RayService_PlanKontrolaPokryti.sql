USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_PlanKontrolaPokryti]    Script Date: 26.06.2025 9:54:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_PlanKontrolaPokryti]
	@RozhodneMnozstviSklad TINYINT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Kontrola pokrytí materiálů pro Výrobní plán
-- =============================================

--MŽ
/*
1.úprava Dilec = vždy 0, aby pak na konci se updatovalo pole Vysledek v tabulce #RayService_PlanKontrolaPokryti a taky aby se updatovalo pole PredchoziPlan
2.úprava vyňaty balící plány, SK = 666
3.úprava filtru pro položky plánu - přidány i částečně zaplánované položky plánů
*/

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
	,Dilec = 0--všude by se mělo kontrolovat. Dříve bylo: CASE WHEN K.Dilec = 1 AND SOT.K1 = N'VD' THEN 0 ELSE K.Dilec END
	,DatPlan = ISNULL(P.Plan_zadani,GETDATE())
	,Potreba = V.mnoz_zad
	,VychoziSklad = PK.VychoziSklad
	,Skladem = CASE @RozhodneMnozstviSklad
				WHEN 0 THEN S.Mnozstvi			-- Mnozstvi skladem
				WHEN 1 THEN S.MnozBezVyd		-- Mnozstvi o vydeji
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
WHERE PL.mnozPrev<PL.mnozstvi/*bylo <= 0.*/
AND (K.SkupZbo NOT IN (N'605',N'666',N'100')) --upraveno 22.6.2021 vyňaty kromě přípravků i karty balící plány. 10.3.2023 vyňaty ještě lepidla
AND V.RezijniMat=0 -- Dále upraveno 23.6.2021 vyňaty režijní položky.
AND V.ID NOT IN (SELECT V1.ID FROM TabPlanPrKVazby V1 INNER JOIN TabKmenZbozi K1 ON V1.nizsi = K1.ID WHERE K1.SkupZbo=150 AND K1.Dilec=1)-- Upraveno 8.8. vyjmuty ještě dílce se SK 150.
AND (K.SkupZbo NOT LIKE N'93%')--12.1.2023 upraveno - vyloučeny procesní dílce
;
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
							WHEN (Skladem - (BlokovanoProVyrobu + PredchoziPlan)) < 0. THEN 0. 
							WHEN (Skladem - (BlokovanoProVyrobu + PredchoziPlan)) > Potreba THEN Potreba
							ELSE (Skladem - (BlokovanoProVyrobu + PredchoziPlan)) 
						END;

-- stanoveni Vysledek
UPDATE #RayService_PlanKontrolaPokryti SET
	Vysledek = CASE
				WHEN Dilec = 1 THEN 0
				WHEN VychoziSklad IS NULL THEN 2
				WHEN Skladem IS NULL THEN 3
				WHEN Nepokryto > 0 THEN 1
				ELSE 0
			END;

-- ulozeni externich informaci
MERGE TabPlanPrKVazby_EXT VE
USING #RayService_PlanKontrolaPokryti Z ON VE.ID = Z.ID
WHEN MATCHED THEN
   UPDATE SET _KontrolaPokryti_Nepokryto = Z.Nepokryto
			,_KontrolaPokryti_PredchoziPlan = Z.PredchoziPlan
			,_KontrolaPokryti_Vysledek = Z.Vysledek
			,_KontrolaPokryti_DatAktualizace = GETDATE()
			,_KontrolaPokryti_RozhodneMnozstviSklad = @RozhodneMnozstviSklad
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ID, _KontrolaPokryti_Nepokryto, _KontrolaPokryti_PredchoziPlan, _KontrolaPokryti_Vysledek, _KontrolaPokryti_DatAktualizace, _KontrolaPokryti_RozhodneMnozstviSklad)
	VALUES (Z.ID, Z.Nepokryto, Z.PredchoziPlan, Z.Vysledek, GETDATE(), @RozhodneMnozstviSklad);

-- * nemusi se, maze sama vyroba
-- vymazeme konrolu pokryti na planech, ktere jsou ji zadane
--UPDATE VE SET
--	_KontrolaPokryti_Nepokryto = NULL
--	,_KontrolaPokryti_PredchoziPlan = NULL
--	,_KontrolaPokryti_Vysledek = NULL
--	,_KontrolaPokryti_DatAktualizace = GETDATE()
--FROM TabPlanPrKVazby_EXT VE
--	INNER JOIN TabPlanPrKVazby V ON VE.ID = V.ID
--	INNER JOIN #TabExtKomID X ON V.IDPlan = X.ID
--WHERE NOT EXISTS(SELECT * FROM #RayService_PlanKontrolaPokryti WHERE ID = V.ID);

--pokud se někde vykrytí nastaví na OK (=0), pak uložit datum tohoto napočtení
--je-li již datum vyplněno, nepřepisovat
--MŽ, 6.3.2024 upraveno - do filtru plánovaného kusovníku přidána podmínka na sortiment = "VD" v kmenové kartě
--MŽ, 8.3.2024 upraveno - do filtru plánovaného kusovníku přidána podmínka na sortiment = "VD" v kmenové kartě nebo material=1
DECLARE @IDPlan INT;
DECLARE CurUpdPlan CURSOR LOCAL FAST_FORWARD FOR
SELECT tp.ID
FROM TabPlan tp WITH(NOLOCK)
LEFT OUTER JOIN TabPlan_EXT tpe WITH(NOLOCK) ON tpe.ID=tp.ID
WHERE (tpe._EXT_RS_OKOrig IS NULL)AND((SELECT ISNULL(MIN(VE._KontrolaPokryti_Vysledek),(SELECT MIN(VVE._KontrolaPokryti_Vysledek)
											FROM TabPlanPrKVazby VV WITH(NOLOCK)
											INNER JOIN TabPlanPrKVazby_EXT VVE WITH(NOLOCK) ON VV.ID = VVE.ID
											LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=VV.nizsi
											WHERE VV.IDPlan = tp.ID AND (tkz.IdSortiment=20 OR tkz.Material=1))) FROM TabPlanPrKVazby V WITH(NOLOCK) INNER JOIN TabPlanPrKVazby_EXT VE WITH(NOLOCK) ON V.ID = VE.ID LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=V.nizsi WHERE V.IDPlan = tp.ID AND (tkz.IdSortiment=20 OR tkz.Material=1) AND VE._KontrolaPokryti_Vysledek > 0)=0);
OPEN CurUpdPlan;
FETCH NEXT FROM CurUpdPlan INTO 
		@IDPlan;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		--nejprve zajistíme, že ext tabulka existuje
		IF (SELECT pe.ID  FROM TabPlan_EXT AS pe WHERE pe.ID = @IDPlan) IS NULL
		 BEGIN 
			INSERT INTO TabPlan_EXT (ID)
			VALUES (@IDPlan)
		 END
		IF (SELECT ISNULL(MIN(VE._KontrolaPokryti_Vysledek),(SELECT MIN(VVE._KontrolaPokryti_Vysledek)
													FROM TabPlanPrKVazby VV WITH(NOLOCK)
													INNER JOIN TabPlanPrKVazby_EXT VVE WITH(NOLOCK) ON VV.ID = VVE.ID
													LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=VV.nizsi
													WHERE VV.IDPlan = @IDPlan AND (tkz.IdSortiment=20 OR tkz.Material=1))
					)
		FROM TabPlanPrKVazby V WITH(NOLOCK)
		INNER JOIN TabPlanPrKVazby_EXT VE WITH(NOLOCK) ON V.ID = VE.ID
		LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=V.nizsi
		WHERE V.IDPlan = @IDPlan AND (tkz.IdSortiment=20 OR tkz.Material=1) AND VE._KontrolaPokryti_Vysledek > 0)=0
		BEGIN
		UPDATE tpe SET tpe._EXT_RS_OKOrig=GETDATE()
		FROM TabPlan tp WITH(NOLOCK)
		LEFT OUTER JOIN TabPlan_EXT tpe WITH(NOLOCK) ON tpe.ID=tp.ID
		WHERE tpe._EXT_RS_OKOrig IS NULL AND tp.ID=@IDPlan
		END

	FETCH NEXT FROM CurUpdPlan INTO 
		@IDPlan;
	END;
CLOSE CurUpdPlan;
DEALLOCATE CurUpdPlan;

/*
NULL=---
0=OK
1=Nedostatek množství
2=Sklad není definován
3=Neexistuje skladová karta
*/
GO

