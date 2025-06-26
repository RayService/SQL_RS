USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_KmenZboziZdroj]    Script Date: 26.06.2025 8:48:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 31.1.2012
-- Description:	Synchronizace zboží - zdrojová DB
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_KmenZboziZdroj]
	@TypSynchro TINYINT			-- Identifikátor synchronizace
	,@ZDokladu BIT = 0			-- volání z dokladu 1-Ano,0-ne
	,@TypAkce TINYINT			-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@IDKmenZboziZdroj INT				-- ID v TabKmenZbozi
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @DBZdroj NVARCHAR(2);
DECLARE @DBCil NVARCHAR(2);
DECLARE @SkupZboZdroj NVARCHAR(3);
DECLARE @RegCisZdroj NVARCHAR(30);
DECLARE @DBName NVARCHAR(128);
DECLARE @DBVerName NVARCHAR(100);
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLCil NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(4000);
DECLARE @CRLF CHAR(2);
DECLARE @LServer BIT;

-- SETy, parametry
SET @CRLF=CHAR(13)+CHAR(10);
SET @Error = NULL;

SELECT 
	@DBCil = DBCil
	,@DBZdroj = DBZdroj
FROM Tabx_SynchroTyp
WHERE TypSynchro = @TypSynchro;

SELECT 
	@SkupZboZdroj = SkupZbo
	,@RegCisZdroj = RegCis
FROM TabKmenZbozi
WHERE ID = @IDKmenZboziZdroj;

/* Funkční tělo procedury */
-- výběr dynamických parametrů komunikace
SELECT
	@DBName = [DBName]
	,@DBVerName = [DBVerName]
	,@ServerName = [ServerName]
FROM Tabx_SynchroConfig
WHERE IdentDB = @DBCil;

-- začneme TRY
BEGIN TRY

	-- Linked server
	IF NOT EXISTS (SELECT * FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = @ServerName)
		BEGIN
			RAISERROR ('- neexistuje linkovaný server %s; kontaktujte správce!',16,1,@ServerName);
			RETURN;
		END;
	
	EXEC @LServer = sp_testlinkedserver @ServerName;
	IF @LServer = 1
		BEGIN
			RAISERROR ('- cílová databáze pro synchronizaci je dočasně nedostupná; Zkuste to prosím později nebo kontaktujte správce!',16,1);
			RETURN;
		END;

	SET @SQLCil = (QUOTENAME(@ServerName) + '.' + QUOTENAME(@DBName) + '.');

	-- zavolání procedury synchronizace cílové DB
	SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_KmenZboziCil]'  + @CRLF +
N' @DBZdroj' + @CRLF +
N' ,@SkupZboZdroj' + @CRLF +
N' ,@RegCisZdroj' + @CRLF +
N' ,@DBVerName' + @CRLF +
N' ,@TypAkce' + @CRLF +
N' ,@Error OUT';

	EXEC sp_executesql @ExecSQL
,N'@DBZdroj NVARCHAR(2)
,@SkupZboZdroj NVARCHAR(3)
,@RegCisZdroj NVARCHAR(30)
,@DBVerName NVARCHAR(100)
,@TypAkce TINYINT
,@Error NVARCHAR(255) OUT'
,@DBZdroj
,@SkupZboZdroj
,@RegCisZdroj
,@DBVerName
,@TypAkce
,@Error OUT;
	
	-- zapíšeme do logu
	IF @TypAkce IN (0,1)
		BEGIN
			
			-- zápis do log tabulky synchronizace
			IF NOT EXISTS (SELECT * FROM Tabx_SynchroLog 
						WHERE Tab = N'TabKmenZbozi'
						AND IdTab = @IDKmenZboziZdroj 
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
					,N'TabKmenZbozi'
					,@IDKmenZboziZdroj
					,NULL
					,GETDATE()
					,SUSER_SNAME()
					,@Error
					,CASE WHEN @Error IS NULL THEN 0 ELSE 1 END);
			ELSE
				UPDATE Tabx_SynchroLog SET
					IdTabCil = NULL
					,DatSynchro = GETDATE()
					,Synchronizoval = SUSER_SNAME()
					,Zprava = @Error
					,Synchro = CASE WHEN @Error IS NULL THEN 0 ELSE 1 END
				WHERE Tab = N'TabKmenZbozi'
					AND IdTab = @IDKmenZboziZdroj
					AND TypSynchro = @TypSynchro;
			
			-- chyba
			IF @Error IS NOT NULL
				BEGIN
					RAISERROR (@Error,16,1);
					RETURN;
				END;
			
			-- hláška uživateli - spouštěno z akce
			IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
				AND @ZDokladu = 0
				INSERT INTO #TabExtKom(Poznamka)
				SELECT ('OK - Synchronizováno: ' + SkupZbo + N' ' + RegCis + N' - ' + Nazev1)
				FROM TabKmenZbozi WHERE ID = @IDKmenZboziZdroj;
			
		END;
		
END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	-- hláška uživateli - spouštěno z akce
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL 
		AND NOT @ZDokladu = 1
		INSERT INTO #TabExtKom(Poznamka)
		SELECT ('X - Chyba synchronizace: ' + SkupZbo + N' ' + RegCis + N' - ' + @ErrorMessage)
		FROM TabKmenZbozi WHERE ID = @IDKmenZboziZdroj

	-- zápis do log tabulky synchronizace
	IF NOT EXISTS (SELECT * FROM Tabx_SynchroLog 
				WHERE Tab = N'TabKmenZbozi'
				AND IdTab = @IDKmenZboziZdroj 
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
			,N'TabKmenZbozi'
			,@IDKmenZboziZdroj
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
			,Zprava = @ErrorMessage
			,Synchro = CASE WHEN @ErrorMessage IS NULL THEN 0 ELSE 1 END
		WHERE Tab = N'TabKmenZbozi'
			AND IdTab = @IDKmenZboziZdroj
			AND TypSynchro = @TypSynchro;
	
	SET @Error = @ErrorMessage;
	
END CATCH
GO

