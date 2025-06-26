USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generate_claim]    Script Date: 26.06.2025 11:06:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_generate_claim]
	@GenNeshVC BIT,@RadaDokladuCil NVARCHAR(3)
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		MŽ
-- Description:	Generování nabídek řady 935 ze všech položek označené příjemky. Včetně spuštění Generování VČ neshodných a zpětného propsání políčka _CisNes do příjemky.
-- Výsledkem je položkový převod.
-- MŽ, 20.1.2023 změna - cílový sklad brát ze skladu zdrojového dokladu
-- =============================================
/*
--cvičné deklarace
SET @RadaDokladuCil=N'935'
SET @GenNeshVC=1

--cvičná tabulka, normálně generovaná v HEO #TabExtKomID
IF OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL
DROP TABLE #TabExtKomID;
CREATE TABLE #TabExtKomID (ID INT)

INSERT INTO #TabExtKomID (ID) VALUES (6104198),(6104199)
*/
DECLARE @IDDokladZdroj INT		-- ID dokladu příjemky, zjistím z položek dokladu
	,@IDSkladCil NVARCHAR(30)--nyní se bere ze zdrojového dokladu='100'		-- Identifikátor cílového skladu pro výběr položek
	,@Autor NVARCHAR(128)=SUSER_SNAME()		-- Autor spuštění
	,@IDDokladCil INT = NULL	-- návratová hodnota založeného dokladu
	,@Error NVARCHAR(255) = NULL	-- návratová hodnota chyby

SET @IDDokladZdroj = (SELECT tpz.IDDoklad FROM #TabExtKomID e LEFT OUTER JOIN TabPohybyZbozi tpz ON e.ID=tpz.ID GROUP BY tpz.IDDoklad)
SET @IDSkladCil=(SELECT tdz.IDSklad FROM TabDokladyZbozi tdz WHERE tdz.ID=@IDDokladZdroj)

DECLARE @CisloOrg INT;
DECLARE @IDPohybOrig INT;
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

-- * Deklarace - Ray Service
DECLARE @DatPovinnostiFa DATETIME;
DECLARE @FormaDopravy NVARCHAR(30);
DECLARE @FormaUhrady NVARCHAR(30);
DECLARE @PozadDatDod DATETIME;
DECLARE @PozPolozka NVARCHAR(MAX);
DECLARE @ParovaciZnakNew NVARCHAR(50);
DECLARE @ParovaciZnakOrig NVARCHAR(50);

/* funkční tělo procedury */

--zacneme TRY
BEGIN TRY
		
	-- * tabulka pro data
	-- založení
	IF OBJECT_ID('tempdb..#TempGenDok') IS NOT NULL
		DROP TABLE #TempGenDok;
	CREATE TABLE [#TempGenDok](
		[IDPohybOrig] [INT] NULL,
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
		[IDZboSklad] [INT] NULL,
		[IDKmenZbozi] [INT] NULL,
		[PozadDatDod] [DATETIME] NULL,
		[PozPolozka] [nvarchar](MAX) NULL,
		[SkupZbo] [nvarchar](3) NULL,--bylo NOT NULL
		[RegCis] [nvarchar](30) NULL--bylo NOT NULL
	);
	-- SQL pro načtení
	SET @ExecSQL = 'INSERT INTO #TempGenDok('+ @CRLF +
		'IDPohybOrig'+ @CRLF +
		',Mena'+ @CRLF +
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
		',IDZboSklad'+ @CRLF +				-- RayService
		',PozadDatDod'+ @CRLF +				-- RayService
		',PozPolozka'+ @CRLF +				-- RayService
		',SkupZbo'+ @CRLF +
		',RegCis'+ @CRLF +
		',IDKmenZbozi'+ @CRLF +
		')'+ @CRLF +
	'SELECT'+ @CRLF +
		'P.ID'+ @CRLF +
		',D.Mena'+ @CRLF +
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
		',P.IDZboSklad' + @CRLF +				-- RayService
		',P.PozadDatDod' + @CRLF +				-- RayService
		',P.Poznamka' + @CRLF +				-- RayService
		',P.SkupZbo'+ @CRLF +
		',P.RegCis'+ @CRLF +
		',tkz.ID'+ @CRLF +
	'FROM #TabExtKomID e'+ @CRLF +
		'LEFT OUTER JOIN TabPohybyZbozi P ON P.ID=e.ID'+ @CRLF +
		'LEFT OUTER JOIN TabStavSkladu SS WITH(NOLOCK) ON P.IDZboSklad=SS.ID'+ @CRLF +
		'INNER JOIN TabDokladyZbozi D ON P.IDDoklad = D.ID'+ @CRLF +
		'LEFT OUTER JOIN TabDokZboDodatek DD ON P.IDDoklad = DD.IDHlavicky'+ @CRLF +
		'LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = (SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=P.IDZboSklad)'+ @CRLF +
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
		,@PozadDatDod = PozadDatDod
	FROM #TempGenDok;
	
	-- ** nahození transakce

	SET @TranCountPred=@@trancount
	IF @TranCountPred=0 BEGIN TRAN

	/* ** Založení dokladu - Nabídka ** */
	
		SET @Insert = 1;
		SET @IDPosta = NULL;
		SET @DruhPohybu = 11;
		SET @PC = NULL;
		SET @DatPorizeni = NULL;
		SET @CisloOrg=(SELECT CisloOrg FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @ParovaciZnakOrig=(SELECT ParovaciZnak FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		
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
				RAISERROR (N'- interní chyba: při generování hlavičky Reklamace',16,1);
				RETURN;
			END;
			
		IF @IDDokladCil IS NULL
			BEGIN
				RAISERROR (N'- interní chyba: neznámý identifikátor generované Reklamace',16,1);
				RETURN;
			END;
			
		-- aktualizace na dokladu
		UPDATE TabDokladyZbozi SET
			JednotkaMeny = @JednotkaMeny
			,Kurz = @Kurz
			,KurzEuro = @KurzEuro
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
			,FormaUhrady = @FormaUhrady
			,FormaDopravy = @FormaDopravy
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
			,@ParovaciZnakNew = D.ParovaciZnak
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
				,IDZboSklad
				,IDKmenZbozi
				,IDPohybOrig
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
				,@IDZboSklad
				,@IDKmenZbozi
				,@IDPohybOrig
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
				SET @IDPolozka = NULL;
					
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
					,NazevSozNa2 = N'CofC nedodán'
					,NazevSozNa3 = @NazevSozNa3
					,Popis4 = @Popis4
					,PozadDatDod = @PozadDatDod
					,Poznamka=@ParovaciZnakOrig
					,Autor = @Autor
					,IDOldPolozka = @IDPohybOrig
					,StredNaklad='20000261'
					,CisloZam=999999
					,IDAkce=58
				WHERE ID = @IDPolozka;

				-- aktualizujeme externí údaje položky
				IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID = @IDPolozka) IS NULL
				 BEGIN 
					INSERT INTO TabPohybyZbozi_EXT (ID,_Pricina)
					VALUES (@IDPolozka,'A99-ostatní')
				 END
				ELSE
				UPDATE TabPohybyZbozi_EXT SET _Pricina='A99-ostatní' WHERE ID = @IDPolozka
				/*
				UPDATE TabPohybyZbozi_EXT SET
					_Pricina = 'A99-ostatní'
				WHERE ID = @IDPolozka;*/

				-- přidáme zpětné propsání políčka _CisNes do příjemky
				UPDATE tpze SET _CisNes=@ParovaciZnakNew
				FROM #TabExtKomID e
				LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=e.ID
				/*LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=tpze.ID
				JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
				WHERE tdz.ID=@IDDokladZdroj*/

				-- ještě musíme spustit Generování VČ neshodné na původním dokladu, pokud je v pevných parametrech zadáno 1
				IF @GenNeshVC=1
				BEGIN
				EXEC GEP__SDMater_GenerVCShodNeshod @IDPZ=@IDPohybOrig, @MnBal=@Mnozstvi, @PocBal=1, @IDSS=@IDZboSklad, @Neshody=-1, @DatExp=NULL, @IDVCP_Old=NULL, @PopisVCP=N''
				END
				
				-- konec akce v kurzoru CurZalozPolozky
			FETCH NEXT FROM CurZalozPolozky INTO 
				@SkupZbo
				,@RegCis
				,@IDZboSklad
				,@IDKmenZbozi
				,@IDPohybOrig
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

