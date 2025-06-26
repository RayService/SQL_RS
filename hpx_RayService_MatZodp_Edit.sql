USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_MatZodp_Edit]    Script Date: 26.06.2025 8:56:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RayService_MatZodp_Edit]
	@TypAkce TINYINT						-- typ akce 0-insert/1-update/2-delete
	,@PracPoziceNazev NVARCHAR(255)		-- název pracovní pozice
	,@Dimenze TINYINT					-- hodnota dimenze
	,@ID INT = NULL						-- ID řádku (NULL pro @Akce = 0)
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Editace matice zodpovednosti na postup
-- =============================================

/* deklarace */
DECLARE @IDPostup INT;
DECLARE @IDPracovniPozice INT;
DECLARE @Kontrola TABLE (
	IDPracovniPozice INT NOT NULL
	,Dimenze TINYINT NOT NULL)

/* kontroly */
-- typ akce
IF @TypAkce NOT IN(0,1,2)
	BEGIN
		RAISERROR (N'Neznámý identifikátor typu akce!',16,1);
		RETURN;
	END;
	
-- IDPostup / selectorvurce
IF @TypAkce = 0
	SELECT TOP 1 @IDPostup = CAST(Cislo as INT)
	FROM #TabExtKomPar
	WHERE Popis='STVlastID';
ELSE
	SELECT @IDPostup = IDPostup FROM Tabx_RayService_MatZodp WHERE ID = @ID;

IF @IDPostup IS NULL
	OR NOT EXISTS(SELECT * FROM TabPostup WHERE ID = @IDPostup)
	BEGIN
		RAISERROR (N'Neznámý identifikátor řádku technologického postupu!',16,1);
		RETURN;
	END;

-- Platná změna
IF (SELECT CZ.Platnost FROM TabPostup P INNER JOIN TabCZmeny CZ ON P.ZmenaOd = CZ.ID WHERE P.ID = @IDPostup) = 1
	BEGIN
		RAISERROR (N'Platná změna! Editace není povolena.',16,1);
		RETURN;
	END;

IF @TypAkce = 2
	GOTO SMAZAT

-- Nevybraná pracovní pozice
IF @TypAkce = 0
	AND (@PracPoziceNazev IS NULL
		OR NOT EXISTS(SELECT * FROM TabPracovniPozice WHERE Nazev = @PracPoziceNazev))
	BEGIN
		RAISERROR (N'Chyba: Neplatná hodnota - Pracovní pozice',16,1);
		RETURN;
	END;
		
SELECT @IDPracovniPozice = ID FROM TabPracovniPozice 
WHERE (@TypAkce = 0 AND Nazev = @PracPoziceNazev)
	OR (@TypAkce = 1 AND ID = (SELECT IDPracovniPozice FROM Tabx_RayService_MatZodp WHERE ID = @ID));

IF @IDPracovniPozice IS NULL
	BEGIN
		RAISERROR (N'Chyba: Neznámý identifikátor pracovní pozice',16,1);
		RETURN;
	END;

-- Kontroly pro insert + update
IF @TypAkce IN (0,1)
	BEGIN
	
		-- dimenze
		IF @Dimenze IS NULL
			BEGIN
				RAISERROR (N'Chyba: Neplatná hodnota - Dimenze',16,1);
				RETURN;
			END;
		
		INSERT INTO @Kontrola(
			IDPracovniPozice
			,Dimenze)
		SELECT
			IDPracovniPozice
			,Dimenze
		FROM Tabx_RayService_MatZodp
		WHERE IDPostup = @IDPostup
			AND (@ID IS NULL OR ID <> @ID);
			
		-- Majitel
		IF @Dimenze = 0 
			AND (EXISTS(SELECT * FROM @Kontrola WHERE Dimenze = 0)
				OR EXISTS(SELECT *
						FROM TabPostup P 
							INNER JOIN TabPostup PP ON P.dilec = PP.dilec
										AND ((P.IDZakazModif IS NULL AND PP.IDZakazModif IS NULL) OR P.IDZakazModif = PP.IDZakazModif)
										AND ((P.IDVarianta IS NULL AND PP.IDVarianta IS NULL) OR P.IDVarianta = PP.IDVarianta)
										AND P.ZmenaOd = PP.ZmenaOd
										AND P.ID <> PP.ID
							INNER JOIN Tabx_RayService_MatZodp M ON PP.ID = M.IDPostup
						WHERE P.ID = @IDPostup
							AND M.Dimenze = 0))
			BEGIN
				RAISERROR (N'Chyba logické kontroly dat: Majitel - může být k na vyráběném dílci pouze jednou',16,1);
				RETURN;
			END;
			
		IF EXISTS(SELECT * FROM @Kontrola)
			BEGIN
				
				-- Odpovídá
				IF @Dimenze = 1 AND EXISTS(SELECT * FROM @Kontrola WHERE Dimenze = 1)
					BEGIN
						RAISERROR (N'Chyba logické kontroly dat: Odpovídá - může být k operaci pouze jednou',16,1);
						RETURN;
					END;
				
				-- Provádí
				IF @Dimenze = 2
					BEGIN
						
						-- JDO: Zrušeno - 10.2.2014 (přání Zálešák)
						--IF EXISTS(SELECT * FROM @Kontrola WHERE Dimenze = 2)
						--	BEGIN
						--		RAISERROR (N'Chyba logické kontroly dat: Provádí - může být k operaci pouze jednou',16,1);
						--		RETURN;
						--	END;
							
						IF EXISTS(SELECT * FROM @Kontrola WHERE IDPracovniPozice = @IDPracovniPozice AND Dimenze = 3) /* Spolupracuje */
							BEGIN
								RAISERROR (N'Chyba logické kontroly dat: Provádí - nemůže být zároveň Spolupracuje',16,1);
								RETURN;
							END;
							
					END;
					
				-- Spolupracuje
				IF @Dimenze = 3 
					AND EXISTS(SELECT * FROM @Kontrola WHERE IDPracovniPozice = @IDPracovniPozice AND Dimenze = 2) /* Provádí */
					BEGIN
						RAISERROR (N'Chyba logické kontroly dat: Spolupracuje - nemůže být zároveň Provádí',16,1);
						RETURN;
					END;
				
			END;
			
	END;


/* funkční tělo procedury */

-- ** Nový
IF @TypAkce = 0
	INSERT INTO Tabx_RayService_MatZodp(
		IDPostup
		,dilec
		,IDPracovniPozice
		,Dimenze)
	SELECT
		@IDPostup
		,dilec
		,@IDPracovniPozice
		,@Dimenze
	FROM TabPostup
	WHERE ID = @IDPostup;
	
-- ** Oprava
IF @TypAkce = 1
	AND EXISTS(SELECT * FROM Tabx_RayService_MatZodp WHERE ID = @ID AND Dimenze <> @Dimenze)
	UPDATE Tabx_RayService_MatZodp SET
		Dimenze = @Dimenze
		,DatZmeny = GETDATE()
		,Zmenil= SUSER_SNAME()
	WHERE ID = @ID;

-- ** Zrušit
SMAZAT:
IF @TypAkce = 2
	DELETE FROM Tabx_RayService_MatZodp WHERE ID = @ID;
GO

