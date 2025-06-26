USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_EPEPCil]    Script Date: 26.06.2025 13:45:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_Synchro_EPEPCil]
	@DBZdroj NVARCHAR(2)				-- identifikátor Zdrojové databáze
	,@IDDokladZdroj INT					-- ID dokladu ve zdrojové databázi v TabDokladyZbozi
	,@Autor NVARCHAR(128)				-- Autor generování ve zdrojové DB
	,@RadaDokladuCil NVARCHAR(3)		-- Cílová řada dokladu
	,@IDSkladCil NVARCHAR(30)			-- Identifikátor cílového skladu pro výběr položek
	,@DBVerName NVARCHAR(100)			-- Název cílové databáze do hlášek
	,@IDDokladCil INT = NULL OUT		-- návratová hodnota založeného dokladu
	,@Error NVARCHAR(255) = NULL OUT	-- návratová hodnota chyby
AS
SET NOCOUNT ON;

-- =============================================
-- Author:		MŽ
-- Description:	Spuštění synchronizace EP > EP - cílová DB
-- =============================================

/* deklarace */
DECLARE @CisloOrg INT;
DECLARE @Mena NVARCHAR(3);
DECLARE @DodFak NVARCHAR(20);
DECLARE @Poznamka NVARCHAR(MAX);
DECLARE @PopisDodavky NVARCHAR(40);
DECLARE @Splatnost DATETIME;
DECLARE @DUZP DATETIME;
DECLARE @HlavniMena NVARCHAR(3);
DECLARE @SkupZbo NVARCHAR(3);
DECLARE @RegCis NVARCHAR(30);
DECLARE @Mnozstvi NUMERIC(19,6);
DECLARE @VstupniCena TINYINT;
DECLARE @Cena NUMERIC(19,6);
DECLARE @IDOldDoklad INT;
DECLARE @NastaveniSlev SMALLINT;
DECLARE @SlevaSkupZbo NUMERIC(5,2);
DECLARE @SlevaZboKmen NUMERIC(5,2);
DECLARE @SlevaZboSklad NUMERIC(5,2);
DECLARE @SlevaOrg NUMERIC(5,2);
DECLARE @SlevaSozNa NUMERIC(5,2);
DECLARE @TerminSlevaProc NUMERIC(5,2);
DECLARE @SlevaCastka NUMERIC(19,6);
DECLARE @NazevSozNa1 NVARCHAR(100);
DECLARE @NazevSozNa2 NVARCHAR(100);
DECLARE @NazevSozNa3 NVARCHAR(100);
DECLARE @Popis4 NVARCHAR(100);

DECLARE @IDPolozka INT;
DECLARE @IDKmenZbozi INT;
DECLARE @IDZboSklad INT;

DECLARE @PoziceZaokrDPH TINYINT;
DECLARE @HraniceZaokrDPH TINYINT;
DECLARE @ZaokrDPHvaluty TINYINT;
DECLARE @ZaokrDPHMalaCisla TINYINT;
DECLARE @ZaokrouhleniFak SMALLINT;
DECLARE @ZaokrouhleniFakVal SMALLINT;
DECLARE @PoziceZaokrDPHHla TINYINT;
DECLARE @HraniceZaokrDPHHla TINYINT;
DECLARE @ZaokrNaPadesat SMALLINT;
DECLARE @ZadanaCastkaZaoKc NUMERIC(19,6);

-- deklarace pro InsertHlavicky
DECLARE @DatPorizeni DATETIME;
DECLARE @DruhPohybu TINYINT;
DECLARE @Insert BIT;
DECLARE @IDPosta INT;
DECLARE @PC INT;

-- deklarace pro InsertPolozky
DECLARE @SazbaDPH NUMERIC(5,2);
DECLARE @JednotkaMeny INT;
DECLARE @Kurz NUMERIC(19,6);
DECLARE @KurzEuro NUMERIC(19,6);
DECLARE @SazbaSD NUMERIC(19,6);
DECLARE @ZakazanoDPH TINYINT;
DECLARE @Kolik INT;
DECLARE @PovolitDuplicitu BIT;
DECLARE @PovolitBlokovane BIT;
DECLARE @IDObalovanePolozky INT;
DECLARE @Selectem BIT;
DECLARE @JCbezDaniKC NUMERIC(19,6);
DECLARE @VstupniCenaProPrepocet INT;
DECLARE @DotahovatSazby BIT;
DECLARE @SlevaDokladu NUMERIC(19,6);
DECLARE @Nabidka INT;
DECLARE @MJ NVARCHAR(10);
DECLARE @HlidanoProOrg BIT;
DECLARE @OrgProCeny INT;

DECLARE @TranCountPred INT;
DECLARE @DBName NVARCHAR(128);
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLZdroj NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(MAX);
DECLARE @CRLF CHAR(2);
DECLARE @LServer BIT;
DECLARE @SQLCil NVARCHAR(128);

DECLARE @IDDoc INT;
DECLARE @IDDocumentNew INT;

SET @CRLF=CHAR(13)+CHAR(10);

-- výběr dynamických parametrů komunikace
SELECT
	@DBName = [DBName]
	,@ServerName = [ServerName]
	,@CisloOrg = CisloOrg
FROM Tabx_SynchroConfig
WHERE IdentDB = @DBZdroj;
SET @SQLCil='RayService.'

-- * Deklarace - Ray Service
DECLARE @DatPovinnostiFa DATETIME;
DECLARE @FormaDopravy NVARCHAR(30);
DECLARE @FormaUhrady NVARCHAR(30);
DECLARE @IDKmenRS INT;
DECLARE @PozadDatDod DATETIME;
DECLARE @PozPolozka NVARCHAR(MAX);

/* funkční tělo procedury */

--zacneme TRY
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
			RAISERROR ('- zdrojová databáze pro synchronizaci je dočasně nedostupná; zkuste to prosím později nebo kontaktujte správce!',16,1);
			RETURN;
		END;

	SET @SQLZdroj = (QUOTENAME(@ServerName) + '.' + QUOTENAME(@DBName) + '.');

	-- neznámý ID zdrojového dokladu	
	IF @IDDokladZdroj IS NULL
		BEGIN
			RAISERROR ('- neznámý identifikátor zdrojového dokladu v cílové databázi',16,1);
			RETURN;
		END;
		
	-- * tabulka pro data
	-- založení
	IF OBJECT_ID('tempdb..#TempGenDok') IS NOT NULL
		DROP TABLE #TempGenDok;
	CREATE TABLE [#TempGenDok](
		[Mena] [nvarchar](3) NULL,
		[JednotkaMeny] [int] NOT NULL,
		[Kurz] [numeric](19, 6) NOT NULL,
		[KurzEuro] [numeric](19, 6) NOT NULL,
		[DatPorizeni] [datetime] NULL,
		[Splatnost] [datetime] NULL,
		[DUZP] [datetime] NULL,
		[DodFak] [nvarchar](20) NULL,
		[Poznamka] [nvarchar](MAX) NULL,
		[PopisDodavky] [nvarchar](40) NULL,
		[PoziceZaokrDPH] [tinyint] NOT NULL,
		[HraniceZaokrDPH] [tinyint] NOT NULL,
		[ZaokrDPHvaluty] [tinyint] NOT NULL,
		[ZaokrDPHMalaCisla] [tinyint] NOT NULL,
		[ZaokrouhleniFak] [smallint] NOT NULL,
		[ZaokrouhleniFakVal] [smallint] NOT NULL,
		[PoziceZaokrDPHHla] [tinyint] NULL,
		[HraniceZaokrDPHHla] [tinyint] NULL,
		[ZaokrNaPadesat] [smallint] NULL,
		[ZadanaCastkaZaoKc] [numeric](19, 6) NOT NULL,
		[SkupZbo] [nvarchar](3) NULL,--bylo NOT NULL
		[RegCis] [nvarchar](30) NULL,--bylo NOT NULL
		[Mnozstvi] [numeric](19, 6) NOT NULL,
		[VstupniCena] [tinyint] NOT NULL,
		[Cena] [numeric](19, 6) NULL,
		[NastaveniSlev] [smallint] NOT NULL,
		[SlevaSkupZbo] [numeric](5, 2) NOT NULL,
		[SlevaZboKmen] [numeric](5, 2) NOT NULL,
		[SlevaZboSklad] [numeric](5, 2) NOT NULL,
		[SlevaOrg] [numeric](5, 2) NOT NULL,
		[SlevaSozNa] [numeric](5, 2) NOT NULL,
		[TerminSlevaProc] [numeric](5, 2) NOT NULL,
		[SlevaCastka] [numeric](19, 6) NOT NULL,
		[NazevSozNa1] [nvarchar](100) NULL,
		[NazevSozNa2] [nvarchar](100) NULL,
		[NazevSozNa3] [nvarchar](100) NULL,
		[Popis4] [nvarchar](100) NULL,
		[SazbaDPH] [numeric](5, 2) NULL,
		[SazbaSD] [numeric](19, 6) NOT NULL,
		[DatPovinnostiFa] [datetime] NOT NULL,	-- RayService
		[FormaDopravy] [nvarchar](30) NULL,		-- RayService
		[FormaUhrady] [nvarchar](30) NULL,		-- RayService
		[IDKmenRS] [INT] NULL,
		[PozadDatDod] [DATETIME] NULL,
		[PozPolozka] [nvarchar](MAX) NULL,
		[SkupZboRS] [nvarchar](3) NULL,--bylo NOT NULL
		[RegCisRS] [nvarchar](30) NULL--bylo NOT NULL
	);
	-- SQL pro načtení
	SET @ExecSQL = 'INSERT INTO #TempGenDok('+ @CRLF +
		'Mena'+ @CRLF +
		',JednotkaMeny'+ @CRLF +
		',Kurz'+ @CRLF +
		',KurzEuro'+ @CRLF +
		',DatPorizeni'+ @CRLF +
		',Splatnost'+ @CRLF +
		',DUZP'+ @CRLF +
		',DodFak'+ @CRLF +
		',Poznamka'+ @CRLF +
		',PopisDodavky'+ @CRLF +
		',PoziceZaokrDPH'+ @CRLF +
		',HraniceZaokrDPH'+ @CRLF +
		',ZaokrDPHvaluty'+ @CRLF +
		',ZaokrDPHMalaCisla'+ @CRLF +
		',ZaokrouhleniFak'+ @CRLF +
		',ZaokrouhleniFakVal'+ @CRLF +
		',PoziceZaokrDPHHla'+ @CRLF +
		',HraniceZaokrDPHHla'+ @CRLF +
		',ZaokrNaPadesat'+ @CRLF +
		',ZadanaCastkaZaoKc'+ @CRLF +
		',SkupZbo'+ @CRLF +
		',RegCis'+ @CRLF +
		',Mnozstvi'+ @CRLF +
		',VstupniCena'+ @CRLF +
		',Cena' + @CRLF +
		',NastaveniSlev' + @CRLF + 
		',SlevaSkupZbo' + @CRLF + 
		',SlevaZboKmen' + @CRLF + 
		',SlevaZboSklad' + @CRLF + 
		',SlevaOrg' + @CRLF + 
		',SlevaSozNa' + @CRLF + 
		',TerminSlevaProc' + @CRLF + 
		',SlevaCastka'+ @CRLF +
		',NazevSozNa1'+ @CRLF +
		',NazevSozNa2'+ @CRLF +
		',NazevSozNa3'+ @CRLF +
		',Popis4'+ @CRLF +
		',SazbaDPH'+ @CRLF +
		',SazbaSD'+ @CRLF +
		',DatPovinnostiFa'+ @CRLF +			-- RayService
		',FormaDopravy'+ @CRLF +			-- RayService
		',FormaUhrady'+ @CRLF +				-- RayService
		',IDKmenRS'+ @CRLF +				-- RayService
		',PozadDatDod'+ @CRLF +				-- RayService
		',PozPolozka'+ @CRLF +				-- RayService
		',SkupZboRS'+ @CRLF +
		',RegCisRS'+ @CRLF +
		')'+ @CRLF +
	'SELECT'+ @CRLF +
		'D.Mena'+ @CRLF +
		',D.JednotkaMeny'+ @CRLF +
		',D.Kurz'+ @CRLF +
		',D.KurzEuro'+ @CRLF +
		',D.DatPorizeni'+ @CRLF +
		',D.Splatnost'+ @CRLF +
		',D.DUZP'+ @CRLF +
		',D.ParovaciZnak'+ @CRLF +
		',D.Poznamka'+ @CRLF +
		',D.PopisDodavky'+ @CRLF +
		',D.PoziceZaokrDPH'+ @CRLF +
		',D.HraniceZaokrDPH'+ @CRLF +
		',D.ZaokrDPHvaluty'+ @CRLF +
		',D.ZaokrDPHMalaCisla'+ @CRLF +
		',D.ZaokrouhleniFak'+ @CRLF +
		',D.ZaokrouhleniFakVal'+ @CRLF +
		',DD.PoziceZaokrDPHHla'+ @CRLF +
		',DD.HraniceZaokrDPHHla'+ @CRLF +
		',DD.ZaokrNaPadesat'+ @CRLF +
		',D.CastkaZaoKc'+ @CRLF +
		',P.SkupZbo'+ @CRLF +
		',P.RegCis'+ @CRLF +
		',P.Mnozstvi'+ @CRLF +
		',P.VstupniCena'+ @CRLF +
		',(CASE P.VstupniCena'+ @CRLF +
			'WHEN  0 THEN P.JCbezDaniKC'+ @CRLF +
			'WHEN  1 THEN P.JCsDPHKc'+ @CRLF +
			'WHEN  2 THEN P.CCbezDaniKc'+ @CRLF +
			'WHEN  3 THEN P.CCsDPHKc'+ @CRLF +
			'WHEN  4 THEN P.JCbezDaniVal'+ @CRLF +
			'WHEN  5 THEN P.JCsDPHVal'+ @CRLF +
			'WHEN  6 THEN P.CCbezDaniVal'+ @CRLF +
			'WHEN  7 THEN P.CCsDPHVal'+ @CRLF +
			'WHEN  8 THEN P.JCsSDKc'+ @CRLF +
			'WHEN  9 THEN P.CCsSDKc'+ @CRLF +
			'WHEN 10 THEN P.JCsSDVal'+ @CRLF +
			'WHEN 11 THEN P.CCsSDVal END) as Cena'+ @CRLF +
		',P.NastaveniSlev' + @CRLF + 
		',P.SlevaSkupZbo' + @CRLF + 
		',P.SlevaZboKmen' + @CRLF + 
		',P.SlevaZboSklad' + @CRLF + 
		',P.SlevaOrg' + @CRLF + 
		',P.SlevaSozNa' + @CRLF + 
		',P.TerminSlevaProc' + @CRLF + 
		',P.SlevaCastka' + @CRLF +
		',P.NazevSozNa1' + @CRLF +
		',P.NazevSozNa2' + @CRLF +
		',P.NazevSozNa3' + @CRLF +
		',P.Popis4' + @CRLF +
		',P.SazbaDPH' + @CRLF +
		',P.SazbaSD' + @CRLF +
		',D.DatPovinnostiFa' + @CRLF +			-- RayService
		',D.FormaDopravy' + @CRLF +				-- RayService
		',D.FormaUhrady' + @CRLF +				-- RayService
		',tkz.ID' + @CRLF +				-- RayService
		',P.PozadDatDod' + @CRLF +				-- RayService
		',P.Poznamka' + @CRLF +				-- RayService
		',P.SkupZbo'+ @CRLF +
		',P.RegCis'+ @CRLF +
	'FROM ' + @SQLZdroj + 'dbo.TabPohybyZbozi P'+ @CRLF +
		'INNER JOIN ' + @SQLZdroj + '[dbo].[TabDokladyZbozi] D ON P.IDDoklad = D.ID'+ @CRLF +
		'LEFT OUTER JOIN ' + @SQLZdroj + '[dbo].[TabDokZboDodatek] DD ON P.IDDoklad = DD.IDHlavicky'+ @CRLF +
		'LEFT OUTER JOIN ' + @SQLZdroj + '[dbo].[TabKmenZbozi] tkz ON tkz.ID = (SELECT TabStavSkladu.IDKmenZbozi FROM ' + @SQLZdroj + '[dbo].[TabStavSkladu] WHERE TabStavSkladu.ID=P.IDZboSklad)'+ @CRLF +
	'WHERE P.IDDoklad = ' + CAST(@IDDokladZdroj as NVARCHAR);
	
	-- načtení dat, kde by už měly položky odpovídat cílové databázi
	EXEC sp_executesql @ExecSQL;

	IF NOT EXISTS(SELECT * FROM #TempGenDok)
		BEGIN
			RAISERROR ('- interní chyba - žádný záznam v synchronizační tabulce dat #TempGenDok',16,1);
			RETURN;
		END;

	SELECT TOP 1
		@Mena = Mena
		,@JednotkaMeny = JednotkaMeny
		,@Kurz = Kurz
		,@KurzEuro = KurzEuro
		,@DatPorizeni = DatPorizeni
		,@Splatnost = Splatnost
		,@DUZP = DUZP
		,@DodFak = DodFak
		,@Poznamka = Poznamka
		,@PopisDodavky = PopisDodavky
		,@PoziceZaokrDPH = PoziceZaokrDPH
		,@HraniceZaokrDPH = HraniceZaokrDPH
		,@ZaokrDPHvaluty = ZaokrDPHvaluty
		,@ZaokrDPHMalaCisla = ZaokrDPHMalaCisla
		,@ZaokrouhleniFak = ZaokrouhleniFak
		,@ZaokrouhleniFakVal = ZaokrouhleniFakVal
		,@PoziceZaokrDPHHla = PoziceZaokrDPHHla
		,@HraniceZaokrDPHHla = HraniceZaokrDPHHla
		,@ZaokrNaPadesat = ZaokrNaPadesat
		,@ZadanaCastkaZaoKc = ZadanaCastkaZaoKc
		-- RayService
		,@DatPovinnostiFa = DatPovinnostiFa
		,@FormaDopravy = FormaDopravy
		,@FormaUhrady = FormaUhrady
		,@IDKmenRS = IDKmenRS
		,@PozadDatDod = PozadDatDod
	FROM #TempGenDok;
	
	/* kontroly */
	-- Organizace
	IF @CisloOrg IS NULL 
		OR NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg = @CisloOrg)
		BEGIN
			RAISERROR('- neznámé nebo neexistující číslo organizace v databázi %s', 16, 1, @DBVerName);
			RETURN;
		END;
	
	-- Řada dokladu
	IF @RadaDokladuCil IS NULL
		OR NOT EXISTS(SELECT * FROM TabDruhDokZbo WHERE RadaDokladu = @RadaDokladuCil AND DruhPohybuZbo = 9)
		BEGIN
			RAISERROR('- neznámá nebo neexistující řada pro založení EP v databázi %s', 16, 1, @DBVerName);
			RETURN;
		END;
		
	-- Sklad
	IF @IDSkladCil IS NULL
		OR NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo = @IDSkladCil)
		BEGIN
			RAISERROR('- neznámý sklad pro výběr položek EP v databázi %s', 16, 1, @DBVerName);
			RETURN;
		END;
	
	-- Měna
	IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod = @Mena)
		BEGIN
			RAISERROR ('- v databázi %s není založena měna %s',16,1,@DBVerName, @Mena);
			RETURN;
		END;
		
	-- Položky
	SET @Error = NULL;
	DECLARE CurKontrolaPol CURSOR LOCAL FAST_FORWARD FOR
		SELECT DISTINCT
			SkupZbo
			,RegCis
		FROM #TempGenDok;
	OPEN CurKontrolaPol;
	FETCH NEXT FROM CurKontrolaPol INTO @SkupZbo, @RegCis;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurKontrolaPol
			IF NOT EXISTS(SELECT * FROM TabKmenZbozi WHERE SkupZbo = @SkupZbo AND RegCis = @RegCis)
				SET @Error = ISNULL((@Error + N', ' + @SkupZbo + N' ' + @RegCis),(@SkupZbo + N' ' + @RegCis))
			
			-- konec akce v kurzoru CurKontrolaPol
		FETCH NEXT FROM CurKontrolaPol INTO @SkupZbo, @RegCis;
		END;
	CLOSE CurKontrolaPol;
	DEALLOCATE CurKontrolaPol;
	
	--kontrola, zda byly všechny položky převedeny
	SET @Error = NULL;
	IF EXISTS (SELECT * FROM #TempGenDok WHERE SkupZbo IS NULL AND RegCis IS NULL)
		SET @Error = 'Některé položky nebyly převedeny'
		BEGIN
		IF @Error IS NOT NULL
		IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
--		AND NOT @ZDokladu = 1
		BEGIN
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Synchronizace dokladů%')
				BEGIN
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Synchronizace dokladů');
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
				END;
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(' Chyba ' + @Error + ', ale exp.příkaz byl úspěšně synchronizován');
		END;
		END;
	/*	forma úhrady a druh dopravy nekontroluju, jsou irelevantní
	-- * Ray Service
	-- Forma úhrady
	IF @FormaUhrady IS NOT NULL
		AND NOT EXISTS(SELECT * FROM TabFormaUhrady WHERE FormaUhrady = @FormaUhrady)
		BEGIN
			RAISERROR('- v databázi %s není založena forma úhrady %s', 16, 1, @DBVerName, @FormaUhrady);
			RETURN;
		END;
		
	-- Způsob dopravy
	IF @FormaDopravy IS NOT NULL
		AND NOT EXISTS(SELECT * FROM TabFormaDopravy WHERE FormaDopravy = @FormaDopravy)
		BEGIN
			RAISERROR('- v databázi %s není založen druh dopravy %s', 16, 1, @DBVerName, @FormaDopravy);
			RETURN;
		END;
	*/	
			
	-- ** nahození transakce

	SET @TranCountPred=@@trancount
	IF @TranCountPred=0 BEGIN TRAN

	/* ** Založení dokladu - EP ** */
	
		SET @Insert = 1;
		SET @IDPosta = NULL;
		SET @DruhPohybu = 9;
		SET @PC = NULL;
		SET @DatPorizeni = NULL;
		
		-- založení hlavičky 
		EXEC dbo.hp_InsertHlavickyOZ 
			@IDDokladCil OUT -- ID vytvorene hlavicky
			,@IDSkladCil -- @IDSkladCil -- Sklad dokladu
			,@DruhPohybu -- Druh pohybu
			,@RadaDokladuCil -- ŘadaDokladu
			,@Insert -- 1: Insertem  /  0: Selectem
			,@IDPosta
			,@Mena -- je-li NULL, dotahne se dle rady, nebo hlavni mena
			,@CisloOrg -- je-li NULL, dotahne se z posty
			,@PC -- poradove cislo, je-li NULL, dotahne se prvni volne
			,@DatPorizeni; -- je-li NULL, dotahne se z posty, nebo GetDate

		IF @@ERROR <> 0
			BEGIN
				RAISERROR (N'- interní chyba: při generování hlavičky EP',16,1);
				RETURN;
			END;
			
		IF @IDDokladCil IS NULL
			BEGIN
				RAISERROR (N'- interní chyba: neznámý identifikátor generovaného EP',16,1);
				RETURN;
			END;
			
		-- aktualizace na dokladu
		UPDATE TabDokladyZbozi SET
			JednotkaMeny = @JednotkaMeny
			--,Kurz = @Kurz
			--,KurzEuro = @KurzEuro
			,DUZP = @DUZP
			,Splatnost = @Splatnost
			,DodFak = ISNULL(@DodFak,N'')
			,Poznamka = @Poznamka
			,PopisDodavky = @PopisDodavky
			,Autor = @Autor
			,ZadanaCastkaZaoKc = @ZadanaCastkaZaoKc
			,DatumDoruceni = CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE())))
			-- Ray Service
			,DatPovinnostiFa = @DatPovinnostiFa
			--,FormaUhrady = @FormaUhrady --vyjmuto
			--,FormaDopravy = @FormaDopravy --vyjmuto
			,NavaznaObjednavka=ISNULL(@DodFak,N'')
		WHERE ID = @IDDokladCil;
		
		-- nastavíme zaokoruhlení
		EXEC [dbo].[hp_ObehZbozi_ZmenaZaokrPoziceHranice]
			@IDDokladCil
			,@ZaokrNaPadesat
			,@PoziceZaokrDPHHla
			,@HraniceZaokrDPHHla
			,@PoziceZaokrDPH
			,@HraniceZaokrDPH
			,@ZaokrDPHvaluty
			,@ZaokrDPHMalaCisla
			,@ZaokrouhleniFak
			,@ZaokrouhleniFakVal;

		-- nakopírujeme dokumenty z RS SK do RS
		IF(OBJECT_ID('tempdb..#TempTabDokum') IS NOT NULL) BEGIN DROP TABLE #TempTabDokum END
		CREATE TABLE #TempTabDokum (ID INT IDENTITY (1,1), Popis NVARCHAR(255), JmenoACesta NVARCHAR(255))

		INSERT INTO #TempTabDokum(Popis,JmenoACesta)
		SELECT tdRSSK.Popis,tdRSSK.JmenoACesta
		FROM RayService5.dbo.TabDokumenty tdRSSK WITH(NOLOCK)
		WHERE ((EXISTS(SELECT*FROM RayService5.dbo.TabDokumVazba WHERE IdDok=tdRSSK.ID AND IdentVazby=9 AND IdTab=@IDDokladZdroj)))

		--SELECT * FROM #TempTabDokum
		BEGIN
		DECLARE Cur1 CURSOR FOR
			SELECT ID From #TempTabDokum;
		OPEN Cur1
		FETCH NEXT FROM Cur1 INTO @IDDoc;
		WHILE @@FETCH_STATUS = 0
		BEGIN
		INSERT INTO TabDokumenty (Popis, JmenoACesta, VseobDok, SledovatHistorii)
		SELECT Popis,JmenoACesta,1,0
		FROM #TempTabDokum
		WHERE ID=@IDDoc
		SET @IDDocumentNew=(IDENT_CURRENT('TabDokumenty'))
		INSERT INTO TabDokumVazba (IdentVazby,IdTab,IdDok)
		SELECT 9,ID,@IDDocumentNew FROM TabDokladyZbozi WHERE ID=@IDDokladCil
		FETCH NEXT FROM Cur1 INTO @IDDoc;
		END;
		CLOSE Cur1;
		DEALLOCATE Cur1;
		END;
		
		-- ** založení položek
		
		-- docasna tabulka za normalnich okolnosti generovana HeO
		IF OBJECT_ID('tempdb..#TabTempUziv') IS NULL
			CREATE TABLE #TabTempUziv(
					[Tabulka] [varchar] (255) NOT NULL,
					[SCOPE_IDENTITY] [int] NULL,
					[Datum] [datetime] NULL
				);
		
		-- hodnoty z dokladu
		SELECT @DruhPohybu = D.DruhPohybuZbo
			,@CisloOrg = D.CisloOrg
			,@Mena = D.Mena
			,@Kurz = D.Kurz
			,@JednotkaMeny = D.JednotkaMeny
			,@KurzEuro = D.KurzEuro	
			,@ZakazanoDPH = DR.OsvobozenaPlneni
		FROM TabDokladyZbozi D
			INNER JOIN TabDruhDokZbo DR ON D.RadaDokladu = DR.RadaDokladu AND D.DruhPohybuZbo = DR.DruhPohybuZbo
		WHERE D.ID = @IDDokladCil;
		
		-- statiské hodnoty - dle potřeb
		SET @SazbaSD = 0;
		SET @SazbaDPH = NULL;
		SET @Kolik = NULL;
		SET @PovolitDuplicitu = 1;
		SET @PovolitBlokovane = 1;
		SET @IDObalovanePolozky = NULL;
		SET @Selectem = 0;
		SET @JCbezDaniKC = 0;
		SET @VstupniCenaProPrepocet = 0 -- dle cenotvorby HeO = NULL / 0 = rychlostně lepší;
		SET @DotahovatSazby = 0;	-- bráz ze zdrojového dokladu
		SET @SlevaDokladu = NULL;
		SET @Nabidka = NULL;
		SET @DatPorizeni = NULL;
		SET @MJ = NULL;
		SET @HlidanoProOrg = 0;
		SET @OrgProCeny = NULL;
		
		-- procházíme položky
		DECLARE CurZalozPolozky CURSOR LOCAL FAST_FORWARD FOR
			SELECT 
				SkupZbo
				,RegCis
				,Mnozstvi
				,VstupniCena
				,Cena
				,NastaveniSlev
				,SlevaSkupZbo
				,SlevaZboKmen
				,SlevaZboSklad
				,SlevaOrg
				,SlevaSozNa
				,TerminSlevaProc
				,SlevaCastka
				,NazevSozNa1
				,NazevSozNa2
				,NazevSozNa3
				,Popis4
				,SazbaDPH
				,SazbaSD
				,PozadDatDod
				,PozPolozka
			FROM #TempGenDok
			WHERE SkupZbo IS NOT NULL;
		OPEN CurZalozPolozky;
		FETCH NEXT FROM CurZalozPolozky INTO 
				@SkupZbo
				,@RegCis
				,@Mnozstvi
				,@VstupniCena
				,@Cena
				,@NastaveniSlev
				,@SlevaSkupZbo
				,@SlevaZboKmen
				,@SlevaZboSklad
				,@SlevaOrg
				,@SlevaSozNa
				,@TerminSlevaProc
				,@SlevaCastka
				,@NazevSozNa1
				,@NazevSozNa2
				,@NazevSozNa3
				,@Popis4
				,@SazbaDPH
				,@SazbaSD
				,@PozadDatDod
				,@PozPolozka;
			WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
			BEGIN
				-- zacatek akce v kurzoru CurZalozPolozky
				
				SET @IDKmenZbozi = NULL;
				SET @IDZboSklad = NULL;
				SET @IDPolozka = NULL;
				
				-- zjistíme IDKmenZbozi
				SELECT @IDKmenZbozi = ID FROM TabKmenZbozi WHERE SkupZbo = @SkupZbo AND RegCis = @RegCis;
				IF @IDKmenZbozi IS NULL
					BEGIN
						RAISERROR ('- interní chyba: neznámý identifikátor kmenové karty',16,1);
						RETURN;
					END;
					
				-- zajistíme IDZboSklad
				SELECT @IDZboSklad = ID FROM TabStavSkladu WHERE IDKmenZbozi = @IDKmenZbozi AND IDSklad = @IDSkladCil;
				IF @IDZboSklad IS NULL
					BEGIN
						INSERT INTO TabStavSkladu(IDKmenZbozi,IDSklad) VALUES(@IDKmenZbozi,@IDSkladCil);
						SELECT @IDZboSklad = SCOPE_IDENTITY();
					END;
				IF @IDZboSklad IS NULL
					BEGIN
						RAISERROR ('- interní chyba: neznámý identifikátor skladové karty',16,1);
						RETURN;
					END;
					
				-- * založení položky
				EXEC dbo.hp_InsertPolozkyOZ 
					@IDPolozka OUTPUT		--ID zalozene polozky
					,@IDDokladCil			--ID hlavičky dokladu, kam položku chceme přidat
					,@DruhPohybu		--o jaký pohybový doklad se jedná (hodnota by měla být stejná s hodnotou na hlavičce)
					,@CisloOrg			--číslo organizace pro cenotvorbu a další věci (hodnota by měla být stejná s hodnotou na hlavičce); možno zadat hodnotu NULL
					,@IDZboSklad		--ID skladové karty zboží, které má být na položce
					,@Mena				--kód měny (hodnota by měla být stejná s hodnotou na hlavičce)
					,@Kurz				--kurz měny
					,@JednotkaMeny		--jednotka měny
					,@KurzEuro			--kurz Euro
					,@SazbaSD			--sazba spotřební daně, pokud se nemá brát z Kmene
					,@SazbaDPH			--sazba DPH, pokud se nemá brát z Kmene; možno zadat hodnotu NULL
					,@ZakazanoDPH		--příznak, zda se má brát v úvahu sazba DPH (při volbě 0 je DPH povoleno, při volbě 1 je DPH zakázáno, při volbě 2 je DPH = 0)
					,@VstupniCena		--typ vstupní ceny, použitelné pouze pro varianty JC; 0=JC bez daní,1=JC s DPH,4=JC bez daní valuty,5=JC s DPH valuty,8=JC se SD,10=JC se SD valuty
					,@Kolik				--jak zboží zařazovat zboží na doklad (NULL-po 0 kusu,0-po jednom kuse,1-mnozstvi k dispozici,2-mnozstvi); default NULL
					,@PovolitDuplicitu	--povolit/zakázat vícenásobného zadání stejného zboží na jeden doklad; default = 0
					,@PovolitBlokovane	--povolit/zakázat možnost zadání blokovaného zboží na doklad; default = 0
					,@Mnozstvi			--množství zadávaného zboží; default = NULL
					,@IDObalovanePolozky	--ID případné obalované položky, které má být přiřazeno k pohybu
					,@Selectem			--tento parametr říká, zda se dohledané parametry mají přímo uložit do tabulky pomocí příkazu INSERT (volba @Selectem=0), či zda se mají vrátit klientovi pomocí příkazu SELECT (nejsou zapsány do tabulky, volba @Selectem=1)
					,@JCbezDaniKC		--parametr pro přímé zadání ceny zboží na položce – pozor musíte zadávat jednotkovou cenu bez daně v KČ a parametr @VstupniCena musí mít hodnotu 0 (většinou se jedná o různé importy, kdy se importuje i cena zboží); jestliže cenu neznáte a nebo chcete zboží ocenit standardními postupy oběhu zboží, zadejte nulu
					,@VstupniCenaProPrepocet	--jestliže chceme, aby zboží bylo oceněno standardními postupy systému, tak tento parametr musí mít hodnotu NULL; jestliže zadáváme vlastní cenu pomocí parametru @JcbezDaniKC, musí být tento parametr roven hodnotě 0
					,@DotahovatSazby	--tento parametr říká, zda dotahovat sazby DPH a spotřební daně z kmene zboží (@DotahovatSazby=1) a nebo použít hodnoty z proměnných @SazbaSD , @SazbaDPH  (@DotahovatSazby=0)
					,@SlevaDokladu		--sleva v procentech
					,@Nabidka			--@Nabidka
					,@DatPorizeni		--datum pořízení položky
					,@MJ				--měrná jednotka pro cenotvorbu
					,@HlidanoProOrg		--zapsat do pohyby číslo organizace pro vyhodnocení hlídaného množství
					,@OrgProCeny;		--číslo organizace pro stanovení cenotvorby
				
				IF @IDPolozka IS NULL
					BEGIN
						RAISERROR ('- interní chyba: neznámý identifikátor položky %s %s',16,1,@SkupZbo,@RegCis);
						RETURN;
					END;
					
				-- aktualizujeme údaje položky
				UPDATE TabPohybyZbozi SET
					VstupniCena = @VstupniCena
					,JCbezDaniKC = CASE @VstupniCena WHEN 0 THEN @Cena ELSE JCbezDaniKC END
					,JCsDPHKc = CASE @VstupniCena WHEN 1 THEN @Cena ELSE JCsDPHKc END
					,CCbezDaniKc = CASE @VstupniCena WHEN 2 THEN @Cena ELSE CCbezDaniKc END
					,CCsDPHKc = CASE @VstupniCena WHEN 3 THEN @Cena ELSE CCsDPHKc END
					,JCbezDaniVal = CASE @VstupniCena WHEN 4 THEN @Cena ELSE JCbezDaniVal END
					,JCsDPHVal = CASE @VstupniCena WHEN 5 THEN @Cena ELSE JCsDPHVal END
					,CCbezDaniVal = CASE @VstupniCena WHEN 6 THEN @Cena ELSE CCbezDaniVal END
					,CCsDPHVal = CASE @VstupniCena WHEN 7 THEN @Cena ELSE CCsDPHVal END
					,JCsSDKc = CASE @VstupniCena WHEN 8 THEN @Cena ELSE JCsSDKc END
					,CCsSDKc = CASE @VstupniCena WHEN 9 THEN @Cena ELSE CCsSDKc END
					,JCsSDVal = CASE @VstupniCena WHEN 10 THEN @Cena ELSE JCsSDVal END
					,CCsSDVal = CASE @VstupniCena WHEN 11 THEN @Cena ELSE CCsSDVal END
					,NastaveniSlev = @NastaveniSlev
					,SlevaSkupZbo = @SlevaSkupZbo
					,SlevaZboKmen = @SlevaZboKmen
					,SlevaZboSklad = @SlevaZboSklad
					,SlevaOrg = @SlevaOrg
					,SlevaSozNa = @SlevaSozNa
					,TerminSlevaProc = @TerminSlevaProc
					,SlevaCastka = @SlevaCastka
					,NazevSozNa1 = @NazevSozNa1
					,NazevSozNa2 = @NazevSozNa2
					,NazevSozNa3 = @NazevSozNa3
					,Popis4 = @Popis4
					,PozadDatDod = @PozadDatDod
					,Poznamka=@PozPolozka
					,Autor = @Autor
				WHERE ID = @IDPolozka;
/*
				-- přidáme vazbu na původní pohyb z db RS
				INSERT INTO TabPohybyZbozi_EXT (ID,_EXT_RS_IDPohybRSOriginal)
				VALUES (@IDPolozka,@IDPohybRS)*/
								
				-- konec akce v kurzoru CurZalozPolozky
			FETCH NEXT FROM CurZalozPolozky INTO 
				@SkupZbo
				,@RegCis
				,@Mnozstvi
				,@VstupniCena
				,@Cena
				,@NastaveniSlev
				,@SlevaSkupZbo
				,@SlevaZboKmen
				,@SlevaZboSklad
				,@SlevaOrg
				,@SlevaSozNa
				,@TerminSlevaProc
				,@SlevaCastka
				,@NazevSozNa1
				,@NazevSozNa2
				,@NazevSozNa3
				,@Popis4
				,@SazbaDPH
				,@SazbaSD
				,@PozadDatDod
				,@PozPolozka;
			END;
		CLOSE CurZalozPolozky;
		DEALLOCATE CurZalozPolozky;
		
	COMMIT;	
	
	-- * nápočtové rutiny dokladu
	EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDokladCil,0;
	UPDATE TabDokladyZbozi SET BlokovaniEditoru = NULL WHERE ID = @IDDokladCil;
	
END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	SET @Error = @ErrorMessage;
	RETURN;
END CATCH;
GO

