USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSGenerovatKontrakt]    Script Date: 26.06.2025 15:34:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RSGenerovatKontrakt] @Kontrola BIT
AS
SET NOCOUNT ON;
/*Označí se rámcová obj (NAB), pak F9. Pak označit řádky a spustit funkci, která vybídne k potvrzení.
Poté se na stejném skladu založí nový kontrakt, v řadě kontraktů odběratelských a převede se do položek vše, množství = zbývá pro převod z původní NAB.
A udělá se ideálně položkový převod.*/

-- =====================================================================================================================================================================
-- Author:		MŽ
-- Description:	Generování kontraktů z NAB na stejném skladě z označených řádků více NAB. Množství přebírat množství zbývá pro převod z původní NAB, včetně všech ext.údajů RS. Řada kontraktů shodná jako řada NAB.
-- Výsledkem je položkový převod.
-- =====================================================================================================================================================================

/*
--cvičné deklarace, cílový sklad určí uživatel v ext.akci
DECLARE @IDSkladCil NVARCHAR(30)='20000280'		-- Identifikátor cílového skladu pro výběr položek
--cvičná tabulka, normálně generovaná v HEO #TabExtKomID, obsahuje ID z označených řádků
IF OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL
DROP TABLE #TabExtKomID;
CREATE TABLE #TabExtKomID (ID INT)
INSERT INTO #TabExtKomID (ID) VALUES (5666458),(5696944),(5666457)
--tady končí cvičná tabulka
*/
--ostré deklarace
DECLARE @RadaDokladuCil NVARCHAR(3)--, @RadaDokladuCil NVARCHAR(3)
DECLARE @IDSkladCil NVARCHAR(30)	-- ID cílového skladu dle zdrojového skladu
DECLARE @IDDokladZdroj INT		-- ID dokladu EP, zjistím z položek dokladu
DECLARE	@Autor NVARCHAR(128)=SUSER_SNAME()		-- Autor spuštění
DECLARE	@IDDokladCil INT = NULL	-- návratová hodnota založeného dokladu
DECLARE	@Error NVARCHAR(255) = NULL	-- návratová hodnota chyby

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
DECLARE @DatumKurzu DATETIME;
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
DECLARE @PotvrzDatDod DATETIME;
DECLARE @PozPolozka NVARCHAR(MAX);
DECLARE @ParovaciZnakNew NVARCHAR(50);
DECLARE @ParovaciZnakOrig NVARCHAR(50);
DECLARE @PoradoveCislo INT;
DECLARE @PozadovanyIndexZmeny NVARCHAR(15);
DECLARE @MnoPrevod NUMERIC(19,6);
DECLARE @LCS_PFA_DuvodOpozdeniExp NVARCHAR(255);
DECLARE @dat_dod DATETIME;
DECLARE @Hmotnost NUMERIC(19,6);
DECLARE @ZemePuvodu NVARCHAR(2);
DECLARE @CisloZakazkyDoc NVARCHAR(15);
DECLARE @CisloZakazkyPol NVARCHAR(15);
DECLARE @MistoUrceni INT;
DECLARE @DIC NVARCHAR(15);
DECLARE @CisloZam INT;
DECLARE @KontaktOsoba INT;
DECLARE @KontaktZam INT;
DECLARE @Poradi INT;

IF @Kontrola=1
BEGIN

IF OBJECT_ID('tempdb..#TabPolozkyKPrevodu') IS NOT NULL
DROP TABLE #TabPolozkyKPrevodu;

CREATE TABLE #TabPolozkyKPrevodu (
ID INT IDENTITY(1,1),
IDPohyb INT, 
IDDoklad INT,
RadaDokladu NVARCHAR (3),
CisloOrg INT,
MistoUrceni INT,
DIC NVARCHAR(15),
Mena NVARCHAR(3), 
Kurz NUMERIC(19,6),
DatumKurzu DATETIME,
VstupniCena TINYINT,
NavaznaObjednavka NVARCHAR(30),
FormaUhrady NVARCHAR(30),
FormaDopravy NVARCHAR(30),
CisloZakazkyDoc NVARCHAR(15),
CisloZam INT,
KontaktOsoba INT,
KontaktZam INT,
MnoPrevod NUMERIC(19,6),
Poradi INT,
IDKmen INT,
IDSklad NVARCHAR(30)
)



INSERT INTO #TabPolozkyKPrevodu (IDPohyb, IDDoklad, RadaDokladu, CisloOrg, MistoUrceni, DIC, Mena, Kurz, DatumKurzu, VstupniCena,
NavaznaObjednavka, FormaUhrady, FormaDopravy, CisloZakazkyDoc, CisloZam, KontaktOsoba, KontaktZam, MnoPrevod, Poradi, IDKmen, IDSklad)
SELECT ei.ID, tdz.ID, tdz.RadaDokladu, tdz.CisloOrg, tdz.MistoUrceni, tdz.DIC, tdz.Mena, tdz.Kurz, tdz.DatumKurzu, tdz.VstupniCena, 
tdz.NavaznaObjednavka, tdz.FormaUhrady, tdz.FormaDopravy, tdz.CisloZakazky, tdz.CisloZam, tdz.KontaktOsoba, tdz.KontaktZam, tpz.Mnozstvi-(SELECT ISNULL(SUM(P.Mnozstvi),0) FROM TabPohybyZbozi P WITH(NOLOCK)
WHERE P.IDOldPolozka = tpz.ID), tpz.Poradi, tkz.ID, tdz.IDSklad
FROM #TabExtKomID ei
LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=ei.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
--WHERE tpz.Mnozstvi-tpz.MnOdebrane>0
ORDER BY tdz.ID

SET @IDSkladCil=(SELECT DISTINCT IDSklad FROM #TabPolozkyKPrevodu)
/*
--nejprve zkontrolujeme a případně založíme skladové karty na cílovém skladu
IF OBJECT_ID('tempdb..#TestSkladu') IS NOT NULL
DROP TABLE #TestSkladu;
CREATE TABLE #TestSkladu (ID INT IDENTITY(1,1), IDKmen INT, IDSklad INT)
INSERT INTO #TestSkladu (IDKmen, IDSklad)
SELECT pk.IDKmen, tss.ID
FROM #TabPolozkyKPrevodu pk
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=pk.IDKmen AND tss.IDSklad=@IDSkladCil
IF EXISTS (SELECT ID FROM #TestSkladu WHERE IDSklad IS NULL)
	BEGIN
	DECLARE @IDKmen INT
	DECLARE CurSklad CURSOR LOCAL FAST_FORWARD FOR
	SELECT IDKmen FROM #TestSkladu WHERE IDSklad IS NULL;
	OPEN CurSklad
	FETCH NEXT FROM CurSklad INTO @IDKmen
	WHILE (@@FETCH_STATUS=0) AND (@@ERROR=0)
		BEGIN
		EXEC hp_InsertStavSkladu @IDKmen=@IDKmen, @IDSklad=@IDSkladCil
		FETCH NEXT FROM CurSklad INTO @IDKmen
		END;
	CLOSE CurSklad;
	DEALLOCATE CurSklad;
	END;
*/
--začneme samotnou práci
DECLARE CurGenDok CURSOR LOCAL FAST_FORWARD FOR
	SELECT IDDoklad, RadaDokladu
	FROM #TabPolozkyKPrevodu
	GROUP BY IDDoklad, RadaDokladu
	;
OPEN CurGenDok;
FETCH NEXT FROM CurGenDok INTO 
		@IDDokladZdroj, @RadaDokladuCil
		;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

/*
	IF (SELECT NULLIF(_EXT_RS_mrn,'') FROM TabDokladyZbozi_EXT WHERE ID = @IDDokladZdroj) IS NOT NULL
	BEGIN
	RAISERROR ('Již existuje převedený doklad, akce je přerušena.',16,1)
	RETURN
	END;
*/
/*
--zacneme TRY
BEGIN TRY
	*/	
	-- * tabulka pro data
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
		[NavaznaObjednavka] [NVARCHAR](30) NULL,
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
		[PotvrzDatDod] [DATETIME] NULL,
		[PozPolozka] [nvarchar](MAX) NULL,
		[SkupZbo] [nvarchar](3) NULL,--bylo NOT NULL
		[RegCis] [nvarchar](30) NULL,--bylo NOT NULL
		[PozadovanyIndexZmeny] [NVARCHAR] (15) NULL,
		[MnoPrevod] [NUMERIC](19,6) NULL,
		[LCS_PFA_DuvodOpozdeniExp] [NVARCHAR](255) NULL,
		[dat_dod] [DATETIME] NULL,
		[Hmotnost] [NUMERIC](19,6) NULL,
		[ZemePuvodu] [NVARCHAR](2) NULL,
		[CisloZakazkyPol] [NVARCHAR] (15) NULL,
		[Poradi] [INT] NULL,
		[JCbezDaniKC] [NUMERIC](19,6) NULL
	);

INSERT INTO #TempGenDok(
		IDPohybOrig
		,Mena
		,JednotkaMeny
		,Kurz
		,KurzEuro
		,DatPorizeni
		,Splatnost
		,DUZP
		,DodFak
		,Poznamka
		,PopisDodavky
		,NavaznaObjednavka
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
		,PozadDatDod				-- RayService
		,PotvrzDatDod				-- RayService
		,PozPolozka				-- RayService
		,SkupZbo
		,RegCis
		,IDKmenZbozi
		,PozadovanyIndexZmeny
		,MnoPrevod
		,LCS_PFA_DuvodOpozdeniExp
		,dat_dod
		,Hmotnost
		,ZemePuvodu
		,CisloZakazkyPol
		,Poradi
		,JCbezDaniKC
		)
	SELECT
		P.ID
		,D.Mena
		,D.JednotkaMeny
		,D.Kurz
		,D.KurzEuro
		,D.DatPorizeni
		,D.Splatnost
		,D.DUZP
		,D.ParovaciZnak
		,D.Poznamka
		,D.PopisDodavky
		,D.NavaznaObjednavka
		,D.PoziceZaokrDPH
		,D.HraniceZaokrDPH
		,D.ZaokrDPHvaluty
		,D.ZaokrDPHMalaCisla
		,D.ZaokrouhleniFak
		,D.ZaokrouhleniFakVal
		,DD.PoziceZaokrDPHHla
		,DD.HraniceZaokrDPHHla
		,DD.ZaokrNaPadesat
		,D.CastkaZaoKc
		,P.Mnozstvi
		,P.VstupniCena
		,(CASE P.VstupniCena
			WHEN  0 THEN P.JCbezDaniKC
			WHEN  1 THEN P.JCsDPHKc
			WHEN  2 THEN P.CCbezDaniKc
			WHEN  3 THEN P.CCsDPHKc
			WHEN  4 THEN P.JCbezDaniVal
			WHEN  5 THEN P.JCsDPHVal
			WHEN  6 THEN P.CCbezDaniVal
			WHEN  7 THEN P.CCsDPHVal
			WHEN  8 THEN P.JCsSDKc
			WHEN  9 THEN P.CCsSDKc
			WHEN 10 THEN P.JCsSDVal
			WHEN 11 THEN P.CCsSDVal END) as Cena
		,P.NastaveniSlev 
		,P.SlevaSkupZbo 
		,P.SlevaZboKmen 
		,P.SlevaZboSklad 
		,P.SlevaOrg 
		,P.SlevaSozNa 
		,P.TerminSlevaProc 
		,P.SlevaCastka
		,P.NazevSozNa1
		,P.NazevSozNa2
		,P.NazevSozNa3
		,P.Popis4
		,P.SazbaDPH
		,P.SazbaSD
		,D.DatPovinnostiFa			-- RayService
		,D.FormaDopravy				-- RayService
		,D.FormaUhrady				-- RayService
		,tss2.ID				-- RayService
		,P.PozadDatDod				-- RayService
		,P.PotvrzDatDod				-- RayService
		,P.Poznamka				-- RayService
		,P.SkupZbo
		,P.RegCis
		,tkz.ID
		,PE._PozadovanyIndexZmeny
		,e.MnoPrevod
		,PE._LCS_PFA_DuvodOpozdeniExp
		,PE._dat_dod
		,P.Hmotnost
		,P.ZemePuvodu
		,P.CisloZakazky
		,e.Poradi
		,P.JCbezDaniKC
	FROM #TabPolozkyKPrevodu e
		LEFT OUTER JOIN TabPohybyZbozi P ON P.ID=e.IDPohyb
		LEFT OUTER JOIN TabPohybyZbozi_EXT PE ON PE.ID=P.ID
		LEFT OUTER JOIN TabStavSkladu SS WITH(NOLOCK) ON P.IDZboSklad=SS.ID
		INNER JOIN TabDokladyZbozi D ON P.IDDoklad = D.ID
		LEFT OUTER JOIN TabDokZboDodatek DD ON P.IDDoklad = DD.IDHlavicky
		LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = (SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=P.IDZboSklad)
		LEFT OUTER JOIN TabStavSkladu tss2 ON tss2.IDKmenZbozi=tkz.ID AND tss2.IDSklad = @IDSkladCil
	WHERE P.IDDoklad = CAST(@IDDokladZdroj as NVARCHAR);

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
		,@DodFak = ISNULL(NavaznaObjednavka,DodFak)
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
		,@PotvrzDatDod = PotvrzDatDod
	FROM #TempGenDok;
	
/*	-- ** nahození transakce

	SET @TranCountPred=@@trancount
	IF @TranCountPred=0 BEGIN TRAN
	*/
	/* ** Založení dokladu - EP ** */
	
		SET @Insert = 1;
		SET @IDPosta = NULL;
		SET @DruhPohybu=11	--Kontrakty=11 (SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj);--dříve bylo 9
		SET @PC = NULL;
		SET @DatPorizeni = NULL;
		SET @CisloOrg=(SELECT CisloOrg FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @MistoUrceni=(SELECT MistoUrceni FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @DIC=(SELECT DIC FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @ParovaciZnakOrig=(SELECT ParovaciZnak FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @PoradoveCislo=(SELECT PoradoveCislo FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @CisloZakazkyDoc=(SELECT CisloZakazky FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @DatumKurzu=(SELECT DatumKurzu FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @CisloZam=(SELECT CisloZam FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @KontaktOsoba=(SELECT KontaktOsoba FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		SET @KontaktZam=(SELECT KontaktZam FROM TabDokladyZbozi WHERE ID=@IDDokladZdroj)
		
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
				RAISERROR (N'- interní chyba: při generování hlavičky dokladu',16,1);
				RETURN;
			END;
			
		IF @IDDokladCil IS NULL
			BEGIN
				RAISERROR (N'- interní chyba: neznámý identifikátor generovaného dokladu',16,1);
				RETURN;
			END;
			
		-- aktualizace dokladu
		UPDATE TabDokladyZbozi SET
			JednotkaMeny = @JednotkaMeny
			,Kurz = @Kurz
			,KurzEuro = @KurzEuro
			,DatumKurzu = @DatumKurzu
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
			,NavaznaObjednavka = ISNULL(@DodFak,N'')
			--,PoradoveCislo = @PoradoveCislo
			,CisloZakazky = @CisloZakazkyDoc
			,MistoUrceni = @MistoUrceni
			,DIC = @DIC
			,CisloZam = @CisloZam
			,KontaktOsoba = @KontaktOsoba
			,KontaktZam = @KontaktZam
		WHERE ID = @IDDokladCil;
		
		--nastavíme zaokoruhlení
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

		--založení položek
		--docasna tabulka za normalnich okolnosti generovana HeO
		IF OBJECT_ID('tempdb..#TabTempUziv') IS NULL
			CREATE TABLE #TabTempUziv(
					[Tabulka] [varchar] (255) NOT NULL,
					[SCOPE_IDENTITY] [int] NULL,
					[Datum] [datetime] NULL
				);
		
		--hodnoty z dokladu
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
		
		--statiské hodnoty - dle potřeb
		SET @SazbaSD = 0;
		SET @SazbaDPH = NULL;
		SET @Kolik = NULL;
		SET @PovolitDuplicitu = 1;
		SET @PovolitBlokovane = 1;
		SET @IDObalovanePolozky = NULL;
		SET @Selectem = 0;
		--SET @JCbezDaniKC = 0;
		SET @VstupniCenaProPrepocet = 0 -- dle cenotvorby HeO = NULL / 0 = rychlostně lepší;
		SET @DotahovatSazby = 0;	-- bráz ze zdrojového dokladu
		SET @SlevaDokladu = NULL;
		SET @Nabidka = NULL;
		SET @DatPorizeni = NULL;
		SET @MJ = NULL;
		SET @HlidanoProOrg = 0;
		SET @OrgProCeny = NULL;
		
		-- procházíme položky
		DECLARE CurGenPol CURSOR LOCAL FAST_FORWARD FOR
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
				,PotvrzDatDod
				,PozPolozka
				,PozadovanyIndexZmeny
				,MnoPrevod
				,LCS_PFA_DuvodOpozdeniExp
				,dat_dod
				,Hmotnost
				,ZemePuvodu
				,CisloZakazkyPol
				,Poradi
				,JCbezDaniKC
			FROM #TempGenDok
			WHERE SkupZbo IS NOT NULL;
		OPEN CurGenPol;
		FETCH NEXT FROM CurGenPol INTO 
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
				,@PotvrzDatDod
				,@PozPolozka
				,@PozadovanyIndexZmeny
				,@MnoPrevod
				,@LCS_PFA_DuvodOpozdeniExp
				,@dat_dod
				,@Hmotnost
				,@ZemePuvodu
				,@CisloZakazkyPol
				,@Poradi
				,@JCbezDaniKC;
			WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
			BEGIN
				-- zacatek akce v kurzoru CurGenPol
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
					,@MnoPrevod			--množství zadávaného zboží; default = NULL
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
					/*
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
					,*/
					NastaveniSlev = @NastaveniSlev
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
					,PotvrzDatDod = @PotvrzDatDod
					,Hmotnost=@Hmotnost
					,Autor = @Autor
					,ZemePuvodu = @ZemePuvodu
					,CisloZakazky = @CisloZakazkyPol
					,Poradi = @Poradi
					,IDOldPolozka = @IDPohybOrig
					--,StredNaklad='20000261'
					--,CisloZam=999999
					--,IDAkce=58
				WHERE ID = @IDPolozka;

				-- aktualizujeme externí údaje položky
				IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID = @IDPolozka) IS NULL
				 BEGIN 
					INSERT INTO TabPohybyZbozi_EXT (ID,_PozadovanyIndexZmeny)
					VALUES (@IDPolozka,@PozadovanyIndexZmeny)
				 END
				ELSE
				UPDATE TabPohybyZbozi_EXT SET _PozadovanyIndexZmeny=@PozadovanyIndexZmeny WHERE ID = @IDPolozka
				
				
				-- konec akce v kurzoru CurGenPol
			FETCH NEXT FROM CurGenPol INTO 
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
				,@PotvrzDatDod
				,@PozPolozka
				,@PozadovanyIndexZmeny
				,@MnoPrevod
				,@LCS_PFA_DuvodOpozdeniExp
				,@dat_dod
				,@Hmotnost
				,@ZemePuvodu
				,@CisloZakazkyPol
				,@Poradi
				,@JCbezDaniKC;
			END;
		CLOSE CurGenPol;
		DEALLOCATE CurGenPol;

	
	-- na konci se aktualizují ceny a DPH
	EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDokladCil,0;
	UPDATE TabDokladyZbozi SET BlokovaniEditoru = NULL WHERE ID = @IDDokladCil;
	UPDATE TabDokladyZbozi_EXT SET _EXT_RS_mrn = CAST(@IDDokladCil AS NVARCHAR(30)) WHERE ID = @IDDokladZdroj;
	-- toto asi ne. UPDATE TabDokladyZbozi SET Splneno = 1 WHERE ID = @IDDokladZdroj;

	--přepojení dokumentů z původního dokladu na nový
	INSERT INTO TabDokumVazba (IdentVazby,IdTab,IdDok) 
	SELECT 9,@IDDokladCil,tdv.IdDok
	FROM TabDokumVazba tdv
	WHERE tdv.IdentVazby=9 AND tdv.IdTab=@IDDokladZdroj

	--nakonec musí proběhnout generování kontraktových vazeb
	--cursor pro vkládání položek do TabParPolKontr
	DECLARE @ID int, @ExtCisloZbozi nvarchar(40), @I int, @JeMaster bit 
	SET @JeMaster=0 
	DECLARE crPolKon CURSOR FAST_FORWARD LOCAL FOR 
	  SELECT PZ.ID, LTRIM(PZ.Skup