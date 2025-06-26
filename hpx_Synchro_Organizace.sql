USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_Organizace]    Script Date: 26.06.2025 8:47:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 28.4.2011
-- Description:	Spustí synchronizaci oragnizace a jejích kontaktů a vztahů
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_Organizace]
	@TypSynchro TINYINT			-- Identifikátor synchronizace
	,@ZDokladu BIT = 0			-- volání z dokladu 1-Ano,0-ne
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@IDOrgZdroj INT							-- ID v TabCisOrg
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @CisloOrgZdroj INT;
DECLARE @IDCisKOs INT;
DECLARE @IDVztahOrgKOs INT;
DECLARE @IDKontakty INT;

/* funkční tělo procedury */
SELECT @CisloOrgZdroj = CisloOrg FROM TabCisOrg WHERE ID = @IDOrgZdroj;

BEGIN TRY

	-- * synchronizace Organizace
	EXEC [dbo].[hpx_Synchro_CisOrgZdroj]
		@CisloOrgZdroj			-- Číslo organizace - ve zdrojové DB
		,@TypSynchro		-- Identifikátor synchronizace
		,1					-- 0-INSERT,1-UPDATE,2-DELETE,9-test existence
		,@Error OUT			-- návratová hodnota chyby
		,@ZDokladu;			-- volání z dokladu 1-Ano,0-ne
	
	IF @Error IS NOT NULL
		BEGIN
			RAISERROR (@Error,16,1);
			RETURN;
		END;
	
	-- * synchronizace Kontaktních osob
	DECLARE CurCisKOs CURSOR LOCAL FAST_FORWARD FOR
		SELECT DISTINCT IDCisKOs
		FROM TabVztahOrgKOs
		WHERE IDOrg = @IDOrgZdroj;
	OPEN CurCisKOs;
	FETCH NEXT FROM CurCisKOs INTO @IDCisKOs;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurCisKOs
			
			EXEC [dbo].[hpx_Synchro_CisKOsZdroj]
				@IDCisKOs		-- ID kontaktní osoby - ve zdrojové DB
				,@TypSynchro		-- Identifikátor synchronizace
				,1				-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
				,@Error OUT		-- návratová hodnota chyby
				,@ZDokladu;		-- volání z dokladu 1-Ano,0-ne
				
			IF @Error IS NOT NULL
				BEGIN
					RAISERROR (@Error,16,1);
					RETURN;
				END;
			
			-- konec akce v kurzoru CurCisKOs
		FETCH NEXT FROM CurCisKOs INTO @IDCisKOs;
		END;
	CLOSE CurCisKOs;
	DEALLOCATE CurCisKOs;
	
	-- * synchronizace vztahů organizací a kontaktních osob
	DECLARE CurVztahOrgKOs CURSOR LOCAL FAST_FORWARD FOR
		SELECT 
			ID
			,IDCisKOs
		FROM TabVztahOrgKOs
		WHERE IDOrg = @IDOrgZdroj;
	OPEN CurVztahOrgKOs;
	FETCH NEXT FROM CurVztahOrgKOs INTO @IDVztahOrgKOs, @IDCisKOs;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurVztahOrgKOs
			
			EXEC [dbo].[hpx_Synchro_VztahOrgKOsZdroj]
				@IDVztahOrgKOs			-- ID vztahu - ve zdrojové DB
				,@CisloOrgZdroj				-- Číslo organizace - ve zdrojové DB
				,@IDCisKOs				-- ID kontaktní osoby - ve zdrojové DB
				,@TypSynchro			-- Identifikátor synchronizace
				,1						-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
				,@Error OUT				-- návratová hodnota chyby
				,@ZDokladu;				-- volání z dokladu 1-Ano,0-ne
			
			IF @Error IS NOT NULL
				BEGIN
					RAISERROR (@Error,16,1);
					RETURN;
				END;
				
			-- * synchronizace kontaktů vztahu
			DECLARE CurKontaktyVztah CURSOR LOCAL FAST_FORWARD FOR
				SELECT ID				
				FROM TabKontakty
				WHERE IDVztahKOsOrg = @IDVztahOrgKOs;
			OPEN CurKontaktyVztah;
			FETCH NEXT FROM CurKontaktyVztah INTO @IDKontakty;
				WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
				BEGIN
					-- zacatek akce v kurzoru CurKontaktyVztah
					
					EXEC [dbo].[hpx_Synchro_KontaktyZdroj]
						@IDKontakty			-- ID kontaktu - ve zdrojové DB
						,@CisloOrgZdroj			-- Číslo organizace - ve zdrojové DB
						,@IDCisKOs			-- ID kontaktní osoby - ve zdrojové DB
						,@IDVztahOrgKOs		-- ID vztahu - ve zdrojové DB
						,@TypSynchro		-- Identifikátor synchronizace
						,1					-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
						,@Error OUT			-- návratová hodnota chyby
						,@ZDokladu;		-- volání z dokladu 1-Ano,0-ne
						
					IF @Error IS NOT NULL
						BEGIN
							RAISERROR (@Error,16,1);
							RETURN;
						END;
					
					-- konec akce v kurzoru CurKontaktyVztah
				FETCH NEXT FROM CurKontaktyVztah INTO @IDKontakty;
				END;
			CLOSE CurKontaktyVztah;
			DEALLOCATE CurKontaktyVztah;
			
			-- konec akce v kurzoru CurVztahOrgKOs
		FETCH NEXT FROM CurVztahOrgKOs INTO @IDVztahOrgKOs, @IDCisKOs;
		END;
	CLOSE CurVztahOrgKOs;
	DEALLOCATE CurVztahOrgKOs;
	
	-- * synchronizace kontaktů organizace
	SET @IDKontakty = NULL;
	DECLARE CurKontaktyOrg CURSOR LOCAL FAST_FORWARD FOR
		SELECT ID
		FROM TabKontakty
		WHERE IDOrg = @IDOrgZdroj AND IDVztahKOsOrg IS NULL;
	OPEN CurKontaktyOrg;
	FETCH NEXT FROM CurKontaktyOrg INTO @IDKontakty;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurKontaktyOrg
			
			EXEC [dbo].[hpx_Synchro_KontaktyZdroj]
				@IDKontakty			-- ID kontaktu - ve zdrojové DB
				,@CisloOrgZdroj			-- Číslo organizace - ve zdrojové DB
				,NULL				-- ID kontaktní osoby - ve zdrojové DB
				,NULL				-- ID vztahu - ve zdrojové DB
				,@TypSynchro		-- Identifikátor synchronizace
				,1					-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
				,@Error OUT			-- návratová hodnota chyby
				,@ZDokladu;			-- volání z dokladu 1-Ano,0-ne
				
			IF @Error IS NOT NULL
				BEGIN
					RAISERROR (@Error,16,1);
					RETURN;
				END;
			
			-- konec akce v kurzoru CurKontaktyOrg
		FETCH NEXT FROM CurKontaktyOrg INTO @IDKontakty;
		END;
	CLOSE CurKontaktyOrg;
	DEALLOCATE CurKontaktyOrg;
	
	-- hláška uživateli
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL 
		AND NOT @ZDokladu = 1
		INSERT INTO #TabExtKom(Poznamka) VALUES ('Organizace č. ' + CAST(@CisloOrgZdroj as NVARCHAR) + ': Synchronizace - OK');
	
END TRY
--zacneme CATCH
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL 
		AND NOT @ZDokladu = 1
		INSERT INTO #TabExtKom (Poznamka)
		VALUES ('Organizace č. ' + CAST(@CisloOrgZdroj as NVARCHAR) + ': !!! CHYBA !!! - ' + @ErrorMessage);

-- zápis do log tabulky synchronizace
		IF NOT EXISTS (SELECT * FROM Tabx_SynchroLog 
					WHERE Tab = N'TabCisOrg'
					AND IdTab = @CisloOrgZdroj 
					AND TypSynchro = @TypSynchro)
			INSERT INTO Tabx_SynchroLog (
				TypSynchro
				,Tab
				,IdTab
				,IdTabCil
				,DatSynchro
				,Synchronizoval
				,Zprava
				,Synchro)
			VALUES (
				@TypSynchro
				,N'TabCisOrg'
				,@CisloOrgZdroj
				,NULL
				,GETDATE()
				,SUSER_SNAME()
				,@ErrorMessage
				,CASE WHEN @ErrorMessage IS NULL THEN 0 ELSE 1 END);
		ELSE
			UPDATE Tabx_SynchroLog SET
				IdTabCil = NULL
				,DatSynchro = GETDATE()
				,Synchronizoval = SUSER_SNAME()
				,Zprava = @Error
				,Synchro = CASE WHEN @ErrorMessage IS NULL THEN 0 ELSE 1 END
			WHERE Tab = N'TabCisOrg'
				AND IdTab = @CisloOrgZdroj
				AND TypSynchro = @TypSynchro;

	SET @Error = @ErrorMessage;

END CATCH;
GO

