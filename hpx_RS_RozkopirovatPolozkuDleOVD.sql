USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_RozkopirovatPolozkuDleOVD]    Script Date: 26.06.2025 15:41:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_RozkopirovatPolozkuDleOVD] @OVD NUMERIC(19,6), @kontrola BIT, @ID INT
AS
SET NOCOUNT ON
/*
--cvičné deklarace
USE HCvicna
DECLARE @OVD NUMERIC(19,6)=9
DECLARE @kontrola BIT=1
DECLARE @ID INT=7871194
--pokud mimo HEO, tak se založí #TabTempUziv
IF OBJECT_ID('tempdb..#TabTempUziv')IS NULL
BEGIN
	CREATE TABLE #TabTempUziv(
		[Tabulka] [varchar] (255) NOT NULL,
		[SCOPE_IDENTITY] [int] NULL,
		[Datum] [datetime] NULL
	)
END;
--konec cvičných deklarací
*/
--ostré deklarace
DECLARE	@Error NVARCHAR(255) = NULL	-- návratová hodnota chyby
DECLARE	@Autor NVARCHAR(128)=SUSER_SNAME()		-- Autor spuštění
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

--SELECT (tpz.Mnozstvi-tpz.MnOdebrane)*tpz.PrepMnozstvi,tpz.* FROM TabPohybyZbozi tpz LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID WHERE tpz.ID=@ID

--deklarace RS
DECLARE
@IDDoklad INT,	--ID dokladu, v němž je položka
@RadaPlanu NVARCHAR(10), --Řada výrobního plánu
@IDZakazka int=NULL, --ID z TabZakazka
@IDNewPohyb int=NULL, --ID nového pohybu
@SkupinaPlanu NVARCHAR(10)=NULL,
@NavaznaObjednavka NVARCHAR(30)=NULL,
@KmenoveStredisko NVARCHAR(30)=NULL,
@PozadIndex NVARCHAR(15)=NULL,
@MnozstviOld NUMERIC(19,6)=NULL,
@MnozstviNew NUMERIC(19,6)=NULL,
@MnozstviOrig NUMERIC(19,6)=NULL,
@HmotnostOld NUMERIC(19,6)=NULL,
@HmotnostNew NUMERIC(19,6)=NULL,
@Zamestnanec INT

IF @kontrola=1
BEGIN
IF OBJECT_ID(N'tempdb..#BudPohyb') IS NOT NULL DROP TABLE #BudPohyb
CREATE TABLE #BudPohyb 
(
ID INT IDENTITY(1,1),
IDPohybOld INT,
Mnozstvi NUMERIC(19,6),
Hmotnost NUMERIC(19,6)
)

--položkový select
SELECT
@SkupinaPlanu=tpze._EXT_RS_SkupinaPlanu
,@RadaPlanu=tpze._EXT_RS_RadaPlanu
,@PozadIndex=tpze._PozadovanyIndexZmeny
,@MnozstviOrig=tpz.Mnozstvi
,@MnozstviOld=(tpz.Mnozstvi-tpz.MnOdebrane)*tpz.PrepMnozstvi
,@IDDOklad=tpz.IDDoklad
,@IDZboSklad=tpz.IDZboSklad
,@JCbezDaniKC=tpz.JCbezDaniKc
,@CisloZakazkyPol=tpz.CisloZakazky
,@HmotnostOld=tpz.Hmotnost
,@PozadDatDod = tpz.PozadDatDod
,@PotvrzDatDod = tpz.PotvrzDatDod
,@NastaveniSlev=tpz.NastaveniSlev
,@SlevaSkupZbo=tpz.SlevaSkupZbo
,@SlevaZboKmen=tpz.SlevaZboKmen
,@SlevaZboSklad=tpz.SlevaZboSklad
,@SlevaOrg=tpz.SlevaOrg
,@SlevaSozNa=tpz.SlevaSozNa
,@TerminSlevaProc=tpz.TerminSlevaProc
,@SlevaCastka=tpz.SlevaCastka
,@NazevSozNa1=tpz.NazevSozNa1
,@NazevSozNa2=tpz.NazevSozNa2
,@NazevSozNa3=tpz.NazevSozNa3
,@Popis4=tpz.Popis4
,@PozadDatDod=tpz.PozadDatDod 
,@PotvrzDatDod=tpz.PotvrzDatDod
,@ZemePuvodu=tpz.ZemePuvodu
,@CisloZakazkyPol=tpz.CisloZakazky
,@Poznamka=tpz.Poznamka
,@Zamestnanec=tpz.CisloZam
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
WHERE tpz.ID=@ID

--kontroly na úvod
IF ISNULL(@MnozstviOld,0)<=0
BEGIN
RAISERROR ('Položka je již plně převedena, nic neproběhne.',16,1)
RETURN
END;
IF ISNULL(@OVD,0)<=0
BEGIN
RAISERROR ('Není zadána nenulová optimální výrobní dávka, nic neproběhne.',16,1)
RETURN
END;
IF @MnozstviOld < @OVD
BEGIN
RAISERROR ('Optimální výrobní dávka převyšuje množství položky, nic neproběhne.',16,1)
RETURN
END;

--dokladový select
SELECT 
		@Mena=tdz.Mena
		,@JednotkaMeny=tdz.JednotkaMeny
		,@Kurz=tdz.Kurz
		,@KurzEuro=tdz.KurzEuro
		,@DatPorizeni=tdz.DatPorizeni
		,@Splatnost=tdz.Splatnost
		,@DUZP=tdz.DUZP
		,@DodFak=ISNULL(tdz.NavaznaObjednavka,tdz.DodFak)
		,@PopisDodavky=tdz.PopisDodavky
		,@PoziceZaokrDPH=tdz.PoziceZaokrDPH
		,@HraniceZaokrDPH=tdz.HraniceZaokrDPH
		,@ZaokrDPHvaluty=tdz.ZaokrDPHvaluty
		,@ZaokrDPHMalaCisla=tdz.ZaokrDPHMalaCisla
		,@ZaokrouhleniFak=tdz.ZaokrouhleniFak
		,@ZaokrouhleniFakVal=tdz.ZaokrouhleniFakVal
		,@PoziceZaokrDPHHla=tdz.PoziceZaokrDPH
		,@HraniceZaokrDPHHla=tdz.HraniceZaokrDPH
		,@ZaokrNaPadesat=tdz.ZaokrNaPadesat
		,@ZadanaCastkaZaoKc=tdz.ZadanaCastkaZaoKc
		-- RayService
		,@DatPovinnostiFa=tdz.DatPovinnostiFa
		,@FormaDopravy=tdz.FormaDopravy
		,@FormaUhrady=tdz.FormaUhrady
		,@DruhPohybu=tdz.DruhPohybuZbo
		,@CisloOrg=tdz.CisloOrg
		,@ZakazanoDPH=DR.OsvobozenaPlneni
		,@ParovaciZnakNew=tdz.ParovaciZnak
		,@VstupniCena=tdz.VstupniCena
	FROM TabDokladyZbozi tdz
	INNER JOIN TabDruhDokZbo DR ON tdz.RadaDokladu = DR.RadaDokladu AND tdz.DruhPohybuZbo = DR.DruhPohybuZbo
	WHERE tdz.ID=@IDDoklad;
		
		--statiské hodnoty - dle potřeb
		SET @SazbaSD = 0;
		SET @SazbaDPH = NULL;
		SET @Kolik = NULL;
		SET @PovolitDuplicitu = 1;
		SET @PovolitBlokovane = 1;
		SET @IDObalovanePolozky = NULL;
		SET @Selectem = 0;
		SET @VstupniCenaProPrepocet = 0 -- dle cenotvorby HeO = NULL / 0 = rychlostně lepší;
		SET @DotahovatSazby = 0;	-- bráz ze zdrojového dokladu
		SET @SlevaDokladu = NULL;
		SET @Nabidka = NULL;
		SET @DatPorizeni = NULL;
		SET @MJ = NULL;
		SET @HlidanoProOrg = 0;
		SET @OrgProCeny = NULL;

SET @MnozstviNew=@MnozstviOld-@OVD
--SELECT @MnozstviOld AS MnoPuvodni,@OVD AS OVD,@MnozstviNew AS Zbytek,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoNove

IF @MnozstviNew=0
BEGIN
RAISERROR ('Množství na položce je stejné jako požadované množství, nic neproběhne.',16,1)
RETURN
END;

INSERT INTO #BudPohyb (IDPohybOld,Mnozstvi,Hmotnost)
SELECT @ID,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPohyb,0

WHILE @MnozstviNew>=@OVD
BEGIN
SET @MnozstviNew=@MnozstviNew-@OVD
IF @MnozstviNew<>0
BEGIN
SELECT @MnozstviOld,@OVD,@MnozstviNew,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPohyb
INSERT INTO #BudPohyb (IDPohybOld,Mnozstvi,Hmotnost)
SELECT @ID,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPohyb,0
END
END;

UPDATE bp SET bp.Hmotnost=tpz.Hmotnost/tpz.Mnozstvi*bp.Mnozstvi
FROM #BudPohyb bp
LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=bp.IDPohybOld

SELECT *
FROM #BudPohyb

DECLARE @IDBudPohyb INT, @MnoBudPohyb NUMERIC(19,6)
DECLARE CurPohyb CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID, Mnozstvi, Hmotnost
	FROM #BudPohyb
	OPEN CurPohyb;
	FETCH NEXT FROM CurPohyb INTO @IDBudPohyb, @MnoBudPohyb, @HmotnostNew;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

	--SET @MnoBudPohyb=(SELECT Mnozstvi FROM #BudPohyb WHERE ID=@IDBudPohyb)

	EXEC dbo.hp_InsertPolozkyOZ 
					@IDPolozka OUTPUT		--ID zalozene polozky
					,@IDDoklad=@IDDoklad			--ID hlavičky dokladu, kam položku chceme přidat
					,@DruhPohybu=11		--o jaký pohybový doklad se jedná (hodnota by měla být stejná s hodnotou na hlavičce)
					,@CisloOrg=NULL			--číslo organizace pro cenotvorbu a další věci (hodnota by měla být stejná s hodnotou na hlavičce); možno zadat hodnotu NULL
					,@IDZboSklad=@IDZboSklad		--ID skladové karty zboží, které má být na položce
					,@Mena=@Mena				--kód měny (hodnota by měla být stejná s hodnotou na hlavičce)
					,@Kurz=@Kurz				--kurz měny
					,@JednotkaMeny=@JednotkaMeny		--jednotka měny
					,@KurzEuro=@KurzEuro			--kurz Euro
					,@SazbaSD=@SazbaSD			--sazba spotřební daně, pokud se nemá brát z Kmene
					,@SazbaDPH=@SazbaDPH			--sazba DPH, pokud se nemá brát z Kmene; možno zadat hodnotu NULL
					,@ZakazanoDPH=@ZakazanoDPH		--příznak, zda se má brát v úvahu sazba DPH (při volbě 0 je DPH povoleno, při volbě 1 je DPH zakázáno, při volbě 2 je DPH = 0)
					,@VstupniCena=@VstupniCena		--typ vstupní ceny, použitelné pouze pro varianty JC; 0=JC bez daní,1=JC s DPH,4=JC bez daní valuty,5=JC s DPH valuty,8=JC se SD,10=JC se SD valuty
					,@Kolik=@Kolik				--jak zboží zařazovat zboží na doklad (NULL-po 0 kusu,0-po jednom kuse,1-mnozstvi k dispozici,2-mnozstvi); default NULL
					,@PovolitDuplicitu=@PovolitDuplicitu	--povolit/zakázat vícenásobného zadání stejného zboží na jeden doklad; default = 0
					,@PovolitBlokovane=@PovolitBlokovane	--povolit/zakázat možnost zadání blokovaného zboží na doklad; default = 0
					,@Mnozstvi=@MnoBudPohyb			--množství zadávaného zboží; default = NULL
					,@IDObalovanePolozky=@IDObalovanePolozky	--ID případné obalované položky, které má být přiřazeno k pohybu
					,@Selectem=@Selectem			--tento parametr říká, zda se dohledané parametry mají přímo uložit do tabulky pomocí příkazu INSERT (volba @Selectem=0), či zda se mají vrátit klientovi pomocí příkazu SELECT (nejsou zapsány do tabulky, volba @Selectem=1)
					,@JCbezDaniKC=@JCbezDaniKC		--parametr pro přímé zadání ceny zboží na položce – pozor musíte zadávat jednotkovou cenu bez daně v KČ a parametr @VstupniCena musí mít hodnotu 0 (většinou se jedná o různé importy, kdy se importuje i cena zboží); jestliže cenu neznáte a nebo chcete zboží ocenit standardními postupy oběhu zboží, zadejte nulu
					,@VstupniCenaProPrepocet=@VstupniCenaProPrepocet	--jestliže chceme, aby zboží bylo oceněno standardními postupy systému, tak tento parametr musí mít hodnotu NULL; jestliže zadáváme vlastní cenu pomocí parametru @JcbezDaniKC, musí být tento parametr roven hodnotě 0
					,@DotahovatSazby=@DotahovatSazby	--tento parametr říká, zda dotahovat sazby DPH a spotřební daně z kmene zboží (@DotahovatSazby=1) a nebo použít hodnoty z proměnných @SazbaSD , @SazbaDPH  (@DotahovatSazby=0)
					,@SlevaDokladu=@SlevaDokladu		--sleva v procentech
					,@Nabidka=@Nabidka			--@Nabidka
					,@DatPorizeni=@DatPorizeni		--datum pořízení položky
					,@MJ=@MJ				--měrná jednotka pro cenotvorbu
					,@HlidanoProOrg=@HlidanoProOrg		--zapsat do pohyby číslo organizace pro vyhodnocení hlídaného množství
					,@OrgProCeny=@OrgProCeny;		--číslo organizace pro stanovení cenotvorby


					UPDATE TabPohybyZbozi SET
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
					,Poznamka = @Poznamka
					,CisloZam=@Zamestnanec
					,PozadDatDod = @PozadDatDod
					,PotvrzDatDod = @PotvrzDatDod
					,Hmotnost=@HmotnostNew
					,Autor = @Autor
					,ZemePuvodu = @ZemePuvodu
					,CisloZakazky = @CisloZakazkyPol
					WHERE ID = @IDPolozka;

					-- aktualizujeme externí údaje položky
					IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID = @IDPolozka) IS NULL
					 BEGIN 
						INSERT INTO TabPohybyZbozi_EXT (ID,_PozadovanyIndexZmeny,_EXT_RS_SkupinaPlanu,_EXT_RS_RadaPlanu)
						VALUES (@IDPolozka,@PozadIndex,@SkupinaPlanu,@RadaPlanu)
					 END
					ELSE
					UPDATE TabPohybyZbozi_EXT SET _PozadovanyIndexZmeny=@PozadIndex,_EXT_RS_SkupinaPlanu=@SkupinaPlanu,_EXT_RS_RadaPlanu=@RadaPlanu  WHERE ID = @IDPolozka

FETCH NEXT FROM CurPohyb INTO @IDBudPohyb, @MnoBudPohyb, @HmotnostNew;
END;
CLOSE CurPohyb;
DEALLOCATE CurPohyb;

--úprava množství na stávajícím řádku
UPDATE tpz SET tpz.mnozstvi=@OVD,tpz.Hmotnost=@HmotnostOld/@MnozstviOrig*@OVD
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID

--aktualizace cen na dokladu
EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1

END;
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN
END;
GO

