USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVVyrFazePrecislovani]    Script Date: 26.06.2025 8:58:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Přešíslování v souvislosti s výrobními fázemi
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_TPVVyrFazePrecislovani]
	@GenVyrFaze BIT		-- voláno z generování výrobních fází?
	,@IDZmeny INT		-- ID vybrané změny
	,@ZmenNazev BIT		-- změnit názvy dle typových operací
	,@ID INT			-- ID v TabKmenZbozi
	,@Precislovat BIT = 0 OUT		-- návratová hodnota zda bylo přečíslováno - kvůli generování fází
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @IDKusovnik INT;
DECLARE @IDVarianta INT;
DECLARE @ZmenaJizProbiha BIT;
DECLARE @FlagZdvojeni BIT;
DECLARE @TranCountPred INT;
DECLARE @PosledniOperace SMALLINT;
DECLARE @Operace TABLE(
	PuvodniOperace CHAR(4) NOT NULL
	,NovaOperace CHAR(4) NULL
	,typ TINYINT NOT NULL
	,TypOznaceni NVARCHAR(10) NULL
	,nazev NVARCHAR(50) NOT NULL
	,Gen TINYINT NOT NULL DEFAULT (0))

SELECT
	@IDKusovnik = IdKusovnik
	,@IDVarianta = IdVarianta
FROM TabKmenZbozi
WHERE ID = @ID;

SET @ZmenaJizProbiha = 0;

BEGIN TRY
	
	-- hlavička do hlášky
	IF @GenVyrFaze = 0
		BEGIN
				
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Přečíslování operací%')
				INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Přečíslování operací');
					
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
			INSERT INTO #TabExtKom(Poznamka)
			SELECT (N'< ' +SkupZbo + N' ' + RegCis + N' - ' + Nazev1 + N' >')
			FROM TabKmenZbozi
			WHERE ID = @ID;
			
		END;
	
	/* kontroly */
	
	-- kontrolujeme jen to, co neni kontrolováno už při generování vyrbních fází
	IF @GenVyrFaze = 0
		BEGIN
		
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
				
		END;
	
	/* funkční tělo procedury */
	
	-- ** existují nepřečíslované operace
	-- probíhá změna - ta co je vybraná
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
				
	-- naplníme pomocnou tabulku
	INSERT INTO @Operace(
		PuvodniOperace
		,typ
		,TypOznaceni
		,nazev)
	SELECT
		O.Operace
		,O.typ
		,O.TypOznaceni
		,O.nazev
	FROM TabPostup O
		LEFT OUTER JOIN TabCzmeny VZmenaOd ON O.ZmenaOd = VZmenaOd.ID
		LEFT OUTER JOIN TabCzmeny VZmenaDo ON O.ZmenaDo = VZmenaDo.ID
	WHERE O.dilec = @IDKusovnik
		AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
		AND (
			(@ZmenaJizProbiha = 0
			AND (VZmenaOd.platnostTPV = 1 AND VZmenaOd.datum <= GETDATE())
			AND	(VZmenaDo.platnostTPV = 0 
					OR O.ZmenaDo IS NULL 
					OR (VZmenaDo.platnostTPV = 1 AND VZmenaDo.datum > GETDATE())))
			OR (@ZmenaJizProbiha = 1 AND O.ZmenaOd = @IDZmeny)
			);
	
	-- duplicita tpoveho oznaceni v jednicovych operacich
	IF EXISTS(SELECT * FROM @Operace
				WHERE typ = 1
					AND TypOznaceni IS NOT NULL
				GROUP BY TypOznaceni
				HAVING COUNT(*) > 1)
		BEGIN
			RAISERROR(N'Technologický postup obsahuje jednicové operace s duplicitním typovým označením!',16,1);
			RETURN;
		END;
	
	-- co se bude precislovavat
	UPDATE O SET
		O.Gen = 
			CASE 
				WHEN O.typ = 1 AND TJE._RayService_Operace IS NOT NULL THEN
					CASE WHEN O.PuvodniOperace <> TJE._RayService_Operace THEN 1 ELSE 0 END
				WHEN O.typ = 0 AND TRE._RayService_Operace IS NOT NULL THEN
					CASE WHEN O.PuvodniOperace <> TRE._RayService_Operace THEN 1 ELSE 0 END
				ELSE
					CASE WHEN LEN(LTRIM(RTRIM(O.PuvodniOperace))) < 3 OR E._RayService_Operace IS NOT NULL 
					THEN 2 ELSE 0 END
				END
		,O.NovaOperace = 
			CASE 
				WHEN O.typ = 1 AND TJE._RayService_Operace IS NOT NULL THEN
					CASE WHEN O.PuvodniOperace <> TJE._RayService_Operace THEN TJE._RayService_Operace ELSE O.PuvodniOperace END
				WHEN O.typ = 0 AND TRE._RayService_Operace IS NOT NULL THEN
					CASE WHEN O.PuvodniOperace <> TRE._RayService_Operace THEN TRE._RayService_Operace ELSE O.PuvodniOperace END
				ELSE
					CASE WHEN LEN(LTRIM(RTRIM(O.PuvodniOperace))) < 3 OR E._RayService_Operace IS NOT NULL 
					THEN N'9999' ELSE O.PuvodniOperace END
				END
	FROM @Operace O
		LEFT OUTER JOIN TabTypPostup TJ ON O.typ = 1 AND O.typ = TJ.typ AND O.TypOznaceni = TJ.TypOznaceni
		LEFT OUTER JOIN TabTypPostup_EXT TJE ON TJ.ID = TJE.ID
		LEFT OUTER JOIN TabTypPostup TR ON O.typ = 0 AND O.typ = TR.typ AND O.TypOznaceni = TR.TypOznaceni AND O.nazev = TR.nazev
		LEFT OUTER JOIN TabTypPostup_EXT TRE ON TR.ID = TRE.ID
		LEFT OUTER JOIN TabTypPostup_EXT E ON O.PuvodniOperace = E._RayService_Operace;
	
	IF EXISTS(SELECT * FROM @Operace WHERE Gen > 0)
		SET @Precislovat = 1;		
	
	-- bude se přečíslovávat	
	IF @Precislovat = 1
		BEGIN
		
			-- precislovani ne-typovych operaci
			IF EXISTS(SELECT * FROM @Operace WHERE Gen = 2)
				BEGIN
					
					SELECT @PosledniOperace = MAX(Operace)
					FROM 
						(SELECT CAST(PE._RayService_Operace as NCHAR(4)) as Operace
						FROM TabTypPostup_EXT PE
						INNER JOIN TabTypPostup P ON PE.ID = P.ID
						UNION
						SELECT O.Operace
						FROM TabPostup O
							LEFT OUTER JOIN TabCzmeny VZmenaOd ON O.ZmenaOd = VZmenaOd.ID
							LEFT OUTER JOIN TabCzmeny VZmenaDo ON O.ZmenaDo = VZmenaDo.ID
						WHERE O.dilec = @IDKusovnik
							AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
							AND (
								(@ZmenaJizProbiha = 0
								AND (VZmenaOd.platnostTPV = 1 AND VZmenaOd.datum <= GETDATE())
								AND	(VZmenaDo.platnostTPV = 0 
										OR O.ZmenaDo IS NULL 
										OR (VZmenaDo.platnostTPV = 1 AND VZmenaDo.datum > GETDATE())))
								OR (@ZmenaJizProbiha = 1 AND O.ZmenaOd = @IDZmeny)
								)) as T;
					
					WITH NeTyp AS (
						SELECT
							ROW_NUMBER() OVER(ORDER BY PuvodniOperace) as Poradi
							,NovaOperace
						FROM @Operace
						WHERE Gen = 2)
					UPDATE NeTyp SET 
						NovaOperace = RIGHT((REPLICATE(CHAR(32),4) + (@PosledniOperace + (Poradi * 10))),4);
					
				END;
			
			IF EXISTS(SELECT * FROM @Operace
				GROUP BY NovaOperace
				HAVING COUNT(*) > 1)
				BEGIN
					RAISERROR(N'Chyba přečíslování: Mechanismus vygeneroval duplicity!',16,1);
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
						
						IF @GenVyrFaze = 0
							INSERT INTO #TabExtKom(Poznamka)
							VALUES(N'(i) - pro vybranou změnu bylo založeno změnové řízení');
					END;
					
				-- přečíslování
				UPDATE O SET
					O.Operace = Z.NovaOperace
					,O.nazev = CASE WHEN @ZmenNazev = 1 AND P.nazev IS NOT NULL THEN P.nazev ELSE O.nazev END
				FROM TabPostup O
					INNER JOIN @Operace Z ON O.Operace = Z.PuvodniOperace
					LEFT OUTER JOIN TabTypPostup_EXT PE ON Z.NovaOperace = PE._RayService_Operace
					LEFT OUTER JOIN TabTypPostup P ON PE.ID = P.ID
				WHERE O.dilec = @IDKusovnik
						AND (O.IDVarianta IS NULL OR O.IDVarianta = @IDVarianta)
						AND O.ZmenaOd = @IDZmeny
				
			COMMIT;
			
			
		END;
	
	-- závěrečná hláška
	IF @GenVyrFaze = 0
		INSERT INTO #TabExtKom(Poznamka)
		SELECT (N'OK - ' + CASE WHEN @Precislovat = 1 THEN N'přečíslováno' ELSE N'přečíslování již proběhlo dříve' END)
		FROM TabKmenZbozi
		WHERE ID = @ID;

END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 --AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = CASE 
		WHEN @FlagZdvojeni = 1 THEN N'Chyba při generování konstrukce a technologie pro vybranou změnu' 
		ELSE ERROR_MESSAGE() END;
	
	IF @GenVyrFaze = 0
		INSERT INTO #TabExtKom(Poznamka)
		SELECT ('!!! CHYBA !!! - ' + @ErrorMessage)
		FROM TabKmenZbozi
		WHERE ID = @ID;
	ELSE
		RAISERROR (@ErrorMessage,16,1);
	
END CATCH;
GO

