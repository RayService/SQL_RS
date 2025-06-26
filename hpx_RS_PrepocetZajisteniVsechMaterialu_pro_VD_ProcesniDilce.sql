USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PrepocetZajisteniVsechMaterialu_pro_VD_ProcesniDilce]    Script Date: 26.06.2025 12:44:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PrepocetZajisteniVsechMaterialu_pro_VD_ProcesniDilce]
AS
--inicializace dočasných tabulek
--1. požadavky k výdeji
BEGIN
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_PozadavkyKVydeji') IS NOT NULL
DROP TABLE #Lokalni_Tab_PozadavkyKVydeji

CREATE TABLE #Lokalni_Tab_PozadavkyKVydeji
(
	loctab_ID INT PRIMARY KEY IDENTITY(1,1),
  local_IDKmen INT NULL,
  local_ID_PrKV_Plan INT NULL,
  local_ID_Prikaz_Plan INT NULL,
	local_mnozstvi NUMERIC(19,6) NULL,
  local_Datum DATETIME NULL,
  local_DatumZajisteni DATETIME NULL,
  local_Plan BIT NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_PozadavkyKVydeji(local_IDKmen)
CREATE INDEX IX_local_Datum ON #Lokalni_Tab_PozadavkyKVydeji(local_Datum ASC)
CREATE INDEX IX_local_Plan ON #Lokalni_Tab_PozadavkyKVydeji(local_Plan)
CREATE INDEX IX_local_ID_Prikaz_Plan ON #Lokalni_Tab_PozadavkyKVydeji(local_ID_Prikaz_Plan)

--2. vykrývací tabulka stavem skladu
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_StavSkladuKVykryti') IS NOT NULL
DROP TABLE #Lokalni_Tab_StavSkladuKVykryti

CREATE TABLE #Lokalni_Tab_StavSkladuKVykryti
(
	loctab_ID INT PRIMARY KEY IDENTITY(1,1),  
  local_IDKmen INT NULL,
	local_mnozstvi NUMERIC(19,6) NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_StavSkladuKVykryti(local_IDKmen)

--3. vykrývací tabulka operací z výrobního příkazu procesního dílce
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_VyrPrikazyKVykryti') IS NOT NULL
DROP TABLE #Lokalni_Tab_VyrPrikazyKVykryti

CREATE TABLE #Lokalni_Tab_VyrPrikazyKVykryti
(
	loctab_ID INT PRIMARY KEY IDENTITY(1,1),  
  local_IDKmen INT NULL,
	local_mnozstvi NUMERIC(19,6) NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_VyrPrikazyKVykryti(local_IDKmen)

--4. vykrývací tabulka výrobními plány
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_VyrPlanyKVykryti') IS NOT NULL
DROP TABLE #Lokalni_Tab_VyrPlanyKVykryti

CREATE TABLE #Lokalni_Tab_VyrPlanyKVykryti
(
	loctab_ID int PRIMARY KEY IDENTITY(1,1),  
  local_IDKmen INT NULL,
	local_mnozstvi numeric(19,6) NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_VyrPlanyKVykryti(local_IDKmen)

--5. vykrývací tabulka pro insert operací z VP a výrobních plánů proc.dílců
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_VydaneObj') is not NULL
DROP TABLE #Lokalni_Tab_VydaneObj

CREATE TABLE #Lokalni_Tab_VydaneObj
(
	loctab_ID INT PRIMARY KEY IDENTITY(1,1),  
  local_IDKmen INT NULL,
  Local_IDPohybZbo INT NULL,  
	local_mnozstvi NUMERIC(19,6) NULL,
  local_PotvrzDatDod DATETIME
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_VydaneObj(local_IDKmen)
CREATE INDEX IX_local_PotvrzDatDod ON #Lokalni_Tab_VydaneObj(local_PotvrzDatDod ASC)

END

--exec hromadná aktualizace rozpadu pro všechny výrobní plány
EXEC hp_VyrPlan_VypocetPlanovaneVyroby @DuvodGenerovani=1

--6. naplnění dočasné tabulky: Požadavky k výdeji
BEGIN
  INSERT INTO #Lokalni_Tab_PozadavkyKVydeji(local_IDKmen, local_ID_PrKV_Plan, local_ID_Prikaz_Plan, local_mnozstvi, local_Plan, local_Datum)
    (SELECT PrKV.nizsi, PrKV.ID, PrKV.IDPrikaz, PrKv.mnoz_Nevydane, 0, P.Plan_zadani
      FROM TabPrKVazby PrKV 
      INNER JOIN TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
	  INNER JOIN TabPrikaz P ON P.ID=PrKV.IDPrikaz
      WHERE PrKv.mnoz_Nevydane>0 AND 
            PrKV.Splneno=0 AND
            PrKV.Prednastaveno=1 AND
            PrKV.IDOdchylkyDo is NULL AND
            KZ.SkupZbo LIKE N'93%' AND 
            KZ.Dilec=1 and
			P.StavPrikazu<=40)

  INSERT INTO #Lokalni_Tab_PozadavkyKVydeji(local_IDKmen, local_ID_PrKV_Plan, local_ID_Prikaz_Plan, local_mnozstvi, local_Plan, local_Datum)
    (SELECT PPrKV.nizsi, PPrKV.ID, PPrKV.IDPlanPrikaz, PPrKV.mnoz_zad, 1, PP.Plan_zadani
      FROM TabPlanPrKVazby PPrKV 
      INNER JOIN TabKmenZbozi KZ ON KZ.ID=PPrKV.nizsi
      INNER JOIN TabPlanPrikaz PP ON PP.ID=PPrKV.IDPlanPrikaz
	  LEFT OUTER JOIN TabPlan TP ON TP.ID=PPrKV.IDPlan
	  LEFT OUTER JOIN TabRadyPlanu TRP ON trp.Rada=TP.Rada
	  WHERE PPrKV.mnoz_zad>0 and          
            KZ.SkupZbo LIKE N'93%' and
			PPrKV.RezijniMat=0 AND
			KZ.Dilec=1 AND TP.StavPrevodu<>N'x' AND TRP.ZahrnoutDoBilancovaniBudPoh=2)
END

--7. naplnění dočasné tabulky: Stav skladů k vykrytí (2.)
BEGIN
  INSERT INTO #Lokalni_Tab_StavSkladuKVykryti(local_IDKmen, local_mnozstvi)
    (SELECT SS.IDKmenZbozi, SUM(SS.MnozSPrij)
      FROM TabStavSkladu SS
      WHERE SS.IDSklad IN (N'20000275900') AND SS.Mnozstvi>0.0
	  GROUP BY SS.IDKmenZbozi )
END

--8. naplnění dočasné tabulky: Výrobní příkazy k vykrytí (3.)
/*
BEGIN
  INSERT INTO #Lokalni_Tab_VyrPrikazyKVykryti(local_IDKmen, local_mnozstvi)
    (SELECT P.IDTabKmen, P.kusy_zad
	FROM TabPrikaz P
	WHERE P.StavPrikazu IN (20,30))
END*/

--8. naplnění dočasné tabulky: Výrobní plány k vykrytí (4.)
/*
BEGIN
  INSERT INTO #Lokalni_Tab_VyrPrikazyKVykryti(local_IDKmen, local_mnozstvi)
    (SELECT P.IDTabKmen, P.mnozNeprev
	FROM TabPlan P
	LEFT OUTER JOIN TabRadyPlanu trp ON trp.Rada=P.Rada
	WHERE P.InterniZaznam=0 AND P.StavPrevodu<>N'x' AND trp.ZahrnoutDoBilancovaniBudPoh=2)
END*/

--upravený nápočet položek k vykrytí (operace z VP na proc. dílec, pak plány na proc.dílce)
BEGIN
  INSERT INTO #Lokalni_Tab_VydaneObj(local_IDKmen, Local_IDPohybZbo, local_mnozstvi, local_PotvrzDatDod)
    (SELECT P.IDTabKmen, P.ID, PrP.Kusy_zive, PrP.Plan_ukonceni
		FROM TabPrikaz P
		LEFT OUTER JOIN TabPrPostup PrP ON P.ID=PrP.IDPrikaz
		WHERE P.StavPrikazu IN (20,30,40) AND P.Rada=N'950' AND PrP.Kusy_zive>0 AND PrP.Splneno=0 AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo is NULL
    UNION ALL
	SELECT P.IDTabKmen, P.ID, P.mnozNeprev, P.datum
		FROM TabPlan P
		LEFT OUTER JOIN TabRadyPlanu trp ON trp.Rada=P.Rada
		WHERE P.InterniZaznam=0 AND P.Rada LIKE N'%tpv%' AND P.mnozNeprev>0)
END

--9. zde se děje plnění data zajištění do řádků

DECLARE @ID INT, @IDKmen INT, @IDPrKV_Plan INT, @IDPrikaz_Plan INT, @Mnozstvi Numeric(19,6), @JePlan BIT, @DatumZajisteni DATETIME, @ID_local INT, @Mnozstvi_local Numeric(19,6)
DECLARE PomCr CURSOR FAST_FORWARD LOCAL FOR 
  SELECT loctab_ID, local_IDKmen, local_ID_PrKV_Plan, local_ID_Prikaz_Plan, local_mnozstvi, local_Plan
    FROM #Lokalni_Tab_PozadavkyKVydeji
    WHERE local_Datum IS NOT NULL
	ORDER BY local_Plan ASC, local_IDKmen, local_Datum ASC
OPEN PomCr

WHILE 1=1
	BEGIN	
  FETCH NEXT FROM PomCr INTO @ID, @IDKmen, @IDPrKV_Plan, @IDPrikaz_Plan, @Mnozstvi, @JePlan
	IF (@@FETCH_STATUS <> 0) BREAK
	--tělo pro práci s curzorem
  SET @DatumZajisteni=NULL
  IF EXISTS(SELECT *
              FROM #Lokalni_Tab_StavSkladuKVykryti SS
              WHERE SS.local_mnozstvi > 0.0 and
                    SS.local_IDKmen=@IDKmen)
    BEGIN      
      SELECT @ID_local=SS.loctab_ID, @Mnozstvi_local=SS.local_mnozstvi
        FROM #Lokalni_Tab_StavSkladuKVykryti SS
        WHERE SS.local_mnozstvi > 0.0 and
              SS.local_IDKmen=@IDKmen
      IF @Mnozstvi_local>=@Mnozstvi
        BEGIN
          SET @DatumZajisteni=GETDATE()
		  --UPDATE #Lokalni_Tab_StavSkladuKVykryti SET local_mnozstvi=(@Mnozstvi_local-@Mnozstvi) WHERE loctab_ID=@ID_local
          UPDATE #Lokalni_Tab_PozadavkyKVydeji SET local_DatumZajisteni=@DatumZajisteni WHERE loctab_ID=@ID
          --SET @Mnozstvi=0.0
        END
      /*zkusím ještě toto vypnout
	  ELSE
        BEGIN
          SET @DatumZajisteni=NULL
		  --UPDATE #Lokalni_Tab_StavSkladuKVykryti SET local_mnozstvi=0.0 WHERE loctab_ID=@ID_local
          --SET @Mnozstvi=@Mnozstvi-@Mnozstvi_local		  
        END*/
    END    
	--tady jsem zahájil zapoznámkování
  WHILE @Mnozstvi>0.0
    BEGIN
	  IF EXISTS(SELECT *
                  FROM #Lokalni_Tab_VydaneObj VO
                  WHERE local_mnozstvi > 0.0 and
                    local_IDKmen=@IDKmen)
        BEGIN
          SELECT TOP 1 @ID_local=VO.loctab_ID, @Mnozstvi_local=VO.local_mnozstvi, @DatumZajisteni=(CASE WHEN VO.local_PotvrzDatDod<GETDATE() THEN GETDATE() ELSE VO.local_PotvrzDatDod END)
            FROM #Lokalni_Tab_VydaneObj VO
            WHERE local_mnozstvi > 0.0 and
                  local_IDKmen=@IDKmen
            ORDER BY local_PotvrzDatDod ASC
          IF @Mnozstvi_local>=@Mnozstvi
            BEGIN
              --toto zkusím vypnout UPDATE #Lokalni_Tab_VydaneObj SET local_mnozstvi=@Mnozstvi_local-@Mnozstvi WHERE loctab_ID=@ID_local
              UPDATE #Lokalni_Tab_PozadavkyKVydeji SET local_DatumZajisteni=@DatumZajisteni WHERE loctab_ID=@ID              
              SET @Mnozstvi=0.0
            END
          ELSE
            BEGIN
              SET @DatumZajisteni=NULL
			  UPDATE #Lokalni_Tab_VydaneObj SET local_mnozstvi=0.0 WHERE loctab_ID=@ID_local
              SET @Mnozstvi=@Mnozstvi-@Mnozstvi_local
            END
        END
      ELSE
        BEGIN
          SET @Mnozstvi=0.0
        END
    END  
	--tady to bylo ukončeno zapoznámkování
  IF @JePlan=1
    BEGIN
      IF NOT EXISTS(SELECT * FROM TabPlanPrKVazby_EXT WHERE ID=@IDPrKV_Plan) INSERT INTO TabPlanPrKVazby_EXT(ID,_EXT_RS_DatZajMat) VALUES(@IDPrKV_Plan,@DatumZajisteni)
	  ELSE UPDATE TabPlanPrKVazby_EXT SET _EXT_RS_DatZajMat=@DatumZajisteni WHERE ID=@IDPrKV_Plan
    END
  ELSE
    BEGIN
      IF NOT EXISTS(SELECT * FROM TabPrKVazby_EXT WHERE ID=@IDPrKV_Plan) INSERT INTO TabPrKVazby_EXT(ID,_EXT_RS_DatZajMat) VALUES(@IDPrKV_Plan,@DatumZajisteni)
	  ELSE UPDATE TabPrKVazby_EXT SET _EXT_RS_DatZajMat=@DatumZajisteni WHERE ID=@IDPrKV_Plan
    END
	END

CLOSE PomCr
DEALLOCATE PomCr

--9. Samotné nastavení zjištěných zajištění na TabPrikaz
BEGIN
DECLARE PomCr2 CURSOR FAST_FORWARD LOCAL FOR 
  SELECT P.ID
	FROM TabPrikaz P
	INNER JOIN TabPrKVazby PrKV ON P.ID=PrKV.IDPrikaz
	INNER JOIN TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
	WHERE PrKv.mnoz_Nevydane>0 AND
          PrKV.Splneno=0 AND
          PrKV.IDOdchylkyDo IS NULL AND
          PrKV.Prednastaveno=1 AND
          KZ.SkupZbo LIKE N'93%' AND
          KZ.Dilec=1 AND
	      P.StavPrikazu<=40
    GROUP BY P.ID
OPEN PomCr2

WHILE 1=1
	BEGIN    
    FETCH NEXT FROM PomCr2 INTO @IDPrikaz_Plan
	  IF (@@FETCH_STATUS <> 0) BREAK
    SET @DatumZajisteni=GETDATE()
    IF EXISTS(SELECT *
          FROM TabPrikaz P
					INNER JOIN TabPrKVazby PrKV ON P.ID=PrKV.IDPrikaz
					INNER JOIN TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
					Left Outer Join TabPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
					WHERE PrKv.mnoz_Nevydane>0 AND
                PrKV.Splneno=0 AND
                PrKV.IDOdchylkyDo IS NULL AND
                PrKV.Prednastaveno=1 AND
                KZ.SkupZbo LIKE N'93%' AND
						    KZ.Dilec=1 AND
							P.StavPrikazu<=40 AND                          
						    PrKVE._EXT_RS_DatZajMat is NULL AND
						    P.ID=@IDPrikaz_Plan)
      BEGIN
		SET @DatumZajisteni=NULL
	  END
	ELSE
	  BEGIN
        SELECT @DatumZajisteni=MAX(PrKVE._EXT_RS_DatZajMat)
          FROM TabPrikaz P
			INNER JOIN TabPrKVazby PrKV ON P.ID=PrKV.IDPrikaz
			INNER JOIN TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
			Left Outer Join TabPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
			WHERE PrKv.mnoz_Nevydane>0 AND
				    PrKV.Splneno=0 AND
            PrKV.IDOdchylkyDo is NULL AND
            PrKV.Prednastaveno=1 and
            KZ.SkupZbo LIKE N'93%' AND 
		    KZ.Dilec=1 AND
				    P.StavPrikazu<=40 AND                          
				    PrKVE._EXT_RS_DatZajMat IS NOT NULL AND
				    P.ID=@IDPrikaz_Plan
      END   

	IF NOT EXISTS(SELECT * FROM TabPrikaz_EXT WHERE ID=@IDPrikaz_Plan) INSERT INTO TabPrikaz_EXT(ID,_EXT_RS_material) VALUES(@IDPrikaz_Plan,@DatumZajisteni)
	ELSE UPDATE TabPrikaz_EXT SET _EXT_RS_material=@DatumZajisteni WHERE ID=@IDPrikaz_Plan 

  END
CLOSE PomCr2
DEALLOCATE PomCr2

--10. Samotné nastavení zjištěných zajištění na TabPlanPrikaz
DECLARE PomCr3 CURSOR FAST_FORWARD LOCAL FOR 
  SELECT P.ID
	FROM TabPlanPrikaz P
	INNER JOIN TabPlanPrKVazby PrKV ON P.ID=PrKV.IDPlanPrikaz
	INNER JOIN TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
    WHERE PrKv.mnoz_zad>0 AND
          KZ.SkupZbo LIKE N'93%' AND
		  PrKV.RezijniMat=0 AND
          KZ.Dilec=1
    GROUP BY P.ID
OPEN PomCr3

WHILE 1=1
	BEGIN    
    FETCH NEXT FROM PomCr3 INTO @IDPrikaz_Plan
	  IF (@@FETCH_STATUS <> 0) BREAK
    
	SET @DatumZajisteni=GETDATE()
    IF EXISTS(SELECT *
                    FROM TabPlanPrikaz P
					INNER JOIN TabPlanPrKVazby PrKV ON P.ID=PrKV.IDPlanPrikaz
					INNER JOIN TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
					Left Outer Join TabPlanPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
					WHERE PrKv.mnoz_zad>0 AND
					      KZ.SkupZbo LIKE N'93%' AND
						  PrKV.RezijniMat=0 AND
						  KZ.Dilec=1 AND
						  PrKVE._EXT_RS_DatZajMat IS NULL AND
						  P.ID=@IDPrikaz_Plan )
      BEGIN
		SET @DatumZajisteni=NULL
	  END
	ELSE
	  BEGIN
        SET @DatumZajisteni=
						(SELECT CASE WHEN (SELECT tp.SkupinaPlanu 
											FROM TabPlanPrikaz tppr WITH(NOLOCK)
											LEFT OUTER JOIN TabPlan tp WITH (NOLOCK) ON tp.ID=tppr.IDPlan
											WHERE tppr.ID=@IDPrikaz_Plan)=N'P100' THEN 
						(SELECT CASE WHEN EXISTS (
								SELECT VVE._EXT_RS_DatZajMat
								FROM TabPlanPrKVazby VV WITH(NOLOCK)
								INNER JOIN TabPlanPrKVazby_EXT VVE WITH(NOLOCK) ON VV.ID = VVE.ID
								LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=VV.nizsi
								LEFT OUTER JOIN TabSkupinyZbozi tsz WITH(NOLOCK) ON tsz.SkupZbo=tkz.SkupZbo
								LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze WITH(NOLOCK) ON tsze.ID=tsz.ID
								WHERE VV.IDPlanPrikaz=@IDPrikaz_Plan AND tkz.SkupZbo LIKE N'93%' AND ISNULL(tsze._EXT_RS_vyraditP100SK,0)<>1 AND VVE._EXT_RS_DatZajMat IS NULL)
							THEN NULL
							ELSE
							(SELECT MAX(VVE._EXT_RS_DatZajMat)
								FROM TabPlanPrKVazby VV WITH(NOLOCK)
								INNER JOIN TabPlanPrKVazby_EXT VVE WITH(NOLOCK) ON VV.ID = VVE.ID
								LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=VV.nizsi
								LEFT OUTER JOIN TabSkupinyZbozi tsz WITH(NOLOCK) ON tsz.SkupZbo=tkz.SkupZbo
								LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze WITH(NOLOCK) ON tsze.ID=tsz.ID
								WHERE VV.IDPlanPrikaz=@IDPrikaz_Plan AND tkz.SkupZbo LIKE N'93%' AND ISNULL(tsze._EXT_RS_vyraditP100SK,0)<>1)
							END)
						ELSE
						(SELECT CASE WHEN EXISTS (
								SELECT VE._EXT_RS_DatZajMat
								FROM TabPlanPrKVazby V WITH(NOLOCK)
								INNER JOIN TabPlanPrKVazby_EXT VE WITH(NOLOCK) ON V.ID = VE.ID
								LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=V.nizsi
								WHERE V.IDPlanPrikaz=@IDPrikaz_Plan AND tkz.SkupZbo  LIKE N'93%' AND VE._EXT_RS_DatZajMat IS NULL)
							THEN NULL
							ELSE
							(SELECT MAX(VE._EXT_RS_DatZajMat)
							FROM TabPlanPrKVazby V WITH(NOLOCK)
							INNER JOIN TabPlanPrKVazby_EXT VE WITH(NOLOCK) ON V.ID = VE.ID
							LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=V.nizsi
							WHERE V.IDPlanPrikaz=@IDPrikaz_Plan AND tkz.SkupZbo  LIKE N'93%')
							END)
						END)
      END 

	IF NOT EXISTS(SELECT * FROM TabPlanPrikaz_EXT WHERE ID=@IDPrikaz_Plan) INSERT INTO TabPlanPrikaz_EXT(ID,_EXT_RS_material) VALUES(@IDPrikaz_Plan,@DatumZajisteni)
	ELSE UPDATE TabPlanPrikaz_EXT SET _EXT_RS_material=@DatumZajisteni WHERE ID=@IDPrikaz_Plan
  END
CLOSE PomCr3
DEALLOCATE PomCr3

-- 11. další krok
/*
UPDATE TabPlanPrikaz_EXT SET _EXT_RS_material=GETDATE() WHERE ID in (SELECT PP.ID FROM TabPlanPrikaz PP Left Outer Join TabPlanPrKVazby P ON P.IDPlanPrikaz=PP.ID WHERE P.IDPlanPrikaz is NULL)
UPDATE TabPrikaz_EXT SET _EXT_RS_material=GETDATE() WHERE ID in (SELECT PP.ID FROM TabPrikaz PP Left Outer Join TabPrKVazby P ON P.IDPrikaz=PP.ID WHERE P.IDPrikaz is NULL)
UPDATE TabPrikaz_EXT SET _EXT_RS_material=GETDATE() WHERE 
	ID in (SELECT PP.ID FROM TabPrikaz PP Left Outer Join TabPrKVazby P ON P.IDPrikaz=PP.ID WHERE P.mnoz_Nevydane=0.0 AND PP.StavPrikazu<=40 )AND
	ID NOT in (SELECT PP.ID 
				FROM TabPrikaz PP 
				Left Outer Join TabPrKVazby P ON P.IDPrikaz=PP.ID 
				Left Outer Join TabKmenZbozi KZ ON KZ.ID=P.nizsi 
				WHERE P.mnoz_Nevydane>0.0 AND 
					  KZ.Material=1 AND
					  KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') AND
					  PP.StavPrikazu<=40)
*/
END
--12. smazání dočasných tabulek
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_PozadavkyKVydeji') IS NOT NULL
DROP TABLE #Lokalni_Tab_PozadavkyKVydeji
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_StavSkladuKVykryti') IS NOT NULL
DROP TABLE #Lokalni_Tab_StavSkladuKVykryti
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_VydaneObj') IS NOT NULL
DROP TABLE #Lokalni_Tab_VydaneObj

GO

