USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_detailni_kalkulace_podklad]    Script Date: 30.06.2025 8:11:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--nová definice
CREATE PROCEDURE [dbo].[hpx_detailni_kalkulace_podklad]
@DatumTPV DATETIME,
@RespekPlanZtratyPriVyrobeDilcu BIT,
@RespekDodatecneProcZtratKV BIT,
@DelitFixniMnozstviOptDavkou BIT,
@RespekNedelitMJ BIT,
@KalkCenyKDnesku BIT,
@Davka TINYINT,
@IDKalkVzor INT,
@CisloTarifuKalk NVARCHAR(8),
@ID INT
AS
SET NOCOUNT ON
-- ===================================================================================
-- Author:		MŽ
-- Create date:            18.7.2019
-- Description:	Výpočet kalkulace výrobku dle interního vzorce RS - přesunuto do Položky pro kalkulaci
-- Edit date: 13.12.2021
-- Desc.: Výpočet kalkulace uložen do externí tabulky, zrušeno ukládání do TabZKalkulace. Zároveň přidána možnost zadání parametrů pro výpočet uživatelem a zapojeno řešení s opt.výrobní dávkou
-- Edit date: 5.5.2022
-- Desc.: Do výpočtu materiálu přidáno zapojení i polotovarů.
-- ===================================================================================

DECLARE @Zakazka_vypocet NVARCHAR(15) = (SELECT CisloZakazky FROM TabZakazka LEFT OUTER JOIN TabPozaZDok_kalk ON TabPozaZDok_kalk.IDZakazka = TabZakazka.ID WHERE TabPozaZDok_kalk.ID = @ID);
--množství z požadavku dám do parametrů výpočtu
DECLARE @Mnozstvi_vypocet NUMERIC(19,6) = (SELECT Pozadavek FROM TabZakazka LEFT OUTER JOIN TabPozaZDok_kalk ON TabPozaZDok_kalk.IDZakazka = TabZakazka.ID WHERE TabPozaZDok_kalk.ID = @ID);
--dohledání ID vyráběného dílce pro kalkulaci
DECLARE @IDPol INT = (SELECT IDKmenZbozi FROM TabPozaZDok_kalk WHERE ID = @ID);
--dohledání osobního čísla
DECLARE @Os_cislo INT = (SELECT MIN(ID) FROM TabCisZam WHERE LoginId=SUSER_SNAME());
--dohledání ID zakázky dle navoleného čísla
DECLARE @IDZakazka_vypocet INT = (SELECT ID FROM TabZakazka WHERE CisloZakazky = @Zakazka_vypocet);
--dohledání tarfiu pro případ indivindi výpočtu
DECLARE @TarifKalk NUMERIC(19,6)=(SELECT (CONVERT(NUMERIC(19,6),(tarp.koef * CASE tarp.koef_ZT WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)))
			FROM TabTarH tarh WITH(NOLOCK)
			LEFT OUTER JOIN TabTarP tarp WITH(NOLOCK) ON tarp.IDTarif=tarh.ID AND EXISTS(SELECT * FROM TabCZmeny Zod
			LEFT OUTER JOIN TabCZmeny Zdo WITH(NOLOCK) ON (ZDo.ID=tarp.zmenaDo)
			WHERE Zod.ID=tarp.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (tarp.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
			WHERE tarh.Tarif=@CisloTarifuKalk)
--vymazání případných předchozích kalkulací pro daný výrobek a zakázku a autora
DELETE FROM TabDetailniKalkulace_kalk WHERE IDFinal = @IDPol AND IDZakazka = @IDZakazka_vypocet AND Autor = SUSER_SNAME();

--tělo hp_getDetailniKalkulaci
DECLARE
    @IDKmenZbozi int = @IDPol, 
    @IDZakazModif int=NULL, 
    --@IDKalkVzor int=11, 
    @MnozNaFinal numeric(19,6)=@Mnozstvi_vypocet, 
    --@DatumTPV datetime=GETDATE(), 
    @CanDP bit=1, 
    @GPoziceZaokr int=NULL, 
    --@RespekPlanZtratyPriVyrobeDilcu bit=1, 
    --@DelitFixniMnozstviOptDavkou bit=0, 
    --@KalkCenyKDnesku bit=1, 
    --@RespekNedelitMJ bit=0, 
    --@RespekDodatecneProcZtratKV bit=1, 
    @KteryMat tinyint=NULL 
 
 SET NOCOUNT ON 
 DECLARE @ErrID int=NULL, @ErrMsg NVarChar(2000)='', @tarif int, /*@davka int,*/ @davka_TEC int, @PoziceZaokr int, @DatumKalkCen datetime, 
         @K_mat numeric(19,6), @K_MatRezie numeric(19,6), @K_koop numeric(19,6), @K_mzda numeric(19,6), @K_rezieS numeric(19,6), @K_rezieP numeric(19,6), @K_ReziePrac numeric(19,6), @K_NakladyPrac numeric(19,6), @K_OPN numeric(19,6), @K_VedProdukt numeric(19,6), @K_naradi numeric(19,6), 
         @typ_mat int, @typ_MatRezie int, @typ_koop int, @typ_mzda int, @typ_rezieS int, @typ_rezieP int, @typ_ReziePrac int, @typ_NakladyPrac int, @typ_OPN int, @typ_VedProdukt int, @typ_naradi int 
 SELECT @DatumTPV=ISNULL(GETDATE(),@DatumTPV), 
        @KteryMat=ISNULL(@KteryMat,0), @PoziceZaokr=ISNULL(@GPoziceZaokr,6), 
        @K_mat=1, @K_MatRezie=1, @K_koop=1, @K_mzda=1, @K_rezieS=1, @K_rezieP=1, @K_ReziePrac=1, @K_NakladyPrac=1, @K_OPN=1, @K_VedProdukt=1, @K_naradi=1, 
        @typ_mat=2, @typ_MatRezie=2, @typ_koop=2, @typ_mzda=2, @typ_rezieS=2, @typ_rezieP=2, @typ_ReziePrac=2, @typ_NakladyPrac=2, @typ_OPN=2, @typ_VedProdukt=2, @typ_naradi=2 
 
 IF EXISTS(SELECT * FROM TabCKalkVzor WHERE ID=@IDKalkVzor AND (typ_mat=1 OR typ_mat1=1 OR typ_mat2=1 OR typ_MatRezie=1 OR typ_koop=1 OR typ_mzda=1 OR typ_rezieS=1 OR typ_rezieP=1 OR typ_ReziePrac=1 OR typ_NakladyPrac=1 OR typ_OPN=1 OR typ_VedProdukt=1 OR typ_naradi=1)) 
   
 SELECT @tarif=tarif, 
        --@Davka=(CASE WHEN davka=1 AND @DelitFixniMnozstviOptDavkou=1 THEN 3 ELSE davka END), 
        @Davka_TEC=(CASE WHEN Davka_TEC=1 AND @DelitFixniMnozstviOptDavkou=1 THEN 3 ELSE Davka_TEC END) 
   FROM TabHGlob 
 EXEC hp_TruncDate @datumTPV OUTPUT 
 IF @KalkCenyKDnesku=1  EXEC hp_GetDnesniDatumX @DatumKalkCen OUTPUT  ELSE  SET @DatumKalkCen=@DatumTPV 
 SELECT @PoziceZaokr=ISNULL(@GPoziceZaokr,PoziceZaokr), @KteryMat=CASE WHEN typ_mat>0 THEN 0 WHEN typ_mat1>0 THEN 1 ELSE 2 END, 
        @K_mat=CASE WHEN typ_mat>0 THEN mat WHEN typ_mat1>0 THEN mat1 ELSE mat2 END, 
        @K_MatRezie=MatRezie, @K_koop=koop, @K_mzda=mzda, @K_rezieS=rezieS, @K_rezieP=rezieP, @K_ReziePrac=ReziePrac, @K_NakladyPrac=NakladyPrac, @K_OPN=OPN, @K_VedProdukt=VedProdukt, @K_naradi=naradi, 
        @typ_mat=CASE WHEN typ_mat>0 THEN typ_mat WHEN typ_mat1>0 THEN typ_mat1 ELSE typ_mat2 END, 
        @typ_MatRezie=typ_MatRezie, @typ_koop=typ_koop, @typ_mzda=typ_mzda, @typ_rezieS=typ_rezieS, @typ_rezieP=typ_rezieP, @typ_ReziePrac=typ_ReziePrac, @typ_NakladyPrac=typ_NakladyPrac, @typ_OPN=typ_OPN, @typ_VedProdukt=typ_VedProdukt, @typ_naradi=typ_naradi 
     FROM TabCKalkVzor WITH(NOLOCK) WHERE ID=@IDKalkVzor
 CREATE TABLE #tabKusovnik_kalk(ID int NOT NULL, IDRodic int NULL, Vyssi integer NULL, IDKmenZbozi integer NOT NULL, uroven integer NOT NULL, poradi integer NOT NULL, IDKVazby integer NULL, mnozstvi numeric(20,6) NOT NULL, 
                                prirez numeric(20,6) NULL, Prime tinyint NOT NULL, RezijniMat bit NOT NULL, VyraditZKalkulace bit NOT NULL, Strom nvarchar(250) COLLATE database_default NOT NULL, 
                                NosnyDuplDilec bit NULL, MnozNosnehoDuplDilce numeric(19,6) NULL, PRIMARY KEY (ID)) 
 INSERT INTO #tabKusovnik_kalk(ID, IDRodic, Vyssi, IDKmenZbozi, uroven, poradi, IDKVazby, mnozstvi, prirez, Prime, RezijniMat, VyraditZKalkulace, Strom) 
   EXEC hp_generujKusovnik @IDKmenZbozi, @MnozNaFinal, @datumTPV, @CanDP, @getStrom=1, @GetRodic=1, 
                           @RespekPlanZtratyPriVyrobeDilcu=@RespekPlanZtratyPriVyrobeDilcu, @DelitFixniMnozstviOptDavkou=@DelitFixniMnozstviOptDavkou, @RespekNedelitMJ=@RespekNedelitMJ, 
                           @IDZakazModif=@IDZakazModif, @RespekDodatecneProcZtratKV=@RespekDodatecneProcZtratKV 
 UPDATE K SET NosnyDuplDilec=ISNULL(S.Nosny,0), MnozNosnehoDuplDilce=ISNULL(S.Mnoz,0.0) 
   FROM #tabKusovnik_kalk K WITH(NOLOCK)
     INNER JOIN TabKmenZbozi KZ WITH(NOLOCK) ON (KZ.ID=K.IDKmenZbozi AND KZ.Dilec=1) 
     LEFT OUTER JOIN (SELECT ID=MAX(K2.ID), Nosny=1, Mnoz=SUM(K2.Mnozstvi) 
                        FROM #tabKusovnik_kalk K2 
                          INNER JOIN TabKmenZbozi KZ2 WITH(NOLOCK) ON (KZ2.ID=K2.IDKmenZbozi AND KZ2.Dilec=1) 
                        WHERE K2.VyraditZKalkulace=0 
                        GROUP BY K2.IDKmenZbozi, K2.prime) S ON (S.ID=K.ID) 

 INSERT INTO TabDetailniKalkulace_kalk(IDFinal, IDZakazka, IDZakazModif, IDKalkVzor, Strom, Patro, IDVyssi,	PopisRadku, TypRadku, IDVazby, mnf, Mnozstvi, Prime, VyraditZKalkulace, Autor,Davka_calc,IDNizsi) 
   SELECT @IDKmenZbozi, @IDZakazka_vypocet, @IDZakazModif, @IDKalkVzor, K.Strom, K.Uroven, K.Vyssi, 
          PopisRadku=LEFT(KZ_N.SkupZbo+N' '+KZ_N.RegCis+N' '+KZ_N.Nazev1, 150), 
          TypRadku=CASE WHEN K.Uroven=0 THEN 0 WHEN KZ_N.Dilec=1 THEN 20 ELSE 10 END, 
          K.IDKVazby, K.mnozstvi, @MnozNaFinal, K.Prime, K.VyraditZKalkulace, SUSER_SNAME(),D.Davka,
		  KZ_N.ID
     FROM #tabKusovnik_kalk K WITH(NOLOCK)
       INNER JOIN TabKmenZbozi KZ_N WITH(NOLOCK) ON (KZ_N.ID=K.IDKmenZbozi)
	   LEFT OUTER JOIN TabDavka D WITH(NOLOCK) ON D.IDDilce=@IDKmenZbozi AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=D.zmenaDo) WHERE Zod.ID=D.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (D.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
--vyjmuto na přání PeZ 20.9.2023, 23.2.2024 na přání PeZ opět zapnuto
--je-li na položce zatrženo FAIR ano nebo PPAP ano nebo CofC ano, tak teprve počítat
--zde proběhne proběhnout výpočet FAIR, CofC. Odlišně pro kabeláž (typ=0) a elektromechaniku (typ=1)
DECLARE @SkupZboVyr NVARCHAR(3), @CountItem INT, @TypVyrPol INT, @PriceFAIR NUMERIC(19,6), @PricePPAP NUMERIC(19,6), @PriceCofC NUMERIC(19,6), @FAIRAno BIT, @PPAPAno BIT, @CofCAno BIT;
BEGIN
SELECT @FAIRAno=ISNULL(KalkulovatFAIR,0), @PPAPAno=ISNULL(KalkulovatPPAP,0), @CofCAno=ISNULL(KalkulovatCofC,0)
FROM TabPozaZDok_kalk pk
WHERE pk.ID=@ID
SET @SkupZboVyr=(SELECT tkz.SkupZbo FROM TabKmenZbozi tkz WHERE tkz.ID=@IDPol)
SELECT @TypVyrPol= CASE WHEN @SkupZboVyr IN ('800','850') THEN 0 WHEN @SkupZboVyr='830' THEN 1 END
SET @CountItem=(SELECT COUNT(tkv.ID)
FROM TabKvazby tkv
LEFT OUTER JOIN TabCzmeny tczOd ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo ON tkv.ZmenaDo=tczDo.ID
WHERE
((tkv.vyssi=@IDPol)AND((tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()))AND(((tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) ))))
	IF @TypVyrPol=0 --kabeláž
	BEGIN
	SELECT @PriceFAIR = CASE WHEN (@CountItem < 10) THEN 200 WHEN (@CountItem >= 10 AND @CountItem < 50) THEN 400 WHEN (@CountItem >= 50) THEN 600 ELSE 0 END
	SELECT @PricePPAP = CASE WHEN (@CountItem < 10) THEN 200 WHEN (@CountItem >= 10 AND @CountItem < 50) THEN 600 WHEN (@CountItem >= 50) THEN 1000 ELSE 0 END
	END;
	IF @TypVyrPol=1 --elektromechanika
	BEGIN
	SELECT @PriceFAIR = CASE WHEN (@CountItem < 10) THEN 600 WHEN (@CountItem >= 10 AND @CountItem < 50) THEN 800 WHEN (@CountItem >= 50) THEN 1000 ELSE 0 END
	SELECT @PricePPAP = CASE WHEN (@CountItem < 10) THEN 200 WHEN (@CountItem >= 10 AND @CountItem < 50) THEN 600 WHEN (@CountItem >= 50) THEN 1000 ELSE 0 END
	END;
	--SELECT @IDPol, @CountItem, @PriceFAIR, @PricePPAP
	SELECT @PriceCofC=100

IF @FAIRAno=1
UPDATE pozdok SET pozdok.FAIR=@PriceFAIR, pozdok.VypocetFairPpap=1
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
IF @PPAPAno=1
UPDATE pozdok SET pozdok.PPAP=@PricePPAP, pozdok.VypocetFairPpap=1
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
IF @CofCAno=1
UPDATE pozdok SET pozdok.CofC3_1=@PriceCofC
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID

END;


 --typ_mat=2=vypočtená, typ_mat=1=pevná
 IF @typ_mat=2 OR @typ_MatRezie=2 
   UPDATE K SET 
       mat=K.mnf * ISNULL(CASE @KteryMat WHEN 0 THEN ISNULL(KC_M.Cena,KC.cena) WHEN 1 THEN ISNULL(KC_M.Cena1,KC.cena1) ELSE ISNULL(KC_M.Cena2,KC.cena2) END,0), 
       matA=CASE WHEN PKZ.KalkSkupina=1 THEN K.mnf * ISNULL(CASE @KteryMat WHEN 0 THEN ISNULL(KC_M.Cena,KC.cena) WHEN 1 THEN ISNULL(KC_M.Cena1,KC.cena1) ELSE ISNULL(KC_M.Cena2,KC.cena2) END,0) END, 
       matB=CASE WHEN PKZ.KalkSkupina=2 THEN K.mnf * ISNULL(CASE @KteryMat WHEN 0 THEN ISNULL(KC_M.Cena,KC.cena) WHEN 1 THEN ISNULL(KC_M.Cena1,KC.cena1) ELSE ISNULL(KC_M.Cena2,KC.cena2) END,0) END, 
       matC=CASE WHEN PKZ.KalkSkupina=3 THEN K.mnf * ISNULL(CASE @KteryMat WHEN 0 THEN ISNULL(KC_M.Cena,KC.cena) WHEN 1 THEN ISNULL(KC_M.Cena1,KC.cena1) ELSE ISNULL(KC_M.Cena2,KC.cena2) END,0) END, 
       MatRezie=K.mnf * ISNULL(CASE @KteryMat WHEN 0 THEN ISNULL(KC_M.Cena,KC.cena) WHEN 1 THEN ISNULL(KC_M.Cena1,KC.cena1) ELSE ISNULL(KC_M.Cena2,KC.cena2) END,0) * ISNULL(ISNULL(KC_M.MatRezie,KC.MatRezie),SZ.MatRezie) / 100.0 
     FROM TabDetailniKalkulace_kalk K 
       INNER JOIN TabKVazby KV ON (KV.ID=K.IDVazby) 
       INNER JOIN TabKmenZbozi KZ ON (KZ.ID=KV.nizsi AND KZ.Material=1) 
       INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo)  
       LEFT OUTER JOIN TabParametryKmeneZbozi PKZ ON (PKZ.IDKmenZbozi=KZ.ID) 
       LEFT OUTER JOIN TabKalkCe KC_M ON (KC_M.IDKmenZbozi=KZ.ID AND KC_M.IDZakazModif=@IDZakazModif) 
       LEFT OUTER JOIN TabKalkCe KC ON (KC_M.ID IS NULL AND KC.IDKmenZbozi=KZ.ID AND 
                                                   EXISTS(SELECT * FROM tabczmeny ZodKC 
                                                             LEFT OUTER JOIN tabczmeny ZdoKC ON (ZDoKC.ID=KC.zmenaDo) 
                                                            WHERE ZodKC.ID=KC.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodKC.platnost ELSE ZodKC.platnostTPV END)=1 AND @DatumKalkCen>=ZodKC.datum AND 
        (KC.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoKC.platnost ELSE ZdoKC.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoKC.platnost ELSE ZdoKC.platnostTPV END)=1 AND @datumKalkCen<ZDoKC.datum)) 
                                                         ) 
                                       ) 
     WHERE K.TypRadku=10 AND K.VyraditZKalkulace=0  AND K.IDFinal=@IDPol AND K.IDZakazka=@IDZakazka_vypocet AND K.Autor=SUSER_SNAME()

--upraven výpočet - zrušeno násobení množstvím z požadavků
--toto je problém, nutno upravit dohledání materiálu v kusovníku!!
/*UPDATE TabDetailniKalkulace_kalk SET
     mat=ISNULL((SELECT (tskk.Cena_vypoctena)*(tkv.mnozstviSeZtratou)/**@Mnozstvi_vypocet*/
                 FROM TabStrukKusovnik_kalk_cenik tskk 
                 JOIN TabKvazby tkv ON tkv.nizsi = tskk.IDNizsi AND tkv.ZmenaDo IS NULL
				 --LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tskk.IDNizsi AND tss.IDSklad='100'
                 WHERE tkv.ID = TabDetailniKalkulace_kalk.IDVazby AND tskk.IDZakazka = @IDZakazka_vypocet AND tskk.Autor=SUSER_SNAME()),0)
WHERE IDFinal=@IDPol AND IDZakazka=@IDZakazka_vypocet AND Autor=SUSER_SNAME()
*/

DECLARE @IDKalk INT,@mnf NUMERIC(19,6);
DECLARE CurMatCenik CURSOR LOCAL FAST_FORWARD FOR
	SELECT tkk.ID, tkk.mnf
	FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
	WHERE tkk.IDFinal=@IDPol AND tkk.IDZakazka=@IDZakazka_vypocet AND tkk.Autor=SUSER_SNAME() AND tkk.TypRadku /*upraveno 5.5.2022, původně bylo = 10*/ IN (10,20)
	OPEN CurMatCenik;
	FETCH NEXT FROM CurMatCenik INTO @IDKalk,@mnf;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

	UPDATE tkk SET mat=(tskk.Cena_vypoctena*@mnf)/* původně bylo: ISNULL((tskk.Cena_vypoctena*@mnf),0) a dále v dalším cursoru opět úprava, která řeší výsledek NULL*/
	FROM TabDetailniKalkulace_kalk tkk
	LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik tskk WITH(NOLOCK) ON tskk.IDNizsi=tkk.IDNizsi AND tskk.IDZakazka=tkk.IDZakazka AND tskk.Autor=tkk.Autor
	WHERE tkk.ID=@IDKalk

FETCH NEXT FROM CurMatCenik INTO @IDKalk,@mnf;
END;
CLOSE CurMatCenik;
DEALLOCATE CurMatCenik;

--pokud je cena materiálu nulová, pokusit se dohledat skladový průměr
--změna na pokud cena není (=NULL)
DECLARE @CenaMat NUMERIC(19,6),@JCenaMat NUMERIC(19,6),@Prumer NUMERIC(19,6),@IDMat INT,@MnozstviSeZtratou NUMERIC(19,6);
DECLARE CurMat CURSOR LOCAL FAST_FORWARD FOR
	SELECT tkk.ID, tkk.mat, tkk.JNmat,tss.Prumer, tkv.nizsi, tkv.mnozstviSeZtratou
	FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
	LEFT OUTER JOIN TabKvazby tkv WITH(NOLOCK) ON tkv.ID=tkk.IDVazby
	LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkv.nizsi AND tss.IDSklad='100'
	WHERE tkk.IDFinal=@IDPol AND tkk.IDZakazka=@IDZakazka_vypocet AND tkk.Autor=SUSER_SNAME() AND tkk.TypRadku /*upraveno 5.5.2022, původně bylo = 10, opět upraveno 19.7.2022, bylo IN (10,20)*/ = 10
	OPEN CurMat;
	FETCH NEXT FROM CurMat INTO 
		@IDKalk,@CenaMat,@JCenaMat,@Prumer,@IDMat,@MnozstviSeZtratou;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		IF @CenaMat IS NULL/*původně bylo: =0 a je to  kvůli předchozímu cursoru, který může vrátit NULL*/
		UPDATE tkk SET tkk.mat=ISNULL((SELECT (@Prumer)*(@MnozstviSeZtratou)*@Mnozstvi_vypocet),0)/*upraveno 22.6.2022, vráceno zpět násobení @Mnozstvi_vypocet*/
		FROM TabDetailniKalkulace_kalk tkk 
		WHERE tkk.ID=@IDKalk

	FETCH NEXT FROM CurMat INTO @IDKalk,@CenaMat,@JCenaMat,@Prumer,@IDMat,@MnozstviSeZtratou;
	END;
	CLOSE CurMat;
	DEALLOCATE CurMat;

--změna 19.7.2022, vloženo: pokud cena polotovaru není (=NULL)
DECLARE @CenaPolotovar NUMERIC(19,6),@JCenaPolotovar NUMERIC(19,6),@IDPolotovar INT;
DECLARE CurPolotovar CURSOR LOCAL FAST_FORWARD FOR
	SELECT tkk.ID, tkk.mat, tkk.JNmat, tkv.nizsi, tkv.mnozstviSeZtratou
	FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
	LEFT OUTER JOIN TabKvazby tkv WITH(NOLOCK) ON tkv.ID=tkk.IDVazby
	WHERE tkk.IDFinal=@IDPol AND tkk.IDZakazka=@IDZakazka_vypocet AND tkk.Autor=SUSER_SNAME() AND tkk.TypRadku= 20
	OPEN CurPolotovar;
	FETCH NEXT FROM CurPolotovar INTO 
		@IDKalk,@CenaPolotovar,@JCenaPolotovar,@IDPolotovar,@MnozstviSeZtratou;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		IF @CenaPolotovar IS NULL/*původně bylo: =0 a je to  kvůli předchozímu cursoru, který může vrátit NULL*/
		BEGIN
		SELECT @CenaPolotovar=tz.Celkem
		FROM TabZKalkulace tz
		WHERE tz.Dilec=@IDPolotovar AND tz.ZmenaDo IS NULL
		UPDATE tkk SET tkk.mat=ISNULL(@CenaPolotovar,0)*@MnozstviSeZtratou*@Mnozstvi_vypocet
		FROM TabDetailniKalkulace_kalk tkk
		WHERE tkk.ID=@IDKalk
		END;
	FETCH NEXT FROM CurPolotovar INTO @IDKalk,@CenaPolotovar,@JCenaPolotovar,@IDPolotovar,@MnozstviSeZtratou;
	END;
	CLOSE CurPolotovar;
	DEALLOCATE CurPolotovar;

--vkládání kooperace
 IF @typ_koop=2 
   BEGIN 
     CREATE TABLE #PomTabProKoop(ID int IDENTITY (1, 1) NOT NULL, Strom nvarchar(255) COLLATE database_default NULL, Patro int NULL, IDVyssi int NULL, PopisRadku nvarchar(150) COLLATE database_default NULL, 
                                 IDVazby int NULL, Mnozstvi numeric(19,6) NOT NULL, Prime bit NOT NULL, VyraditZKalkulace bit NOT NULL, 
                                 MenaPrepravy nvarchar(3) NULL, MenaKalkulace nvarchar(3) NULL, CenaPrepravy numeric(19,6) NULL, CenaDavky numeric(19,6) NULL, CenaMJ numeric(19,6) NULL) 
     INSERT INTO #PomTabProKoop(Strom, Patro, IDVyssi, PopisRadku, IDVazby, Mnozstvi, Prime, VyraditZKalkulace, MenaPrepravy, MenaKalkulace, CenaPrepravy, CenaDavky, CenaMJ) 
       SELECT K.Strom + N' ---', K.Uroven, K.IDKmenZbozi, 
              PopisRadku=LEFT(P.Operace + ISNULL(N' '+P.Nazev, ''), 150), 
              P.ID, K.Mnozstvi, K.Prime, K.VyraditZKalkulace, 
              CK.MenaPrepravy, MenaKalkulace=(CASE WHEN P.Koop_IndividualniKalkulace=1 THEN P.Koop_MenaKalkulace ELSE CK.MenaKalkulace END), 
              CenaPrepravy=dbo.hf_GetCastkuHM(CK.CenaPrepravy, CK.MenaPrepravy, @DatumKalkCen) * CASE WHEN CK.PrepravniDavka=0 THEN 1.0 ELSE CEILING((K.MnozNosnehoDuplDilce * P.KoopMnozstvi/P.DavkaTPV)/CK.PrepravniDavka) END, 
              CenaDavky=dbo.hf_GetCastkuHM(ISNULL(P.Koop_CenaDavky,CK.CenaDavky), (CASE WHEN P.Koop_IndividualniKalkulace=1 THEN P.Koop_MenaKalkulace ELSE CK.MenaKalkulace END), @DatumKalkCen) * CEILING((K.MnozNosnehoDuplDilce * P.KoopMnozstvi/P.DavkaTPV)/ISNULL(P.Koop_KalkulacniDavka,CK.KalkulacniDavka)), 
              CenaMJ=dbo.hf_GetCastkuHM(ISNULL(P.Koop_CenaMJ,CK.CenaMJ), (CASE WHEN P.Koop_IndividualniKalkulace=1 THEN P.Koop_MenaKalkulace ELSE CK.MenaKalkulace END), @DatumKalkCen) * K.mnozstvi*P.KoopMnozstvi/P.DavkaTPV 
          FROM #tabKusovnik_kalk K 
            INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.Dilec=1) 
            LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
            LEFT OUTER JOIN TabPostup P1 ON (ZMD.ID IS NULL AND P1.dilec=KZ.IDKusovnik AND P1.IDZakazModif IS NULL AND (P1.IDVarianta IS NULL OR P1.IDVarianta=KZ.IDVarianta) AND 
                                                EXISTS(SELECT * FROM TabCZmeny Zod 
                                                           LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=P1.zmenaDo) 
                                                         WHERE Zod.ID=P1.zmenaOd AND (CASE WHEN @CanDP=0 THEN Zod.platnost ELSE Zod.platnostTPV END)=1 AND @datumTPV>=Zod.datum AND 
                                                               (P1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=1 AND @datumTPV<ZDo.datum))) ) 
            LEFT OUTER JOIN TabPostup P2 ON (ZMD.ID IS NOT NULL AND P2.dilec=KZ.ID AND P2.IDZakazModif=ZMD.IDZakazModif) 
            INNER JOIN TabPostup P ON (P.ID=(SELECT P1.ID WHERE P1.ID IS NOT NULL UNION ALL SELECT P2.ID WHERE P2.ID IS NOT NULL)) 
            INNER JOIN TabCKoop CK ON (CK.ID=P.IDKooperace) 
          WHERE K.VyraditZKalkulace=0 AND P.typ=2 
          ORDER BY P.Operace ASC 
     SELECT TOP 1 @ErrID=63477, @ErrMsg=MenaPrepravy FROM #PomTabProKoop WHERE CenaPrepravy IS NULL AND MenaPrepravy IS NOT NULL 
      
     SELECT TOP 1 @ErrID=63477, @ErrMsg=MenaKalkulace FROM #PomTabProKoop WHERE (CenaDavky IS NULL OR CenaMJ IS NULL) AND MenaKalkulace IS NOT NULL 

--vložení vypočtených hodnot do naší trvale zobrazitelné tabulky     
   INSERT INTO TabDetailniKalkulace_kalk(IDFinal, IDZakazka, IDZakazModif, IDKalkVzor, Strom, Patro, IDVyssi, PopisRadku, TypRadku, IDVazby, mnf, Mnozstvi, Prime, VyraditZKalkulace, Koop, Autor,Davka_calc)
     SELECT @IDKmenZbozi, @IDZakazka_vypocet, @IDZakazModif, @IDKalkVzor, Strom, Patro, IDVyssi, PopisRadku, TypRadku=40, IDVazby, NULL, @MnozNaFinal, Prime, VyraditZKalkulace, Koop=CenaPrepravy+CenaDavky+CenaMJ, SUSER_SNAME(),D.Davka
       FROM #PomTabProKoop
	   LEFT OUTER JOIN TabDavka D WITH(NOLOCK) ON D.IDDilce=@IDKmenZbozi AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=D.zmenaDo) WHERE Zod.ID=D.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (D.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
       ORDER BY #PomTabProKoop.ID ASC 
   DROP TABLE #PomTabProKoop 
   END 
--vkládání OPN
 IF @typ_OPN=2 
   INSERT INTO TabDetailniKalkulace_kalk(IDFinal, IDZakazka, IDZakazModif, IDKalkVzor, Strom, Patro, IDVyssi, PopisRadku, TypRadku, IDVazby, mnf, Mnozstvi, Prime, VyraditZKalkulace, OPN, Autor, Davka_calc) 
     SELECT @IDKmenZbozi, @IDZakazka_vypocet, @IDZakazModif, @IDKalkVzor, K.Strom + N' ---', K.Uroven, K.IDKmenZbozi, 
            PopisRadku=LEFT(O.Kod + ISNULL(N' '+O.Nazev, ''), 150), 
            TypRadku=60, P.ID, NULL, @MnozNaFinal, K.Prime, K.VyraditZKalkulace, 
            OPN=CASE WHEN P.FixniNaklady=1 THEN (CASE WHEN K.NosnyDuplDilec=1 THEN ISNULL(S.sazba,0.0)*P.mnozstvi ELSE 0.0 END) ELSE ISNULL(S.sazba,0.0)*K.mnozstvi*P.mnozstvi/P.DavkaTPV END, SUSER_SNAME(),D.Davka
        FROM #tabKusovnik_kalk K 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.dilec=1)
          LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
          LEFT OUTER JOIN TabTpvOPN P1 ON (ZMD.ID IS NULL AND P1.dilec=KZ.IDKusovnik AND P1.IDZakazModif IS NULL AND (P1.IDVarianta IS NULL OR P1.IDVarianta=KZ.IDVarianta) AND 
                                              EXISTS(SELECT * FROM TabCZmeny Zod 
                                                         LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=P1.zmenaDo) 
                                                       WHERE Zod.ID=P1.zmenaOd AND (CASE WHEN @CanDP=0 THEN Zod.platnost ELSE Zod.platnostTPV END)=1 AND @datumTPV>=Zod.datum AND 
                                                             (P1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=1 AND @datumTPV<ZDo.datum))) ) 
          LEFT OUTER JOIN TabTpvOPN P2 ON (ZMD.ID IS NOT NULL AND P2.dilec=KZ.ID AND P2.IDZakazModif=ZMD.IDZakazModif) 
          INNER JOIN TabTpvOPN P ON (P.ID=(SELECT P1.ID WHERE P1.ID IS NOT NULL UNION ALL SELECT P2.ID WHERE P2.ID IS NOT NULL)) 
          INNER JOIN TabCisOPN O ON (O.ID=P.IDCisOPN) 
          LEFT OUTER JOIN TabCisOPNSazba S ON (S.IDCisOPN=P.IDCisOPN AND EXISTS(SELECT * FROM tabczmeny ZodS   
                                                                                  LEFT OUTER JOIN tabczmeny ZdoS ON (ZDoS.ID=S.zmenaDo)  
                                                                                 WHERE ZodS.ID=S.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodS.platnost ELSE ZodS.platnostTPV END)=1 AND @datumKalkCen>=ZodS.datum AND 
                                                                                       (S.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoS.platnost ELSE ZdoS.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoS.platnost ELSE ZdoS.platnostTPV END)=1 AND @datumKalkCen<ZDoS.datum)) 
                                                                               )  
                                              )
		LEFT OUTER JOIN TabDavka D WITH(NOLOCK) ON D.IDDilce=@IDKmenZbozi AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=D.zmenaDo) WHERE Zod.ID=D.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (D.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
        WHERE K.VyraditZKalkulace=0 
        ORDER BY O.Kod ASC 
 --vkládání vedlejších produktů
 IF @typ_VedProdukt=2 
   INSERT INTO TabDetailniKalkulace_kalk(IDFinal, IDZakazka, IDZakazModif, IDKalkVzor, Strom, Patro, IDVyssi, PopisRadku, TypRadku, IDVazby, mnf, Mnozstvi, Prime, VyraditZKalkulace, VedProdukt, Autor, Davka_calc) 
     SELECT @IDKmenZbozi, @IDZakazka_vypocet, @IDZakazModif, @IDKalkVzor, K.Strom + N' ---', K.Uroven, K.IDKmenZbozi, 
            PopisRadku=LEFT(VP.SkupZbo+N' '+VP.RegCis+N' '+VP.Nazev1, 150), 
            TypRadku=70, P.ID, K.mnozstvi*P.mnozstvi/P.DavkaTPV, @MnozNaFinal, K.Prime, K.VyraditZKalkulace, 
            VedProdukt=ISNULL(S.cena,0.0)*K.mnozstvi*P.mnozstvi/P.DavkaTPV, SUSER_SNAME(), D.davka
        FROM #tabKusovnik_kalk K 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.dilec=1) 
          LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
          LEFT OUTER JOIN TabVPVazby P1 ON (ZMD.ID IS NULL AND P1.dilec=KZ.IDKusovnik AND P1.IDZakazModif IS NULL AND (P1.IDVarianta IS NULL OR P1.IDVarianta=KZ.IDVarianta) AND 
                                              EXISTS(SELECT * FROM TabCZmeny Zod 
                                                         LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=P1.zmenaDo) 
                                                       WHERE Zod.ID=P1.zmenaOd AND (CASE WHEN @CanDP=0 THEN Zod.platnost ELSE Zod.platnostTPV END)=1 AND @datumTPV>=Zod.datum AND 
                                                             (P1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=1 AND @datumTPV<ZDo.datum))) ) 
          LEFT OUTER JOIN TabVPVazby P2 ON (ZMD.ID IS NOT NULL AND P2.dilec=KZ.ID AND P2.IDZakazModif=ZMD.IDZakazModif) 
          INNER JOIN TabVPVazby P ON (P.ID=(SELECT P1.ID WHERE P1.ID IS NOT NULL UNION ALL SELECT P2.ID WHERE P2.ID IS NOT NULL)) 
          INNER JOIN TabKmenZbozi VP ON (VP.ID=P.VedProdukt) 
          LEFT OUTER JOIN TabVedProduktCena S ON (S.IDKmenZbozi=P.VedProdukt AND EXISTS(SELECT * FROM tabczmeny ZodS   
                                                                                  LEFT OUTER JOIN tabczmeny ZdoS ON (ZDoS.ID=S.zmenaDo)  
                                                                                 WHERE ZodS.ID=S.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodS.platnost ELSE ZodS.platnostTPV END)=1 AND @datumKalkCen>=ZodS.datum AND 
                                                                                       (S.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoS.platnost ELSE ZdoS.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoS.platnost ELSE ZdoS.platnostTPV END)=1 AND @datumKalkCen<ZDoS.datum)) 
                                                                               )  
                                              ) 
        LEFT OUTER JOIN TabDavka D WITH(NOLOCK) ON D.IDDilce=@IDKmenZbozi AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=D.zmenaDo) WHERE Zod.ID=D.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (D.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
		WHERE K.VyraditZKalkulace=0 
        ORDER BY VP.SkupZbo ASC, VP.RegCis ASC 
 --vkládání nářadí
 IF @typ_naradi=2 
   INSERT INTO TabDetailniKalkulace_kalk(IDFinal, IDZakazka, IDZakazModif, IDKalkVzor, Strom, Patro, IDVyssi, PopisRadku, TypRadku, IDVazby, mnf, Mnozstvi, Prime, VyraditZKalkulace, Naradi, Autor, Davka_calc) 
     SELECT @IDKmenZbozi, @IDZakazka_vypocet, @IDZakazModif, @IDKalkVzor, K.Strom + N' ---', K.Uroven, K.IDKmenZbozi, 
            PopisRadku=LEFT(KZ_N.SkupZbo+N' '+KZ_N.RegCis+N' '+KZ_N.Nazev1, 150), 
            TypRadku=50, NV.ID, NULL, @MnozNaFinal, K.Prime, K.VyraditZKalkulace, 
            naradi=CASE WHEN ISNULL(PN.TypNaradi,0)=0 THEN 
                                      NV.mnozstvi * ISNULL(CN.cena,0) * 
                                      K.mnozstvi * NV.KoefOpotrebeni * 
                                      CASE WHEN ISNULL(PN.TypZivotnosti,0)=0 THEN ISNULL(NV.pocetUziti/NV.DavkaTPV,1) 
                                           WHEN ISNULL(NV.DobaPouzitiPodle,0)=1 THEN ISNULL(NV.DobaPouziti_N/NV.DavkaTPV,0) 
                                           WHEN ISNULL(NV.operace,'')<>'' THEN ISNULL(P.TAC_N/P.DavkaTPV_VO,0) 
                                           ELSE ISNULL(PTop1.TAC_N/PTop1.DavkaTPV_VO,0) 
                                      END  /  ISNULL(PN.Zivotnost_N,1) 
                                    ELSE 
                                      NV.mnozstvi * ISNULL(CN.cena,0) * 
                                     CEILING( 
                                      K.MnozNosnehoDuplDilce * NV.KoefOpotrebeni * 
                                      CASE WHEN ISNULL(PN.TypZivotnosti,0)=0 THEN ISNULL(NV.pocetUziti/NV.DavkaTPV,1) 
                                           WHEN ISNULL(NV.DobaPouzitiPodle,0)=1 THEN ISNULL(NV.DobaPouziti_N/NV.DavkaTPV,0) 
                                           WHEN ISNULL(NV.operace,'')<>'' THEN ISNULL(P.TAC_N/P.DavkaTPV_VO,0) 
                                           ELSE ISNULL(PTop1.TAC_N/PTop1.DavkaTPV_VO,0) 
                                      END  /  ISNULL(PN.Zivotnost_N,1) 
                                            ) 
                               END, SUSER_SNAME(), D.davka
          FROM #tabKusovnik_kalk K 
            INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.dilec=1) 
            LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
            LEFT OUTER JOIN TabNVazby NV1 ON (ZMD.ID IS NULL AND NV1.dilec=KZ.IDKusovnik AND NV1.IDZakazModif IS NULL AND (NV1.IDVarianta IS NULL OR NV1.IDVarianta=KZ.IDVarianta) AND 
                                              EXISTS(SELECT * FROM TabCZmeny Zod 
                                                         LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=NV1.zmenaDo) 
                                                       WHERE Zod.ID=NV1.zmenaOd AND (CASE WHEN @CanDP=0 THEN Zod.platnost ELSE Zod.platnostTPV END)=1 AND @datumTPV>=Zod.datum AND 
                                                             (NV1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=1 AND @datumTPV<ZDo.datum))) ) 
            LEFT OUTER JOIN TabNVazby NV2 ON (ZMD.ID IS NOT NULL AND NV2.dilec=KZ.ID AND NV2.IDZakazModif=ZMD.IDZakazModif) 
            INNER JOIN TabNVazby NV ON (NV.ID=(SELECT NV1.ID WHERE NV1.ID IS NOT NULL UNION ALL SELECT NV2.ID WHERE NV2.ID IS NOT NULL)) 
            INNER JOIN TabKmenZbozi KZ_N ON (KZ_N.ID=NV.Naradi) 
            LEFT OUTER JOIN TabParNar PN ON (PN.IDKmenZbozi=NV.naradi) 
            LEFT OUTER JOIN TabPostup P1 ON (ISNULL(PN.TypZivotnosti,0)<>0 AND ISNULL(NV.DobaPouzitiPodle,0)=0 AND ISNULL(NV.operace,'')<>'' AND 
                                             ZMD.ID IS NULL AND P1.dilec=KZ.IDKusovnik AND P1.IDZakazModif IS NULL AND (P1.IDVarianta IS NULL OR P1.IDVarianta=KZ.IDVarianta) AND 
                                                EXISTS(SELECT * FROM tabczmeny ZodP  
                                                                  LEFT OUTER JOIN tabczmeny ZdoP ON (ZDoP.ID=P1.zmenaDo) 
                                                                WHERE ZodP.ID=P1.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodP.platnost ELSE ZodP.platnostTPV END)=1 AND @datumTPV>=ZodP.datum AND  
                                                                      (P1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoP.platnost ELSE ZdoP.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoP.platnost ELSE ZdoP.platnostTPV END)=1 AND @datumTPV<ZDoP.datum))) AND 
                                             P1.operace=NV.operace) 
            LEFT OUTER JOIN TabPostup P2 ON (ISNULL(PN.TypZivotnosti,0)<>0 AND ISNULL(NV.DobaPouzitiPodle,0)=0 AND ISNULL(NV.operace,'')<>'' AND 
                                             ZMD.ID IS NOT NULL AND P2.dilec=KZ.ID AND P2.IDZakazModif=ZMD.IDZakazModif AND 
                                             P2.operace=NV.operace) 
            LEFT OUTER JOIN TabPostup P ON (ISNULL(PN.TypZivotnosti,0)<>0 AND ISNULL(NV.DobaPouzitiPodle,0)=0 AND ISNULL(NV.operace,'')<>'' AND 
                                            P.ID=(SELECT P1.ID WHERE P1.ID IS NOT NULL UNION ALL SELECT P2.ID WHERE P2.ID IS NOT NULL)) 
            LEFT OUTER JOIN TabPostup PTop1 ON (ISNULL(PN.TypZivotnosti,0)<>0 AND ISNULL(NV.DobaPouzitiPodle,0)=0 AND ISNULL(NV.operace,'')='' AND 
                                                PTop1.ID=(SELECT TOP 1 P0.ID 
                                                            FROM TabPostup P0 
                                                             INNER JOIN tabCZmeny ZOdP0 ON (ZOdP0.ID=P0.zmenaOd) 
                                                             LEFT OUTER JOIN tabCZmeny ZDoP0 ON (ZDoP0.ID=P0.zmenaDo) 
                                                            WHERE ZMD.ID IS NULL AND P0.dilec=KZ.IDKusovnik AND P0.IDZakazModif IS NULL AND (P0.IDVarianta IS NULL OR P0.IDVarianta=KZ.IDVarianta) AND 
                                                                  (CASE WHEN @CanDP=0 THEN ZodP0.platnost ELSE ZodP0.platnostTPV END)=1 AND @datumTPV>=ZodP0.datum AND 
                                                                  (P0.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoP0.platnost ELSE ZdoP0.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoP0.platnost ELSE ZdoP0.platnostTPV END)=1 AND @datumTPV<ZDoP0.datum)) 
                                                            ORDER BY P0.operace 
                                                          UNION ALL 
                                                          SELECT TOP 1 P0.ID 
                                                            FROM TabPostup P0 
                                                            WHERE ZMD.ID IS NOT NULL AND P0.dilec=KZ.ID AND P0.IDZakazModif=ZMD.IDZakazModif 
                                                            ORDER BY P0.operace) ) 
            LEFT OUTER JOIN TabNaradi CN ON (CN.naradi=NV.naradi AND EXISTS(SELECT * FROM tabczmeny ZodCN 
                                                                                      LEFT OUTER JOIN tabczmeny ZdoCN ON (ZDoCN.ID=CN.zmenaDo) 
                                                                                     WHERE ZodCN.ID=CN.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodCN.platnost ELSE ZodCN.platnostTPV END)=1 AND @datumKalkCen>=ZodCN.datum AND 
        (CN.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoCN.platnost ELSE ZdoCN.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoCN.platnost ELSE ZdoCN.platnostTPV END)=1 AND @datumKalkCen<ZDoCN.datum)) 
                                                                           ) 
                                            ) 
          LEFT OUTER JOIN TabDavka D WITH(NOLOCK) ON D.IDDilce=@IDKmenZbozi AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=D.zmenaDo) WHERE Zod.ID=D.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (D.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
		  WHERE K.VyraditZKalkulace=0 AND 
                (ISNULL(NV.AltOperace,'')='' OR NV.AltOperace=N'A') 
          ORDER BY KZ_N.SkupZbo ASC, KZ_N.RegCis ASC 
 --vkládání operací
 CREATE TABLE #PomKalkTab (TAC_N numeric(20,6) NULL, TAC_Obsluhy_N numeric(20,6) NULL, TAC_KC numeric(20,6) NULL, 
                               TBC_N numeric(20,6) NULL, TBC_Obsluhy_N numeric(20,6) NULL, TBC_KC numeric(20,6) NULL, 
                               TEC_N numeric(20,6) NULL, TEC_Obsluhy_N numeric(20,6) NULL, TEC_KC numeric(20,6) NULL, 
                               RezieS numeric(20,6) NULL, RezieS_T int NULL, RezieP numeric(20,6) NULL, RezieP_T int NULL, ReziePrac numeric(20,6) NULL, ReziePrac_T int NULL, NakladyPrac numeric(20,6) NULL, NakladyPrac_T int NULL, 
                               AgenturniPrac bit NOT NULL, Typ int NOT NULL, 
                               K_ID int NOT NULL, P_ID int NOT NULL) 
   INSERT INTO #PomKalkTab(TAC_N, TAC_Obsluhy_N, TAC_KC, TBC_N, TBC_Obsluhy_N, TBC_KC, TEC_N, TEC_Obsluhy_N, TEC_KC, RezieS, RezieS_T, RezieP, RezieP_T, ReziePrac, ReziePrac_T, NakladyPrac, NakladyPrac_T, AgenturniPrac, Typ, K_ID, P_ID) 
        SELECT TAC_N=(P.TAC_N * K.mnozstvi / P.DavkaTPV_VO), 
               TAC_Obsluhy_N=(P.TAC_Obsluhy_N * K.mnozstvi / P.DavkaTPV_VO), 
               TAC_KC=(CASE WHEN (@tarif=0) THEN (P.TAC_KC * K.mnozstvi / P.DavkaTPV_VO)  
                            ELSE (P.TAC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) * K.mnozstvi / (P.DavkaTPV_VO * 3600.0))  
                       END ),  
               TBC_N=(CASE WHEN @davka=0 THEN (0) 
                           WHEN @davka=2 THEN (P.TBC_N * K.mnozstvi) 
                           WHEN @davka=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TBC_N ELSE 0.0 END) 
                           ELSE (K.mnozstvi * P.TBC_N / D.davka) 
                      END ), 
               TBC_Obsluhy_N=(CASE WHEN @davka=0 THEN (0) 
                                   WHEN @davka=2 THEN (P.TBC_Obsluhy_N * K.mnozstvi) 
                                   WHEN @davka=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TBC_Obsluhy_N ELSE 0.0 END) 
                                   ELSE (K.mnozstvi * P.TBC_Obsluhy_N / D.davka) 
                              END ), 
               TBC_KC=(CASE @tarif WHEN 0 THEN ( CASE WHEN @davka=0 THEN (0) 
                                                      WHEN @davka=2 THEN (P.TBC_KC * K.mnozstvi) 
                                                      WHEN @davka=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TBC_KC ELSE 0.0 END) 
                                                      ELSE (K.mnozstvi * P.TBC_KC / D.davka) 
                                                 END ) 
                                   ELSE ( CASE WHEN @davka=0 THEN (0) 
                                               WHEN @davka=2 THEN (P.TBC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) * K.mnozstvi / 3600.0) 
                                               WHEN @davka=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TBC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) / 3600.0 ELSE 0.0 END) 
                                               ELSE (K.mnozstvi * P.TBC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) / (D.davka * 3600.0)) 
                                          END ) 
                       END ), 
               TEC_N=(CASE WHEN @davka_TEC=0 THEN (0) 
                           WHEN @davka_TEC=2 THEN (P.TEC_N * K.mnozstvi) 
                           WHEN @davka_TEC=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TEC_N ELSE 0.0 END) 
                           ELSE (K.mnozstvi * P.TEC_N / D.davka) 
                      END ), 
               TEC_Obsluhy_N=(CASE WHEN @davka_TEC=0 THEN (0) 
                                   WHEN @davka_TEC=2 THEN (P.TEC_Obsluhy_N * K.mnozstvi) 
                                   WHEN @davka_TEC=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TEC_Obsluhy_N ELSE 0.0 END) 
                                   ELSE (K.mnozstvi * P.TEC_Obsluhy_N / D.davka) 
                              END ), 
               TEC_KC=(CASE @tarif WHEN 0 THEN ( CASE WHEN @davka_TEC=0 THEN (0) 
                                                      WHEN @davka_TEC=2 THEN (P.TEC_KC * K.mnozstvi) 
                                                      WHEN @davka_TEC=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TEC_KC ELSE 0.0 END) 
                                                      ELSE (K.mnozstvi * P.TEC_KC / D.davka) 
                                                 END ) 
                                   ELSE ( CASE WHEN @davka_TEC=0 THEN (0) 
                                               WHEN @davka_TEC=2 THEN (P.TEC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) * K.mnozstvi / 3600.0) 
                                               WHEN @davka_TEC=1 OR D.davka IS NULL THEN (CASE WHEN K.NosnyDuplDilec=1 THEN P.TEC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) / 3600.0 ELSE 0.0 END) 
                                               ELSE (K.mnozstvi * P.TEC_Obsluhy_S * ISNULL(@TarifKalk,ISNULL(TP.koef_ZH,0)) / (D.davka * 3600.0)) 
                                          END ) 
                       END ), 
               RezieS=ISNULL(R.RezieS,0), 
               RezieS_T=ISNULL(R.RezieS_T,0), 
               RezieP=ISNULL(R.RezieP,0), 
               RezieP_T=ISNULL(R.RezieP_T,0), 
               ReziePrac=ISNULL(NP.ReziePrac,0), 
               ReziePrac_T=ISNULL(NP.ReziePrac_T,0), 
               NakladyPrac=ISNULL(NP.NakladyPrac,0), 
               NakladyPrac_T=ISNULL(NP.NakladyPrac_T,0), 
               AgenturniPrac=ISNULL(TH.AgenturniPrac, 0), 
               Typ=P.Typ, 
               K_ID=K.ID, P_ID=P.ID 
              FROM #tabKusovnik_kalk K 
                 INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.dilec=1) 
                 LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
                 LEFT OUTER JOIN TabPostup P1 ON (ZMD.ID IS NULL AND P1.dilec=KZ.IDKusovnik AND P1.IDZakazModif IS NULL AND (P1.IDVarianta IS NULL OR P1.IDVarianta=KZ.IDVarianta) AND 
                                                   EXISTS(SELECT * FROM TabCZmeny Zod 
                                                              LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=P1.zmenaDo) 
                                                            WHERE Zod.ID=P1.zmenaOd AND (CASE WHEN @CanDP=0 THEN Zod.platnost ELSE Zod.platnostTPV END)=1 AND @datumTPV>=Zod.datum AND 
                                                                  (P1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN Zdo.platnost ELSE Zdo.platnostTPV END)=1 AND @datumTPV<ZDo.datum))) ) 
                 LEFT OUTER JOIN TabPostup P2 ON (ZMD.ID IS NOT NULL AND P2.dilec=KZ.ID AND P2.IDZakazModif=ZMD.IDZakazModif) 
                 INNER JOIN TabPostup P ON (P.ID=(SELECT P1.ID WHERE P1.ID IS NOT NULL UNION ALL SELECT P2.ID WHERE P2.ID IS NOT NULL)) 
                 LEFT OUTER JOIN TabTarH TH ON (TH.ID=P.tarif) 
                 LEFT OUTER JOIN TabTarP TP ON (TP.IDTarif=TH.ID AND EXISTS(SELECT * FROM tabczmeny ZodTP 
                                                                                       LEFT OUTER JOIN tabczmeny ZdoTP ON (ZDoTP.ID=TP.zmenaDo) 
                                                                                     WHERE ZodTP.ID=TP.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodTP.platnost ELSE ZodTP.platnostTPV END)=1 AND @datumKalkCen>=ZodTP.datum AND 
       (TP.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoTP.platnost ELSE ZdoTP.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoTP.platnost ELSE ZdoTP.platnostTPV END)=1 AND @datumKalkCen<ZDoTP.datum)) 
                                                                           ) 
                                               ) 
                 LEFT OUTER JOIN TabDavka D1 ON (ZMD.ID IS NULL AND D1.IDDilce=KZ.IDKusovnik AND D1.IDZakazModif IS NULL AND 
                                                     EXISTS(SELECT * FROM tabczmeny ZodD 
                                                        LEFT OUTER JOIN tabczmeny ZdoD ON (ZDoD.ID=D1.zmenaDo) 
                                                       WHERE ZodD.ID=D1.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodD.platnost ELSE ZodD.platnostTPV END)=1 AND @datumTPV>=ZodD.datum AND 
      (D1.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoD.platnost ELSE ZdoD.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoD.platnost ELSE ZdoD.platnostTPV END)=1 AND @datumTPV<ZDoD.datum))) ) 
                 LEFT OUTER JOIN TabDavka D2 ON (ZMD.ID IS NOT NULL AND D2.IDDilce=KZ.ID AND D2.IDZakazModif=ZMD.IDZakazModif) 
                 LEFT OUTER JOIN TabDavka D ON (D.ID=(SELECT D1.ID WHERE D1.ID IS NOT NULL UNION ALL SELECT D2.ID WHERE D2.ID IS NOT NULL)) 
                 LEFT OUTER JOIN TabCPraco CP ON (CP.ID=P.pracoviste) 
                 LEFT OUTER JOIN TabRezie R ON (R.Stredisko=CP.IDTabStrom AND EXISTS(SELECT * FROM tabczmeny ZodR 
                                                                                             LEFT OUTER JOIN tabczmeny ZdoR ON (ZDoR.ID=R.zmenaDo) 
                                                                                            WHERE ZodR.ID=R.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodR.platnost ELSE ZodR.platnostTPV END)=1 AND @datumKalkCen>=ZodR.datum AND 
       (R.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoR.platnost ELSE ZdoR.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoR.platnost ELSE ZdoR.platnostTPV END)=1 AND @datumKalkCen<ZDoR.datum)) 
                                                                                    ) 
                                               ) 
                 LEFT OUTER JOIN TabCPracoNakl NP ON (NP.IDPraco=P.pracoviste AND EXISTS(SELECT * FROM tabczmeny ZodNP 
                                                                                       LEFT OUTER JOIN tabczmeny ZdoNP ON (ZDoNP.ID=NP.zmenaDo) 
                                                                                     WHERE ZodNP.ID=NP.zmenaOd AND (CASE WHEN @CanDP=0 THEN ZodNP.platnost ELSE ZodNP.platnostTPV END)=1 AND @datumKalkCen>=ZodNP.datum AND 
          (NP.ZmenaDo IS NULL OR (CASE WHEN @CanDP=0 THEN ZdoNP.platnost ELSE ZdoNP.platnostTPV END)=0 OR ((CASE WHEN @CanDP=0 THEN ZdoNP.platnost ELSE ZdoNP.platnostTPV END)=1 AND @datumKalkCen<ZDoNP.datum)) 
                                                                                        ) 
                                                     ) 
              WHERE K.VyraditZKalkulace=0 AND (P.typ=0 OR P.typ=1) 
   INSERT INTO TabDetailniKalkulace_kalk(IDFinal, IDZakazka, IDZakazModif, IDKalkVzor, Strom, Patro, IDVyssi, PopisRadku, TypRadku, IDVazby, mnf, Mnozstvi, Prime, VyraditZKalkulace, Koop, 
                                     TAC, TAC_T, TAC_Obsluhy, TAC_Obsluhy_T, TAC_KC, 
                                     TBC, TBC_T, TBC_Obsluhy, TBC_Obsluhy_T, TBC_KC, 
                                     TEC, TEC_T, TEC_Obsluhy, TEC_Obsluhy_T, TEC_KC, 
                                     RezieS, RezieP, ReziePrac, NakladyPrac, Autor, Davka_calc) 
     SELECT @IDKmenZbozi, @IDZakazka_vypocet, @IDZakazModif, @IDKalkVzor, K.Strom + N' ---', K.Uroven, K.IDKmenZbozi, 
            PopisRadku=LEFT(P.Operace + ISNULL(N' '+P.Nazev, ''), 150), 
            TypRadku=30, P.ID, NULL, @MnozNaFinal, K.Prime, K.VyraditZKalkulace, 
            Koop= CASE WHEN X.AgenturniPrac=1 THEN X.TAC_KC+X.TBC_KC+X.TEC_KC ELSE 0.0 END, 
            X.TAC_N, 1, 
            X.TAC_Obsluhy_N, 1, 
            TAC_KC= CASE WHEN X.AgenturniPrac=0 THEN X.TAC_KC ELSE 0.0 END, 
            X.TBC_N, 1, 
            X.TBC_Obsluhy_N, 1, 
            TBC_KC= CASE WHEN X.AgenturniPrac=0 THEN X.TBC_KC ELSE 0.0 END, 
            X.TEC_N, 1, 
            X.TEC_Obsluhy_N, 1, 
            TEC_KC= CASE WHEN X.AgenturniPrac=0 THEN X.TEC_KC ELSE 0.0 END, 
            RezieS= CASE WHEN X.RezieS_T=0 THEN (CASE WHEN X.AgenturniPrac=0 THEN X.TAC_KC+X.TBC_KC+X.TEC_KC ELSE 0.0 END) * X.RezieS / 100.0 
                         WHEN X.RezieS_T IN (1,3) OR X.Typ=1 THEN (X.TAC_N+X.TBC_N+X.TEC_N) * X.RezieS / 60.0 
                         ELSE 0.0 END, 
            RezieP= CASE WHEN X.RezieP_T=0 THEN (CASE WHEN X.AgenturniPrac=0 THEN X.TAC_KC+X.TBC_KC+X.TEC_KC ELSE 0.0 END) * X.RezieP / 100.0 
                         WHEN X.RezieP_T IN (1,3) OR X.Typ=1 THEN (X.TAC_N+X.TBC_N+X.TEC_N) * X.RezieP / 60.0 
                         ELSE 0.0 END, 
            ReziePrac=  CASE WHEN X.ReziePrac_T=0 THEN (CASE WHEN X.AgenturniPrac=0 THEN X.TAC_KC+X.TBC_KC+X.TEC_KC ELSE 0.0 END) * X.ReziePrac / 100.0 
                             WHEN X.ReziePrac_T IN (1,3) OR X.Typ=1 THEN (X.TAC_N+X.TBC_N+X.TEC_N) * X.ReziePrac / 60.0 
                             ELSE 0.0 END, 
            NakladyPrac=CASE WHEN X.NakladyPrac_T=0 THEN (CASE WHEN X.AgenturniPrac=0 THEN X.TAC_KC+X.TBC_KC+X.TEC_KC ELSE 0.0 END) * X.NakladyPrac / 100.0 
                             WHEN X.NakladyPrac_T IN (1,3) OR X.Typ=1 THEN (X.TAC_N+X.TBC_N+X.TEC_N) * X.NakladyPrac / 60.0 
                             ELSE 0.0 END,
			SUSER_SNAME(), D.davka
          FROM #PomKalkTab X
            INNER JOIN #tabKusovnik_kalk K ON (K.ID=X.K_ID)
            INNER JOIN TabPostup P ON (P.ID=X.P_ID)
			LEFT OUTER JOIN TabDavka D WITH(NOLOCK) ON D.IDDilce=@IDKmenZbozi AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=D.zmenaDo) WHERE Zod.ID=D.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (D.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
          ORDER BY P.Operace ASC

		  --úprava TBC na 0, pokud je středisko na operaci 2000026% a nově úprava kvůli novým pracovištím - přidání podmínky za středisko 2002x a ext.sloupec pracoviště TK=0
		  --po dohodě s PaM 30.1.2024 upravena podmínka pracoviště TK=1
		UPDATE tkk SET tkk.rezieS=tkk.rezieS-(tkk.TBC_KC*4)
		FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
		LEFT OUTER JOIN TabPostup tp WITH(NOLOCK) ON tp.ID=tkk.IDVazby
		LEFT OUTER JOIN TabCPraco tcpo ON tkk.TypRadku=30 AND tcpo.ID=(SELECT P.pracoviste FROM TabPostup P WHERE P.ID=tkk.IDVazby)
		LEFT OUTER JOIN TabCPraco_EXT tcpoe WITH(NOLOCK) ON tcpoe.ID=tcpo.ID
		WHERE tkk.TypRadku=30 AND tkk.IDFinal=@IDPol AND tkk.Autor=SUSER_SNAME() AND (tcpo.IDTabStrom LIKE N'2000026%' OR tcpo.IDTabStrom LIKE N'20000275' OR (tcpo.IDTabStrom LIKE N'2002%'AND ISNULL(tcpoe._EXT_RS_wokplaceQA,0)=1))

		UPDATE tkk SET tkk.TBC=0,tkk.TBC_Obsluhy=0,tkk.TBC_KC=0
		FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
		LEFT OUTER JOIN TabPostup tp WITH(NOLOCK) ON tp.ID=tkk.IDVazby
		LEFT OUTER JOIN TabCPraco tcpo ON tkk.TypRadku=30 AND tcpo.ID=(SELECT P.pracoviste FROM TabPostup P WHERE P.ID=tkk.IDVazby)
		LEFT OUTER JOIN TabCPraco_EXT tcpoe WITH(NOLOCK) ON tcpoe.ID=tcpo.ID
		WHERE tkk.TypRadku=30 AND tkk.IDFinal=@IDPol AND tkk.Autor=SUSER_SNAME() AND (tcpo.IDTabStrom LIKE N'2000026%' OR tcpo.IDTabStrom LIKE N'20000275' OR (tcpo.IDTabStrom LIKE N'2002%'AND ISNULL(tcpoe._EXT_RS_wokplaceQA,0)=1))

		--úprava TAC i TBC, Pokud je operace na pracovišti PŘÍPRAVA nebo SKLAD, nastav TAC i TBC na nulu (tzn i náklady na přípravnou a jednincovou mzdu), MŽ 16.1.2025 na přání PaM
		UPDATE tkk SET tkk.TBC=0,tkk.TBC_Obsluhy=0,tkk.TBC_KC=0, TAC=0, TAC_Obsluhy=0, TAC_KC=0, rezieP=0, ReziePrac=0, rezieS=0, NakladyPrac=0
		FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
		LEFT OUTER JOIN TabPostup tp WITH(NOLOCK) ON tp.ID=tkk.IDVazby
		LEFT OUTER JOIN TabCPraco tcpo ON tkk.TypRadku=30 AND tcpo.ID=(SELECT P.pracoviste FROM TabPostup P WHERE P.ID=tkk.IDVazby)
		LEFT OUTER JOIN TabCPraco_EXT tcpoe WITH(NOLOCK) ON tcpoe.ID=tcpo.ID
		WHERE tkk.TypRadku=30 AND tkk.IDFinal=@IDPol AND tkk.Autor=SUSER_SNAME() AND (tcpo.IDTabStrom LIKE N'2002%'AND ISNULL(tcpoe._EXT_RS_workplaceWH,0)=1)
 
	UPDATE TabDetailniKalkulace_kalk SET
	mat=ROUND(@K_mat*mat,@PoziceZaokr), matA=ROUND(@K_mat*matA,@PoziceZaokr), matB=ROUND(@K_mat*matB,@PoziceZaokr), matC=ROUND(@K_mat*matC,@PoziceZaokr), 
	MatRezie=ROUND(@K_MatRezie*MatRezie,@PoziceZaokr), koop=ROUND(@K_koop*koop,@PoziceZaokr), naradi=ROUND(@K_naradi*naradi,@PoziceZaokr), TAC_KC=ROUND(@K_mzda*TAC_KC,@PoziceZaokr), 
	TBC_KC=ROUND(@K_mzda*TBC_KC,@PoziceZaokr), TEC_KC=ROUND(@K_mzda*TEC_KC,@PoziceZaokr), RezieS=ROUND(@K_RezieS*RezieS,@PoziceZaokr), RezieP=ROUND(@K_RezieP*RezieP,@PoziceZaokr), ReziePrac=ROUND(@K_ReziePrac*ReziePrac,@PoziceZaokr), 
	NakladyPrac=ROUND(@K_NakladyPrac*NakladyPrac,@PoziceZaokr), OPN=ROUND(@K_OPN*OPN,@PoziceZaokr), VedProdukt=ROUND(@K_VedProdukt*VedProdukt,@PoziceZaokr) 
 
	UPDATE TabDetailniKalkulace_kalk SET IDParNapoctu=2 WHERE IDParNapoctu IS NULL

DROP TABLE #PomKalkTab
DROP TABLE #tabKusovnik_kalk

--dotažení seznamu položek MZ z detailní kalkulace do Položky pro kalkulaci
--nejprve vymažu stávající poznámku MZ
UPDATE pozdok SET PolozkyMZ = NULL
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
--vložím text oddělený čárkou
UPDATE pozdok SET PolozkyMZ = (
SELECT STRING_AGG(tkk.PopisRadku,', ') AS Popis
FROM TabDetailniKalkulace_kalk tkk WITH(NOLOCK)
WHERE tkk.IDFinal=@IDPol AND tkk.IDZakazka=@IDZakazka_vypocet AND tkk.Autor=SUSER_SNAME() AND tkk.TypRadku=10 AND tkk.PopisRadku LIKE N'999%')
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
--uložíme tarif a dávku
UPDATE pozdok SET CisloTarifuKalk=@CisloTarifuKalk, Davka=@Davka
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
GO

