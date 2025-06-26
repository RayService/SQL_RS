USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_VztahOrgKOsZdroj]    Script Date: 26.06.2025 8:46:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 3.5.2011
-- Description:	Synchronizační procedura ve zdrojové databázi - Vztah organizace a kontaktní osoby
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_VztahOrgKOsZdroj]
	@IDVztahOrgKOsZdroj INT			-- ID vztahu - ve zdrojové DB
	,@CisloOrgZdroj INT				-- Číslo organizace - ve zdrojové DB
	,@IDCisKOsZdroj INT				-- ID kontaktní osoby - ve zdrojové DB
	,@TypSynchro TINYINT			-- Identifikátor synchronizace
	,@TypAkce TINYINT				-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@ZDokladu BIT = 0					-- volání z dokladu 1-Ano,0-ne
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @DBCil NVARCHAR(2);
DECLARE @DBName NVARCHAR(128);
DECLARE @DBVerName NVARCHAR(100);
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLCil NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(MAX);
DECLARE @CRLF CHAR(2);

-- deklarace pro update/insert
DECLARE @OdKdyZamestnan DATETIME;
DECLARE @ZamestnanDo DATETIME;
DECLARE @Funkce NVARCHAR(70);
DECLARE @Oddeleni NVARCHAR(30);
DECLARE @Kancelar NVARCHAR(15);
DECLARE @Asistent NVARCHAR(30);
DECLARE @Nadrizeny NVARCHAR(30);
DECLARE @Poznamka NVARCHAR(255);
DECLARE @IDVztahOrgKOsCil INT;
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
			@OdKdyZamestnan = V.OdKdyZamestnan
			,@ZamestnanDo = V.ZamestnanDo
			,@Funkce = V.Funkce
			,@Oddeleni = V.Oddeleni
			,@Kancelar = V.Kancelar
			,@Asistent = V.Asistent
			,@Nadrizeny = V.Nadrizeny
			,@Poznamka = V.Poznamka
		FROM TabVztahOrgKOs V
		WHERE V.ID = @IDVztahOrgKOsZdroj;
			
		/* test existence organizace */
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
			
		/* test existence kontaktní osoby */
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

-- * spouštíme proceduru ve slave DB
SET @Error = NULL;
SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_VztahOrgKOsCil] ' + @CRLF +
N' @IDVztahOrgKOsZdroj' + @CRLF +
N' ,@CisloOrgZdroj' + @CRLF +
N' ,@IDCisKOsZdroj' + @CRLF +
N' ,@DBVerName' + @CRLF +
N' ,@TypAkce' + @CRLF +
N' ,@Error OUT' + @CRLF +
N' ,@IDVztahOrgKOsCil OUT' + @CRLF +
N' ,@OdKdyZamestnan' + @CRLF + 
N' ,@ZamestnanDo' + @CRLF + 
N' ,@Funkce' + @CRLF + 
N' ,@Oddeleni' + @CRLF + 
N' ,@Kancelar' + @CRLF + 
N' ,@Asistent' + @CRLF + 
N' ,@Nadrizeny' + @CRLF + 
N' ,@Poznamka';

EXEC sp_executesql @ExecSQL
	,N'@IDVztahOrgKOsZdroj INT
	,@CisloOrgZdroj INT
	,@IDCisKOsZdroj INT
	,@DBVerName NVARCHAR(100)
	,@TypAkce TINYINT
	,@Error NVARCHAR(255) OUT
	,@IDVztahOrgKOsCil INT OUT
	,@OdKdyZamestnan DATETIME
	,@ZamestnanDo DATETIME
	,@Funkce NVARCHAR(70)
	,@Oddeleni NVARCHAR(30)
	,@Kancelar NVARCHAR(15)
	,@Asistent NVARCHAR(30)
	,@Nadrizeny NVARCHAR(30)
	,@Poznamka NVARCHAR(255)'
	,@IDVztahOrgKOsZdroj
	,@CisloOrgZdroj
	,@IDCisKOsZdroj
	,@DBVerName
	,@TypAkce
	,@Error OUT
	,@IDVztahOrgKOsCil OUT
	,@OdKdyZamestnan
	,@ZamestnanDo
	,@Funkce
	,@Oddeleni
	,@Kancelar
	,@Asistent
	,@Nadrizeny
	,@Poznamka;

-- zapíšeme do logu
IF @TypAkce IN (0,1)
	BEGIN
		
		-- zápis do log tabulky synchronizace
		IF NOT EXISTS (SELECT * FROM Tabx_SynchroLog 
					WHERE Tab = N'TabVztahOrgKOs'
					AND IdTab = @IDVztahOrgKOsZdroj
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
				,N'TabVztahOrgKOs'
				,@IDVztahOrgKOsZdroj
				,@IDVztahOrgKOsCil
				,GETDATE()
				,SUSER_SNAME()
				,@Error
				,CASE WHEN @Error IS NULL THEN 0 ELSE 1 END);
		ELSE
			UPDATE Tabx_SynchroLog SET
				IdTabCil = @IDVztahOrgKOsCil
				,DatSynchro = GETDATE()
				,Synchronizoval = SUSER_SNAME()
				,Zprava = @Error
				,Synchro = CASE WHEN @Error IS NULL THEN 0 ELSE 1 END
			WHERE Tab = N'TabVztahOrgKOs'
				AND IdTab = @IDVztahOrgKOsZdroj
				AND TypSynchro = @TypSynchro;
				
	END;
GO

