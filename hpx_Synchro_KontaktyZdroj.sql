USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_KontaktyZdroj]    Script Date: 26.06.2025 8:47:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 3.5.2011
-- Description:	Synchronizační procedura ve zdrojové databázi - Kontakt
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_KontaktyZdroj]
	@IDKontaktyZdroj INT		-- ID kontaktu - ve zdrojové DB
	,@CisloOrgZdroj INT			-- Číslo organizace - ve zdrojové DB
	,@IDCisKOsZdroj INT			-- ID kontaktní osoby - ve zdrojové DB
	,@IDVztahOrgKOsZdroj INT	-- ID vztahu - ve zdrojové DB
	,@TypSynchro TINYINT		-- Identifikátor synchronizace
	,@TypAkce TINYINT			-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@ZDokladu BIT = 0					-- volání z dokladu 1-Ano,0-ne
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @CisloOrgVztah INT;
DECLARE @IDCisKOsVztah INT;
DECLARE @DBCil NVARCHAR(2);
DECLARE @DBName NVARCHAR(128);
DECLARE @DBVerName NVARCHAR(100);
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLCil NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(MAX);
DECLARE @CRLF CHAR(2);

-- deklarace pro update/insert
DECLARE @Popis NVARCHAR(255);
DECLARE @Spojeni NVARCHAR(255);
DECLARE @Spojeni2 NVARCHAR(255);
DECLARE @Druh SMALLINT;
DECLARE @Kam SMALLINT;
DECLARE @IDKontaktyCil INT;
DECLARE @LServer BIT;

-- SETy, parametry
SET @CRLF=CHAR(13)+CHAR(10);
SET @Error = NULL;

SELECT 
	@DBCil = DBCil
FROM Tabx_SynchroTyp
WHERE TypSynchro = @TypSynchro;

/* funkční tělo procedury */
-- výběr dynamických parametrů komunikace
SELECT
	@DBName = [DBName]
	,@DBVerName = [DBVerName]
	,@ServerName = [ServerName]
FROM Tabx_SynchroConfig
WHERE IdentDB = @DBCil;

-- Linked server
IF NOT EXISTS (SELECT * FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = @ServerName)
	BEGIN
		RAISERROR ('Neexistuje linkovaný server %s; kontaktujte správce!',16,1,@ServerName);
		RETURN;
	END;

EXEC @LServer = sp_testlinkedserver @ServerName;
IF @LServer = 1
	BEGIN
		RAISERROR ('Cílová databáze pro synchronizaci je dočasně nedostupná; Zkuste to prosím později nebo kontaktujte správce!',16,1);
		RETURN;
	END;

SET @SQLCil = (QUOTENAME(@ServerName) + '.' + QUOTENAME(@DBName) + '.');

-- * hodnoty do paramterů
-- pro INSERT/UPDATE
IF @TypAkce IN (0,1)
	BEGIN
		SELECT 
			@Popis = K.Popis
			,@Spojeni = K.Spojeni
			,@Spojeni2 = K.Spojeni2
			,@Druh = K.Druh
			,@Kam = K.Kam
		FROM TabKontakty K
		WHERE K.ID = @IDKontaktyZdroj;
			
		/* test existence organizace */
		IF @CisloOrgZdroj IS NOT NULL
			BEGIN
				EXEC [dbo].[hpx_Synchro_CisOrgZdroj]
					@CisloOrgZdroj			-- Číslo organizace - ve zdrojové DB
					,@TypSynchro			-- Identifikátor synchronizace
					,9					-- 0-INSERT,1-UPDATE,2-DELETE,9-test existence
					,@Error OUT			-- návratová hodnota chyby
					,@ZDokladu;			-- volání z dokladu 1-Ano,0-ne
			
				-- organizace neexistuje, vydráždíme synchronizaci
				IF @Error IS NOT NULL
					BEGIN
						EXEC [dbo].[hpx_Synchro_CisOrgZdroj]
							@CisloOrgZdroj		-- Číslo organizace - ve zdrojové DB
							,@TypSynchro		-- Identifikátor synchronizace
							,@TypAkce			-- 0-INSERT,1-UPDATE,2-DELETE,9-test existence
							,@Error OUT			-- návratová hodnota chyby
							,@ZDokladu;			-- volání z dokladu 1-Ano,0-ne
						
						-- synchronizace organizace skončila chybou
						IF @Error IS NOT NULL
							BEGIN
								ROLLBACK;
								RAISERROR (@Error,16,1);
								RETURN;
							END;
					END;
			END;
			
		/* test existence kontaktní osoby */
		IF @IDCisKOsZdroj IS NOT NULL
			BEGIN
				EXEC [dbo].[hpx_Synchro_CisKOsZdroj]
					@IDCisKOsZdroj			-- ID kontaktní osoby - ve zdrojové DB
					,@TypSynchro			-- Identifikátor synchronizace
					,9						-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
					,@Error OUT				-- návratová hodnota chyby
					,@ZDokladu;				-- volání z dokladu 1-Ano,0-ne
				
				-- KOs neexistuje, vydráždíme synchronizaci
				IF @Error IS NOT NULL
					BEGIN
						EXEC [dbo].[hpx_Synchro_CisKOsZdroj]
							@IDCisKOsZdroj			-- ID kontaktní osoby - ve zdrojové DB
							,@TypSynchro			-- Identifikátor synchronizace
							,@TypAkce				-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
							,@Error OUT				-- návratová hodnota chyby
							,@ZDokladu;				-- volání z dokladu 1-Ano,0-ne
						
						-- synchronizace organizace skončila chybou
						IF @Error IS NOT NULL
							BEGIN
								ROLLBACK;
								RAISERROR (@Error,16,1);
								RETURN;
							END;
					END;
			END;
			
		/* test existence vztahu */
		IF @IDVztahOrgKOsZdroj IS NOT NULL
			BEGIN
				SELECT @CisloOrgVztah = O.CisloOrg
					,@IDCisKOsVztah = V.IDCisKOs
				FROM TabVztahOrgKOs V
					INNER JOIN TabCisOrg O ON V.IDOrg = O.ID
				WHERE V.ID = @IDVztahOrgKOsZdroj;
				
				EXEC [dbo].[hpx_Synchro_VztahOrgKOsZdroj]
					@IDVztahOrgKOsZdroj			-- ID vztahu - ve zdrojové DB
					,@CisloOrgVztah			-- Číslo organizace - ve zdrojové DB
					,@IDCisKOsVztah			-- ID kontaktní osoby - ve zdrojové DB
					,@TypSynchro			-- Identifikátor synchronizace
					,9						-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
					,@Error OUT				-- návratová hodnota chyby
					,@ZDokladu;				-- volání z dokladu 1-Ano,0-ne
					
				--  Vztah neexistuje, vydráždíme synchronizaci
				IF @Error IS NOT NULL
					BEGIN
						EXEC [dbo].[hpx_Synchro_VztahOrgKOsZdroj]
							@IDVztahOrgKOsZdroj			-- ID vztahu - ve zdrojové DB
							,@CisloOrgVztah			-- Číslo organizace - ve zdrojové DB
							,@IDCisKOsVztah			-- ID kontaktní osoby - ve zdrojové DB
							,@TypSynchro			-- Identifikátor synchronizace
							,@TypAkce						-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
							,@Error OUT				-- návratová hodnota chyby
							,@ZDokladu;				-- volání z dokladu 1-Ano,0-ne
						
						-- synchronizace organizace skončila chybou
						IF @Error IS NOT NULL
							BEGIN
								ROLLBACK;
								RAISERROR (@Error,16,1);
								RETURN;
							END;
					END;
			END;
		
	END;

-- * spouštíme proceduru ve slave DB
SET @Error = NULL;
SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_KontaktyCil] ' + @CRLF +
N' @IDKontaktyZdroj' + @CRLF +
N' ,@CisloOrgZdroj' + @CRLF +
N' ,@IDCisKOsZdroj' + @CRLF +
N' ,@IDVztahOrgKOsZdroj' + @CRLF +
N' ,@DBVerName' + @CRLF +
N' ,@TypAkce' + @CRLF +
N' ,@Error OUT' + @CRLF +
N' ,@IDKontaktyCil OUT' + @CRLF +
N' ,@Popis' + @CRLF + 
N' ,@Spojeni' + @CRLF + 
N' ,@Spojeni2' + @CRLF + 
N' ,@Druh' + @CRLF + 
N' ,@Kam';

EXEC sp_executesql @ExecSQL
	,N'@IDKontaktyZdroj INT
	,@CisloOrgZdroj INT
	,@IDCisKOsZdroj INT
	,@IDVztahOrgKOsZdroj INT
	,@DBVerName NVARCHAR(100)
	,@TypAkce TINYINT
	,@Error NVARCHAR(255) OUT
	,@IDKontaktyCil INT OUT
	,@Popis NVARCHAR(255)
	,@Spojeni NVARCHAR(255)
	,@Spojeni2 NVARCHAR(255)
	,@Druh SMALLINT
	,@Kam SMALLINT'
	,@IDKontaktyZdroj
	,@CisloOrgZdroj
	,@IDCisKOsZdroj
	,@IDVztahOrgKOsZdroj
	,@DBVerName
	,@TypAkce
	,@Error OUT
	,@IDKontaktyCil OUT
	,@Popis
	,@Spojeni
	,@Spojeni2
	,@Druh
	,@Kam;

-- zapíšeme do logu
IF @TypAkce IN (0,1)
	BEGIN
		
		-- zápis do log tabulky synchronizace
		IF NOT EXISTS (SELECT * FROM Tabx_SynchroLog 
					WHERE Tab = N'TabKontakty'
					AND IdTab = @IDKontaktyZdroj
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
				,N'TabKontakty'
				,@IDKontaktyZdroj
				,@IDKontaktyCil
				,GETDATE()
				,SUSER_SNAME()
				,@Error
				,CASE WHEN @Error IS NULL THEN 0 ELSE 1 END);
		ELSE
			UPDATE Tabx_SynchroLog SET
				IdTabCil = @IDKontaktyCil
				,DatSynchro = GETDATE()
				,Synchronizoval = SUSER_SNAME()
				,Zprava = @Error
				,Synchro = CASE WHEN @Error IS NULL THEN 0 ELSE 1 END
			WHERE Tab = N'TabKontakty'
				AND IdTab = @IDKontaktyZdroj
				AND TypSynchro = @TypSynchro;
				
	END;
GO

