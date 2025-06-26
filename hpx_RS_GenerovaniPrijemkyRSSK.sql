USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniPrijemkyRSSK]    Script Date: 26.06.2025 15:42:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniPrijemkyRSSK] @Sklad NVARCHAR(30), @DatumPorizeni DATETIME, @IDVydejky INT	--parametr sklad nechat na výběrovém políčku z číselníku skladů pro RS SK, přednastavit 
AS
--SET NOCOUNT ON

-- cvičně
--DECLARE @IDVydejky INT=1937415;
--DECLARE @DatumPorizeni DATETIME=GETDATE()
--DECLARE @Sklad nvarchar(30)='20000244';
--konec cvičné deklarace

DECLARE @Realizovano BIT, @IDPrijemky INT, @Rada NVARCHAR(3), @IDPZVydejky INT, @IDPZPrijemky INT, @DruhPohybuZbo INT, @IDSarzeVydejky INT, @IDSarzePrijemky INT, @IDSarze INT, @IDpzVOBSK INT;
DECLARE @IDPolSK INT;
DECLARE @IDZboSklad INT;
DECLARE @IDPohybu INT;

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
DECLARE @VstupniCena TINYINT;
DECLARE @KurzSK NUMERIC(19,6);
DECLARE @MnozstviOrig NUMERIC(19,6)=NULL;

--deklarace pro vklad šarží
DECLARE @Nazev1Sarze NVARCHAR(100);
DECLARE @NazevSarze NVARCHAR(100);
DECLARE @MnoSarze NUMERIC(19,6);
DECLARE @IdVyrCS INT;
DECLARE @IDVyrCK INT;

SET @Rada='533';
SET @DruhPohybuZbo=0;

--úvodní kontroly
SELECT @Realizovano=Realizovano 
FROM TabDokladyZbozi
WHERE ID=@IDVydejky
IF (@Realizovano=0)
BEGIN
	RAISERROR('Doklad není realizovaný, nelze generovat.', 16, 1)
	RETURN
END;

IF (SELECT tpze._EXT_RS_IDPrijemkyRS_SK  FROM TabDokladyZbozi_EXT tpze WHERE tpze.ID = @IDVydejky) IS NOT NULL
BEGIN
	RAISERROR('Doklad je již převeden, nelze generovat.', 16, 1)
	RETURN
END;


--dočasná tabule pro položky
IF OBJECT_ID('tempdb..#Polozky') IS NOT NULL DROP TABLE #Polozky
CREATE TABLE #Polozky (ID INT IDENTITY(1,1), SkupZbo NVARCHAR(3), RegCis NVARCHAR(30), IDPolSK INT, JCBezDani NUMERIC(19,6), MnoPol NUMERIC(19,6), MJ NVARCHAR(10), IDPohybu INT, IDpzVOBSK INT)
INSERT INTO #Polozky (SkupZbo, RegCis, IDPolSK, JCBezDani, MnoPol, MJ, IDPohybu, IDpzVOBSK)
SELECT tpz.SkupZbo, tpz.RegCis, tkzSK.ID, tpz.JCbezDaniVal, tpz.Mnozstvi, tpz.MJEvidence, tpz.ID, tpze._EXT_RS_IDPohybuVOB_RSSK
FROM RayService.dbo.TabPohybyZbozi tpz
LEFT OUTER JOIN RayService.dbo.TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
LEFT OUTER JOIN RayService5.dbo.TabKmenZbozi tkzSK ON tkzSK.SkupZbo=tpz.SkupZbo AND tkzSK.RegCis=tpz.RegCis
WHERE tpz.IDDoklad=@IDVydejky
--dočasná tabule pro šarže
IF OBJECT_ID('tempdb..#Sarze') IS NOT NULL DROP TABLE #Sarze
CREATE TABLE #Sarze (ID INT IDENTITY(1,1), Nazev1 NVARCHAR(100), Nazev/*Popis*/ NVARCHAR(100), MnoSar NUMERIC(19,6), IDPohybu INT)
INSERT INTO #Sarze (Nazev1, Nazev, MnoSar, IDPohybu)
SELECT vcs.Nazev1, vcs.Nazev2, vcp.Mnozstvi, tpz.ID
FROM TabVyrCP vcp
LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=vcp.IDVyrCis
--LEFT OUTER JOIN RayService5.dbo.TabKmenZbozi tkzSK ON tkzSK.SkupZbo=tpz.SkupZbo AND tkzSK.RegCis=tpz.RegCis
--LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE tpz.IDDoklad=@IDVydejky

--kontrola položek
IF EXISTS (SELECT ID FROM #Polozky WHERE IDPolSK IS NULL)
BEGIN
RAISERROR('Nelze pokračovat, některá položka není v RS SK založena.',16,1)
RETURN;
END;


--SELECT *
--FROM #Polozky

--SELECT *
--FROM #Sarze


------Vložení hlavičky dokladu------
BEGIN
EXEC RayService5.dbo.hp_InsertHlavickyOZ @IDPrijemky OUTPUT, @Sklad=@Sklad, @DruhPohybu=@DruhPohybuZbo, @RadaDokladu=@Rada, @CisloOrg=2, @DatumPorizeni=@DatumPorizeni
IF (@@ERROR<>0) OR (@IDPrijemky IS NULL)
	BEGIN
	RAISERROR('Nepodařilo se vygenerovat příjemku.',16,1)
	RETURN
	END;
--úpravy příjemky
UPDATE DZ SET DZ.CisloZakazky='0'--, DZ.VstupniCena=DZ_V.VstupniCena
FROM RayService5.dbo.TabDokladyZbozi DZ
INNER JOIN TabDokladyZbozi DZ_V ON DZ_V.ID=@IDVydejky
WHERE DZ.ID=@IDPrijemky

SELECT @VstupniCena=VstupniCena, @Mena=Mena, @Kurz=Kurz, @KurzEuro=KurzEuro, @JednotkaMeny=JednotkaMeny
FROM RayService5.dbo.TabDokladyZbozi
WHERE ID=@IDPrijemky
--zjistím aktuální kurz pro přepočet ceny
--SET @KurzSK=(SELECT TOP 1 Kurz
--FROM TabKurzList
--WHERE Mena='EUR'
--ORDER BY Datum DESC)

SET @SazbaSD = 0;
SET @SazbaDPH = NULL;
SET @ZakazanoDPH=0;
SET @Kolik = NULL;
SET @PovolitDuplicitu = 1;
SET @PovolitBlokovane = 1;
SET @IDObalovanePolozky = NULL;
SET @Selectem = 0;
SET @VstupniCenaProPrepocet = 0 -- dle cenotvorby HeO = NULL / 0 = rychlostně lepší;
SET @DotahovatSazby = 0;	-- bráz ze zdrojového dokladu
SET @SlevaDokladu = NULL;
SET @Nabidka = NULL;
--SET @DatPorizeni = NULL;
--SET @MJ = NULL;
SET @HlidanoProOrg = 0;
SET @OrgProCeny = NULL;

--začneme vkládat položky, pojedeme smyčkou v #Polozky
DECLARE @IDStart INT, @IDEnd INT
SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #Polozky

WHILE @IDStart<=@IDEnd
BEGIN
	SET @IDPolSK=(SELECT IDPolSK FROM #Polozky WHERE ID=@IDStart)
	SET @IDZboSklad=(SELECT ID FROM RayService5.dbo.TabStavSkladu WHERE IDSklad=@Sklad AND IDKmenZbozi=@IDPolSK)
	IF @IDZboSklad IS NULL
		BEGIN
		EXEC RayService5.dbo.hp_InsertStavSkladu @IDKmen=@IDPolSK, @IDSklad=@Sklad, @IDZboSklad=@IDZboSklad OUTPUT
		END;
	SET @JCbezDaniKC=(SELECT JCBezDani/*/@KurzSK*/ FROM #Polozky WHERE ID=@IDStart)
	SET @MnozstviOrig=(SELECT MnoPol FROM #Polozky WHERE ID=@IDStart)
	SET @MJ=(SELECT MJ FROM #Polozky WHERE ID=@IDStart)
	SET @IDPohybu=(SELECT IDPohybu FROM #Polozky WHERE ID=@IDStart)
	SET @IDpzVOBSK=(SELECT IDpzVOBSK FROM #Polozky WHERE ID=@IDStart)

		EXEC RayService5.dbo.hp_InsertPolozkyOZ
					@IDPZPrijemky OUTPUT
					,@IDDoklad=@IDPrijemky
					,@DruhPohybu=@DruhPohybuZbo
					,@CisloOrg=2
					,@IDZboSklad=@IDZboSklad
					,@Mena=@Mena
					,@Kurz=@Kurz
					,@JednotkaMeny=@JednotkaMeny
					,@KurzEuro=@KurzEuro
					,@SazbaSD=@SazbaSD
					,@SazbaDPH=@SazbaDPH
					,@ZakazanoDPH=@ZakazanoDPH
					,@VstupniCena=@VstupniCena        -- 13. druh vstupni ceny
					,@Kolik=NULL
					,@PovolitDuplicitu=1
					,@PovolitBlokovane=0
					,@Mnozstvi=@MnozstviOrig
					,@IDObalovanePolozky=NULL
					,@Selectem=0
					,@JCbezDaniKC=@JCbezDaniKC
					,@VstupniCenaProPrepocet=NULL
					,@DotahovatSazby=1
					,@SlevaDokladu=NULL
					,@Nabidka=NULL
					,@DatPorizeni=NULL
					,@MJ=NULL
					,@HlidanoProOrg=NULL
					,@OrgProCeny=NULL
					,@IDOZTxtPol=NULL

				--update na pohybu
				BEGIN
					--IF (SELECT tpze.ID  FROM RayService5.dbo.TabPohybyZbozi_EXT tpze WHERE tpze.ID=@IDPZPrijemky) IS NULL
					-- BEGIN 
					--	INSERT INTO RayService5.dbo.TabPohybyZbozi_EXT (ID, _EXT_RS_PromisedStockingDate)
					--	VALUES (@IDPZPrijemky,@IDpzVOBSK)
					-- END
					--ELSE
					UPDATE tpz SET tpz.IDOldPolozka=@IDpzVOBSK
					FROM RayService5.dbo.TabPohybyZbozi tpz
					WHERE tpz.ID = @IDPZPrijemky
				END;

		--SELECT @IDPZPrijemky AS ID_Pohybu
		--SET @IDPZPrijemky = SCOPE_IDENTITY()
		
		------Vložení šarží na doklad------
		DECLARE crVlozSarze CURSOR FAST_FORWARD LOCAL FOR
		SELECT ID FROM #Sarze WHERE IDPohybu=@IDPohybu
		OPEN crVlozSarze;
		FETCH NEXT FROM crVlozSarze INTO @IDSarze;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			SET @Nazev1Sarze=(SELECT Nazev1 FROM #Sarze WHERE ID=@IDSarze)
			SET @NazevSarze=(SELECT Nazev FROM #Sarze WHERE ID=@IDSarze)
			SET @MnoSarze=(SELECT MnoSar FROM #Sarze WHERE ID=@IDSarze)
			SET @IdVyrCS=(SELECT ID FROM RayService5.dbo.TabVyrCS WHERE Nazev1=@Nazev1Sarze AND IDStavSkladu=@IDZboSklad)
			IF @IdVyrCS IS NULL
				BEGIN
				--EXEC RayService5.dbo.hp_OZInsertVyrCK @IDVyrCK OUTPUT, @IDkmenZbozi=@IDPolSK, @Selectem=1, @IDZakazModif=NULL, @Nazev1=@NazevSarze1
				EXEC RayService5.dbo.hp_OZInsertVyrCS @IdVyrCS OUTPUT, @IDVyrCK OUTPUT, @IDkmenZbozi=@IDPolSK, @IDZboSklad=@IDZboSklad, @IDZakazModif=NULL, @Nazev1=@Nazev1Sarze, @Nazev2=@NazevSarze
				END;
			INSERT INTO RayService5.dbo.TabVyrCP (IDPolozkaDokladu, Autor, IDVyrCis, Nazev, Mnozstvi, Poznamka, DatVstup, DatVystup, DatExpirace)
			VALUES (@IDPZPrijemky, SUSER_SNAME(), @IdVyrCS, @Nazev1Sarze, @MnoSarze, N'', NULL, NULL, NULL)

			--------Vložení umístění položek------
			--INSERT INTO Gatema_PohybUmisteni (IDPohZbo, DruhPohybu, IDStavSkladu, IDKmenZbozi, IDVyrCis, IDUmisteni, Mnozstvi, Autor, DatPorizeni)
			--SELECT @IDPZPrijemky, @DruhPohybuZbo, IDStavSkladu, IDKmenZbozi, IDVyrCis, IDUmisteni, -Mnozstvi, SUSER_SNAME(), GETDATE()
			--	FROM Gatema_PohybUmisteni
			--WHERE IDPohZbo=@IDPZVydejky AND IDVyrCis=@IDSarze
			SET @Nazev1Sarze=NULL;
			SET @NazevSarze=NULL;
			SET @MnoSarze=NULL;
			SET @IDVyrCS=NULL;
			SET @IDVyrCK=NULL;
			FETCH NEXT FROM crVlozSarze INTO @IDSarze;
		END;
		CLOSE crVlozSarze;
		DEALLOCATE crVlozSarze;

SET @IDStart=@IDStart+1
--konec cyklu v #Polozky
END;

--přepočet cen na příjemce
EXEC RayService5.dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDPrijemky, @AktualizaceSlev=0
UPDATE RayService5.dbo.TabDokladyZbozi SET BlokovaniEditoru=NULL WHERE ID=@IDPrijemky

--doplníme vazbu příjemky na výdejku
IF (SELECT tpze.ID  FROM TabDokladyZbozi_EXT tpze WHERE tpze.ID = @IDVydejky) IS NULL
					 BEGIN 
						INSERT INTO TabDokladyZbozi_EXT (ID,_EXT_RS_IDPrijemkyRS_SK)
						VALUES (@IDVydejky,@IDPrijemky)
					 END
					ELSE
					UPDATE TabDokladyZbozi_EXT SET _EXT_RS_IDPrijemkyRS_SK=@IDPrijemky  WHERE ID = @IDVydejky

--doplníme vazbu výdejky na příjemku
IF (SELECT tpze.ID  FROM RayService5.dbo.TabDokladyZbozi_EXT tpze WHERE tpze.ID = @IDPrijemky) IS NULL
					 BEGIN 
						INSERT INTO RayService5.dbo.TabDokladyZbozi_EXT (ID,_EXT_RS_IDVydejkyRS)
						VALUES (@IDPrijemky,@IDVydejky)
					 END
					ELSE
					UPDATE RayService5.dbo.TabDokladyZbozi_EXT SET _EXT_RS_IDVydejkyRS=@IDVydejky  WHERE ID = @IDPrijemky


END;
GO

