USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_generovani_dokladu_polozky]    Script Date: 26.06.2025 15:25:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--příprava generování poptávek
--přednastavený parametr: číslo organizace, číslo organizace 2 a číslo organizace 3
CREATE PROCEDURE [dbo].[hpx_generovani_dokladu_polozky]
@CisloOrg INT,
@CisloOrg2 INT,
@CisloOrg3 INT,
@ID INT
AS
SET NOCOUNT ON;
-- ==========================================================================================================
-- Author:		MŽ
-- Description:	Generování poptávek (nabídek) z označených položek ceníku - nejprve generujeme seznam položek
-- Date: 10.7.2019
-- Changed: 11.11.2019. Změna řady dokladů dle země na organizaci
-- Changed: 29.7.2020. Přidání dotažení termínu nacenění z kalkulací
-- Changed: 10.9.2020. Přidání přípravy pro dvě další organizace.
-- ==========================================================================================================
DECLARE @RadaDokladuCil NVARCHAR(3);		-- Cílová řada dokladu (340 nebo 350 dle země na organizaci)
DECLARE @RadaDokladuCil2 NVARCHAR(3);		-- Cílová řada dokladu (340 nebo 350 dle země na organizaci)
DECLARE @RadaDokladuCil3 NVARCHAR(3);		-- Cílová řada dokladu (340 nebo 350 dle země na organizaci)
DECLARE @IDSkladCil NVARCHAR(30);			-- Identifikátor cílového skladu pro výběr položek
DECLARE @Zeme NVARCHAR(3);		--ID země z organizace
DECLARE @Zeme2 NVARCHAR(3);		--ID země z organizace
DECLARE @Zeme3 NVARCHAR(3);		--ID země z organizace
DECLARE @Autor NVARCHAR(128);				-- Autor generování
DECLARE @VstupniCena TINYINT;
DECLARE @VstupniCena2 TINYINT;
DECLARE @VstupniCena3 TINYINT;
DECLARE @Cena NUMERIC(19,6) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @NastaveniSlev SMALLINT = 0; --dávám nulu, protože nevím o jiné hodnotě
DECLARE @SlevaSkupZbo NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaZboKmen NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaZboSklad NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaOrg NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaSozNa NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @TerminSlevaProc NUMERIC(5,2) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SlevaCastka NUMERIC(19,6) = 0; --dávám nulu, protože nevím, jakou dohledat
DECLARE @SazbaDPH NUMERIC(5,2);
DECLARE @SazbaSD NUMERIC(19,6) = 0;
DECLARE @JCbezDaniKC NUMERIC(19,6);
DECLARE @generovany_polozky BIT;
DECLARE @DruhPohybu TINYINT;
DECLARE @DatPorizeni DATETIME;
DECLARE @Termin_naceneni DATETIME;
--příprava položek před generováním
--sada pro první firmu
SET @Zeme = (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg = @CisloOrg)
SET @RadaDokladuCil = (CASE WHEN (@Zeme = 'CZ') THEN '340'
			WHEN (@Zeme IS NULL) THEN '340'
			WHEN (@Zeme = '') THEN '340'
			ELSE '350' END);
SET @VstupniCena = (CASE WHEN (@RadaDokladuCil= '340') THEN 0
			WHEN (@RadaDokladuCil = '350') THEN 4
			ELSE 0 END);
--sada pro druhou firmu
SET @Zeme2 = (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg = @CisloOrg2)
SET @RadaDokladuCil2 = (CASE WHEN (@Zeme2 = 'CZ') THEN '340'
			WHEN (@Zeme2 IS NULL) THEN '340'
			WHEN (@Zeme2 = '') THEN '340'
			ELSE '350' END);
SET @VstupniCena2 = (CASE WHEN (@RadaDokladuCil2= '340') THEN 0
			WHEN (@RadaDokladuCil2 = '350') THEN 4
			ELSE 0 END);
--sada pro třetí firmu
SET @Zeme3 = (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg = @CisloOrg3)
SET @RadaDokladuCil3 = (CASE WHEN (@Zeme3 = 'CZ') THEN '340'
			WHEN (@Zeme3 IS NULL) THEN '340'
			WHEN (@Zeme3 = '') THEN '340'
			ELSE '350' END);
SET @VstupniCena3 = (CASE WHEN (@RadaDokladuCil3= '340') THEN 0
			WHEN (@RadaDokladuCil3 = '350') THEN 4
			ELSE 0 END);
SET @IDSkladCil = '100';
SET @DruhPohybu = 11;
SET @Autor = SUSER_SNAME();
--naplnění tabulky s položkami
IF @CisloOrg IS NOT NULL--dříve bylo <> ''
BEGIN
INSERT INTO TempGenPol (IDKusovnik,SkupZbo,RegCis,Mnozstvi,VstupniCena,Cena,NastaveniSlev,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,TerminSlevaProc,SlevaCastka,SazbaSD,CisloOrg,Autor,DatPorizeni,IDZakazka,Termin_naceneni,PoradiOrg)
SELECT T.ID,Z.SkupZbo,Z.RegCis,T.mnf,@VstupniCena,@Cena,@NastaveniSlev,@SlevaSkupZbo,@SlevaZboKmen,@SlevaZboSklad,@SlevaOrg,@SlevaSozNa,@TerminSlevaProc,@SlevaCastka,@SazbaSD,@CisloOrg,SUSER_SNAME(),GETDATE(),tz.CisloZakazky,Termin_naceneni,1
FROM TabStrukKusovnik_kalk_cenik T
LEFT OUTER JOIN TabKmenZbozi Z ON Z.ID = T.IDNizsi
LEFT OUTER JOIN TabZakazka tz ON tz.ID = T.IDZakazka
WHERE T.ID = @ID AND T.OrgNabidka IS NULL/* AND NOT EXISTS (SELECT ID FROM TempGenPol WHERE (IdKusovnik = @ID AND CisloOrg = @CisloOrg AND PoradiOrg = 1))*//*AND T.generovany_polozky IS NULL*/
--označení řádků, z nichž se generovalo a přidání organizace, která byla vybrána
UPDATE TabStrukKusovnik_kalk_cenik
SET TabStrukKusovnik_kalk_cenik.generovany_polozky = 1, TabStrukKusovnik_kalk_cenik.OrgNabidka = @CisloOrg
FROM TabStrukKusovnik_kalk_cenik
WHERE TabStrukKusovnik_kalk_cenik.ID = @ID AND TabStrukKusovnik_kalk_cenik.OrgNabidka IS NULL /*AND TabStrukKusovnik_kalk_cenik.generovany_polozky IS NULL*/
END
IF @CisloOrg2 IS NOT NULL--dříve bylo  <> ''
BEGIN
INSERT INTO TempGenPol (IDKusovnik,SkupZbo,RegCis,Mnozstvi,VstupniCena,Cena,NastaveniSlev,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,TerminSlevaProc,SlevaCastka,SazbaSD,CisloOrg,Autor,DatPorizeni,IDZakazka,Termin_naceneni,PoradiOrg)
SELECT T.ID,Z.SkupZbo,Z.RegCis,T.mnf,@VstupniCena2,@Cena,@NastaveniSlev,@SlevaSkupZbo,@SlevaZboKmen,@SlevaZboSklad,@SlevaOrg,@SlevaSozNa,@TerminSlevaProc,@SlevaCastka,@SazbaSD,@CisloOrg2,SUSER_SNAME(),GETDATE(),tz.CisloZakazky,Termin_naceneni,2
FROM TabStrukKusovnik_kalk_cenik T
LEFT OUTER JOIN TabKmenZbozi Z ON Z.ID = T.IDNizsi
LEFT OUTER JOIN TabZakazka tz ON tz.ID = T.IDZakazka
WHERE T.ID = @ID AND T.OrgNabidka2 IS NULL /*AND T.generovany_polozky IS NULL*/
--označení řádků, z nichž se generovalo a přidání organizace 2, která byla vybrána
UPDATE TabStrukKusovnik_kalk_cenik
SET TabStrukKusovnik_kalk_cenik.generovany_polozky = 1, TabStrukKusovnik_kalk_cenik.OrgNabidka2 = @CisloOrg2
FROM TabStrukKusovnik_kalk_cenik
WHERE TabStrukKusovnik_kalk_cenik.ID = @ID AND TabStrukKusovnik_kalk_cenik.OrgNabidka2 IS NULL  /*AND TabStrukKusovnik_kalk_cenik.generovany_polozky IS NULL*/
END
IF @CisloOrg3 IS NOT NULL--dříve bylo  <> ''
BEGIN
INSERT INTO TempGenPol (IDKusovnik,SkupZbo,RegCis,Mnozstvi,VstupniCena,Cena,NastaveniSlev,SlevaSkupZbo,SlevaZboKmen,SlevaZboSklad,SlevaOrg,SlevaSozNa,TerminSlevaProc,SlevaCastka,SazbaSD,CisloOrg,Autor,DatPorizeni,IDZakazka,Termin_naceneni,PoradiOrg)
SELECT T.ID,Z.SkupZbo,Z.RegCis,T.mnf,@VstupniCena3,@Cena,@NastaveniSlev,@SlevaSkupZbo,@SlevaZboKmen,@SlevaZboSklad,@SlevaOrg,@SlevaSozNa,@TerminSlevaProc,@SlevaCastka,@SazbaSD,@CisloOrg3,SUSER_SNAME(),GETDATE(),tz.CisloZakazky,Termin_naceneni,3
FROM TabStrukKusovnik_kalk_cenik T
LEFT OUTER JOIN TabKmenZbozi Z ON Z.ID = T.IDNizsi
LEFT OUTER JOIN TabZakazka tz ON tz.ID = T.IDZakazka
WHERE T.ID = @ID AND T.OrgNabidka3 IS NULL /*AND T.generovany_polozky IS NULL*/
--označení řádků, z nichž se generovalo a přidání organizace 3, která byla vybrána
UPDATE TabStrukKusovnik_kalk_cenik
SET TabStrukKusovnik_kalk_cenik.generovany_polozky = 1, TabStrukKusovnik_kalk_cenik.OrgNabidka3 = @CisloOrg3
FROM TabStrukKusovnik_kalk_cenik
WHERE TabStrukKusovnik_kalk_cenik.ID = @ID AND TabStrukKusovnik_kalk_cenik.OrgNabidka3 IS NULL  /*AND TabStrukKusovnik_kalk_cenik.generovany_polozky IS NULL*/
END
GO

