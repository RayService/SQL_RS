USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_GenPrMajOZ]    Script Date: 26.06.2025 9:06:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[hpx_RayService_GenPrMajOZ]
	@BrowseID INT			-- zdrojový přehled ID
	,@InfoOut BIT			-- vracet informace o vygenerovaném majetku
	,@TypMaj NVARCHAR(3)	-- typ majetku
	,@ID INT				-- ID zdrojového záznamu
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	
-- =============================================
 
 /* deklarace */
DECLARE @CisloMaj INT;
DECLARE @IDZpracuj INT;
DECLARE @Zpracuj TABLE (
	ID INT IDENTITY(1,1) NOT NULL
	,Nazev1 NVARCHAR(100) NOT NULL
	,Polozka1 NVARCHAR(50) NOT NULL
	,DatumPor DATETIME NULL
	,DatumZav DATETIME NULL
	,Doklad NVARCHAR(20) NOT NULL
	,VyrCislo NVARCHAR(100) NOT NULL
	,CisZam INT NULL
	,Utvar NVARCHAR(30) NULL
	,Mnozstvi INT NOT NULL);
DECLARE @MnozstviCounter INT;
DECLARE @Mnozstvi INT;
DECLARE @IDPrZa INT;

 /* kontroly */

-- špatný vstup
IF @BrowseID NOT IN (2,45,74)
	BEGIN
		RAISERROR (N'Chyba konfigurace: Nepovolená hodnota @BrowseID',16,1);
		RETURN;
	END;
	
-- neznámý typ majetku
IF @TypMaj IS NULL
	OR NOT EXISTS(SELECT * FROM TabMaTyp WHERE TypMaj = @TypMaj)
	BEGIN
		RAISERROR (N'Neplatná hodnota typu majetku. Vyberte hodnotu z návazného číselníku!',16,1);
		RETURN;
	END;
	
-- musí být typu výdejka/výdej v evidenční ceně nebo faktura přijatá
IF @BrowseID IN (45,74)
	AND (SELECT DruhPohybuZbo FROM TabPohybyZbozi WHERE ID = @ID) NOT IN (2,4,18)
	BEGIN
		RAISERROR (N'Neplatný druh dokladu pro spuštění akce. Povoleno pro: Výdej, Výdej v evidenční cena, Faktura přijatá!',16,1);
		RETURN;
	END;
	
IF @BrowseID IN (45,74)
	AND (SELECT DruhPohybuZbo FROM TabPohybyZbozi WHERE ID = @ID) IN (2,4)
	AND (SELECT SkutecneDatReal FROM TabPohybyZbozi WHERE ID = @ID) IS NULL
	BEGIN
		RAISERROR (N'Výdejka / Výdej v evidenční ceně musí být realizován!',16,1);
		RETURN;
	END;
	
/* funkční tělo procedury */
BEGIN TRY

	-- informace - hlavička
	IF @InfoOut = 1
		BEGIN
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Generování protokolu majetku%')
				BEGIN
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Generování protokolu majetku');
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
				END;
		END;
	
	-- hodnoty pro kmenovou kartu
	IF @BrowseID = 2
		INSERT INTO @Zpracuj(
			Nazev1
			,Polozka1
			,DatumPor
			,DatumZav
			,Doklad
			,VyrCislo
			,Mnozstvi)
		SELECT
			CASE WHEN LEN((Nazev2 + CHAR(32) + Nazev1)) > 100 THEN 
				SUBSTRING((Nazev2 + CHAR(32) + Nazev1),1,97) + N'...'
			ELSE (Nazev2 + CHAR(32) + Nazev1) END
			,SkupZbo + CHAR(32) + RegCis
			,GETDATE()
			,GETDATE()
			,N''
			,N''
			,1
		FROM TabKmenZbozi
		WHERE ID = @ID;
	
	-- hodnoty pro položku dokladu OZ
	IF @BrowseID IN (45,74)
		BEGIN
			
			IF EXISTS(SELECT * FROM TabVyrCP WHERE IDPolozkaDokladu = @ID)
				AND (SELECT DruhPohybuZbo FROM TabPohybyZbozi WHERE ID = @ID) IN (2,4)
				INSERT INTO @Zpracuj(
					Nazev1
					,Polozka1
					,DatumPor
					,DatumZav
					,Doklad
					,VyrCislo
					,CisZam
					,Utvar
					,Mnozstvi)
				SELECT
					CASE WHEN LEN((P.Nazev2 + CHAR(32) + P.Nazev1)) > 100 THEN 
							SUBSTRING((P.Nazev2 + CHAR(32) + P.Nazev1),1,97) + N'...'
						ELSE (P.Nazev2 + CHAR(32) + P.Nazev1) END
					,(P.SkupZbo + CHAR(32) + P.RegCis)
					,D.DatRealizace
					,D.DatRealizace
					,D.ParovaciZnak
					,CS.Nazev1
					,Z.Cislo
					,Z.Stredisko
					,CEILING(CP.Mnozstvi)
				FROM TabVyrCP CP
					INNER JOIN TabPohybyZbozi P ON CP.IDPolozkaDokladu = P.ID
					INNER JOIN TabVyrCS CS ON CP.IDVyrCis = CS.ID
					INNER JOIN TabDokladyZbozi D ON P.IDDoklad = D.ID
					LEFT OUTER JOIN TabCisZam Z ON D.CisloZam = Z.Cislo
				WHERE CP.IDPolozkaDokladu = @ID;
			ELSE
				INSERT INTO @Zpracuj(
					Nazev1
					,Polozka1
					,DatumPor
					,DatumZav
					,Doklad
					,VyrCislo
					,CisZam
					,Utvar
					,Mnozstvi)
				SELECT
					(P.Nazev2 + CHAR(32) + P.Nazev1)
					,(P.SkupZbo + CHAR(32) + P.RegCis)
					,CASE WHEN P.DruhPohybuZbo IN (2,4) THEN D.DatRealizace ELSE D.DatPorizeni END
					,CASE WHEN P.DruhPohybuZbo IN (2,4) THEN D.DatRealizace ELSE D.DatPorizeni END
					,D.ParovaciZnak
					,N''
					,CASE WHEN P.DruhPohybuZbo IN (2,4) THEN Z.Cislo END
					,CASE WHEN P.DruhPohybuZbo IN (2,4) THEN Z.Stredisko END
					,CEILING(P.Mnozstvi)
				FROM TabPohybyZbozi P
					INNER JOIN TabDokladyZbozi D ON P.IDDoklad = D.ID
					LEFT OUTER JOIN TabCisZam Z ON D.CisloZam = Z.Cislo
				WHERE P.ID = @ID;
		END;
			
	-- Mnozstvi = 0 - Pryč
	IF EXISTS(SELECT * FROM @Zpracuj WHERE Mnozstvi < 1)
		BEGIN
			IF @InfoOut = 1
				INSERT INTO #TabExtKom(Poznamka)
				SELECT TOP 1 ('X - ' + Polozka1 + ' - ' + Nazev1 + N' - položka má nulové nebo záporné množství')
				FROM @Zpracuj
			RETURN;		
		END;
		
	-- Generujeme protokol
	BEGIN TRAN
	
		DECLARE CurZpracuj CURSOR LOCAL FAST_FORWARD FOR
			SELECT 
				ID
				,Mnozstvi
			FROM @Zpracuj; -- {select}
		OPEN CurZpracuj;
		FETCH NEXT FROM CurZpracuj INTO @IDZpracuj, @Mnozstvi; -- {proměnné}
			WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
			BEGIN
				-- zacatek akce v kurzoru CurZpracuj
				
					SET @MnozstviCounter = 1
					WHILE @MnozstviCounter <= @Mnozstvi
					BEGIN
						SET @CisloMaj = NULL;
						SET @IDPrZa = NULL;
						
						EXEC dbo.hp_Ma_CisloMajetku 
							@MaKar_CisloMaj = @CisloMaj OUTPUT
							,@MaKar_TypMaj = @TypMaj
							,@Stav = 0;
						
						INSERT INTO TabMaPrZa(
							CisloMaj
							,TypMaj
							,Nazev1
							,Polozka1
							,DatumPor
							,DatumZav
							,Doklad
							,VyrCislo
							,IdDrPoUM
							,DatumPlatnostiUM
							,CisZam
							,Utvar
							,Prislusenstvi
							,SKP)
						SELECT
							@CisloMaj
							,@TypMaj
							,Nazev1
							,Polozka1
							,DatumPor
							,DatumZav
							,Doklad
							,VyrCislo
							,CASE WHEN CisZam IS NOT NULL THEN 201 END
							,CASE WHEN CisZam IS NOT NULL THEN ((CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumPor)))) + N'00:00:01.000') END
							,CisZam
							,Utvar
							,0
							,N''
						FROM @Zpracuj
						WHERE ID = @IDZpracuj;
							
						IF @@ERROR <> 0
							BEGIN
								IF @InfoOut = 1
									INSERT INTO #TabExtKom(Poznamka)
									SELECT ('X - ' + Polozka1 + ' - ' + Nazev1 + N' - interní chyba při zakládání protokolu majetku')
									FROM @Zpracuj
									WHERE ID = @IDZpracuj;
								RETURN;	
							END;
						
						SELECT @IDPrZa = SCOPE_IDENTITY();
						
						IF @IDPrZa IS NULL
							BEGIN
								IF @InfoOut = 1
									INSERT INTO #TabExtKom(Poznamka)
									SELECT ('X - ' + Polozka1 + ' - ' + Nazev1 +  N' - interní chyba při zakládání protokolu majetku')
									FROM @Zpracuj
									WHERE ID = @IDZpracuj;
								RETURN;	
							END;
						
						EXEC dbo.hp_Ma_PrZaCistic @IDPrZa;
						
						SET @MnozstviCounter = @MnozstviCounter + 1;
					
					END
				
				-- konec akce v kurzoru CurZpracuj
			FETCH NEXT FROM CurZpracuj INTO @IDZpracuj, @Mnozstvi; -- {proměnné}
			END;
		CLOSE CurZpracuj;
		DEALLOCATE CurZpracuj;
	
	COMMIT;
	
	-- vlozime info
	IF @InfoOut = 1
		INSERT INTO #TabExtKom(Poznamka)
		SELECT ('OK - ' + MIN(Polozka1) + ' - ' + MIN(Nazev1) + N' - vygenerován protokol zavedení (' + CAST(CAST(SUM(Mnozstvi) as INT) as NVARCHAR) + N'x)')
		FROM @Zpracuj;

END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 --AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	RAISERROR (@ErrorMessage,16,1);
	RETURN;
END CATCH;
GO

