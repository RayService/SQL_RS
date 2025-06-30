USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_generovani_dokladu_poptavky_new]    Script Date: 30.06.2025 8:58:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--generování poptávek
CREATE PROCEDURE [dbo].[hpx_generovani_dokladu_poptavky_new]
AS
SET NOCOUNT ON;
-- =========================================================================================
-- Author:		MŽ
-- Description:	Generování poptávek (nabídek) z označených položek ceníku
-- Date: 8.7.209
-- Changed: 11.11.2019 Řada dokladů dle země na organizaci
-- Changed: 29.7.2020 přidán import Termínu nacenění do ext.pole Termín nacenění v položkách
-- Changed: 14.9.2020 Přidána možnost seskupovat podle více organizací z předgenerování
-- =========================================================================================
--deklarace
DECLARE @CisloOrg INT;
DECLARE @Autor NVARCHAR(128);				-- Autor generování
DECLARE @RadaDokladuCil NVARCHAR(3);		-- Cílová řada dokladu (340 nebo 350 dle země na organizaci)
DECLARE @IDSkladCil NVARCHAR(30);			-- Identifikátor cílového skladu pro výběr položek
DECLARE @IDDokladCil INT = NULL;		-- návratová hodnota založeného dokladu
DECLARE @DBVerName NVARCHAR(100) = 'RayService';			-- Název cílové databáze do hlášek
DECLARE @Error NVARCHAR(255) = NULL;	-- návratová hodnota chyby
DECLARE @Mena NVARCHAR(3);
DECLARE @Zeme NVARCHAR(3);
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
DECLARE @Cena NUMERIC(19,6) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @IDOldDoklad INT;
DECLARE @NastaveniSlev SMALLINT = 0; --dávám nulu, protože nevím o jiné hodnotě
DECLARE @SlevaSkupZbo NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaZboKmen NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaZboSklad NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaOrg NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaSozNa NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @TerminSlevaProc NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaCastka NUMERIC(19,6) = 0; --dávám nulu, protože nevím, jakou dohledat
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
DECLARE @ZadanaCastkaZaoKc NUMERIC(19,6) = 0; --dávám nulu, protože nevím, kde hledat
-- deklarace pro InsertHlavicky
DECLARE @DatPorizeni DATETIME;
DECLARE @DruhPohybu TINYINT;
DECLARE @Insert BIT;
DECLARE @IDPosta INT;
DECLARE @PC INT;
DECLARE @DatumKurzu DATETIME;
-- deklarace pro InsertPolozky
DECLARE @SazbaDPH NUMERIC(5,2);
DECLARE @JednotkaMeny INT = 1;
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
DECLARE @IDZakazka INT;
DECLARE @CisloZakazky NVARCHAR(15);
DECLARE @Termin_naceneni DATETIME;
DECLARE @DatPovinnostiFa DATETIME = GETDATE();
DECLARE @FormaDopravy NVARCHAR(30);
DECLARE @FormaUhrady NVARCHAR(30);
DECLARE @ObdobiStavu_DatumOd DATETIME;
DECLARE @ObdobiStavu_DatumDo DATETIME;
DECLARE @ObdobiStavu_Stav TINYINT;
DECLARE @IdObdobiStavu INT;
DECLARE @BankSpojeni_CisloUctu NVARCHAR(40);
DECLARE @BankSpojeni_KodUstavu NVARCHAR(15);
DECLARE @IDBankSpoj INT;
DECLARE @KontaktOsoba INT;

SET @Autor = SUSER_SNAME();

IF NOT EXISTS(SELECT * FROM TempGenPol WHERE Autor = @Autor)
	BEGIN
		RAISERROR ('- interní chyba - žádný záznam v přípravné tabulce dat TempGenPol',16,1);
		RETURN;
	END;
-- docasna tabulka za normalnich okolnosti generovana HeO
		IF OBJECT_ID('tempdb..#TabTempUziv') IS NULL
			CREATE TABLE #TabTempUziv(
					[Tabulka] [varchar] (255) NOT NULL,
					[SCOPE_IDENTITY] [int] NULL,
					[Datum] [datetime] NULL
				);

BEGIN
--první kursor
DECLARE Cur1 CURSOR FOR
    SELECT CisloOrg From TempGenPol
	WHERE Autor = @Autor
	GROUP BY CisloOrg
	ORDER BY CisloOrg ASC;
OPEN Cur1
FETCH NEXT FROM Cur1 INTO @CisloOrg;
WHILE @@FETCH_STATUS = 0
BEGIN
/*
SET @CisloOrg = /*(SELECT TOP 1 CisloOrg FROM TempGenPol WHERE Autor = @Autor)*/(select CisloOrg from (SELECT CisloOrg, ROW_NUMBER() OVER (ORDER BY CisloOrg) AS rn	FROM TempGenPol	WHERE Autor = @Autor
				GROUP BY CisloOrg) x where x.rn = 1);*/
SET @KontaktOsoba = (SELECT VOK.IDCisKOs FROM TabVztahOrgKOs VOK JOIN TabCisOrg Org ON VOK.IDOrg=Org.ID WHERE Org.CisloOrg=@CisloOrg AND VOK.Prednastaveno=1);
SET @CisloZakazky = (SELECT TOP 1 IDZakazka FROM TempGenPol WHERE TempGenPol.Autor = @Autor);
SET @Termin_naceneni = (SELECT TOP 1 Termin_naceneni FROM TempGenPol WHERE TempGenPol.Autor = @Autor);
SET @Zeme = (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg = @CisloOrg);
SET @RadaDokladuCil = (CASE WHEN (@Zeme = 'CZ') THEN '340'
			WHEN (@Zeme IS NULL) THEN '340'
			WHEN (@Zeme = '') THEN '340'
			ELSE '350' END);
SET @Mena = ISNULL((SELECT Mena FROM TabCisOrg WHERE CisloOrg = @CisloOrg),(SELECT DruhMeny FROM TabDruhDokZbo WHERE RadaDokladu = @RadaDokladuCil AND DruhPohybuZbo = 11));
SET @IDSkladCil = '100';
SET @PC = NULL;
SET @DatPorizeni = GETDATE();
SET @VstupniCena = (CASE WHEN (@RadaDokladuCil= '340') THEN 0 WHEN (@RadaDokladuCil = '350') THEN 4	ELSE 0 END);
SET @Insert = 1;
SET @IDPosta = NULL;
SET @DruhPohybu = 11;
IF @CisloOrg IS NOT NULL
/* funkční tělo procedury */
	EXEC dbo.hp_InsertHlavickyOZ 
		@IDDokladCil OUT -- ID vytvorene hlavicky
		,@IDSkladCil -- @Sklad -- Sklad dokladu
		,@DruhPohybu -- Druh pohybu
		,@RadaDokladuCil -- ŘadaDokladu
		,@Insert -- 1: Insertem  /  0: Selectem
		,@IDPosta
		,@Mena -- je-li NULL, dotahne se dle rady, nebo hlavni mena
		,@CisloOrg -- je-li NULL, dotahne se z posty
		,@PC -- poradove cislo, je-li NULL, dotahne se prvni volne
		,@DatPorizeni -- je-li NULL, dotahne se z posty, nebo GetDate
		IF @@ERROR <> 0
			BEGIN
				RAISERROR (N'- interní chyba: při generování dokladu - nic se nevygenerovalo',16,1);
				RETURN;
			END;
			
		IF @IDDokladCil IS NULL
			BEGIN
				RAISERROR (N'- interní chyba: neznámý identifikátor nového dokladu - neznáme hlavičku',16,1);
				RETURN;
			END;
--dohledání kurzu
	SET @DatumKurzu = GETDATE();
	EXEC dbo.hp_EUR_NajdiKurz 1, @Mena, @DatumKurzu OUT,
	@Kurz OUT, @KurzEuro OUT, @JednotkaMeny OUT
-- aktualizace na dokladu
	UPDATE TabDokladyZbozi SET
	JednotkaMeny = ISNULL(@JednotkaMeny,1)
	,Kurz = ISNULL(@Kurz,1)
	,KurzEuro = ISNULL(@KurzEuro,1)
	,DUZP = @DUZP
	,Splatnost = @Splatnost
	,DodFak = ISNULL(@DodFak,N'')
	,Poznamka = @Poznamka
	,PopisDodavky = @PopisDodavky
	,Autor = @Autor
	,ZadanaCastkaZaoKc = @ZadanaCastkaZaoKc
	,DatumDoruceni = CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE())))
	,DatPovinnostiFa = @DatPovinnostiFa
	,FormaUhrady = @FormaUhrady
	,FormaDopravy = @FormaDopravy
	,IdObdobiStavu = @IdObdobiStavu
	,IDBankSpoj = @IDBankSpoj
	,KontaktOsoba = @KontaktOsoba
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
-- založení položek
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
		-- statistické hodnoty - dle potřeb
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
				,IDZakazka
				--,Termin_naceneni
			FROM TempGenPol
			WHERE Autor = @Autor AND CisloOrg = @CisloOrg;
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
				,@IDZakazka;
				--,@Termin_naceneni;
			WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
			BEGIN
			-- zacatek akce v kurzoru CurZalozPolozky
			--SET @Termin_naceneni = (SELECT TOP 1 Termin_naceneni FROM TempGenPol WHERE SkupZbo = @SkupZbo AND RegCis = @RegCis)
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
		-- založení položky
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
--předvyplnění hodnot
	SET @NazevSozNa1 = (SELECT Nazev1 FROM TabKmenZbozi WHERE ID = @IDKmenZbozi)
	SET @NazevSozNa2 = (SELECT Nazev2 FROM TabKmenZbozi WHERE ID = @IDKmenZbozi)
	SET @NazevSozNa3 = (SELECT Nazev3 FROM TabKmenZbozi WHERE ID = @IDKmenZbozi)
	SET @Popis4 = (SELECT Nazev4 FROM TabKmenZbozi WHERE ID = @IDKmenZbozi)
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
			,Autor = @Autor
		WHERE ID = @IDPolozka;
/*		-- dotáhneme ext.políčko Termín nacenění
		INSERT INTO TabPohybyZbozi_EXT (ID) SELECT @IDPolozka
		UPDATE TabPohybyZbozi_EXT SET
			_EXT_RS_termin_naceneni_kalkulace = @Termin_naceneni
		WHERE ID = @IDPolozka;*/
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
				,@IDZakazka;
				--,@Termin_naceneni;
			END;
		CLOSE CurZalozPolozky;
		DEALLOCATE CurZalozPolozky;
	-- nápočtové rutiny dokladu
	EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDokladCil,0;
	UPDATE TabDokladyZbozi SET BlokovaniEditoru = NULL WHERE ID = @IDDokladCil;
	UPDATE TabDokladyZbozi SET CisloZakazky = @CisloZakazky WHERE TabDokladyZbozi.ID = @IDDokladCil;
	INSERT INTO TabDokladyZbozi_EXT (ID) SELECT @IDDokladCil
	UPDATE TabDokladyZbozi_EXT SET _EXT_RS_termin_naceneni_kalkulace = @Termin_naceneni	WHERE ID = @IDDokladCil;

	-- MŽ, 16.6.2025 na žádost MM se do ext.políčka _EXT_RS_PlanovaneUkonceniOperace propisuje plánované ukončení operace s názvem Ceník, která je ve VP, který má stejnou zakázku, jako hlavička poptávky
	DECLARE @DatumPlanovanehoUkonceni DATETIME
	SET @DatumPlanovanehoUkonceni=(SELECT TOP 1 tpp.Plan_ukonceni
									FROM TabPrPostup tpp
									LEFT OUTER JOIN TabZakazka tz ON tz.ID=(SELECT P.IDZakazka FROM TabPrikaz P WHERE P.ID=tpp.IDPrikaz)
									LEFT OUTER JOIN TabPrPostup_EXT tppe ON tppe.ID=tpp.ID
									WHERE
									(tpp.IDOdchylkyDo IS NULL)AND
									(tpp.nazev=N'ceník')AND
									(tz.CisloZakazky=@CisloZakazky)
									ORDER BY tpp.Plan_ukonceni DESC)
	UPDATE TabDokladyZbozi_EXT SET _EXT_RS_PlanovaneUkonceniOperace=@DatumPlanovanehoUkonceni WHERE ID=@IDDokladCil;

	UPDATE TabStrukKusovnik_kalk_cenik SET generovana_poptavka = 1
	FROM TabStrukKusovnik_kalk_cenik
	LEFT OUTER JOIN TempGenPol tgp ON tgp.IDKusovnik = TabStrukKusovnik_kalk_cenik.ID
	WHERE (TabStrukKusovnik_kalk_cenik.generovany_polozky = 1 AND ISNULL(TabStrukKusovnik_kalk_cenik.generovana_poptavka,0) = 0 AND (TabStrukKusovnik_kalk_cenik.OrgNabidka = @CisloOrg OR TabStrukKusovnik_kalk_cenik.OrgNabidka2 = @CisloOrg OR TabStrukKusovnik_kalk_cenik.OrgNabidka3 = @CisloOrg)) AND tgp.Autor = @Autor;
--vymažeme po sobě tabulku s položkami
DELETE FROM TempGenPol WHERE Autor = @Autor AND CisloOrg = @CisloOrg;

FETCH NEXT FROM Cur1 INTO @CisloOrg;
END;
CLOSE Cur1;
DEALLOCATE Cur1;
END;


BEGIN
--vymažeme po sobě dočasnou tabulku
DROP TABLE #TabTempUziv
END;
GO

