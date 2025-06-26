USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generate_claim_coop]    Script Date: 26.06.2025 13:32:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_generate_claim_coop]
	@RadaDokladuCil NVARCHAR(3),@ID INT
AS
SET NOCOUNT ON;
-- ================================================================================================
-- Author:		MŽ
-- Description:	Generování nabídek řady 935 z evidence operací. Včetně zpětného propsání políčka _CisNesKoop do evidence.
-- Organizaci dohledat z viníka neshody - kooperační operace.
-- ================================================================================================
/*
--cvičné deklarace
USE HCvicna
DECLARE @RadaDokladuCil NVARCHAR(3),@ID INT
SET @RadaDokladuCil=N'935'
SET @ID=3019974
*/

DECLARE @IDSkladCil NVARCHAR(30)--nyní se bere ze zdrojového dokladu='100'		-- Identifikátor cílového skladu pro výběr položek
	,@Autor NVARCHAR(128)=SUSER_SNAME()		-- Autor spuštění
	,@IDDokladCil INT = NULL	-- návratová hodnota založeného dokladu
	,@IDPrikaz INT --příkaz na němž je evidence mzdy
	,@IDDilce INT --ID kmenové karty, která se bude generovat do neshody
	,@DokladKoop INT --číslo dokladu kooperační operace
	,@Error NVARCHAR(255) = NULL	-- návratová hodnota chyby

SET @IDSkladCil='100'

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
	--úvodní parametry
	SET @IDPrikaz=(SELECT tpmaz.IDPrikaz FROM TabPrikazMzdyAZmetky tpmaz WHERE tpmaz.ID=@ID)
	SET @DokladKoop=(SELECT prpzmetdok.Doklad
				FROM TabPrikazMzdyAZmetky tpmz
				LEFT OUTER JOIN TabPrPostup prpzmetdok ON tpmz.IDPrikazZmetku=prpzmetdok.IDPrikaz AND tpmz.DokladPrPostupZmetku=prpzmetdok.Doklad AND tpmz.AltPrPostupZmetku=prpzmetdok.Alt AND prpzmetdok.IDOdchylkyDo IS NULL
				WHERE tpmz.ID=@ID)
	SET @IDDilce=(SELECT IDTabKmen FROM TabPrikaz WHERE ID=@IDPrikaz)
	SET @IDZboSklad=(SELECT
				tss.ID
				FROM TabStavSkladu tss
				LEFT OUTER JOIN TabKmenZbozi tkz ON tss.IDKmenZbozi=tkz.ID
				WHERE ((tss.IDSklad=@IDSkladCil)AND(tkz.ID=@IDDilce)))

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
		[PozPolozka] [nvarchar](MAX) NULL,
		[SkupZbo] [nvarchar](3) NULL,--bylo NOT NULL
		[RegCis] [nvarchar](30) NULL--bylo NOT NULL
	);
	-- SQL pro načtení
INSERT INTO #TempGenDok(
		Mena
		,JednotkaMeny
		,Kurz
		,KurzEuro
		,DatPorizeni
		,Splatnost
		,DUZP
		,DodFak
		,Poznamka
		,PopisDodavky
		,PoziceZaokrDPH
		,HraniceZaokrDPH
		,ZaokrDPHvaluty
		,ZaokrDPHMalaCisla
		,ZaokrouhleniFak
		,ZaokrouhleniFakVal
		,PoziceZaokrDPHHla
		,HraniceZaokrDPHHla
		,ZaokrNaPadesat
		,ZadanaCastkaZaoKc
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
		,DatPovinnostiFa			-- RayService
		,FormaDopravy			-- RayService
		,FormaUhrady				-- RayService
		,IDZboSklad				-- RayService
		,PozPolozka			-- RayService
		,SkupZbo
		,RegCis
		,IDKmenZbozi
		)
	SELECT
		koob.Mena
		,koob.JednotkaMeny
		,koob.Kurz
		,0
		,GETDATE()
		,GETDATE()
		,GETDATE()
		,CONVERT(NVARCHAR(4),tppZm.Doklad)+'/'+tp.RadaPrikaz
		,tpmz.Poznamka
		,'PopisDodavky'
		,2/*pozicezaokrdph*/
		,2/*hranicezaokrdph*/
		,0--		',D.ZaokrDPHvaluty'+ @CRLF +
		,0--		',D.ZaokrDPHMalaCisla'+ @CRLF +
		,2--		',D.ZaokrouhleniFak'+ @CRLF +
		,2--		',D.ZaokrouhleniFakVal'+ @CRLF +
		,2--		',DD.PoziceZaokrDPHHla'+ @CRLF +
		,2--		',DD.HraniceZaokrDPHHla'+ @CRLF +
		,0--		',DD.ZaokrNaPadesat'+ @CRLF +
		,0.0--		',D.CastkaZaoKc'+ @CRLF +
		,tpmz.kusy_zmet_opr_IO+tpmz.kusy_zmet_neopr+tpmz.kusy_zmet_opr
		,(CASE tco.Mena
				WHEN 'CZK' THEN 0
				WHEN '' THEN 0
				WHEN 'EUR' THEN 4
				WHEN 'USD' THEN 4
				ELSE 0 END) AS Cena
		,0.0
		,0
		,0.0
		,0.0
		,0.0
		,0.0
		,0.0
		,0.0
		,0.0
		,''
		,''
		,''
		,''
		,21
		,0
		,GETDATE()  --',D.DatPovinnostiFa' + @CRLF +			-- RayService
		,''  --',D.FormaDopravy' + @CRLF +				-- RayService
		,''  --',D.FormaUhrady' + @CRLF +				-- RayService
		,@IDZboSklad
		,tpmz.Poznamka
		,tkz.SkupZbo
		,tkz.RegCis
		,tkz.ID
		FROM TabPrikazMzdyAZmetky tpmz
		LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz
		LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tp.IDTabKmen
		LEFT OUTER JOIN TabPrPostup tppZm ON tppZm.IDPrikaz=tpmz.IDPrikazZmetku AND tpmz.DokladPrPostupZmetku=tppZm.Doklad AND tpmz.AltPrPostupZmetku=tppZm.Alt AND tppZm.IDOdchylkyDo IS NULL
		LEFT OUTER JOIN TabPolKoopObj polkoo ON polkoo.IDPrikaz=tppZm.IDPrikaz AND polkoo.DokladPrPostup=tppZm.Doklad AND polkoo.AltPrPostup=tppZm.Alt AND tppZm.IDOdchylkyDo IS NULL
		LEFT OUTER JOIN TabKoopObj koob ON koob.ID=polkoo.IDObjednavky
		LEFT OUTER JOIN TabCisOrg tco ON tco.ID=koob.IDOrganizace
		WHERE tpmz.ID=@ID;

SELECT * FROM #TempGenDok


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
		,@DatPovinnostiFa = DatPovinnostiFa
		,@FormaDopravy = FormaDopravy
		,@FormaUhrady = FormaUhrady
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
		--zjistíme číslo organizace
		SET @CisloOrg=(SELECT
		tco.CisloOrg
		FROM TabPolKoopObj polkoo
		LEFT OUTER JOIN TabPrPostup prpos ON polkoo.IDPrikaz=prpos.IDPrikaz AND polkoo.DokladPrPostup=prpos.Doklad AND polkoo.AltPrPostup=prpos.Alt AND prpos.IDOdchylkyDo IS NULL
		LEFT OUTER JOIN TabCisOrg tco ON tco.ID=(SELECT KO.IDOrganizace FROM TabKoopObj KO WHERE KO.ID=polkoo.IDObjednavky)
		WHERE
		((polkoo.IDPrikaz=@IDPrikaz AND polkoo.DokladPrPostup=@DokladKoop)))
				
		SET @ParovaciZnakOrig=(SELECT 'Evidence č. '+CONVERT(NVARCHAR(20),tpmz.ID)+', '+tp.RadaPrikaz FROM TabPrikazMzdyAZmetky tpmz LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz WHERE tpmz.ID=@ID)
		
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
			,Splatnost = NULL--úprava z 16.5.2023 @Splatnost
			,DodFak = ISNULL(@DodFak,N'')
			,Poznamka = @Poznamka
			,PopisDodavky = @PopisDodavky
			,Autor = @Autor
			,ZadanaCastkaZaoKc = @ZadanaCastkaZaoKc
			,DatumDoruceni = CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE())))
			-- Ray Service
			,DatPovinnostiFa = @DatPovinnostiFa
			--,FormaUhrady = @FormaUhrady
			--,FormaDopravy = @FormaDopravy
			,NavaznaObjednavka=ISNULL(@DodFak,N'')
		WHERE ID = @IDDokladCil;
		
		UPDATE TabDokladyZbozi SET
		TabDokladyZbozi.CisloZam=(SELECT tcz.Cislo FROM TabCisZam tcz WHERE tcz.LoginID=SUSER_SNAME())
		WHERE TabDokladyZbozi.ID = @IDDokladCil;

		--aktualizujeme externí údaje na dokladu
		IF (SELECT tdze.ID  FROM TabDokladyZbozi_EXT tdze WHERE tdze.ID = @IDDokladCil) IS NULL
				 BEGIN 
					INSERT INTO TabDokladyZbozi_EXT (ID,_dtumvyporadani)
					SELECT @IDDokladCil,tpmz.datum
					FROM TabPrikazMzdyAZmetky tpmz
					WHERE tpmz.ID=@ID
				 END
			ELSE
			UPDATE TabDokladyZbozi_EXT SET TabDokladyZbozi_EXT._dtumvyporadani=(SELECT tpmz.datum
				FROM TabPrikazMzdyAZmetky tpmz
				WHERE tpmz.ID=@ID)
			WHERE TabDokladyZbozi_EXT.ID = @IDDokladCil

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

SELECT *
FROM TabDokladyZbozi
WHERE ID=@IDDokladCil
		
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
				,PozPolozka
			FROM #TempGenDok
			WHERE SkupZbo IS NOT NULL;
		OPEN CurZalozPolozky;
		FETCH NEXT FROM CurZalozPolozky INTO 
				@SkupZbo
				,@RegCis
				,@IDZboSklad
				,@IDKmenZbozi
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
		
		SELECT @IDPolozka


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
					,Poznamka=@ParovaciZnakOrig
					,Autor = @Autor
					,StredNaklad='20000261'
					,CisloZam=999999
					,IDAkce=58
				WHERE ID = @IDPolozka;

				-- aktualizujeme externí údaje položky
				IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID = @IDPolozka) IS NULL
				 BEGIN 
					INSERT INTO TabPohybyZbozi_EXT (ID,_Pricina)
					SELECT @IDPolozka,tpmze._podnesh
					FROM TabPrikazMzdyAZmetky tpmz
					LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze ON tpmze.ID=tpmz.ID
					WHERE tpmz.ID=@ID
				 END
				ELSE
				UPDATE TabPohybyZbozi_EXT SET _Pricina=(SELECT tpmze._podnesh
				FROM TabPrikazMzdyAZmetky tpmz
				LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze ON tpmze.ID=tpmz.ID
				WHERE tpmz.ID=@ID)
				WHERE ID = @IDPolozka

				UPDATE TabPohybyZbozi SET TabPohybyZbozi.NazevSozNa1=(SELECT koob.Objednavka+','+tp.RadaPrikaz
				FROM TabPrikazMzdyAZmetky tpmz
				LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz
				LEFT OUTER JOIN TabPrPostup tppZm ON tppZm.IDPrikaz=tpmz.IDPrikazZmetku AND tpmz.DokladPrPostupZmetku=tppZm.Doklad AND tpmz.AltPrPostupZmetku=tppZm.Alt AND tppZm.IDOdchylkyDo IS NULL
				LEFT OUTER JOIN TabPolKoopObj polkoo ON polkoo.IDPrikaz=tppZm.IDPrikaz AND polkoo.DokladPrPostup=tppZm.Doklad AND polkoo.AltPrPostup=tppZm.Alt AND tppZm.IDOdchylkyDo IS NULL
				LEFT OUTER JOIN TabKoopObj koob ON koob.ID=polkoo.IDObjednavky
				WHERE tpmz.ID=@ID)
				WHERE TabPohybyZbozi.ID = @IDPolozka

				UPDATE TabPohybyZbozi SET TabPohybyZbozi.NazevSozNa2=(SELECT CONVERT(NVARCHAR(100),tpmze._komennesh)
				FROM TabPrikazMzdyAZmetky tpmz
				LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze ON tpmze.ID=tpmz.ID
				WHERE tpmz.ID=@ID)
				WHERE TabPohybyZbozi.ID = @IDPolozka
		
				-- přidáme zpětné propsání políčka _CisNesKoop do příjemky
				UPDATE tpmaze SET _CisNesKoop=@ParovaciZnakNew
				FROM TabPrikazMzdyAZmetky tpmaz
				LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmaze ON tpmaze.ID=tpmaz.ID
				WHERE tpmaze.ID=@ID
	
				-- konec akce v kurzoru CurZalozPolozky
			FETCH NEXT FROM CurZalozPolozky INTO 
				@SkupZbo
				,@RegCis
				,@IDZboSklad
				,@IDKmenZbozi
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
				,@PozPolozka;
			END;
		CLOSE CurZalozPolozky;
		DEALLOCATE CurZalozPolozky;
	
	COMMIT;	
	
	-- * nápočtové rutiny dokladu
	EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDokladCil,0;
	UPDATE TabDokladyZbozi SET BlokovaniEditoru = NULL WHERE ID = @IDDokladCil;

	--přivazbíme dokumenty
	INSERT INTO TabDokumVazba (IdentVazby,IdTab,IdDok) 
	SELECT 9,@IDDokladCil,tdv.IdDok
	FROM TabDokumVazba tdv
	WHERE tdv.IdentVazby=42 AND tdv.IdTab=@ID


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

