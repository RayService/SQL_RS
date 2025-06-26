USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerateSerialNumber_100_115]    Script Date: 26.06.2025 13:39:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_GenerateSerialNumber_100_115] @Realizovat BIT
AS
SET NOCOUNT ON;

--Výčet šarží:
--OK	Množství po výdeji vcs.MnozBezVyd > 0
--OK	Zbývající expirace - vcs.DatExpirace >= dnes+90 (dnů) NEBO POLE NENÍ VYPLNĚNO
--OK	VČ není blokované čtečkou = aktuálně se nevychystává (není v tabulce hvw_BlokovaneSarze)
--OK	VČ není blokováné funkcí přiřazení VČ (není v tabulce hvw__SDMater_VyrCislaKVyskladneni)
--Řadit dle: (vzít postupně shora)
--OK•	Nerozebrané VČ nahoru ; rozebrané dolů (na VČ existuje pohyb řady 6xx)
--•	„Množství?“ Pokud se dá vydat celé požadoné množství v jedné dávce, vybrat to. Pokud ne, brát… <viz níže>
--•	FEFO - nejnižší  nahoru (vcs.DatExpirace_X) //hodina, minuta, vteřina neřešíme…
--•	FIFO = Datum vstup – nejnižší nahoru (vcs.DatVstup_X) //hodina, minuta, vteřina neřešíme…
--•	Pro případ shody několika záznamů může být dalším parametrem třízení  ID 
/*
Optimální by bylo, kdyby sis dokázal zjistit kombinaci VČ s takovým množstvím, aby nedocházelo ke zbytečnému dělení.
Př.
Požadováno: 600m
Skladem: 500m, 300m, 300m
Správná volba: 300m + 300m
Špatná volba: 500m + 100m
I za předpodkladu, že potlačíme FIFO, FEFO.*/
/*
USE HCvicna
--cvičná deklarace - řešeno na předdefinovaných parametrech
DECLARE @Realizovat BIT=1
--cvičná deklarace tabulky s označenými řádky (vše najednou)
IF OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL DROP TABLE #TabExtKomID
CREATE TABLE #TabExtKomID (ID INT)
INSERT INTO #TabExtKomID (ID)
VALUES (6426680),(6426681)
*/
--ostrý start procedury

BEGIN TRY
IF OBJECT_ID('tempdb..#TabPolID') IS NOT NULL DROP TABLE #TabPolID
CREATE TABLE #TabPolID (ID INT IDENTITY(1,1) NOT NULL, IDPolozka INT NOT NULL)
INSERT INTO #TabPolID (IDPolozka)
SELECT ID FROM #TabExtKomID

IF OBJECT_ID('tempdb..#SarzeVyber') IS NOT NULL DROP TABLE #SarzeVyber
CREATE TABLE #SarzeVyber
(ID INT IDENTITY(1,1) NOT NULL
, IDSarze INT NOT NULL
, DatumVstup DATETIME NULL
, Expirace DATETIME NULL
, MnoSarze NUMERIC(19,6) NULL
, MnoPol NUMERIC(19,6) NOT NULL
, KodUmisteni NVARCHAR(50) NULL
, IDPol INT NOT NULL
, Rozbalena BIT NULL
, Zbytek NUMERIC(19,6) NULL
, Poradi INT NULL
, PouzitoVeVypoctu BIT NULL
, SumMnoSarze NUMERIC(19,6)
, VybranaKombinaci BIT NULL
)

--nejrpve spustíme smyčku za jednotlivé řádky dočasné tabule
DECLARE @PolozkaMin INT, @PolozkaMax INT, @IDPol INT, @IDPolText NVARCHAR(255)
SET @PolozkaMin=(SELECT MIN(ID) FROM #TabPolID)
SET @PolozkaMax=(SELECT MAX(ID) FROM #TabPolID)

--SELECT @PolozkaMin AS PolozkaMin, @PolozkaMax AS PolozkaMax

--zjištění hlavičkových údajů
DECLARE @IDVydej INT
DECLARE @DatPripadu DATETIME
DECLARE @DatRealizace DATETIME
DECLARE @Autor SMALLINT

SET @IDVydej=(SELECT TOP 1 tpz.IDDoklad FROM TabPohybyZbozi tpz WHERE tpz.ID IN (SELECT IDPolozka FROM #TabPolID))
SET @DatPripadu=(SELECT DatPorizeni FROM TabDokladyZbozi WHERE ID=@IDVydej)
SET @DatRealizace= (SELECT CASE OZHromadnaRealizace_DruhDatumu WHEN 0 THEN @DatPripadu WHEN 1 THEN GETDATE() WHEN 2 THEN @DatPripadu END FROM TabHGlob)
SET @Autor=(SELECT ID FROM TabUserCfg WHERE LoginName=SUSER_SNAME())

--nejsou-li označeny všechny položky a realizovat=1, tak pryč
IF @Realizovat=1 AND (SELECT COUNT(tpz.ID) FROM TabPohybyZbozi tpz WHERE tpz.IDDoklad=@IDVydej)>(SELECT COUNT(ID) FROM #TabPolID)
BEGIN
RAISERROR('- nejsou označeny všechny položky, není možné generovat šarže a zároveň realizovat výdejku.',16,1)
RETURN
END;

--nahození první smyčky, která prochází označené položky
WHILE (@PolozkaMin<=@PolozkaMax)
BEGIN

	--@IDPol bude řádek v dočasné tabuli
	SET @IDPol=(SELECT IDPolozka FROM #TabPolID WHERE ID=@PolozkaMin)
	SET @IDPolText=(SELECT tpz.SkupZbo+'/'+tpz.RegCis FROM TabPohybyZbozi tpz WHERE tpz.ID=@IDPol)--dříve bylo (SELECT CONVERT(NVARCHAR(20),@IDPol))
	--SELECT @IDPol AS IDPol, @IDPolText AS IDPolText
	
	IF @IDPol IS NOT NULL
	BEGIN
	
	IF OBJECT_ID('tempdb..#SarzeVyber') IS NOT NULL TRUNCATE TABLE #SarzeVyber
	--všechny použitelné šarže, nejprve najdeme vhodné šarže

	INSERT INTO #SarzeVyber (IDSarze,DatumVstup,Expirace,MnoSarze,MnoPol,KodUmisteni,IDPol)
	SELECT vcs.ID AS IDSarze,vcs.DatVstup AS DatumVstup,vcs.DatExpirace AS Expirace ,vcs.MnozDispoBezVyd AS MnoSarze,tpz.Mnozstvi AS MnoPol, tu.Kod AS KodUmisteni,tpz.ID AS IDPol
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=tpz.IDZboSklad
	LEFT OUTER JOIN TabVyrCS vcs ON vcs.IDStavSkladu=tss.ID
	LEFT OUTER JOIN TabUmisteni tu ON tu.ID=(SELECT TOP 1 IDUmisteni FROM hvw_Gatema_StavUmisteni WHERE IDVyrCis=vcs.ID AND Mnozstvi>0)
	WHERE
	(tpz.ID=@IDPol)
	AND(vcs.MnozDispoBezVyd>0)
	AND((vcs.DatExpirace>=GETDATE()+90)OR(vcs.DatExpirace IS NULL))
	AND (NOT EXISTS (SELECT VyrCislo FROM Gatema_BlokovaniSarze_ZK bs WHERE bs.VyrCislo=vcs.Nazev1))
	AND (NOT EXISTS (SELECT IDVyrCisla FROM Tab_SDMater_VyrCislaKVyskladneni vyskl
					LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=(SELECT PZ.IDDoklad FROM TabPohybyZbozi PZ WITH(NOLOCK) WHERE PZ.ID = vyskl.IDPohybyZbozi)
					WHERE vyskl.IDVyrCisla=vcs.ID AND tdz.Realizovano=0))
	AND (tu.Kod NOT IN ('ROZDIL'))
	AND (tu.Nazev<>N'Regál na cívky - příprava výroby')

	IF OBJECT_ID('tempdb..#TabTmpZustDobaExpirace') IS NOT NULL DROP TABLE #TabTmpZustDobaExpirace
	CREATE TABLE #TabTmpZustDobaExpirace (
	ID INT, ZustatkovaDoba INT)

	--teď dodáme informaci o ne/rozbalení
	UPDATE sar SET sar.Rozbalena= CASE WHEN tdz.RadaDokladu LIKE '6%' THEN 1 ELSE 0 END
	FROM #SarzeVyber sar
	LEFT OUTER JOIN TabVyrCP AS vcpRoz ON vcpRoz.IDVyrCis=sar.IDSarze
	LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=vcpRoz.IDPolozkaDokladu
	LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad AND tdz.DruhPohybuZbo IN (2,3,4)
	WHERE sar.IDSarze=vcpRoz.IDVyrCis


		--teď zkusíme vybrat z nerozbalených šarží kombinaci
		IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL DROP TABLE #TempTable
		CREATE TABLE #TempTable (
		ID INT IDENTITY (1,1),
		IDVC INT,
		Mnozstvi NUMERIC(19,6))

		IF OBJECT_ID('tempdb..#TempVC') IS NOT NULL DROP TABLE #TempVC
		CREATE TABLE #TempVC (
		ID INT IDENTITY (1,1),
		IDVCText VARCHAR(7000))

		IF OBJECT_ID('tempdb..#TempVCImport') IS NOT NULL DROP TABLE #TempVCImport
		CREATE TABLE #TempVCImport (
		ID INT IDENTITY (1,1),
		IDVC VARCHAR(7000))

		DECLARE @MnozstviPolozky NUMERIC(19,6)
		SELECT @MnozstviPolozky=tpz.Mnozstvi
		FROM TabPohybyZbozi tpz
		WHERE tpz.ID=@IDPol/*6426725*/
		INSERT INTO #TempTable (IDVC, Mnozstvi)
		SELECT s.IDSarze, s.MnoSarze
		FROM #SarzeVyber s
		WHERE s.Rozbalena=0
		--SELECT * FROM #SarzeVyber
		--SELECT * FROM #TempTable
		IF @MnozstviPolozky<=1 GOTO POKRACOVAT

		;
		WITH SelfRecCTE AS
		( 
		   SELECT CAST(T.IDVC AS VARCHAR(8000)) AS IDVC
		   , T.Mnozstvi AS Mnozstvi
		   , T.ID
		   FROM #TempTable AS T
		   UNION ALL
		   SELECT CAST(T1.IDVC AS VARCHAR(8000)) + ',' + CAST(T2.IDVC AS VARCHAR(8000)) AS IDVC
		   , CAST((T2.Mnozstvi+T1.Mnozstvi) AS NUMERIC(19,6)) AS Mnozstvi
		   , T1.ID
		   FROM #TempTable T1
		   INNER JOIN SelfRecCTE T2 ON T1.ID < T2.ID
		)
		INSERT INTO #TempVC (IDVCText)
		SELECT TOP 1 CONVERT(VARCHAR(7000),IDVC)--, Mnozstvi
		FROM SelfRecCTE
		WHERE Mnozstvi=@MnozstviPolozky
		ORDER By Mnozstvi DESC

		--SELECT * FROM #TempVC
		DECLARE @TEXT VARCHAR(7000)
		SET @TEXT=(SELECT IDVCText FROM #TempVC)
		--SELECT @TEXT AS TextForInsert
		
		INSERT INTO #TempVCImport (IDVC)
		SELECT *  
		FROM STRING_SPLIT(@TEXT, ',') AS result  
		SELECT * FROM #TempVCImport

		--máme-li šarže z kombinace, upravíme tabulku pro výběr šarží, odmažeme nepotřebné a pokračujeme s generováním položek
		IF EXISTS (SELECT * FROM #TempVCImport)
		BEGIN
		--teď zapíšeme výběr šarží zpět do #SarzeVyber
		MERGE #SarzeVyber AS TARGET
		USING #TempVCImport AS SOURCE
		ON TARGET.IDSarze=SOURCE.IDVC
		WHEN MATCHED THEN
		UPDATE SET TARGET.VybranaKombinaci=1, TARGET.PouzitoVeVypoctu=1,TARGET.SumMnoSarze=TARGET.MnoSarze,TARGET.Zbytek=0/*zde musíme nastavit i Pouzitovevypoctu, Zbytek a SumMnoSarze*/
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
		--vytvoříme a uložíme si pořadí šarží
		;WITH RN AS (
		SELECT sar.ID,ROW_NUMBER() OVER (ORDER BY sar.Rozbalena ASC, sar.Expirace ASC, sar.DatumVstup ASC) AS rn
		FROM #SarzeVyber sar)
		UPDATE sarze SET sarze.Poradi=RN.rn
		FROM #SarzeVyber sarze
		LEFT OUTER JOIN RN ON RN.ID=sarze.ID
		GOTO POKRACOVAT
		END

	--vytvoříme a uložíme si pořadí šarží pro případ, že by šarže nebyly v kombinaci
	;WITH RN AS (
	SELECT sar.ID,ROW_NUMBER() OVER (ORDER BY sar.Rozbalena ASC, sar.Expirace ASC, sar.DatumVstup ASC) AS rn
	FROM #SarzeVyber sar)
	UPDATE sarze SET sarze.Poradi=RN.rn
	FROM #SarzeVyber sarze
	LEFT OUTER JOIN RN ON RN.ID=sarze.ID

	--příprava smyčky pro zjištění, která šarže má být použita z výše vybraných
	DECLARE @Poradi INT, @PoradiMax INT, @Zbytek NUMERIC(19,6), @SumMnoSarze NUMERIC(19,6)
	SET @Poradi=1
	SET @PoradiMax=(SELECT MAX(Poradi) FROM #SarzeVyber)
	SET @Zbytek=0
	--nahození smyčky
	WHILE (@Poradi<=@PoradiMax)
	BEGIN
		SELECT @SumMnoSarze=SUM(MnoSarze)
		FROM #SarzeVyber
		WHERE Poradi<=@Poradi
		SELECT @Zbytek=@SumMnoSarze-MnoPol
		FROM #SarzeVyber
		WHERE Poradi=@Poradi
		ORDER BY Poradi ASC

		UPDATE sar SET sar.Zbytek=@Zbytek,sar.SumMnoSarze=@SumMnoSarze,sar.PouzitoVeVypoctu=1
		FROM #SarzeVyber sar
		WHERE sar.Poradi=@Poradi
		--pokud jsem na prvním kladném zbytku, odchod z cyklu
		IF @Zbytek>=0
		BEGIN
		BREAK
		END;

		SET @Poradi=@Poradi+1
		SELECT @Poradi AS NovePoradi
	END;
	
	POKRACOVAT:--tady pokračujeme, pokud jsme dosáhli seznamu šarží z kombinace

	--SELECT * FROM #SarzeVyber ORDER BY Poradi
	SELECT MAX(MnoPol) AS MnoPol FROM #SarzeVyber
	SELECT SUM(MnoSarze) AS MnoSarze FROM #SarzeVyber
	--pokud je množství použitelných šarží menší než množství položky - odchod
	IF (SELECT MAX(MnoPol) FROM #SarzeVyber)>(SELECT SUM(MnoSarze) FROM #SarzeVyber)
	BEGIN
	RAISERROR('- není dostatek použitelných šarží %s, není možné generovat.',16,1,@IDPolText)
	RETURN
	END;

	IF NOT EXISTS (SELECT * FROM #SarzeVyber WHERE PouzitoVeVypoctu=1)
	BEGIN
	RAISERROR('- nejsou žádné použitelné šarže %s, není možné generovat.',16,1,@IDPolText)
	RETURN
	END;
		
	--šarže už máme, tak je nasypeme na položku
	DECLARE @IDPolozky INT, @IDSarze INT
	DECLARE @Popis NVARCHAR(100)
	DECLARE @DatumVstup DATETIME
	DECLARE @Expirace DATETIME

	DECLARE CurDoplnSarze CURSOR LOCAL FAST_FORWARD FOR
	SELECT Poradi
	FROM #SarzeVyber
	WHERE PouzitoVeVypoctu=1
	ORDER BY Poradi ASC
	OPEN CurDoplnSarze
	FETCH NEXT FROM CurDoplnSarze INTO @Poradi
	WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @IDSarze =(SELECT IDSarze FROM #SarzeVyber WHERE Poradi=@Poradi)
			SET @IDPolozky=(SELECT IDPol FROM #SarzeVyber WHERE Poradi=@Poradi)

			SELECT @IDPolozky AS IDPolozky

			--pokud existuje, vkládám šarži a umístění řeší Gatema trigger
			IF @IDSarze IS NOT NULL
				BEGIN

					SELECT @Popis=vcs.Nazev2, @DatumVstup=sv.DatumVstup, @Expirace=sv.Expirace
					FROM #SarzeVyber sv
					LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcs.ID=sv.IDSarze
					WHERE sv.IDSarze=@IDSarze

					--následná práce v položce dokladu:
					--vložení šarže na položku
					DECLARE @p10 int
					INSERT INTO TabVyrCP (IDPolozkaDokladu, IDVyrCis, Nazev, DatVstup, BlokovaniEditoru, DatExpirace, JeNovaVetaEditor)
					VALUES (@IDPolozky,@IDSarze,@Popis,@DatumVstup,NULL,@Expirace,1)
					SELECT @p10=SCOPE_IDENTITY()
					--umístění pořeší trigger od Gatemy

					UPDATE TabVyrCP SET Mnozstvi=(SELECT CASE WHEN Zbytek<=0 THEN MnoSarze WHEN Zbytek>0 THEN MnoSarze-Zbytek ELSE 0 END FROM #SarzeVyber WHERE IDSarze=@IDSarze) WHERE ID=@p10

					--zkopírování ext.atributů z položky na šarži
					DECLARE @KID INT --id kmene
					DECLARE @SID INT -- id stav skladu
					DECLARE @VID INT --id vč
					SET @VID=@IDSarze
					SELECT @KID = K.ID, @SID = S.ID
					FROM TabVyrCS      AS V
					JOIN TabStavSkladu AS S ON S.ID = V.IDStavSkladu
					JOIN TabKmenZbozi  AS K ON K.ID = S.IDKmenZbozi
					WHERE V.ID = @VID
					EXEC hp_CopyExtAtributy @KID, NULL, N'TabKmenZbozi', N'TabVyrCP', 0, 1

					--výpočet zbývající doby expirace
					DECLARE @CisloOrg INT
					SET @CisloOrg = (SELECT tdz.CisloOrg FROM TabPohybyZbozi tpz LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad WHERE tpz.ID=@IDPolozky)
					EXEC dbo.hp_OZVypoctiZustatkovouDobuExpirace @CisloOrg, @SID

				END;

		--konec kursoru
		FETCH NEXT FROM CurDoplnSarze INTO @Poradi

		END;
	CLOSE CurDoplnSarze;
	DEALLOCATE CurDoplnSarze;
	SET @PolozkaMin=@PolozkaMin+1
	IF @PolozkaMin>@PolozkaMax
	BEGIN
	BREAK
	END;
	
	END;--konec podmínky na NULL idpol
END;--konec první smyčky, která prochází označené položky

--pokud byly označeny všechny položky a realizovat=1, tak realizovat výdejku
IF @Realizovat=1 AND (SELECT COUNT(tpz.ID) FROM TabPohybyZbozi tpz WHERE tpz.IDDoklad=@IDVydej)=(SELECT COUNT(ID) FROM #TabPolID)
BEGIN
	EXEC dbo.hp_realizuj_vydej @IDvydej, @DatRealizace, @Autor, 1, NULL, 1, 1
	DECLARE @IDStorno INT, @IDObdobi INT
	SET @IDObdobi=(SELECT Obdobi FROM TabDokladyZbozi WHERE ID=@IDVydej)
	--tabulka pro načtení výsledků generování příjemky
	DECLARE @t TABLE (IDStorno INT, RadaDokladu NVARCHAR(3), DruhPohybuZbo INT, PoradoveCislo NVARCHAR(30), IDSklad NVARCHAR(50), ChybaSkladana INT, BylaChyba INT, Zavaznost INT)
	INSERT @t
	EXEC dbo.hp_generuj_storno_doklad @IDvydej,N'0',N'522',N'10000115',@IDObdobi,NULL,1,1,1,NULL,1
	--uložení ID příjemky
	SELECT @IDStorno=IDStorno FROM @t

	--po realizaci výdejky a vygenerování příjemky následně upravit umístění na šaržích
	--DECLARE @IDStorno INT, @IDvydej INT
	DECLARE @IDSkladPrijem NVARCHAR(30)
	--dočasná tabule pro předgenerování umístění
	IF OBJECT_ID('tempdb..#Umisteni') IS NOT NULL DROP TABLE #Umisteni
	CREATE TABLE #Umisteni (ID INT IDENTITY(1,1) NOT NULL,IDStavSkladu INT,IDKmenZbozi INT,IDVyrCis INT,IDUmisteni INT,DruhPohybu INT,Mnozstvi NUMERIC(19, 6),IDPohZbo INT,NazevVyrC NVARCHAR(100), Kod NVARCHAR(100))

	--SET @IDvydej=1521389
	--SET @IDStorno=1521403
	SET @IDSkladPrijem=(SELECT IDSklad FROM TabDokladyZbozi tdz WHERE tdz.ID=@IDStorno)
	/*
	SELECT gpu.ID,gpu.IDStavSkladu,gpu.IDKmenZbozi,gpu.IDVyrCis,gpu.IDUmisteni,gpu.DruhPohybu,gpu.Mnozstvi,gpu.IDPohZbo,vcs.Nazev1,tu.Kod
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
	LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
	LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
	WHERE tpz.IDDoklad=@IDvydej
	*/
	--vložení do dočasné tabule
	INSERT INTO #Umisteni (IDStavSkladu,IDKmenZbozi,IDVyrCis,DruhPohybu,Mnozstvi,IDPohZbo,NazevVyrC)
	SELECT tpz.IDZboSklad,tss.IDKmenZbozi, vcp.IDVyrCis,0,vcp.Mnozstvi,tpz.ID,vcs.Nazev1
	FROM TabVyrCP vcp
	LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcs.ID=vcp.IDVyrCis
	LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
	LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.ID=tpz.IDZboSklad AND tss.IDSklad=@IDSkladPrijem
	WHERE tpz.IDDoklad=@IDStorno
	--dotažení kódu umístění do dočasné tabule pro následné dohledání nových ID umístění
	/*UPDATE umn SET umn.Kod=(SELECT tu.Kod
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
	LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
	LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
	WHERE tpz.IDDoklad=@IDvydej AND vcs.Nazev1=umn.NazevVyrC)
	FROM #Umisteni umn*/
	;WITH CTE AS (SELECT tu.Kod, vcs.Nazev1, gpu.Mnozstvi
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
	LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
	LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
	WHERE tpz.IDDoklad=@IDvydej)
	UPDATE umn SET umn.Kod=CTE.Kod
	FROM #Umisteni umn
	LEFT OUTER JOIN CTE ON CTE.Nazev1=umn.NazevVyrC AND CTE.Mnozstvi*(-1)=umn.Mnozstvi
	--dotažení nových ID umístění do dočasné tabule
	UPDATE umn SET umn.IDUmisteni=tu.ID
	FROM #Umisteni umn
	LEFT OUTER JOIN TabUmisteni tu ON tu.Kod=umn.Kod AND tu.IdSklad=@IDSkladPrijem

	--pokud umístění na skladu 115 chybí, dogenerovat
	IF EXISTS (SELECT * FROM #Umisteni WHERE IDUmisteni IS NULL)
	BEGIN
		IF OBJECT_ID('tempdb..#UmisteniNew') IS NOT NULL DROP TABLE #UmisteniNew
		CREATE TABLE #UmisteniNew (ID INT IDENTITY(1,1) NOT NULL, IDUmisteni INT, Kod NVARCHAR(100), IDSklad NVARCHAR(30), _IDPolice INT, _PovolitZaporneMnozNaUmisteni BIT, _VyjmoutZMapySkladu BIT, _EXT_RS_IDLocationPrint INT, _EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint BIT,  _EXT_RS_generate_stock_taking_subordinate BIT, _EXT_RS_PhysicalPlace INT)

		DECLARE @IDSkladVydej NVARCHAR(30)
		DECLARE @U TABLE (ID INT)
		SET @IDSkladVydej=(SELECT IDSklad FROM TabDokladyZbozi WHERE ID=@IDVydej)
		;WITH InsU AS (SELECT u.Kod AS Kod, @IDSkladPrijem AS IDSklad, tu.Nazev AS Nazev--, tue._IDPolice, tue._PovolitZaporneMnozNaUmisteni, tue._VyjmoutZMapySkladu , tue._EXT_RS_IDLocationPrint, tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, tue._EXT_RS_generate_stock_taking_subordinate, tue._EXT_RS_PhysicalPlace
		FROM #Umisteni u
		LEFT OUTER JOIN TabUmisteni tu ON tu.Kod=u.Kod AND tu.IDSklad=@IDSkladVydej
		WHERE u.IDUmisteni IS NULL)
		INSERT INTO TabUmisteni (Kod, IDsklad, Nazev)
		OUTPUT inserted.ID INTO @U
		SELECT InsU.Kod, InsU.IDSklad, InsU.Nazev
		FROM InsU

		INSERT INTO #UmisteniNew (IDUmisteni)
		SELECT ID FROM @U

		UPDATE un SET un.Kod=tu.Kod, un.IDSklad=tu.IdSklad
		FROM #UmisteniNew un
		LEFT OUTER JOIN TabUmisteni tu ON tu.ID=un.IDUmisteni
		WHERE tu.IdSklad=@IDSkladPrijem

		UPDATE un SET un._IDPolice=tue._IDPolice, un._PovolitZaporneMnozNaUmisteni=tue._PovolitZaporneMnozNaUmisteni,un._VyjmoutZMapySkladu=tue._VyjmoutZMapySkladu , un._EXT_RS_IDLocationPrint=tue._EXT_RS_IDLocationPrint,
		un._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint=tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, un._EXT_RS_generate_stock_taking_subordinate=tue._EXT_RS_generate_stock_taking_subordinate, un._EXT_RS_PhysicalPlace=tue._EXT_RS_PhysicalPlace
		FROM #UmisteniNew un
		LEFT OUTER JOIN TabUmisteni tu100 ON tu100.Kod=un.Kod AND tu100.IDSklad=@IDSkladVydej
		LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=tu100.ID

		--SELECT * FROM #UmisteniNew

		MERGE TabUmisteni_EXT AS TARGET
		USING #UmisteniNew AS SOURCE
		ON TARGET.ID=SOURCE.IDUmisteni
		WHEN MATCHED THEN UPDATE SET
		TARGET._IDPolice=SOURCE._IDPolice, TARGET._PovolitZaporneMnozNaUmisteni=SOURCE._PovolitZaporneMnozNaUmisteni,TARGET._VyjmoutZMapySkladu=SOURCE._VyjmoutZMapySkladu , TARGET._EXT_RS_IDLocationPrint=SOURCE._EXT_RS_IDLocationPrint,
		TARGET._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint=SOURCE._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, TARGET._EXT_RS_generate_stock_taking_subordinate=SOURCE._EXT_RS_generate_stock_taking_subordinate,
		TARGET._EXT_RS_PhysicalPlace=SOURCE._EXT_RS_PhysicalPlace
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (ID,_IDPolice, _PovolitZaporneMnozNaUmisteni,_VyjmoutZMapySkladu , _EXT_RS_IDLocationPrint, _EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, _EXT_RS_generate_stock_taking_subordinate, _EXT_RS_PhysicalPlace)
		VALUES (SOURCE.IDUmisteni, SOURCE._IDPolice, SOURCE._PovolitZaporneMnozNaUmisteni, SOURCE._VyjmoutZMapySkladu , SOURCE._EXT_RS_IDLocationPrint,SOURCE._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,
		SOURCE._EXT_RS_generate_stock_taking_subordinate, SOURCE._EXT_RS_PhysicalPlace)
		;
	END;
	--znovu dotažení nových ID umístění do dočasné tabule po případném vygenerování
	UPDATE umn SET umn.IDUmisteni=tu.ID
	FROM #Umisteni umn
	LEFT OUTER JOIN TabUmisteni tu ON tu.Kod=umn.Kod AND tu.IdSklad=@IDSkladPrijem

	--vymažeme stávající špatná umístění
	DELETE FROM gpu
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
	LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
	LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
	WHERE tpz.IDDoklad=@IDStorno

	--finální vložení nových umístění
	INSERT INTO Gatema_PohybUmisteni (IDStavSkladu,IDKmenZbozi,IDVyrCis,IDUmisteni,DruhPohybu,Mnozstvi,IDPohZbo)
	SELECT IDStavSkladu,IDKmenZbozi,IDVyrCis,IDUmisteni,DruhPohybu,Mnozstvi,IDPohZbo
	FROM #Umisteni

	--nakonec zřejmě výpočet cen položek
	--EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDvydej, 0
END;

END TRY

--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
-- hláška uživateli
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	-- hláška uživateli - spouštěno z akce
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
		--AND NOT @ZDokladu = 1
		BEGIN
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Výsledek generování šarží%')
				BEGIN
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Výsledek generování šarží');
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
				END;
			INSERT INTO #TabExtKom(Poznamka)
			VALUES('!! CHYBA !! ' + @ErrorMessage);
		END;
END CATCH;	
GO

