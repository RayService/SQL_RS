USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kus]    Script Date: 26.06.2025 12:11:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kus]
AS 
  SET NOCOUNT ON
DECLARE
  @RespekPlanZtratyPriVyrobeDilcu bit=0, 
  @DelitFixniMnozstviOptDavkou bit=0, 
  @KalkCenyKDnesku bit=0, 
  @RespekNedelitMJ bit=0, 
  @KalkulaceJednotlivychPolozek bit=0, 
  @IDKalkVzor INT=NULL, 
  @VcetneFinalu bit=1, 
  @RespekDodatecneProcZtratKV bit=0, 
  @VcetneNulovychKV bit=0, 
  @Ret INT,
  @RecID INT,
  @IDZadani INT,
  @Skupina nvarchar(20)=NULL,
  @dilec INT,
  @IDZakazModif INT,
  @IDZakazka INT,
  @mnozstvi numeric(20,6),
  @DatumTPV datetime=GETDATE(),
  @Dnes datetime 

--dohledání hlavičky dokladu, v němž je akce spouštěna
DECLARE @IDHlavicka INT
SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
--dočasně
--SELECT @IDHlavicka = 3607;
--SELECT @Skupina = 'A'
--konec dočasně

  EXEC hp_GetDnesniDatumX @Dnes OUTPUT 
  CREATE TABLE #tabKusovnik_proZadVyp (vyssi integer NULL, IDKmenZbozi integer NOT NULL, IDKVazby integer NULL, mnozstvi numeric(20,6) NOT NULL, prirez numeric(20,6) NULL, prime bit NOT NULL, RezijniMat tinyint NOT NULL, VyraditZKalkulace tinyint NOT NULL)
  CREATE INDEX IX_tabKusovnik_proZadVyp_IDKmenZbozi ON #tabKusovnik_proZadVyp (IDKmenZbozi) 
  
  --vyčištění přechozích výpočtů
  DELETE FROM TabKalkulace WHERE Autor=SUSER_SNAME() AND TabID=1 
  DELETE FROM TabKusovnik_polozky WHERE Autor=SUSER_SNAME() 

  --zahájení akce v kurzoru
  DECLARE ZadVyp_RS CURSOR FAST_FORWARD LOCAL FOR
  --zde se musí přepsat select kvůli záměně tabZadVyp za TabPohybyZbozi  
    SELECT tpz.ID, tss.IDKmenZbozi, tz.ID, tpz.Mnozstvi, @DatumTPV, @Skupina, NULL
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN TabStavSkladu tss ON tss.ID = tpz.IDZboSklad
	LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky = tpz.CisloZakazky
	WHERE tpz.IDDoklad = @IDHlavicka
/*původní select
	SELECT ID/*řádku z tabulky*/, dilec/*ID kmenové karty*/, IDZakazka, mnozstvi/*TabPohbyZbozi.mnozstvi*/, DatumTPVOrDnes, Skupina/*dám NULL*/, IDZakazModif/*dám NULL*/
	FROM tabZadVyp/*TabPohybyZbozi*/
	WHERE autor=SUSER_SNAME() AND IDVarianta IS NULL /*IDDoklad = @IDHlavicka*/
    SELECT ID, dilec, IDZakazka, mnozstvi, DatumTPVOrDnes, Skupina, IDZakazModif
	FROM tabZadVyp
	WHERE autor=SUSER_SNAME() AND IDVarianta IS NULL
*/
  --konec přepisu
  OPEN ZadVyp_RS 
  FETCH NEXT FROM ZadVyp_RS INTO @IDZadani, @dilec, @IDZakazka, @mnozstvi, @DatumTPV, @Skupina, @IDZakazModif 
  WHILE @@fetch_status=0 
    BEGIN 
      INSERT INTO #TabKusovnik_proZadVyp EXEC hp_generujQuickKusovnik @dilec,@mnozstvi,@DatumTPV, 1, 0, 1, 0, @RespekPlanZtratyPriVyrobeDilcu=@RespekPlanZtratyPriVyrobeDilcu, @DelitFixniMnozstviOptDavkou=@DelitFixniMnozstviOptDavkou, 
                                                                      @RespekNedelitMJ=@RespekNedelitMJ, @IDZakazModif=@IDZakazModif, @RespekDodatecneProcZtratKV=@RespekDodatecneProcZtratKV, @VcetneNulovychKV=@VcetneNulovychKV 
      INSERT INTO TabKusovnik_polozky(Final, IDFinal, IDKmenZbozi, IDZadani, IDZakazka, mnf, Skupina, RezijniMat, VyraditZKalkulace) 
        SELECT CASE WHEN Vyssi IS NULL THEN 1 ELSE 0 END, @dilec, IDKmenZbozi, @IDZadani, @IDZakazka, SUM(mnozstvi), @Skupina, RezijniMat, VyraditZKalkulace 
          FROM #TabKusovnik_proZadVyp 
          WHERE (@VcetneFinalu=1 OR Vyssi IS NOT NULL) 
          GROUP BY CASE WHEN Vyssi IS NULL THEN 1 ELSE 0 END, IDKmenZbozi, RezijniMat, VyraditZKalkulace 
      DELETE FROM #tabKusovnik_proZadVyp 
      FETCH NEXT FROM ZadVyp_RS INTO @IDZadani, @dilec, @IDZakazka, @mnozstvi, @DatumTPV, @Skupina, @IDZakazModif 
    END 
  CLOSE ZadVyp_RS 
  DEALLOCATE ZadVyp_RS 
  DROP TABLE #tabKusovnik_proZadVyp 

  DELETE TabParNapoctuZadVyp WHERE TypVypoctu=1 AND autor=SUSER_SNAME() 

  INSERT INTO TabParNapoctuZadVyp(TypVypoctu, RespekPlanZtratyPriVyrobeDilcu, DelitFixniMnozstviOptDavkou, KalkCenyKDnesku, RespekNedelitMJ, VcetneNulovychKV, RespekDodatecneProcZtratKV) 
    VALUES(1, @RespekPlanZtratyPriVyrobeDilcu, @DelitFixniMnozstviOptDavkou, @KalkCenyKDnesku, @RespekNedelitMJ, @VcetneNulovychKV, @RespekDodatecneProcZtratKV) 
  UPDATE TabKusovnik_polozky SET cena=ISNULL(KC_M.cena,KC.cena), cena1=ISNULL(KC_M.cena1,KC.cena1), cena2=ISNULL(KC_M.cena2,KC.cena2) 
    FROM TabKusovnik_polozky K 
      INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.material=1) 
      LEFT OUTER JOIN TabKalkCe KC_M ON (KC_M.IDKmenZbozi=K.IDKmenZbozi) 
      LEFT OUTER JOIN TabKalkCe KC ON (KC_M.ID IS NULL AND KC.IDKmenZbozi=K.IDKmenZbozi AND 
                                          EXISTS(SELECT * FROM tabczmeny ZodKC 
                                                   LEFT OUTER JOIN tabczmeny ZdoKC ON (ZDoKC.ID=KC.zmenaDo) 
                                                  WHERE ZodKC.ID=KC.zmenaOd AND ZodKC.platnostTPV=1 AND CASE WHEN @KalkCenyKDnesku=1 THEN @Dnes ELSE @DatumTPV END>=ZodKC.datum AND 
                                                        (KC.ZmenaDo IS NULL OR ZdoKC.platnostTPV=0 OR (ZDoKC.platnostTPV=1 AND CASE WHEN @KalkCenyKDnesku=1 THEN @Dnes ELSE @DatumTPV END<ZDoKC.datum)) 
                                  ) ) 
    WHERE K.Autor=SUSER_SNAME() AND K.VyraditZKalkulace=0
/* původní
      INNER JOIN TabZadVyp ZV ON (ZV.ID=K.IDZadani) 
      INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.material=1) 
      LEFT OUTER JOIN TabKalkCe KC_M ON (KC_M.IDKmenZbozi=K.IDKmenZbozi AND KC_M.IDZakazModif=ZV.IDZakazModif) 
      LEFT OUTER JOIN TabKalkCe KC ON (KC_M.ID IS NULL AND KC.IDKmenZbozi=K.IDKmenZbozi AND 
                                          EXISTS(SELECT * FROM tabczmeny ZodKC 
                                                   LEFT OUTER JOIN tabczmeny ZdoKC ON (ZDoKC.ID=KC.zmenaDo) 
                                                  WHERE ZodKC.ID=KC.zmenaOd AND ZodKC.platnostTPV=1 AND CASE WHEN @KalkCenyKDnesku=1 THEN @Dnes ELSE ZV.DatumTPVOrDnes END>=ZodKC.datum AND 
                                                        (KC.ZmenaDo IS NULL OR ZdoKC.platnostTPV=0 OR (ZDoKC.platnostTPV=1 AND CASE WHEN @KalkCenyKDnesku=1 THEN @Dnes ELSE ZV.DatumTPVOrDnes END<ZDoKC.datum)) 
                                  ) ) 
    WHERE K.Autor=SUSER_SNAME() AND K.VyraditZKalkulace=0
*/
  IF @KalkulaceJednotlivychPolozek=1 
    BEGIN 
      DECLARE crPolKusZV CURSOR FAST_FORWARD LOCAL FOR 
        SELECT K.ID, K.IDZadani, K.IDKmenZbozi, K.Mnf 
          FROM TabKusovnik_polozky K 
            INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND (KZ.dilec=1 OR KZ.Material=1)) 
          WHERE K.Autor=SUSER_SNAME() AND K.VyraditZKalkulace=0 
      OPEN crPolKusZV 
      FETCH NEXT FROM crPolKusZV INTO @RecID, @IDZadani, @Dilec, @Mnozstvi 
      WHILE @@fetch_status=0 
        BEGIN 
          EXEC @Ret=hp_VypocetKalkulacePolozky 1, @RecID, @IDZadani, @Dilec, @Mnozstvi, @IDKalkVzor, @RespekPlanZtratyPriVyrobeDilcu, @DelitFixniMnozstviOptDavkou, @KalkCenyKDnesku, @RespekNedelitMJ, @RespekDodatecneProcZtratKV 
          IF @@error<>0 OR @Ret<>0  GOTO CHYBA 
          FETCH NEXT FROM crPolKusZV INTO @RecID, @IDZadani, @Dilec, @Mnozstvi 
        END 
      CLOSE crPolKusZV 
      DEALLOCATE crPolKusZV 
    END 
  RETURN 0 
  CHYBA: 
    RETURN 1

--v rámci výpočtu souhrnného kusovníku proběhne ještě toto:
DECLARE @ID int 
SET @ID=0 
  UPDATE TabKusovnik_polozky SET Sklad=CASE 
              WHEN K.Final=1 THEN NULL 
              WHEN ParKmZbo.VychoziSklad IS NOT NULL THEN ParKmZbo.VychoziSklad 
              WHEN KZ.material=1 THEN S.cislo_V 
              ELSE S.cislo_M 
                               END 
    FROM TabKusovnik_polozky K 
      INNER JOIN TabZadVyp ZV ON (ZV.ID=K.IDZadani)
	  INNER JOIN TabKmenZbozi F ON (F.ID=K.IDFinal)
	  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi)
	  LEFT OUTER JOIN TabParametryKmeneZbozi ParKmZbo ON (ParKmZbo.IDKmenZbozi=K.IDKmenZbozi) 
      LEFT OUTER JOIN TabStrom S ON (S.cislo=ISNULL(ZV.KmenoveStredisko,F.KmenoveStredisko)) 
    WHERE K.autor = SUSER_SNAME()


/*
--toto je akce, která bude nad výsledným zobrazeným přehledem na pravé tl.myši
--spuštění souhrnného kusovníku v rámci skupiny plánu
CREATE TABLE dbo.#TabSouKusovProSkupinu(
ID INT IDENTITY NOT NULL,
IDKmenZbozi INT NULL,
mnf NUMERIC(19,6) NULL,
Skupina NVARCHAR(10) COLLATE database_default NULL,
Cena NUMERIC(19,6) NULL,
Cena1 NUMERIC(19,6) NULL,
Cena2 NUMERIC(19,6) NULL,
CCena AS (CONVERT(numeric(19,6),([Cena] * [mnf]))),
CCena1 AS (CONVERT(numeric(19,6),([Cena1] * [mnf]))),
CCena2 AS (CONVERT(numeric(19,6),([Cena2] * [mnf]))),
CONSTRAINT PK__#TabSouKusovProSkupinu__ID__51 PRIMARY KEY(ID))

INSERT INTO #TabSouKusovProSkupinu (Skupina, IDKmenZbozi, mnf, Cena, Cena1, Cena2) 
  SELECT Skupina, IDKmenZbozi, SUM(mnf), MAX(Cena), MAX(Cena1), MAX(Cena2) FROM TabKusovnik_polozky WHERE Autor=SUSER_SNAME() AND Final=0 GROUP BY Skupina, IDKmenZbozi

IF (OBJECT_ID(N'TempDB..#TabSouKusovProSkupinu' ) IS NOT NULL) SELECT 1 ELSE SELECT 0

SELECT
#TabSouKusovProSkupinu.ID,#TabSouKusovProSkupinu.IDKmenZbozi,VSouhrKusovProSkupinuSkPlanu.Skupina,VSouhrKusovProSkupinuKmenZbozi.SkupZbo,VSouhrKusovProSkupinuKmenZbozi.RegCis,VSouhrKusovProSkupinuKmenZbozi.Nazev1,#TabSouKusovProSkupinu.mnf,VSouhrKusovProSkupinuKmenZbozi.MJEvidence,VSouhrKusovProSkupinuKmenZbozi.CisloZbozi
FROM #TabSouKusovProSkupinu
  LEFT OUTER JOIN TabSkPlanu VSouhrKusovProSkupinuSkPlanu ON #TabSouKusovProSkupinu.Skupina=VSouhrKusovProSkupinuSkPlanu.Skupina AND (VSouhrKusovProSkupinuSkPlanu.Globalni=1 OR VSouhrKusovProSkupinuSkPlanu.IDVarianta IS NULL AND VSouhrKusovProSkupinuSkPlanu.autor=SUSER_SNAME())
  LEFT OUTER JOIN TabKmenZbozi VSouhrKusovProSkupinuKmenZbozi ON #TabSouKusovProSkupinu.IDKmenZbozi=VSouhrKusovProSkupinuKmenZbozi.ID
ORDER BY
9 ASC /* VSouhrKusovProSkupinuKmenZbozi.CisloZbozi */
*/
GO

