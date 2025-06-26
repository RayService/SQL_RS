USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVVyrFazeGen]    Script Date: 26.06.2025 9:02:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Generování výrobních fází
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_TPVVyrFazeGen]
	@IDZmeny INT		-- ID vybrané změny
	,@ID INT			-- ID v TabKmenZbozi
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @IDKusovnik INT;
DECLARE @IDVarianta INT;
DECLARE @ZmenaJizProbiha BIT;
DECLARE @FlagZdvojeni BIT;
DECLARE @BylaChyba BIT;
DECLARE @ByloPrecislovano BIT;
DECLARE @AktualizovatTypOznaceniOperaci BIT;
DECLARE @TranCountPred INT;
DECLARE @VF_Cislo INT;
DECLARE @VF_TypOznaceni NVARCHAR(10);
DECLARE @VF_nazev NVARCHAR(50);
DECLARE @Materska NCHAR(4);
DECLARE @OperaceOd TINYINT;
DECLARE @T_VyrFaze TABLE(
	Cislo INT NULL
	,TypOznaceni NVARCHAR(10) NULL
	,_RayService_Operace NVARCHAR(4) NULL
	,nazev NVARCHAR(50) NULL
	,Materska NCHAR(4) NULL
	,Gen BIT NOT NULL DEFAULT (0));
DECLARE @T_VyrFaze_Run TABLE(
	Poradi INT NOT NULL
	,Cislo INT NOT NULL
	,TypOznaceni NVARCHAR(10) NOT NULL
	,_RayService_Operace NVARCHAR(4) NOT NULL
	,_RAY_ZvyrazneniSeda BIT NULL
	,nazev NVARCHAR(50) NOT NULL
	,Materska NCHAR(4) NULL
	,Gen BIT NOT NULL DEFAULT (0));
DECLARE @T_Operace TABLE(
	ID INT NOT NULL
	,Operace NCHAR(4) NOT NULL
	,nazev NVARCHAR(50) NOT NULL
	,TypOznaceni NVARCHAR(10) NULL);

SELECT
	@IDKusovnik = IdKusovnik
	,@IDVarianta = IdVarianta
FROM TabKmenZbozi
WHERE ID = @ID;

SET @BylaChyba = 0;

BEGIN TRY

	-- hlavička do hlášky
	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Generování výrobních fází%')
		INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Generování výrobních fází');
			
	INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
	INSERT INTO #TabExtKom(Poznamka)
	SELECT (N'< ' +SkupZbo + N' ' + RegCis + N' - ' + Nazev1 + N' >')
	FROM TabKmenZbozi
	WHERE ID = @ID;
	
	/* kontroly */
	-- neexistující změna
	IF NOT EXISTS(SELECT * FROM TabCzmeny WHERE ID = @IDZmeny)
		BEGIN
			RAISERROR (N'Neplatná hodnota vybrané změny!',16,1);
			RETURN;
		END;
		
	-- vybraná změna je platná
	IF (SELECT Platnost FROM TabCzmeny WHERE ID = @IDZmeny) = 1
		BEGIN
			RAISERROR (N'Nelze vybrat platnou změnu!',16,1);
			RETURN;
		END;
		
	-- již probíhá změna
	IF EXISTS(SELECT *
			FROM TabCzmeny
			WHERE TabCZmeny.ID IN 
				(SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM TabAltKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM TabAltKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabAltPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabAltPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabAltNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabAltNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDKusovnik 
				UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDKusovnik)
				AND TabCZmeny.Platnost = 0
				AND TabCZmeny.ID <> @IDZmeny)
		BEGIN
			RAISERROR (N'Na dílci se změna již provádí - jiná, než byla vybrána při spuštení akce!',16,1);
			RETURN;
		END;
	
	/* spuštění přečíslování */
	BEGIN TRY
		
		EXEC [dbo].[hpx_RayService_TPVVyrFazePrecislovani]
			1	-- @GenVyrFaze BIT / voláno z generování výrobních fází?
			,@IDZmeny	-- @IDZmeny INT / ID vybrané změny
			,1			-- změna názvu
			,@ID		-- @ID INT / ID v TabKmenZbozi
			,@ByloPrecislovano OUT	-- zda bylo přečíslováno
			
		INSERT INTO #TabExtKom(Poznamka)
		VALUES(N'(i) - přečíslování operací - ' + CASE WHEN @ByloPrecislovano = 1 THEN 'OK' ELSE N'proběhlo již dříve' END);
		
		IF @ByloPrecislovano = 1
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(N'(i) - pro vybranou změnu bylo založeno změnové řízení');
	
	END TRY
	BEGIN CATCH
		
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR (N'Přečíslování operací: %s',16,1,@ErrorMessage);
		
	END CATCH;
	
	/* kontroly - pokračování */
	
	-- ** kontroly výrobních fází
	
	-- probíhá jíž změna - vybranná
	IF EXISTS(SELECT *
			FROM TabCzmeny
			WHERE TabCZmeny.ID IN 
				(SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM TabAltKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM TabAltKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabAltPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabAltPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabAltNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabAltNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDKusovnik 
				UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDKusovnik)
				AND TabCZmeny.Platnost = 0
				AND TabCZmeny.ID = @IDZmeny)
		SET @ZmenaJizProbiha = 1;
	ELSE
		SET @ZmenaJizProbiha = 0;
		
	-- tabulka výrobních fází pro kontrolu	
	INSERT INTO @T_VyrFaze(
		Cislo
		,TypOznaceni
		,_RayService_Operace
		,nazev)	
	SELECT DISTINCT 
		F.IDTypPostup
		,P.TypOznaceni
		,PE._RayService_Operace
		,P.nazev
	FROM TabKvazby K
		INNER JOIN Tabx_RayService_MatVyrFaze F ON K.nizsi = F.IDKmenZbozi
		LEFT OUTER JOIN TabTypPostup P ON F.IDTypPostup = P.Cislo
		LEFT OUTER JOIN TabTypPostup_EXT PE ON P.ID = PE.ID
		LEFT OUTER JOIN TabCzmeny VZmenaOd ON K.ZmenaOd = VZmenaOd.ID
		LEFT OUTER JOIN TabCzmeny VZmenaDo ON K.ZmenaDo = VZmenaDo.ID
	WHERE K.vyssi = @IDKusovnik
		AND (K.IDVarianta IS NULL OR K.IDVarianta = @IDVarianta)
		AND ((@ZmenaJizProbiha = 1 AND K.ZmenaOd = @IDZmeny)
			OR (@ZmenaJizProbiha = 0 AND (VZmenaOd.platnostTPV = 1 AND VZmenaOd.datum <= GETDATE())
				AND	(VZmenaDo.platnostTPV = 0 
						OR K.ZmenaDo IS NULL 
						OR (VZmenaDo.platnostTPV = 1 AND VZmenaDo.datum > GETDATE()))));
						
	-- nejsou žádé výrobní fáze
	IF NOT EXISTS(SELECT * FROM @T_VyrFaze)
		BEGIN
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(N'X - Materiál dílce neobsahuje žádné výrobní fáze');
			RETURN;
		END;
	
	-- chybí vazba na typovou operaci
	IF EXISTS(SELECT * FROM @T_VyrFaze WHERE _RayService_Operace IS NULL)
		BEGIN
		
			SET @BylaChyba = 1;
		
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(N'* Následující výrobní fáze přidružené materiálu nemají vyplněno v typových operacích Pořadí operace:');
		
			INSERT INTO #TabExtKom(Poznamka)
			SELECT CAST(Cislo as NVARCHAR) + ISNULL((N' - ' + TypOznaceni),N'' ) + N' - ' + nazev
			FROM @T_VyrFaze
			WHERE _RayService_Operace IS NULL;
		
		END;
		
	-- nevyplněno typové označení
	IF EXISTS(SELECT * FROM @T_VyrFaze WHERE _RayService_Operace IS NOT NULL AND ISNULL(TypOznaceni,N'') = N'')
		BEGIN
		
			SET @BylaChyba = 1;
		
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(N'* Následující výrobní fáze přidružené materiálu nemají vyplněno v typových operacích Typové označení:');
		
			INSERT INTO #TabExtKom(Poznamka)
			SELECT CAST(Cislo as NVARCHAR) + N' - ' + nazev
			FROM @T_VyrFaze WHERE nazev IS NOT NULL AND ISNULL(TypOznaceni,N'') = N''
		
		END;
		
	-- tabulka operací pro kontrolu / porovnání
	INSERT @T_Operace(
		ID
		,Operace
		,nazev
		,TypOznaceni)
	SELECT 
		O.ID
		,O.Operace
		,O.nazev
		,O.TypOznaceni
	FROM TabPostup O
		LEFT OUTER JOIN TabCzmeny VZmenaOd ON O.ZmenaOd = VZmenaOd.ID
		LEFT OUTER JOIN TabCzmeny VZmenaDo ON O.ZmenaDo = VZmenaDo.ID
	WHERE O.dilec = @IDKusovnik
		AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
		AND O.Typ = 1	-- pouze jednicové
		AND ((@ZmenaJizProbiha = 1 AND O.ZmenaOd = @IDZmeny)
			OR (@ZmenaJizProbiha = 0 AND (VZmenaOd.platnostTPV = 1 AND VZmenaOd.datum <= GETDATE())
				AND	(VZmenaDo.platnostTPV = 0 
						OR O.ZmenaDo IS NULL 
						OR (VZmenaDo.platnostTPV = 1 AND VZmenaDo.datum > GETDATE()))));
	
	-- kontroly jednotlivých výrobních fází
	DELETE FROM @T_VyrFaze WHERE ISNULL(TypOznaceni,N'') = N'' OR _RayService_Operace IS NULL;
	
	DECLARE CurVF CURSOR LOCAL FAST_FORWARD FOR
		SELECT
			Cislo
			,nazev
			,TypOznaceni
		FROM @T_VyrFaze; -- {select}
	OPEN CurVF;
	FETCH NEXT FROM CurVF INTO @VF_Cislo, @VF_nazev, @VF_TypOznaceni ; -- {proměnné}
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurVF
			
			BEGIN TRY
			
				--  pro typové označení neexistuje operace - zjistí, zda v Číselníku typových operací existuje Jednicová operace stejného Typového označení
				IF NOT EXISTS(SELECT * FROM @T_Operace
							WHERE TypOznaceni = @VF_TypOznaceni)
					BEGIN
						--	neexistuje - akce se přeruší s příslušnou hláškou
						IF NOT EXISTS(SELECT * FROM TabTypPostup
									WHERE TypOznaceni = @VF_TypOznaceni AND typ = 1)
							RAISERROR(N'Pro typové označení %s neexistuje jednicová operace v technologickém postupu ani v typových operacích',16,1,@VF_TypOznaceni);
						
						-- existuje více v typových pro typové ozn.
						IF EXISTS(SELECT * FROM TabTypPostup
									WHERE TypOznaceni = @VF_TypOznaceni AND typ = 1
								GROUP BY TypOznaceni
								HAVING COUNT(*) > 1)
							RAISERROR(N'Pro typové označení %s neexistuje jednicová operace v technologickém postupu a více v typových operacích',16,1,@VF_TypOznaceni);
						
						IF EXISTS(SELECT * FROM TabTypPostup
									WHERE TypOznaceni = @VF_TypOznaceni AND typ = 1)
							UPDATE @T_VyrFaze SET
								Gen = 1
							WHERE Cislo = @VF_Cislo;
						
					END;
				
				-- v technologickém postupu existuje Jednicová operace stejného Typového označení - tzv. Mateřská
				IF EXISTS(SELECT * FROM @T_Operace
							WHERE TypOznaceni = @VF_TypOznaceni
						GROUP BY TypOznaceni
						HAVING COUNT(*) > 1)
					RAISERROR(N'Pro typové označení %s existuje více jednicových operací v technologickém postupu',16,1,@VF_TypOznaceni);
				
			END TRY
			BEGIN CATCH
				SELECT @ErrorMessage = ERROR_MESSAGE();
				INSERT INTO #TabExtKom(Poznamka)
				VALUES(N'* Kontrola výrobní fáze ' + CAST(@VF_Cislo as NVARCHAR) + ' - ' + @VF_TypOznaceni + ' - ' + @VF_nazev + N': ' + @ErrorMessage);
			END CATCH;
			
			-- konec akce v kurzoru CurVF
		FETCH NEXT FROM CurVF INTO @VF_Cislo, @VF_nazev, @VF_TypOznaceni; -- {proměnné}
		END;
	CLOSE CurVF;
	DEALLOCATE CurVF;
	
	-- doplníme číslo dohledné mateřské operace
	UPDATE VF SET
		VF.Materska = O.Operace
	FROM @T_VyrFaze VF
		INNER JOIN @T_Operace O ON VF.TypOznaceni = O.TypOznaceni;
		
	-- pro jistotu ještě kontrola na NULL mateřskou operaci
	IF @BylaChyba = 0 
		AND EXISTS(SELECT * FROM @T_VyrFaze WHERE Materska IS NULL AND Gen = 0)
		BEGIN
			SET @BylaChyba = 1;
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(N'* Existence prázdná hodnoty mateřské operace po všech kontrolách');
		END;
	
	-- byla chyba - nepokračujeme
	IF @BylaChyba = 1
		RETURN;
		

	
	/* funkční tělo procedury */
	
	-- naplníme tabulku pro vkládání operací
	INSERT INTO @T_VyrFaze_Run(
		Poradi
		,Cislo
		,TypOznaceni
		,_RayService_Operace
		,_RAY_ZvyrazneniSeda
		,nazev
		,Materska
		,Gen)
	SELECT 
		ROW_NUMBER() OVER(ORDER BY K.pozice,F.Poradi) as Poradi
		,P.Cislo
		,P.TypOznaceni
		,PE._RayService_Operace
		,PE._RAY_ZvyrazneniSeda
		,P.nazev
		,VF.Materska
		,VF.Gen
	FROM TabKvazby K
		INNER JOIN Tabx_RayService_MatVyrFaze F ON K.nizsi = F.IDKmenZbozi
		INNER JOIN TabTypPostup P ON F.IDTypPostup = P.Cislo
		INNER JOIN TabTypPostup_EXT PE ON P.ID = PE.ID
		INNER JOIN @T_VyrFaze VF ON F.IDTypPostup = VF.Cislo 
		LEFT OUTER JOIN TabCzmeny VZmenaOd ON K.ZmenaOd = VZmenaOd.ID
		LEFT OUTER JOIN TabCzmeny VZmenaDo ON K.ZmenaDo = VZmenaDo.ID
	WHERE K.vyssi = @IDKusovnik
		AND (K.IDVarianta IS NULL OR K.IDVarianta = @IDVarianta)
		AND ((@ZmenaJizProbiha = 1 AND K.ZmenaOd = @IDZmeny)
			OR (@ZmenaJizProbiha = 0 AND (VZmenaOd.platnostTPV = 1 AND VZmenaOd.datum <= GETDATE())
				AND	(VZmenaDo.platnostTPV = 0 
						OR K.ZmenaDo IS NULL 
						OR (VZmenaDo.platnostTPV = 1 AND VZmenaDo.datum > GETDATE()))));
	
	-- odtraníme duplicity
	WITH Dupl AS 
		(SELECT 
			Cislo
			,ROW_NUMBER() OVER(PARTITION BY Cislo ORDER BY Poradi ASC) as PoradiDupl
		FROM @T_VyrFaze_Run)
	DELETE FROM Dupl WHERE PoradiDupl > 1;
	
	-- odstraníme, kde už režijní operace daného typového označení existuje
	DELETE VF
	FROM @T_VyrFaze_Run VF
		INNER JOIN TabPostup O ON VF.TypOznaceni = O.TypOznaceni AND VF._RayService_Operace = O.Operace AND O.Typ = 0 -- režijní
		LEFT OUTER JOIN TabCzmeny VZmenaOd ON O.ZmenaOd = VZmenaOd.ID
		LEFT OUTER JOIN TabCzmeny VZmenaDo ON O.ZmenaDo = VZmenaDo.ID
	WHERE O.dilec = @IDKusovnik
		AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
		AND ((@ZmenaJizProbiha = 1 AND O.ZmenaOd = @IDZmeny)
			OR (@ZmenaJizProbiha = 0 AND (VZmenaOd.platnostTPV = 1 AND VZmenaOd.datum <= GETDATE())
				AND	(VZmenaDo.platnostTPV = 0 
						OR O.ZmenaDo IS NULL 
						OR (VZmenaDo.platnostTPV = 1 AND VZmenaDo.datum > GETDATE()))));
	
	-- je co zpracovávat
	IF EXISTS (SELECT * FROM @T_VyrFaze_Run)
		BEGIN
		
			-- kontrola, jednicove operace pro generovani maji sva poradova cisla
			IF EXISTS(SELECT * FROM @T_VyrFaze_Run WHERE Gen = 1)
				AND EXISTS(SELECT * FROM @T_VyrFaze_Run VF
									INNER JOIN TabTypPostup P ON VF.TypOznaceni = P.TypOznaceni AND P.typ = 1 -- jednicove
									LEFT OUTER JOIN TabTypPostup_EXT PE ON P.ID = PE.ID
								WHERE Gen = 1
									AND PE._RayService_Operace IS NULL)
				BEGIN
						
					INSERT INTO #TabExtKom(Poznamka)
					VALUES(N'* Následující Typová označení nemají v typových operacích u jednicových operací vyplněno Pořadí operace pro potřeby generování:');
				
					INSERT INTO #TabExtKom(Poznamka)
					SELECT DISTINCT VF.TypOznaceni
					FROM @T_VyrFaze_Run VF
						INNER JOIN TabTypPostup P ON VF.TypOznaceni = P.TypOznaceni AND P.typ = 1 -- jednicove
						LEFT OUTER JOIN TabTypPostup_EXT PE ON P.ID = PE.ID
					WHERE Gen = 1
						AND PE._RayService_Operace IS NULL;
						
					RETURN;
					
				END;
		
			SET @TranCountPred=@@trancount;
			IF @TranCountPred=0 BEGIN TRAN;
			
				-- generování konstrukce pro danou změnu
				IF @ZmenaJizProbiha = 0
					BEGIN
						SET @FlagZdvojeni = 1
						EXEC dbo.hp_ZdvojeniKonstrukceATech 
							@IDVyssi = @ID
							,@IDZmena = @IDZmeny;
						SET @FlagZdvojeni = NULL;
						
						INSERT INTO #TabExtKom(Poznamka)
						VALUES(N'(i) - pro vybranou změnu bylo založeno změnové řízení');
					END;
				
				-- založení jedicových operací
				IF EXISTS(SELECT * FROM @T_VyrFaze_Run WHERE Gen = 1)
					BEGIN
					
						INSERT INTO TabPostup(
							dilec
							,IDVarianta
							,ZmenaOd
							,Operace
							,typ
							,nazev
							,pracoviste
							,IDkooperace
							,tarif
							,TBC
							,TBC_T
							,TBC_KC
							,TEC
							,TEC_T
							,TEC_KC
							,TAC
							,TAC_T
							,TAC_KC
							,KoopMnozstvi
							,Poznamka
							,PocetLidi
							,PocetKusu
							,PocetStroju
							,IDObrazek
							,PlanDavka
							,MeziOperCas
							,MeziOperCas_T
							,ZpusobZaplanovani
							,TypOznaceni
							,KVO
							,ParKP_ParalelZpracTranDavek
							,ParKP_PovolitPreruseniTranDavky
							,ParKP_PovolitPreruseniOperace
							,ParKP_ZpusobPouzitiTBC
							,ParKP_ZpusobPouzitiTEC
							,Konf_ZahrnoutDoKapacPlan
							,ParKP_ZpusobBlokovaniKapacit
							,TBC_Obsluhy
							,TBC_Obsluhy_T
							,TEC_Obsluhy
							,TEC_Obsluhy_T
							,TAC_Obsluhy
							,TAC_Obsluhy_T
							,VyraditZKontrolyPosloupOper)
						SELECT 
							@IDKusovnik
							,@IDVarianta
							,@IDZmeny
							,OE._RayService_Operace
							,O.typ
							,O.nazev
							,O.pracoviste
							,O.IDkooperace
							,O.tarif
							,O.TBC
							,O.TBC_T
							,O.TBC_KC
							,O.TEC
							,O.TEC_T
							,O.TEC_KC
							,O.TAC
							,O.TAC_T
							,O.TAC_KC
							,O.KoopMnozstvi
							,O.Poznamka
							,O.PocetLidi
							,O.PocetKusu
							,O.PocetStroju
							,O.IDObrazek
							,O.PlanDavka
							,O.MeziOperCas
							,O.MeziOperCas_T
							,O.ZpusobZaplanovani
							,O.TypOznaceni
							,O.KVO
							,O.ParKP_ParalelZpracTranDavek
							,O.ParKP_PovolitPreruseniTranDavky
							,O.ParKP_PovolitPreruseniOperace
							,O.ParKP_ZpusobPouzitiTBC
							,O.ParKP_ZpusobPouzitiTEC
							,O.Konf_ZahrnoutDoKapacPlan
							,O.ParKP_ZpusobBlokovaniKapacit
							,O.TBC_Obsluhy
							,O.TBC_Obsluhy_T
							,O.TEC_Obsluhy
							,O.TEC_Obsluhy_T
							,O.TAC_Obsluhy
							,O.TAC_Obsluhy_T
							,O.VyraditZKontrolyPosloupOper
						FROM 
							(SELECT DISTINCT TypOznaceni
							FROM @T_VyrFaze_Run WHERE Gen = 1) as T
							INNER JOIN TabTypPostup O ON T.TypOznaceni = O.TypOznaceni AND O.typ = 1
							INNER JOIN TabTypPostup_EXT OE ON O.ID = OE.ID;
						
						UPDATE VF SET
							VF.Materska = O.Operace
						FROM @T_VyrFaze_Run VF
							INNER JOIN TabPostup O ON VF.TypOznaceni = O.TypOznaceni AND O.typ = 1
						WHERE O.dilec = @IDKusovnik
							AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
							AND O.ZmenaOd = @IDZmeny
							AND VF.Materska IS NULL;
						
					END;				
				
				-- generujeme režijní operace
				
				INSERT INTO TabPostup(
					dilec
					,IDVarianta
					,typ
					,ZmenaOd
					,ZmenaDo
					,Operace
					,nazev
					,pracoviste
					,IDkooperace
					,TBC
					,TBC_T
					,TBC_KC
					,TEC
					,TEC_T
					,TEC_KC
					,KoopMnozstvi
					,Poznamka
					,CisloTypOperace
					,PocetLidi
					,PocetKusu
					,PocetStroju
					,IDObrazek
					,DatPorizeni
					,Autor
					,PlanDavka
					,MeziOperCas
					,MeziOperCas_T
					,ZpusobZaplanovani
					,TypOznaceni
					,DavkaTPV
					,KVO
					,ParKP_ParalelZpracTranDavek
					,ParKP_PovolitPreruseniTranDavky
					,ParKP_PovolitPreruseniOperace
					,ParKP_ZpusobPouzitiTBC
					,ParKP_ZpusobPouzitiTEC
					,IDZakazModif
					,Konf_ZahrnoutDoKapacPlan
					,ParKP_ZpusobBlokovaniKapacit
					,Odvadeci
					,TBC_Obsluhy
					,TBC_Obsluhy_T
					,TEC_Obsluhy
					,TEC_Obsluhy_T
					,TAC_Obsluhy_J
					,TAC_Obsluhy_J_T
					,TAC_Obsluhy
					,TAC_Obsluhy_T
					,IDStroje
					,Koop_KalkulacniDavka
					,Koop_CenaDavky
					,Koop_CenaMJ)
				SELECT
					O.dilec
					,O.IDVarianta
					,0 -- režijní
					,O.ZmenaOd
					,O.ZmenaDo
					,R._RayService_Operace
					,R.nazev -- název z typové
					,O.pracoviste
					,O.IDkooperace
					,O.TBC
					,O.TBC_T
					,O.TBC_KC
					,O.TEC
					,O.TEC_T
					,O.TEC_KC
					,O.KoopMnozstvi
					,O.Poznamka
					,O.CisloTypOperace
					,O.PocetLidi
					,O.PocetKusu
					,O.PocetStroju
					,O.IDObrazek
					,GETDATE()
					,SUSER_SNAME()
					,O.PlanDavka
					,O.MeziOperCas
					,O.MeziOperCas_T
					,O.ZpusobZaplanovani
					,R.TypOznaceni -- typové označení z typové
					,O.DavkaTPV
					,O.KVO
					,O.ParKP_ParalelZpracTranDavek
					,O.ParKP_PovolitPreruseniTranDavky
					,O.ParKP_PovolitPreruseniOperace
					,O.ParKP_ZpusobPouzitiTBC
					,O.ParKP_ZpusobPouzitiTEC
					,O.IDZakazModif
					,O.Konf_ZahrnoutDoKapacPlan
					,O.ParKP_ZpusobBlokovaniKapacit
					,O.Odvadeci
					,O.TBC_Obsluhy
					,O.TBC_Obsluhy_T
					,O.TEC_Obsluhy
					,O.TEC_Obsluhy_T
					,O.TAC_Obsluhy_J
					,O.TAC_Obsluhy_J_T
					,O.TAC_Obsluhy
					,O.TAC_Obsluhy_T
					,O.IDStroje
					,O.Koop_KalkulacniDavka
					,O.Koop_CenaDavky
					,O.Koop_CenaMJ
				FROM TabPostup O
					INNER JOIN @T_VyrFaze_Run R ON O.Operace = R.Materska
				WHERE O.dilec = @IDKusovnik
					AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
					AND O.ZmenaOd = @IDZmeny;
				
			COMMIT;
			
			-- doplnění EXT informací  na vygenerované režijní operace
			WITH O AS (
				SELECT
					O.ID
					,R._RAY_ZvyrazneniSeda
				FROM TabPostup O
					INNER JOIN @T_VyrFaze_Run R ON O.Operace = R._RayService_Operace
				WHERE O.dilec = @IDKusovnik
					AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
					AND O.ZmenaOd = @IDZmeny)
			MERGE TabPostup_EXT E
			USING O ON E.ID = O.ID
			WHEN MATCHED THEN
				UPDATE SET E._RAY_ZvyrazneniSeda = O._RAY_ZvyrazneniSeda
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (ID,_RAY_ZvyrazneniSeda) VALUES(O.ID, O._RAY_ZvyrazneniSeda);
			
		END;
	
	-- závěrečná hláška
	INSERT INTO #TabExtKom(Poznamka)
	VALUES(N'OK - výrobní fáze ' + CASE WHEN EXISTS(SELECT * FROM @T_VyrFaze_Run) THEN 'vygenerovány' ELSE N'byly vygenerovány již dříve' END);
	
END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	INSERT INTO #TabExtKom(Poznamka)
	VALUES(N'!!! CHYBA !!! - ' + @ErrorMessage);
	
END CATCH;

GO

