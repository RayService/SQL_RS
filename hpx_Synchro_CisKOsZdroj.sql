USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_CisKOsZdroj]    Script Date: 26.06.2025 8:45:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 3.5.2011
-- Description:	Synchronizační procedura ve zdrojové databázi - Kontaktní osoby
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_CisKOsZdroj]
	@IDCisKOsZdroj INT			-- ID kontaktní osoby - ve zdrojové DB
	,@TypSynchro TINYINT		-- Identifikátor synchronizace
	,@TypAkce TINYINT			-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
	,@Error NVARCHAR(255) = NULL OUT -- návratová hodnota chyby
	,@ZDokladu BIT = 0			-- volání z dokladu 1-Ano,0-ne
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
DECLARE @Jmeno NVARCHAR(100);
DECLARE @Prijmeni NVARCHAR(100);
DECLARE @RodnePrijmeni NVARCHAR(100);
DECLARE @TitulPred NVARCHAR(100);
DECLARE @TitulZa NVARCHAR(100);
DECLARE @DatumNarozeni DATETIME;
DECLARE @RodneCislo NVARCHAR(11);
DECLARE @MistoNarozeni NVARCHAR(100);
DECLARE @Ulice NVARCHAR(100);
DECLARE @Misto NVARCHAR(100);
DECLARE @PSC NVARCHAR(10);
DECLARE @AdrZeme NVARCHAR(3);
DECLARE @StatniPrislus NVARCHAR(3);
DECLARE @Narodnost NVARCHAR(100);
DECLARE @RodinnyStav SMALLINT;
DECLARE @CisloOP NVARCHAR(15);
DECLARE @CisloPasu NVARCHAR(20);
DECLARE @Pohlavi SMALLINT;
DECLARE @IDCisKOsCil INT;
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
			@Jmeno = Os.Jmeno
			,@Prijmeni = Os.Prijmeni
			,@RodnePrijmeni = Os.RodnePrijmeni
			,@TitulPred = Os.TitulPred
			,@TitulZa = Os.TitulZa
			,@DatumNarozeni = Os.DatumNarozeni
			,@RodneCislo = Os.RodneCislo
			,@MistoNarozeni = Os.MistoNarozeni
			,@Ulice = Os.Ulice
			,@Misto = Os.Misto
			,@PSC = Os.PSC
			,@AdrZeme = Os.AdrZeme
			,@StatniPrislus = Os.StatniPrislus
			,@Narodnost = Os.Narodnost
			,@RodinnyStav = Os.RodinnyStav
			,@CisloOP = Os.CisloOP
			,@CisloPasu = Os.CisloPasu
			,@Pohlavi = Os.Pohlavi
		FROM TabCisKOs Os
		WHERE Os.ID = @IDCisKOsZdroj;
			
	END;

-- * spouštíme proceduru ve slave DB
SET @Error = NULL;
SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_CisKOsCil] ' + @CRLF +
N' @IDCisKOsZdroj' + @CRLF +
N' ,@DBVerName' + @CRLF +
N' ,@TypAkce' + @CRLF +
N' ,@Error OUT' + @CRLF +
N' ,@IDCisKOsCil OUT' + @CRLF +
N' ,@Jmeno' + @CRLF + 
N' ,@Prijmeni' + @CRLF + 
N' ,@RodnePrijmeni' + @CRLF + 
N' ,@TitulPred' + @CRLF + 
N' ,@TitulZa' + @CRLF + 
N' ,@DatumNarozeni' + @CRLF + 
N' ,@RodneCislo' + @CRLF + 
N' ,@MistoNarozeni' + @CRLF + 
N' ,@Ulice' + @CRLF + 
N' ,@Misto' + @CRLF + 
N' ,@PSC' + @CRLF + 
N' ,@AdrZeme' + @CRLF + 
N' ,@StatniPrislus' + @CRLF + 
N' ,@Narodnost' + @CRLF + 
N' ,@RodinnyStav' + @CRLF + 
N' ,@CisloOP' + @CRLF + 
N' ,@CisloPasu' + @CRLF + 
N' ,@Pohlavi';

EXEC sp_executesql @ExecSQL
	,N'@IDCisKOsZdroj INT
	,@DBVerName NVARCHAR(100)
	,@TypAkce TINYINT
	,@Error NVARCHAR(255) OUT
	,@IDCisKOsCil INT OUT
	,@Jmeno NVARCHAR(100)
	,@Prijmeni NVARCHAR(100)
	,@RodnePrijmeni NVARCHAR(100)
	,@TitulPred NVARCHAR(100)
	,@TitulZa NVARCHAR(100)
	,@DatumNarozeni DATETIME
	,@RodneCislo NVARCHAR(11)
	,@MistoNarozeni NVARCHAR(100)
	,@Ulice NVARCHAR(100)
	,@Misto NVARCHAR(100)
	,@PSC NVARCHAR(10)
	,@AdrZeme NVARCHAR(3)
	,@StatniPrislus NVARCHAR(3)
	,@Narodnost NVARCHAR(100)
	,@RodinnyStav SMALLINT
	,@CisloOP NVARCHAR(15)
	,@CisloPasu NVARCHAR(20)
	,@Pohlavi SMALLINT'
	,@IDCisKOsZdroj
	,@DBVerName
	,@TypAkce
	,@Error OUT
	,@IDCisKOsCil OUT
	,@Jmeno
	,@Prijmeni
	,@RodnePrijmeni
	,@TitulPred
	,@TitulZa
	,@DatumNarozeni
	,@RodneCislo
	,@MistoNarozeni
	,@Ulice
	,@Misto
	,@PSC
	,@AdrZeme
	,@StatniPrislus
	,@Narodnost
	,@RodinnyStav
	,@CisloOP
	,@CisloPasu
	,@Pohlavi;
	
-- zapíšeme do logu
IF @TypAkce IN (0,1)
	BEGIN
		
		-- zápis do log tabulky synchronizace
		IF NOT EXISTS (SELECT * FROM Tabx_SynchroLog 
					WHERE Tab = N'TabCisKOs'
					AND IdTab = @IDCisKOsZdroj
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
				,N'TabCisKOs'
				,@IDCisKOsZdroj
				,@IDCisKOsCil
				,GETDATE()
				,SUSER_SNAME()
				,@Error
				,CASE WHEN @Error IS NULL THEN 0 ELSE 1 END);
		ELSE
			UPDATE Tabx_SynchroLog SET
				IdTabCil = @IDCisKOsCil
				,DatSynchro = GETDATE()
				,Synchronizoval = SUSER_SNAME()
				,Zprava = @Error
				,Synchro = CASE WHEN @Error IS NULL THEN 0 ELSE 1 END
			WHERE Tab = N'TabCisKOs'
				AND IdTab = @IDCisKOsZdroj
				AND TypSynchro = @TypSynchro;
		
	END;
GO

