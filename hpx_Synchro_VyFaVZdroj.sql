USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_VyFaVZdroj]    Script Date: 26.06.2025 9:11:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[hpx_Synchro_VyFaVZdroj]
	@TypSynchro TINYINT					-- Identifikátor synchronizace
	,@ZDokladu BIT = 0					-- volání z dokladu 1-Ano,0-ne
	,@SynchOZCiselniky BIT = 1			-- synchronizovat číselníky dokladu OZ
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@IDDokladZdroj INT					-- ID dokladu v TabDokladyZbozi
AS
SET NOCOUNT ON;

-- =============================================
-- Author:		DJ
-- Description:	Spuštění synchronizace Vy > FaV - zdrojová DB
-- =============================================

/* deklarace */
DECLARE @DBZdroj NVARCHAR(2);
DECLARE @DBCil NVARCHAR(2);
DECLARE @IDSkladCil NVARCHAR(30);
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
		,@IDSkladCil = IDSkladCil
		,@RadaDokladuCil = RadaDokladuCil
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
	
	-- SET @HlaskaSynchroCo = N'Faktura vydaná > Faktura vydaná (' + ISNULL(@DBVerName,N'') + ') '
	
	-- typy synchronizace OZ číselníků
	--IF @SynchOZCiselniky = 1 
	--	AND (@TypSynchroKmen IS NULL OR @TypSynchroOrg IS NULL)
	--	BEGIN
	--		RAISERROR ('- neznámý identifikátor oblasti synchronizace pro kmenové karty nebo organizace',16,1);
	--		RETURN;
	--	END;
	
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

	-- je to výdejka
	IF (SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID = @IDDokladZdroj) NOT IN (2,4)
		BEGIN
			RAISERROR ('- doklad není typu Výdej, Výdej v evideční ceně, nelze synchronizovat',16,1);
			RETURN;
		END;
	
	-- kontrola na realizaci výdejky
	IF EXISTS (SELECT * FROM TabDokladyZbozi WHERE ID = @IDDokladZdroj AND DatRealizace IS NULL)
		BEGIN
			RAISERROR ('- doklad není realizován, nelze synchronizovat',16,1);
			RETURN;
		END;

	-- již bylo synchronizováno
	IF EXISTS(SELECT * FROM Tabx_SynchroLog 
						WHERE Tab = N'TabDokladyZbozi'
						AND IdTab = @IDDokladZdroj 
						AND TypSynchro = @TypSynchro
						AND Synchro = 0)
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
		
	/* Funkční tělo procedury */
	-- synchronizace číselníků
	IF @SynchOZCiselniky = 1
		EXEC [dbo].[hpx_Synchro_DokladOZCiselniky]
			@TypSynchro -- Identifikátor synchronizace
			,@TypSynchroOrg		-- Identifikátor synchronizace - Organizace
			,@TypSynchroKmen	-- Identifikátor synchronizace - Kmenové karty
			,@IDDokladZdroj;	-- ID dokladu v TabDokladyZbozi
	
	-- zavolání procedury synchronizace v slave db
	SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_VyFavCil]' + @CRLF +
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
			VALUES(@ParovaciZnak + ' - OK - ' + @HlaskaSynchroCo + '- výdejka úspěšně synchronizována');
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

