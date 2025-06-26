USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_prenos_do_nakladovosti_prikazu]    Script Date: 26.06.2025 12:47:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--výpočet nákladovosti VP
--data uložena v externí tabulce (něco jako nákladovost zakázek), výpočet za označený VP
CREATE PROCEDURE [dbo].[hpx_RS_prenos_do_nakladovosti_prikazu] @CisloTarifu NVARCHAR(8),@IDVzorec INT,@Davka TINYINT,@ID INT
AS
/*
Stačí pouze ukončený = rozhodné datum pro zařazení do měsíce/kvartálu/roku
1. plánované hodnoty
za označený VP a zakázku dohledám dílec v kalkulaci dílců
není-li v kalkulaci dílců, hledám v základní kalkulaci
sesumuju náklady a vložím do plánovaných hodnot (obdobně jako u zakázek)
opět dotaz na tarif
2. úprava 31.1.2022
- dohledání kalkulace dílce v základních kalkulacích se řídí datem pořízení zakázky. Pokud je pořízení >= 1.1.2022, tak změna aktuální, pokud je < 1.1.2022, tak změna ID = 62454
*/
/*
DECLARE @ID INT=154585 --ID VP, v proceduře označený řádek
DECLARE @CisloTarifu NVARCHAR(8)='01' --číslo tarifu, v proceduře výběrové pole s číslem
DECLARE @Davka TINYINT=3 --podle konfigurace, jak pracovat s přípravným časem
DECLARE @IDVzorec INT=14; --ID kalkulačního vzorce, v proceduře výběrové pole s ID
*/
DECLARE @Rada NVARCHAR(10);
DECLARE @CisloZakazky NVARCHAR(15);
DECLARE @DatPorizeniZak DATETIME;
DECLARE @NakladyPlan NUMERIC(19,6);
DECLARE @NakladyReal NUMERIC(19,6);
DECLARE @NakladyMatPlan NUMERIC(19,6);
DECLARE @NakladyMatReal NUMERIC(19,6);
DECLARE @Ukonceni DATETIME;
DECLARE @IDPol INT;
DECLARE @MnoPol NUMERIC(19,6);
DECLARE @OPTDavka NUMERIC(19,6);
DECLARE @TAC NUMERIC(19,6);
DECLARE @TBC NUMERIC(19,6);
DECLARE @TEC NUMERIC(19,6);
DECLARE @Radek1 NUMERIC(19,6);
DECLARE @Radek2 NUMERIC(19,6);
DECLARE @Radek3 NUMERIC(19,6);
DECLARE @Radek5 NUMERIC(19,6);
DECLARE @Radek1Puv NUMERIC(19,6);
DECLARE @Radek2Puv NUMERIC(19,6);
DECLARE @Radek3Puv NUMERIC(19,6);
DECLARE @Radek5Puv NUMERIC(19,6);
DECLARE @Tarif NUMERIC(19,6);
SET @CisloZakazky=(SELECT tz.CisloZakazky FROM TabPrikaz tp WITH(NOLOCK) LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tz.ID=tp.IDZakazka WHERE tp.ID=@ID)
SET @DatPorizeniZak=(SELECT tz.DatPorizeni FROM TabZakazka tz WITH(NOLOCK) WHERE tz.CisloZakazky=@CisloZakazky)
SET @Tarif=(SELECT (CONVERT(NUMERIC(19,6),(tarp.koef * CASE tarp.koef_ZT WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)))
			FROM TabTarH tarh WITH(NOLOCK)
			LEFT OUTER JOIN TabTarP tarp WITH(NOLOCK) ON tarp.IDTarif=tarh.ID AND EXISTS(SELECT * FROM TabCZmeny Zod
			LEFT OUTER JOIN TabCZmeny Zdo WITH(NOLOCK) ON (ZDo.ID=tarp.zmenaDo)
			WHERE Zod.ID=tarp.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (tarp.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
			WHERE tarh.Tarif=@CisloTarifu
			)
--vymažeme dosavadní dočasné výpočty
IF(OBJECT_ID('tempdb..#TabPorPS') IS NOT NULL) BEGIN DROP TABLE #TabPorPS END
--teď spočítáme plánované náklady
SELECT @IDPol=tkz.ID, @MnoPol=tp.kusy_zad,@Ukonceni=tp.ukonceni
FROM TabPrikaz tp WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tp.IDTabKmen
WHERE tp.ID=@ID

SET @OPTDavka=(SELECT TabDavka.Davka
				FROM TabKmenZbozi 
LEFT OUTER JOIN TabDavka ON TabDavka.IDDilce=TabKmenZbozi.IDKusovnik AND EXISTS(SELECT * FROM TabCZmeny Zod
												LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=TabDavka.zmenaDo) WHERE Zod.ID=TabDavka.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() 
												AND (TabDavka.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
				WHERE TabKmenZbozi.ID=@IDPol)
--náklady celkové
SET @Radek1=(SELECT ISNULL(rsk.mat,0)+ISNULL(rsk.koop,0)+ISNULL(rsk.OPN,0) FROM Tabx_RS_ZKalkulace rsk WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol
SET @TAC=(SELECT ((ISNULL(rsk.TAC,0))/CASE rsk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)*@Tarif
			FROM Tabx_RS_ZKalkulace rsk WITH(NOLOCK) WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol
SET @TBC=(SELECT ((ISNULL(rsk.TBC,0))/CASE rsk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)*@Tarif
			FROM Tabx_RS_ZKalkulace rsk WITH(NOLOCK) WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol
SET @TEC=(SELECT ((ISNULL(rsk.TEC,0))/CASE rsk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)*@Tarif
			FROM Tabx_RS_ZKalkulace rsk WITH(NOLOCK) WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol

SET @Radek2=(SELECT (CASE @Davka WHEN 0 THEN (@TAC/**@MnoPol*/) WHEN 1 THEN (@TAC/**@MnoPol*/)+@TBC+@TEC WHEN 2 THEN (@TAC+@TBC+@TEC)/**@MnoPol*/ WHEN 3 THEN (@TAC+(@TBC/@OPTDavka)+(@TEC/@OPTDavka))/**@MnoPol*/ END)
			FROM Tabx_RS_ZKalkulace rsk WITH(NOLOCK) WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)
--pokud jsou náklady nulové (není zkalkulováno)
IF ISNULL(@Radek1,0)=0 AND @DatPorizeniZak>='20220101'
SET @Radek1=(SELECT ISNULL(tzk.mat,0)+ISNULL(tzk.koop,0)+ISNULL(tzk.OPN,0) FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)*@MnoPol
IF ISNULL(@Radek2,0)=0 AND @DatPorizeniZak>='20220101'
BEGIN
SET @TAC=(SELECT ((ISNULL(tzk.TAC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)
SET @TBC=(SELECT ((ISNULL(tzk.TBC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)
SET @TEC=(SELECT ((ISNULL(tzk.TEC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)

SET @Radek2=(SELECT (CASE @Davka WHEN 0 THEN (@TAC*@MnoPol) WHEN 1 THEN (@TAC*@MnoPol)+@TBC+@TEC WHEN 2 THEN (@TAC+@TBC+@TEC)*@MnoPol WHEN 3 THEN (@TAC+(@TBC/@OPTDavka)+(@TEC/@OPTDavka))*@MnoPol END)
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)
END
IF ISNULL(@Radek1,0)=0 AND @DatPorizeniZak<'20220101'
SET @Radek1=(SELECT ISNULL(tzk.mat,0)+ISNULL(tzk.koop,0)+ISNULL(tzk.OPN,0) FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOd=62454)*@MnoPol

IF ISNULL(@Radek2,0)=0 AND @DatPorizeniZak<'20220101'
BEGIN
SET @TAC=(SELECT ((ISNULL(tzk.TAC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOD=62454)
SET @TBC=(SELECT ((ISNULL(tzk.TBC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOD=62454)
SET @TEC=(SELECT ((ISNULL(tzk.TEC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOD=62454)
SELECT @TAC,@TBC,@TEC
SET @Radek2=(SELECT (CASE @Davka WHEN 0 THEN (@TAC*@MnoPol) WHEN 1 THEN (@TAC*@MnoPol)+@TBC+@TEC WHEN 2 THEN (@TAC+@TBC+@TEC)*@MnoPol WHEN 3 THEN (@TAC+(@TBC/@OPTDavka)+(@TEC/@OPTDavka))*@MnoPol END)
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)
--SELECT @Radek1,@Radek2
END

SET @Radek3=@Radek2*4/*(SELECT (CASE @Davka WHEN 0 THEN (@TAC/**@MnoPol*/)*4 WHEN 1 THEN ((@TAC/**@MnoPol*/)+@TBC+@TEC)*4 WHEN 2 THEN (@TAC+@TBC+@TEC)/**@MnoPol*/*4 WHEN 3 THEN (@TAC+(@TBC/@OPTDavka)+(@TEC/@OPTDavka))/**@MnoPol*/*4 END)
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)*/
SET @Radek5=ISNULL(@Radek1,0)+ISNULL(@Radek2,0)+ISNULL(@Radek3,0)
--SELECT @Radek1,@Radek2,@Radek3,@Radek5
SET @NakladyPlan=ISNULL(@Radek5,0)

--náklady pouze materiál
--MŽ 12.5.2023 upraveno - přidáno kromě ISNULL(rsk.mat,0) navíc i koop a OPN
SET @NakladyMatPlan=(SELECT ISNULL(rsk.mat,0)+ISNULL(rsk.koop,0)+ISNULL(rsk.OPN,0) FROM Tabx_RS_ZKalkulace rsk WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol
--pokud jsou náklady nulové (není zkalkulováno)
IF ISNULL(@NakladyMatPlan,0)=0 AND @DatPorizeniZak>='20220101'
SET @NakladyMatPlan=(SELECT ISNULL(tzk.mat,0)+ISNULL(tzk.koop,0)+ISNULL(tzk.OPN,0) FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)*@MnoPol
IF ISNULL(@NakladyMatPlan,0)=0 AND @DatPorizeniZak<'20220101'
SET @NakladyMatPlan=(SELECT ISNULL(tzk.mat,0)+ISNULL(tzk.koop,0)+ISNULL(tzk.OPN,0) FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOd=62454)*@MnoPol

/*
2. skutečné náklady
použije se stejný výpočet jako u HEO - Porovnání plánovaných a skutečných nákladů
vzorec se vybírá na začátku
*/
--tabulka porovnání plánovaných a skutečných nákladů
IF(OBJECT_ID('tempdb..#TabPorPS') IS NOT NULL) BEGIN DROP TABLE #TabPorPS END
CREATE TABLE dbo.#TabPorPS(
ID INT IDENTITY NOT NULL,
IDPrikaz INT NOT NULL,
IDKmenZbozi INT NOT NULL,
IDZakazka INT NULL,
mat_Pl NUMERIC(19,6) NOT NULL,
matA_Pl NUMERIC(19,6) NOT NULL,
matB_Pl NUMERIC(19,6) NOT NULL,
matC_Pl NUMERIC(19,6) NOT NULL,
MatRezie_Pl NUMERIC(19,6) NOT NULL,
koop_Pl NUMERIC(19,6) NOT NULL,
mzda_Pl NUMERIC(19,6) NOT NULL,
rezieS_Pl NUMERIC(19,6) NOT NULL,
rezieP_Pl NUMERIC(19,6) NOT NULL,
ReziePrac_Pl NUMERIC(19,6) NOT NULL,
NakladyPrac_Pl NUMERIC(19,6) NOT NULL,
OPN_Pl NUMERIC(19,6) NOT NULL,
VedProdukt_Pl NUMERIC(19,6) NOT NULL,
naradi_Pl NUMERIC(19,6) NOT NULL,
mat_P_Pl NUMERIC(19,6) NOT NULL,
matA_P_Pl NUMERIC(19,6) NOT NULL,
matB_P_Pl NUMERIC(19,6) NOT NULL,
matC_P_Pl NUMERIC(19,6) NOT NULL,
MatRezie_P_Pl NUMERIC(19,6) NOT NULL,
koop_P_Pl NUMERIC(19,6) NOT NULL,
Mzda_P_Pl NUMERIC(19,6) NOT NULL,
rezieS_P_Pl NUMERIC(19,6) NOT NULL,
rezieP_P_Pl NUMERIC(19,6) NOT NULL,
ReziePrac_P_Pl NUMERIC(19,6) NOT NULL,
NakladyPrac_P_Pl NUMERIC(19,6) NOT NULL,
OPN_P_Pl NUMERIC(19,6) NOT NULL,
VedProdukt_P_Pl NUMERIC(19,6) NOT NULL,
naradi_P_Pl NUMERIC(19,6) NOT NULL,
mat NUMERIC(19,6) NOT NULL,
matA NUMERIC(19,6) NOT NULL,
matB NUMERIC(19,6) NOT NULL,
matC NUMERIC(19,6) NOT NULL,
MatRezie NUMERIC(19,6) NOT NULL,
koop NUMERIC(19,6) NOT NULL,
mzda NUMERIC(19,6) NOT NULL,
rezieS NUMERIC(19,6) NOT NULL,
rezieP NUMERIC(19,6) NOT NULL,
ReziePrac NUMERIC(19,6) NOT NULL,
NakladyPrac NUMERIC(19,6) NOT NULL,
OPN NUMERIC(19,6) NOT NULL,
VedProdukt NUMERIC(19,6) NOT NULL,
naradi NUMERIC(19,6) NOT NULL,
NespecNakl NUMERIC(19,6) NOT NULL,
mat_P NUMERIC(19,6) NOT NULL,
matA_P NUMERIC(19,6) NOT NULL,
matB_P NUMERIC(19,6) NOT NULL,
matC_P NUMERIC(19,6) NOT NULL,
MatRezie_P NUMERIC(19,6) NOT NULL,
koop_P NUMERIC(19,6) NOT NULL,
Mzda_P NUMERIC(19,6) NOT NULL,
rezieS_P NUMERIC(19,6) NOT NULL,
rezieP_P NUMERIC(19,6) NOT NULL,
ReziePrac_P NUMERIC(19,6) NOT NULL,
NakladyPrac_P NUMERIC(19,6) NOT NULL,
OPN_P NUMERIC(19,6) NOT NULL,
VedProdukt_P NUMERIC(19,6) NOT NULL,
naradi_P NUMERIC(19,6) NOT NULL,
cas_Pl NUMERIC(19,6) NOT NULL,
cas_Pl_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__cas_Pl_T DEFAULT 1,
cas_Sk NUMERIC(19,6) NOT NULL,
cas_Sk_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__cas_Sk_T DEFAULT 1,
OdpracovanyCas NUMERIC(19,6) NOT NULL,
OdpracovanyCas_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__OdpracovanyCas_T DEFAULT 1,
ZaplacenyCas NUMERIC(19,6) NOT NULL,
ZaplacenyCas_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__ZaplacenyCas_T DEFAULT 1,
cas_Obsluhy_Pl NUMERIC(19,6) NOT NULL,
cas_Obsluhy_Pl_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__cas_Obsluhy_Pl_T DEFAULT 1,
cas_Obsluhy_Sk NUMERIC(19,6) NOT NULL,
cas_Obsluhy_Sk_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__cas_Obsluhy_Sk_T DEFAULT 1,
OdpracovanyCas_Obsluhy NUMERIC(19,6) NOT NULL,
OdpracovanyCas_Obsluhy_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__OdpracovanyCas_Obsluhy_T DEFAULT 1,
ZaplacenyCas_Obsluhy NUMERIC(19,6) NOT NULL,
ZaplacenyCas_Obsluhy_T TINYINT NOT NULL CONSTRAINT DF__#TabPorPS__ZaplacenyCas_Obsluhy_T DEFAULT 1,
UhradaZmetku NUMERIC(19,6) NOT NULL,
Prikaz_ukonceno BIT NOT NULL,
Prikaz_kusy_ciste NUMERIC(19,6) NOT NULL,
Prikaz_kusy_odved NUMERIC(19,6) NOT NULL,
Celkem_Pl AS (convert(Numeric(19,6),([mat_Pl] + [MatRezie_Pl] + [koop_Pl] + [mzda_Pl] + [rezies_Pl] + [reziep_Pl] + [reziePrac_Pl] + [NakladyPrac_Pl] + [OPN_Pl] - [VedProdukt_Pl] + [naradi_Pl]))),
JNCelkem_Pl AS (convert(Numeric(19,6),(CASE WHEN [Prikaz_kusy_ciste]<>0.0 THEN ([mat_Pl] + [MatRezie_Pl] + [koop_Pl] + [mzda_Pl] + [rezies_Pl] + [reziep_Pl] + [reziePrac_Pl] + [NakladyPrac_Pl] + [OPN_Pl] - [VedProdukt_Pl] + [naradi_Pl]) / [Prikaz_kusy_ciste] END))),
Celkem_P_Pl AS (convert(Numeric(19,6),([mat_P_Pl] + [MatRezie_P_Pl] + [koop_P_Pl] + [mzda_P_Pl] + [rezies_P_Pl] + [reziep_P_Pl] + [reziePrac_P_Pl] + [NakladyPrac_P_Pl] + [OPN_P_Pl] - [VedProdukt_P_Pl] + [naradi_P_Pl]))),
JNCelkem_P_Pl AS (convert(Numeric(19,6),(CASE WHEN [Prikaz_kusy_ciste]<>0.0 THEN ([mat_P_Pl] + [MatRezie_P_Pl] + [koop_P_Pl] + [mzda_P_Pl] + [rezies_P_Pl] + [reziep_P_Pl] + [reziePrac_P_Pl] + [NakladyPrac_P_Pl] + [OPN_P_Pl] - [VedProdukt_P_Pl] + [naradi_P_Pl]) / [Prikaz_kusy_ciste] END))),
Celkem AS (convert(Numeric(19,6),([mat] + [MatRezie] + [koop] + [mzda] + [rezies] + [reziep] + [reziePrac] + [NakladyPrac] + [OPN] - [VedProdukt] + [naradi] + [NespecNakl]))),
JNCelkem AS (convert(Numeric(19,6),(CASE WHEN [Prikaz_kusy_odved]<>0.0 THEN ([mat] + [MatRezie] + [koop] + [mzda] + [rezies] + [reziep] + [reziePrac] + [NakladyPrac] + [OPN] - [VedProdukt] + [naradi] + [NespecNakl]) / [Prikaz_kusy_odved] END))),
Celkem_P AS (convert(Numeric(19,6),([mat_P] + [MatRezie_P] + [koop_P] + [mzda_P] + [rezies_P] + [reziep_P] + [reziePrac_P] + [NakladyPrac_P] + [OPN_P] - [VedProdukt_P] + [naradi_P]))),
JNCelkem_P AS (convert(Numeric(19,6),(CASE WHEN [Prikaz_kusy_odved]<>0.0 THEN ([mat_P] + [MatRezie_P] + [koop_P] + [mzda_P] + [rezies_P] + [reziep_P] + [reziePrac_P] + [NakladyPrac_P] + [OPN_P] - [VedProdukt_P] + [naradi_P]) / [Prikaz_kusy_odved] END))),
cas_Pl_S AS (CONVERT(NUMERIC(19,6),([cas_Pl] * CASE [cas_Pl_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
cas_Pl_N AS (CONVERT(NUMERIC(19,6),CASE [cas_Pl_T] WHEN 0 THEN ([cas_Pl] / 60.0) WHEN 1 THEN [cas_Pl] WHEN 2 THEN (60.0 * [cas_Pl]) END)),
cas_Pl_H AS (CONVERT(NUMERIC(19,6),([cas_Pl] / CASE [cas_Pl_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
cas_Sk_S AS (CONVERT(NUMERIC(19,6),([cas_Sk] * CASE [cas_Sk_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
cas_Sk_N AS (CONVERT(NUMERIC(19,6),CASE [cas_Sk_T] WHEN 0 THEN ([cas_Sk] / 60.0) WHEN 1 THEN [cas_Sk] WHEN 2 THEN (60.0 * [cas_Sk]) END)),
cas_Sk_H AS (CONVERT(NUMERIC(19,6),([cas_Sk] / CASE [cas_Sk_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
OdpracovanyCas_S AS (CONVERT(NUMERIC(19,6),([OdpracovanyCas] * CASE [OdpracovanyCas_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
OdpracovanyCas_N AS (CONVERT(NUMERIC(19,6),CASE [OdpracovanyCas_T] WHEN 0 THEN ([OdpracovanyCas] / 60.0) WHEN 1 THEN [OdpracovanyCas] WHEN 2 THEN (60.0 * [OdpracovanyCas]) END)),
OdpracovanyCas_H AS (CONVERT(NUMERIC(19,6),([OdpracovanyCas] / CASE [OdpracovanyCas_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
ZaplacenyCas_S AS (CONVERT(NUMERIC(19,6),([ZaplacenyCas] * CASE [ZaplacenyCas_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
ZaplacenyCas_N AS (CONVERT(NUMERIC(19,6),CASE [ZaplacenyCas_T] WHEN 0 THEN ([ZaplacenyCas] / 60.0) WHEN 1 THEN [ZaplacenyCas] WHEN 2 THEN (60.0 * [ZaplacenyCas]) END)),
ZaplacenyCas_H AS (CONVERT(NUMERIC(19,6),([ZaplacenyCas] / CASE [ZaplacenyCas_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
cas_Obsluhy_Pl_S AS (CONVERT(NUMERIC(19,6),([cas_Obsluhy_Pl] * CASE [cas_Obsluhy_Pl_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
cas_Obsluhy_Pl_N AS (CONVERT(NUMERIC(19,6),CASE [cas_Obsluhy_Pl_T] WHEN 0 THEN ([cas_Obsluhy_Pl] / 60.0) WHEN 1 THEN [cas_Obsluhy_Pl] WHEN 2 THEN (60.0 * [cas_Obsluhy_Pl]) END)),
cas_Obsluhy_Pl_H AS (CONVERT(NUMERIC(19,6),([cas_Obsluhy_Pl] / CASE [cas_Obsluhy_Pl_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
cas_Obsluhy_Sk_S AS (CONVERT(NUMERIC(19,6),([cas_Obsluhy_Sk] * CASE [cas_Obsluhy_Sk_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
cas_Obsluhy_Sk_N AS (CONVERT(NUMERIC(19,6),CASE [cas_Obsluhy_Sk_T] WHEN 0 THEN ([cas_Obsluhy_Sk] / 60.0) WHEN 1 THEN [cas_Obsluhy_Sk] WHEN 2 THEN (60.0 * [cas_Obsluhy_Sk]) END)),
cas_Obsluhy_Sk_H AS (CONVERT(NUMERIC(19,6),([cas_Obsluhy_Sk] / CASE [cas_Obsluhy_Sk_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
OdpracovanyCas_Obsluhy_S AS (CONVERT(NUMERIC(19,6),([OdpracovanyCas_Obsluhy] * CASE [OdpracovanyCas_Obsluhy_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
OdpracovanyCas_Obsluhy_N AS (CONVERT(NUMERIC(19,6),CASE [OdpracovanyCas_Obsluhy_T] WHEN 0 THEN ([OdpracovanyCas_Obsluhy] / 60.0) WHEN 1 THEN [OdpracovanyCas_Obsluhy] WHEN 2 THEN (60.0 * [OdpracovanyCas_Obsluhy]) END)),
OdpracovanyCas_Obsluhy_H AS (CONVERT(NUMERIC(19,6),([OdpracovanyCas_Obsluhy] / CASE [OdpracovanyCas_Obsluhy_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
ZaplacenyCas_Obsluhy_S AS (CONVERT(NUMERIC(19,6),([ZaplacenyCas_Obsluhy] * CASE [ZaplacenyCas_Obsluhy_T] WHEN 0 THEN 1.0 WHEN 1 THEN 60.0 WHEN 2 THEN 3600.0 END))),
ZaplacenyCas_Obsluhy_N AS (CONVERT(NUMERIC(19,6),CASE [ZaplacenyCas_Obsluhy_T] WHEN 0 THEN ([ZaplacenyCas_Obsluhy] / 60.0) WHEN 1 THEN [ZaplacenyCas_Obsluhy] WHEN 2 THEN (60.0 * [ZaplacenyCas_Obsluhy]) END)),
ZaplacenyCas_Obsluhy_H AS (CONVERT(NUMERIC(19,6),([ZaplacenyCas_Obsluhy] / CASE [ZaplacenyCas_Obsluhy_T] WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))),
Splneno AS (CASE WHEN [Prikaz_ukonceno]=1 THEN 100.0       WHEN [cas_Pl]=0 THEN 0.0       ELSE (CASE [Cas_Sk_T] WHEN 0 THEN [Cas_Sk] WHEN 1 THEN ([Cas_Sk] * 60.0) ELSE ([Cas_Sk] * 3600.0) END /             CASE [Cas_Pl_T] WHEN 0 THEN [Cas_Pl] WHEN 1 THEN ([Cas_Pl] * 60.0) ELSE ([Cas_Pl] * 3600.0) END * 100.0) END),
CONSTRAINT PK__#TabPorPS__ID PRIMARY KEY(ID),
CONSTRAINT CK__#TabPorPS__cas_Pl_T CHECK(cas_Pl_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__cas_Sk_T CHECK(cas_Sk_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__OdpracovanyCas_T CHECK(OdpracovanyCas_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__ZaplacenyCas_T CHECK(ZaplacenyCas_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__cas_Obsluhy_Pl_T CHECK(cas_Obsluhy_Pl_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__cas_Obsluhy_Sk_T CHECK(cas_Obsluhy_Sk_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__OdpracovanyCas_Obsluhy_T CHECK(OdpracovanyCas_Obsluhy_T BETWEEN 0 AND 2),
CONSTRAINT CK__#TabPorPS__ZaplacenyCas_Obsluhy_T CHECK(ZaplacenyCas_Obsluhy_T BETWEEN 0 AND 2))

--procedura výpočtu
EXEC dbo.hp_PorovPlanSkutecNaklVyrPrik @IDPrikaz=@ID, @IDKalkVzor=@IDVzorec

--výsledná dočasná tabule
/*SELECT #TabPorPS.Celkem
FROM #TabPorPS
*/
--nastavíme náklady reálné
SET @NakladyReal=(SELECT #TabPorPS.Celkem FROM #TabPorPS)
SET @NakladyMatReal=(SELECT #TabPorPS.mat FROM #TabPorPS)

IF @NakladyPlan<>0 AND @NakladyReal<>0
BEGIN
DELETE FROM Tabx_RS_NakladyPrikazy WHERE IDPrikaz=@ID

INSERT INTO Tabx_RS_NakladyPrikazy (IDPrikaz,CisloZakazky, NakladyReal, NakladyPlan, Ukonceni, NakladyMatReal, NakladyMatPlan)
SELECT @ID,@CisloZakazky,@NakladyReal, @NakladyPlan, @Ukonceni, @NakladyMatReal, @NakladyMatPlan

DROP TABLE #TabPorPS

END
ELSE
RETURN;
GO

