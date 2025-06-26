USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_CisOrgZdroj]    Script Date: 26.06.2025 8:45:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 22.4.2011
-- Description:	Synchronizační procedura ve zdrojové databázi - Organizace
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_CisOrgZdroj]
	@CisloOrgZdroj INT			-- Číslo organizace - ve zdrojové DB
	,@TypSynchro TINYINT		-- Identifikátor synchronizace
	,@TypAkce TINYINT			-- typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
	,@ZDokladu BIT = 0			-- volání z dokladu 1-Ano,0-ne
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @IDOrg INT;
DECLARE @DBCil NVARCHAR(2);
DECLARE @DBName NVARCHAR(128);
DECLARE @DBVerName NVARCHAR(100);
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLCil NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(MAX);
DECLARE @CRLF CHAR(2);

-- deklarace pro update/insert
DECLARE @CisloOrgCil INT;
DECLARE @NadrizenaOrg INT;
DECLARE @Nazev NVARCHAR(100);
DECLARE @DruhyNazev NVARCHAR(100);
DECLARE @Misto NVARCHAR(100);
DECLARE @IdZeme NVARCHAR(3);
DECLARE @Ulice NVARCHAR(100);
DECLARE @PSC NVARCHAR(10);
DECLARE @PoBox NVARCHAR(40);
DECLARE @DIC NVARCHAR(15);
DECLARE @LhutaSplatnosti SMALLINT;
DECLARE @Stav TINYINT;
DECLARE @PravniForma TINYINT;
DECLARE @ICO NVARCHAR(20);
DECLARE @Poznamka NVARCHAR(MAX);
DECLARE @JeOdberatel BIT;
DECLARE @JeDodavatel BIT;
DECLARE @Upozorneni NVARCHAR(255);
DECLARE @Fakturacni BIT;
DECLARE @MU BIT;
DECLARE @Prijemce BIT;
DECLARE @CarovyKodEAN NVARCHAR(13);
DECLARE @PostAddress NVARCHAR(255);
DECLARE @Kredit NUMERIC(19,6);
DECLARE @TIN NVARCHAR(17);
DECLARE @EvCisDanovySklad NVARCHAR(30);
DECLARE @DICsk NVARCHAR(15);
DECLARE @OrCislo NVARCHAR(15);
DECLARE @PopCislo NVARCHAR(15);
DECLARE @EORI NVARCHAR(17);
DECLARE @LServer BIT;

-- SETy, parametry
SET @CRLF=CHAR(13)+CHAR(10);
SET @Error = NULL;

SELECT 
	@DBCil = DBCil
FROM Tabx_SynchroTyp
WHERE TypSynchro = @TypSynchro;

SELECT @IDOrg = ID 
FROM TabCisOrg
WHERE CisloOrg = @CisloOrgZdroj;

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
	SELECT 
		@NadrizenaOrg = O.NadrizenaOrg
		,@Nazev = O.Nazev
		,@DruhyNazev = O.DruhyNazev
		,@Misto = O.Misto
		,@IdZeme = O.IdZeme
		,@Ulice = O.Ulice
		,@PSC = O.PSC
		,@PoBox = O.PoBox
		,@DIC = O.DIC
		,@LhutaSplatnosti = O.LhutaSplatnosti
		,@Stav = O.Stav
		,@PravniForma = O.PravniForma
		,@ICO = O.ICO
		,@Poznamka = O.Poznamka
		,@JeOdberatel = O.JeOdberatel
		,@JeDodavatel = O.JeDodavatel
		,@Upozorneni = O.Upozorneni
		,@Fakturacni = O.Fakturacni
		,@MU = O.MU
		,@Prijemce = O.Prijemce
		,@CarovyKodEAN = O.CarovyKodEAN
		,@PostAddress = O.PostAddress
		,@Kredit = O.Kredit
		,@TIN = O.TIN
		,@EvCisDanovySklad = O.EvCisDanovySklad
		,@DICsk = O.DICsk
		,@OrCislo = O.OrCislo
		,@PopCislo = O.PopCislo
		,@EORI = O.EORI
	FROM TabCisOrg O
		LEFT OUTER JOIN TabCisOrg_EXT OE ON O.ID = OE.ID
	WHERE
		O.CisloOrg = @CisloOrgZdroj;

-- * spouštíme proceduru ve slave DB
SET @ExecSQL = N'EXEC ' + @SQLCil + N'[dbo].[hpx_Synchro_CisOrgCil] ' + @CRLF +
N' @CisloOrgZdroj' + @CRLF +
N' ,@DBVerName' + @CRLF +
N' ,@TypAkce' + @CRLF +
N' ,@Error OUT' + @CRLF +
N' ,@CisloOrgCil OUT' + @CRLF +
N' ,@NadrizenaOrg' + @CRLF + 
N' ,@Nazev' + @CRLF + 
N' ,@DruhyNazev' + @CRLF + 
N' ,@Misto' + @CRLF + 
N' ,@IdZeme' + @CRLF + 
N' ,@Ulice' + @CRLF + 
N' ,@PSC' + @CRLF + 
N' ,@PoBox' + @CRLF + 
N' ,@DIC' + @CRLF + 
N' ,@LhutaSplatnosti' + @CRLF + 
N' ,@Stav' + @CRLF + 
N' ,@PravniForma' + @CRLF + 
N' ,@ICO' + @CRLF + 
N' ,@Poznamka' + @CRLF + 
N' ,@JeOdberatel' + @CRLF + 
N' ,@JeDodavatel' + @CRLF + 
N' ,@Upozorneni' + @CRLF + 
N' ,@Fakturacni' + @CRLF + 
N' ,@MU' + @CRLF + 
N' ,@Prijemce' + @CRLF + 
N' ,@CarovyKodEAN' + @CRLF + 
N' ,@PostAddress' + @CRLF + 
N' ,@Kredit' + @CRLF + 
N' ,@TIN' + @CRLF + 
N' ,@EvCisDanovySklad' + @CRLF + 
N' ,@DICsk' + @CRLF + 
N' ,@OrCislo' + @CRLF + 
N' ,@PopCislo' + @CRLF + 
N' ,@EORI'

EXEC sp_executesql @ExecSQL
	,N'@CisloOrgZdroj INT
	,@DBVerName NVARCHAR(100)
	,@TypAkce TINYINT
	,@Error NVARCHAR(255) OUT
	,@CisloOrgCil INT OUT
	,@NadrizenaOrg INT
	,@Nazev NVARCHAR(100)
	,@DruhyNazev NVARCHAR(100)
	,@Misto NVARCHAR(100)
	,@IdZeme NVARCHAR(3)
	,@Ulice NVARCHAR(100)
	,@PSC NVARCHAR(10)
	,@PoBox NVARCHAR(40)
	,@DIC NVARCHAR(15)
	,@LhutaSplatnosti SMALLINT
	,@Stav TINYINT
	,@PravniForma TINYINT
	,@ICO NVARCHAR(20)
	,@Poznamka NVARCHAR(MAX)
	,@JeOdberatel BIT
	,@JeDodavatel BIT
	,@Upozorneni NVARCHAR(255)
	,@Fakturacni BIT
	,@MU BIT
	,@Prijemce BIT
	,@CarovyKodEAN NVARCHAR(13)
	,@PostAddress NVARCHAR(255)
	,@Kredit NUMERIC(19,6)
	,@TIN NVARCHAR(17)
	,@EvCisDanovySklad NVARCHAR(30)
	,@DICsk NVARCHAR(15)
	,@OrCislo NVARCHAR(15)
	,@PopCislo NVARCHAR(15)
	,@EORI NVARCHAR(17)'
	,@CisloOrgZdroj
	,@DBVerName
	,@TypAkce
	,@Error OUT
	,@CisloOrgCil OUT
	,@NadrizenaOrg
	,@Nazev
	,@DruhyNazev
	,@Misto
	,@IdZeme
	,@Ulice
	,@PSC
	,@PoBox
	,@DIC
	,@LhutaSplatnosti
	,@Stav
	,@PravniForma
	,@ICO
	,@Poznamka
	,@JeOdberatel
	,@JeDodavatel
	,@Upozorneni
	,@Fakturacni
	,@MU
	,@Prijemce
	,@CarovyKodEAN
	,@PostAddress
	,@Kredit
	,@TIN
	,@EvCisDanovySklad
	,@DICsk
	,@OrCislo
	,@PopCislo
	,@EORI;

-- zapíšeme do logu
IF @TypAkce IN (0,1)
	BEGIN
		
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
				,@CisloOrgCil
				,GETDATE()
				,SUSER_SNAME()
				,@Error
				,CASE WHEN @Error IS NULL THEN 0 ELSE 1 END);
		ELSE
			UPDATE Tabx_SynchroLog SET
				IdTabCil = @CisloOrgCil
				,DatSynchro = GETDATE()
				,Synchronizoval = SUSER_SNAME()
				,Zprava = @Error
				,Synchro = CASE WHEN @Error IS NULL THEN 0 ELSE 1 END
			WHERE Tab = N'TabCisOrg'
				AND IdTab = @CisloOrgZdroj
				AND TypSynchro = @TypSynchro;
		
	END;
GO

