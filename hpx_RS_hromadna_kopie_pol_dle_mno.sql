USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_kopie_pol_dle_mno]    Script Date: 26.06.2025 12:44:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_hromadna_kopie_pol_dle_mno]
@MnozstviNew1 NUMERIC(19,6),@MnozstviNew2 NUMERIC(19,6),@MnozstviNew3 NUMERIC(19,6),@MnozstviNew4 NUMERIC(19,6),@MnozstviNew5 NUMERIC(19,6),
@kontrola BIT,
@ID INT
AS
/*
DECLARE @MnozstviNew1 NUMERIC(19,6),@MnozstviNew2 NUMERIC(19,6),@MnozstviNew3 NUMERIC(19,6),@MnozstviNew4 NUMERIC(19,6),@MnozstviNew5 NUMERIC(19,6),
@kontrola BIT,
@ID INT
--testovací nahození :
SELECT @MnozstviNew1=1,@MnozstviNew2=2,@MnozstviNew3=NULL,@MnozstviNew4=25.5,@MnozstviNew5=NULL,@kontrola=1,@ID=5841064
*/
IF @kontrola=1
BEGIN
/*není nutné, je-li akce spouštěna z HEO
IF OBJECT_ID('tempdb..#TabTempUziv')IS NULL
BEGIN
	CREATE TABLE #TabTempUziv(
		[Tabulka] [varchar] (255) NOT NULL,
		[SCOPE_IDENTITY] [int] NULL,
		[Datum] [datetime] NULL
	)
END;*/

DECLARE @IDDoklad INT, @HmotnostNew NUMERIC (19,6), @IDENT INT, @ID1 INT, @ID2 INT, @ID3 INT, @ID4 INT, @ID5 INT;
SET @IDDoklad=(SELECT tpz.IDDoklad FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID)
--první množství upraví stávající řádek
SET @HmotnostNew=(SELECT tpz.Hmotnost/tpz.Mnozstvi*@MnozstviNew1 FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID)
UPDATE tpz SET Mnozstvi=@MnozstviNew1
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID
UPDATE tpz SET Hmotnost=@HmotnostNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID
--EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
--založí se druhá položka
IF ISNULL(@MnozstviNew2,0) >0
BEGIN
INSERT INTO TabPohybyZbozi (IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor)
SELECT IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi+1,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor
FROM TabPohybyZbozi
WHERE ID = @ID
SET @ID2=(SELECT SCOPE_IDENTITY())

SET @HmotnostNew=(SELECT tpz.Hmotnost/tpz.Mnozstvi*@MnozstviNew2 FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID2)
UPDATE tpz SET Mnozstvi=@MnozstviNew2
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID2
UPDATE tpz SET Hmotnost=@HmotnostNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID2
--EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
END;

--založí se třetí položka
IF ISNULL(@MnozstviNew3,0) >0
BEGIN
INSERT INTO TabPohybyZbozi (IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor)
SELECT IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi+2,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor
FROM TabPohybyZbozi
WHERE ID = @ID
SET @ID3=(SELECT SCOPE_IDENTITY())

SET @HmotnostNew=(SELECT tpz.Hmotnost/tpz.Mnozstvi*@MnozstviNew3 FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID3)
UPDATE tpz SET Mnozstvi=@MnozstviNew3
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID3
UPDATE tpz SET Hmotnost=@HmotnostNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID3
--EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
END;

--založí se čtvrtá položka
IF ISNULL(@MnozstviNew4,0) >0
BEGIN
INSERT INTO TabPohybyZbozi (IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor)
SELECT IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi+3,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor
FROM TabPohybyZbozi
WHERE ID = @ID
SET @ID4=(SELECT SCOPE_IDENTITY())

SET @HmotnostNew=(SELECT tpz.Hmotnost/tpz.Mnozstvi*@MnozstviNew4 FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID4)
UPDATE tpz SET Mnozstvi=@MnozstviNew4
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID4
UPDATE tpz SET Hmotnost=@HmotnostNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID4
--EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
END;

--založí se pátá položka
IF ISNULL(@MnozstviNew5,0) >0
BEGIN
INSERT INTO TabPohybyZbozi (IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor)
SELECT IDZboSklad,IDDoklad,IDOZTxtPol,IDOldPolozka,Poradi+4,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,NazevSozNa1,NazevSozNa2,NazevSozNa3,Popis4,CisloZakazky,IDVozidlo
,CisloZam,MJ,MJEvidence,MJKV,PrepMnozstvi,Mena,Kurz,JednotkaMeny,KurzEuro,SazbaDPH,SazbaDPHproPDP,DruhSazbyDPH,IDKodPDP,SazbaDPHHlavicky,SazbaSD,Mnozstvi,VraceneMnozstvi
,MnOdebrane,MnozOdebrane,MnozstviStorno,MnozstviReal,MnozstviKV,MnOdebraneReal,MnozstviStornoReal,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,VstupniCena,ZamknoutCenu
,JCbezDaniKC,JCsSDKc,JCsDPHKc,JCbezDaniVal,JCsSDVal,JCsDPHVal,JCbezDaniKcPoS,JCsSDKcPoS,JCsDPHKcPoS,JCbezDaniValPoS,JCsSDValPoS,JCsDPHValPoS,CCbezDaniKc,CCsSDKc,CCsDPHKc
,CCbezDaniVal,CCsSDVal,CCsDPHVal,CCbezDaniKcPoS,CCsSDKcPoS,CCsDPHKcPoS,CCbezDaniValPoS,CCsSDValPoS,CCsDPHValPoS,CCevid,CCevidSN,AltCena,CCevidPozadovana,NastaveniSlev,Poznamka
,EvMnozstvi,EvStav,Obal,JeSN,CisloNOkruh,IDZakazModif,CisloOrg,DruhPohybuZbo,JCZadaneDPHKc,CCZadaneDPHKc,JCZadaneDPHKcPoS,CCZadaneDPHKcPoS,JCZadaneDPHVal,CCZadaneDPHVal,JCZadaneDPHValPoS
,CCZadaneDPHValPoS,PotvrzDatDod,PozadDatDod,Hmotnost,ZemePuvodu,ZemePreference,IDAkce,StredNaklad,SkutecneDatReal,ZemeOdeslani,MnozstviObalu,KodBaleni,CisloEUR1,CisloLicence,CisloJCD
,PorCisloPolJCD,DatumProjednaniJCD,DodaciPodminka,KurzJCD,HmotnostBrutto,Lhuta,PCDCislo,PCDPorCisloPol,PCDDatum,BarCode,KJKontrolovat,TerminSlevaProc,TerminSlevaNazev,SlevaCastka,IdUmisteni
,SamoVyDPHZaklad,SamoVyDPHCastka,SamoVyDPHZakladHM,SamoVyDPHCastkaHM,SamoVyDPHRucneZadano,IDCiloveTxtPol,MnozstviRPT,IDDanovyKlic,EET_dic_poverujiciho,DruhEET,Zisk,Marze,ObchPrirazka
,PlZisk,PlMarze,PlObchPrirazka,ZdrojNC,ZdrojNCSl,HraniceMarze,NCMarze,PomerKoef,SplnenoPol,SplnenoHlava,PouzitoMajetek,PouzitoSklad,JeNovaVetaEditor
FROM TabPohybyZbozi
WHERE ID = @ID
SET @ID5=(SELECT SCOPE_IDENTITY())

SET @HmotnostNew=(SELECT tpz.Hmotnost/tpz.Mnozstvi*@MnozstviNew5 FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID5)
UPDATE tpz SET Mnozstvi=@MnozstviNew5
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID5
UPDATE tpz SET Hmotnost=@HmotnostNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID5
END;

EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1

--EXEC dbo.hp_ObehZbozi_CastkyProHlavicku @IDDoklad,1,NULL,NULL,NULL,NULL,GETDATE(),0,0,9,N'CZK',1,1,0,2,2,0,0

END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

