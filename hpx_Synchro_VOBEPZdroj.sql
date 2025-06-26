USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_VOBEPZdroj]    Script Date: 26.06.2025 10:53:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_Synchro_VOBEPZdroj]
	@TypSynchro TINYINT					-- Identifikátor synchronizace
	,@ZDokladu BIT = 0					-- volání z dokladu 1-Ano,0-ne
	,@SynchOZCiselniky BIT = 1			-- synchronizovat číselníky dokladu OZ
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@IDSkladCil NVARCHAR(30)			-- číslo skladu v cílové db
	,@IDDokladZdroj INT					-- ID dokladu v TabDokladyZbozi
AS
SET NOCOUNT ON;

-- =============================================
-- Author:		MŽ
-- Description:	Spuštění synchronizace VOB > EP - zdrojová DB
-- =============================================

/* deklarace */
DECLARE @DBZdroj NVARCHAR(2);
DECLARE @DBCil NVARCHAR(2);
--bylo dříve, nyní je to volitelné při spuštění DECLARE @IDSkladCil NVARCHAR(30);
DECLARE @RadaDokladuCil NVARCHAR(3);
DECLARE @DBName NVARCHAR(128);
DECLARE @DBVerName NVARCHAR(100);
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLCil NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(4000);
DECLARE @Err VARCHAR(255);
DECLARE @IDDokladCil INT;
DECLARE @CRLF CHAR(2);
DECLARE @ParovaciZnak NVARCHAR(20);
DECLARE @CisloOrg INT;

DECLARE @Autor NVARCHAR(128);
DECLARE @SynchroNe BIT;
DECLARE @LServer BIT;
DECLARE @TypSynchroOrg TINYINT;
DECLARE @TypSynchroKmen TINYINT;
DECLARE @HlaskaSynchroCo NVARCHAR(255);

-- SETy, naplnění parametrů
SET @CRLF=CHAR(13)+CHAR(10);
SET @Autor = SUSER_SNAME();
SET @HlaskaSynchroCo = N''

-- začneme TRY
BEGIN TRY
	
	/* Kontroly */
		
	-- akce spuštěna v prázdném přehledu
	IF @IDDokladZdroj IS NULL OR @IDDokladZdroj = 0
		BEGIN
			RAISERROR ('- neznámý identifikátor zdrojového dokladu, pravděpodobně spouštíte akci v prázdném přehledu',16,1);
			RETURN;
		END;
		
	SELECT
		@ParovaciZnak = ParovaciZnak
		,@CisloOrg = CisloOrg
	FROM TabDokladyZbozi
	WHERE ID = @IDDokladZdroj;
	
	-- typ synchronizace
	IF @TypSynchro IS NULL
		SELECT @TypSynchro = DRE._Synchro_TypSynchro
		FROM TabDokladyZbozi D
			INNER JOIN TabDruhDokZbo DR ON D.RadaDokladu = DR.RadaDokladu AND D.DruhPohybuZbo = DR.DruhPohybuZbo
			INNER JOIN TabDruhDokZbo_EXT DRE ON DR.ID = DRE.ID
		WHERE D.ID = @IDDokladZdroj;
	
	IF @TypSynchro IS NULL
		OR NOT EXISTS(SELECT * FROM Tabx_SynchroTyp WHERE TypSynchro = @TypSynchro)
		BEGIN
			RAISERROR ('- neznámý identifikátor oblasti synchronizace',16,1);
			RETURN;
		END;
		
	-- výběr dynamických parametrů komunikace
	SELECT 
		@DBCil = DBCil
		,@DBZdroj = DBZdroj
		--bylo dříve, nyní je sklad volený při spuštění ext.akce,@IDSkladCil = IDSkladCil
		--bylo dříve, nyní se řada cílového dokladu odvíjí od vybraného cílového skladu,@RadaDokladuCil = RadaDokladuCil
		,@RadaDokladuCil = CASE WHEN @IDSkladCil = '100' THEN '400' ELSE '420' END
		,@TypSynchroKmen = TypSynchroKmen
		,@TypSynchroOrg = TypSynchroOrg
		,@HlaskaSynchroCo = Nazev
	FROM Tabx_SynchroTyp
	WHERE TypSynchro = @TypSynchro;
	
	SELECT
		@DBName = [DBName]
		,@DBVerName = [DBVerName]
		,@ServerName = [ServerName]
	FROM Tabx_SynchroConfig
	WHERE IdentDB = @DBCil;

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

	-- je to vydaná objednávka
	IF (SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID = @IDDokladZdroj) <> 6
		BEGIN
			RAISERROR ('- doklad není typu Vydaná objednávka, nelze synchronizovat',16,1);
			RETURN;
		END;
	
	-- organizace
	IF (SELECT CisloOrg FROM Tabx_SynchroConfig WHERE IdentDB = @DBCil) IS NULL
		OR (@CisloOrg <> (SELECT CisloOrg FROM Tabx_SynchroConfig WHERE IdentDB = @DBCil))
		BEGIN
			RAISERROR ('- organizace odběratele neodpovídá nulté organizací cílové databáze',16,1);
			RETURN;
		END;

	-- již bylo synchronizováno
	IF EXISTS(SELECT * FROM Tabx_SynchroLog 
						WHERE Tab = N'TabDokladyZbozi'
						AND IdTab = @IDDokladZdroj 
						--AND TypSynchro = @TypSynchro
						AND Synchro = 1)
		BEGIN
			SET @SynchroNe = 1;
			RAISERROR(N'- doklad již bych synchronizován',16,1);
			RETURN;
		END;

	-- je použita sleva za doklad (mechanismus neřeší)
	IF EXISTS(SELECT * FROM TabOZSumaceCen WHERE IDDoklad = @IDDokladZdroj AND TypSlevy > 0)
		OR EXISTS(SELECT * FROM TabDokladyZbozi WHERE ID = @IDDokladZdroj AND Sleva > 0)
		BEGIN
			RAISERROR ('- na dokladu jsou použity slevy za doklad nebo úprava cen, nelze synchronizovat',16,1);
			RETURN;
		END;
		
	-- * funkční tělo procedury
	-- zavolání procedury synchronizace v slave db
	SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_VOBEPCil]' + @CRLF +
N'	@DBZdroj' + @CRLF +
N'	,@IDDokladZdroj' + @CRLF + 
N'	,@Autor' + @CRLF + 
N'	,@RadaDokladuCil' + @CRLF + 
N'	,@IDSkladCil' + @CRLF + 
N'	,@DBVerName' + @CRLF +
N'	,@IDDokladCil OUT'  + @CRLF + 
N'	,@Error OUT';

	EXEC sp_executesql @ExecSQL
,N'@DBZdroj NVARCHAR(2)
,@IDDokladZdroj INT
,@Autor NVARCHAR(128)
,@RadaDokladuCil NVARCHAR(3)
,@IDSkladCil NVARCHAR(30)
,@DBVerName NVARCHAR(100)
,@IDDokladCil INT OUT
,@Error NVARCHAR(255) OUT'
,@DBZdroj
,@IDDokladZdroj
,@Autor
,@RadaDokladuCil
,@IDSkladCil
,@DBVerName
,@IDDokladCil OUT
,@Error OUT;

	-- zápis do log tabulky synchronizace
	IF NOT EXISTS(SELECT * FROM Tabx_SynchroLog 
				WHERE Tab = N'TabDokladyZbozi'
				AND IdTab = @IDDokladZdroj
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
			,N'TabDokladyZbozi'
			,@IDDokladZdroj
			,@IDDokladCil
			,GETDATE()
			,SUSER_SNAME()
			,@Error
			,CASE WHEN @Error IS NULL OR @SynchroNe = 1 THEN 0 ELSE 1 END);
	ELSE
		UPDATE Tabx_SynchroLog SET
			IdTabCil = @IDDokladCil
			,DatSynchro = GETDATE()
			,Synchronizoval = SUSER_SNAME()
			,Zprava = @Error
			,Synchro = CASE WHEN @Error IS NULL OR @SynchroNe = 1 THEN 0 ELSE 1 END
		WHERE Tab = N'TabDokladyZbozi'
			AND IdTab = @IDDokladZdroj
			AND TypSynchro = @TypSynchro;
	
	-- chyba
	IF @Error IS NOT NULL
		BEGIN
			RAISERROR (@Error,16,1);
			RETURN;
		END;
	
	-- hláška uživateli - spouštěno z akce
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
		AND NOT @ZDokladu = 1
		BEGIN
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Synchronizace dokladů%')
				BEGIN
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Synchronizace dokladů');
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
				END;
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(@ParovaciZnak + ' - OK - ' + @HlaskaSynchroCo + '- vydaná objednávka úspěšně synchronizována');
		END;
	
END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	SET @Error = @ErrorMessage;

	-- hláška uživateli - spouštěno z akce
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
		AND NOT @ZDokladu = 1
		BEGIN
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Synchronizace dokladů%')
				BEGIN
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Synchronizace dokladů');
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
				END;
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(@ParovaciZnak + ' - !! CHYBA !! ' + @HlaskaSynchroCo + @ErrorMessage);
		END;
	
	-- zápis do log tabulky synchronizace
	IF @TypSynchro IS NULL
		RETURN;
	
	IF NOT EXISTS(SELECT * FROM Tabx_SynchroLog 
				WHERE Tab = N'TabDokladyZbozi'
				AND IdTab = @IDDokladZdroj
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
			,N'TabDokladyZbozi'
			,@IDDokladZdroj
			,@IDDokladCil
			,GETDATE()
			,SUSER_SNAME()
			,@ErrorMessage
			,CASE WHEN @ErrorMessage IS NULL OR @SynchroNe = 1 THEN 0 ELSE 1 END);
	ELSE
		UPDATE Tabx_SynchroLog SET
			IdTabCil = @IDDokladCil
			,DatSynchro = GETDATE()
			,Synchronizoval = SUSER_SNAME()
			,Zprava = @ErrorMessage
			,Synchro = CASE WHEN @ErrorMessage IS NULL OR @SynchroNe = 1 THEN 0 ELSE 1 END
		WHERE Tab = N'TabDokladyZbozi'
			AND IdTab = @IDDokladZdroj
			AND TypSynchro = @TypSynchro;

END CATCH;
GO

