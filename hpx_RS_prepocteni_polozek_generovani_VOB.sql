USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_prepocteni_polozek_generovani_VOB]    Script Date: 26.06.2025 13:13:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_prepocteni_polozek_generovani_VOB] @IDradku INT
AS
SET NOCOUNT ON
--smažeme, pokud existuje dočasnou tabulku s budoucími pohyby
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB')IS NOT NULL
DROP TABLE #TabBudPohybyVOB
--vytvoříme dočasnou tabulku s označenými řádky
IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh')IS NULL
CREATE TABLE #TabOznacIDSS_GenBudPoh(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TabOznacIDSS_GenBudPoh
--naplníme tabulku ID z kmenových karet z označených řádků
DECLARE @IDPol INT
SET @IDPol=(SELECT tss.ID FROM TabStavSkladu tss WITH(NOLOCK) LEFT OUTER JOIN #TabBudPohyby ON tss.IDSklad='100' AND #TabBudPohyby.IDKmeneZbozi=tss.IDKmenZbozi WHERE #TabBudPohyby.ID=@IDradku)
--SET @IDPol=15248--7023
IF @IDPol IS NOT NULL  INSERT #TabOznacIDSS_GenBudPoh(ID)VALUES(@IDPol)

--vytvoříme další dočasnou tabulku s budoucími pohyby
--IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB')IS NULL
CREATE TABLE dbo.#TabBudPohybyVOB(
ID INT IDENTITY NOT NULL,
Generuj BIT NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__Generuj */DEFAULT 1,
IDPohyb INT NULL,
GUIDDosObjR BINARY(16) NULL,
IDPolKontraktu INT NULL,
IDTermOdvolavky INT NULL,
IDOdvolavky INT NULL,
IDPlan INT NULL,
IDPredPlan INT NULL,
PrKVDoklad INT NULL,
PrVPVDoklad INT NULL,
IDPlanPrikaz INT NULL,
IDPrikaz INT NULL,
IDGprUlohyMatZdroje INT NULL,
Oblast TINYINT NOT NULL,
Sklad NVARCHAR(30) COLLATE database_default NULL,
IDKmeneZbozi INT NOT NULL,
IDZakazModif INT NULL,
DatumPohybu_Pl DATETIME NULL,
DatumPohybu DATETIME NOT NULL,
PoradiPohybu INT NOT NULL /*CONSTRAINT DF__#TabBudPohybyVOB__PoradiPohybu*/ DEFAULT 1,
MnozstviNaSklade NUMERIC(19,6) NOT NULL /*CONSTRAINT DF__#TabBudPohybyVOB__MnozstviNaSklade */DEFAULT 0,
Mnozstvi_Pl NUMERIC(19,6) NOT NULL,
Mnozstvi NUMERIC(19,6) NOT NULL,
IDPolDodavKontraktu INT NULL,
Dodavatel INT NULL,
Objednat NUMERIC(19,6) NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__Objednat*/ DEFAULT 0,
generovano NUMERIC(19,6) NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__generovano*/ DEFAULT 0,
IDZakazka INT NULL,
DodaciLhuta INT NOT NULL /*CONSTRAINT DF__#TabBudPohybyVOB__DodaciLhuta*/ DEFAULT 0,
TypDodaciLhuty TINYINT NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__TypDodaciLhuty*/ DEFAULT 0,
LhutaNaskladneni INT NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__LhutaNaskladneni*/ DEFAULT 0,
PozadDatDod AS ([DatumPohybu] - [LhutaNaskladneni]),
)
CREATE NONCLUSTERED INDEX IX__#TabBudPohybyVOB__IDKmeneZbozi__Sklad__IDZakazka ON #TabBudPohybyVOB(IDKmeneZbozi,Sklad,IDZakazka) 
CREATE NONCLUSTERED INDEX IX__#TabBudPohybyVOB__Oblast ON #TabBudPohybyVOB(Oblast)
--nasypeme do tabulky s dočasnými pohyby řádky pohybů

DECLARE
 @Sklad nvarchar(50)='100', 
 @RespekMnozNaOstatSkladech bit=0, 
 @ZobrazitChybejiciKmenKarty bit=0, 
 @DoplnitPod int=0, 
 @TypStrediska int=0, 
 @R_prijemky bit=1, 
 @R_vydejky bit=1, 
 @R_EP bit=1, 
 @R_Rez bit=0, 
 @R_Obj bit=1, 
 @R_OdvPrijate bit=0, 
 @R_PredPlan int=0, 
 @R_Plan bit=1, 
 @R_VyrPrik bit=1, 
 @JenMaterialy bit=0, 
 @JenDilce bit=0, 
 @GenerovatNulovePohyby bit=1, 
 @ProSeznamKZ bit=0, 
 @R_OdvVydane bit=0, 
 @OkamziteDoplneniPojisZasob bit=0, 
 @R_DosObj bit=0, 
 @R_StornaPrijemek bit=0, 
 @R_StornaVydejek bit=0, 
 @TypFormulare int=6, 
 @R_AdvKP bit=0, 
 @R_ProjRizeni bit=0 

DECLARE @Ret int 
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB') IS NOT NULL AND COL_LENGTH(N'tempdb..#TabBudPohybyVOB', N'IDZakazModif') IS NULL  ALTER TABLE #TabBudPohybyVOB ADD IDZakazModif int NULL 
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB') IS NOT NULL AND COL_LENGTH(N'tempdb..#TabBudPohybyVOB', N'IDPlanPrikaz') IS NULL  ALTER TABLE #TabBudPohybyVOB ADD IDPlanPrikaz int NULL 
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB') IS NOT NULL AND COL_LENGTH(N'tempdb..#TabBudPohybyVOB', N'IDGprUlohyMatZdroje') IS NULL  ALTER TABLE #TabBudPohybyVOB ADD IDGprUlohyMatZdroje int NULL 

SET NOCOUNT ON 
DECLARE @SUSER_SNAME nvarchar(150), @DnesX datetime, @ProSeznamSS bit, 
        @PozadavekKP numeric(19,6), @DatumPozadavkuKP datetime, 
        @Pozadavek numeric(19,6), @Vykryto numeric(19,6), @VykrytoJemnouOdv numeric(19,6), @IDPolKontraktu int, @IDTermOdvolavky int, @IDOdvolavky int, 
        @SkladPozadavku nvarchar(30), @IDKmenZbozi int, @IDZakazModif int, @DatumPozadavku datetime, 
        @MasterOdv bit, @JemnaOdv bit, @IDZakazka int, @IDOrg int, @DodaciLhuta int, @TypDodaciLhuty TINYINT, @LhutaNaskladneni int, 
        @IDAdvKapacPlan int, @IDPrikaz int, @Doklad int, @RecID int, @MnozZad numeric(19,6), 
        @ZakazRozpaduPlanovaneVyroby bit 
SET @Sklad='100';
SET @RespekMnozNaOstatSkladech=0;
SET @ZobrazitChybejiciKmenKarty=0;
SET @DoplnitPod=0;
SET @TypStrediska=0;
SELECT @IDAdvKapacPlan=NULL, @SUSER_SNAME=SUSER_SNAME() 
EXEC hp_GetDnesniDatumX @DnesX OUT 

SET @ProSeznamSS= @ProSeznamKZ ^ 1 
IF NOT EXISTS(SELECT * FROM #TabOznacIDSS_GenBudPoh) SELECT @ProSeznamKZ=0, @ProSeznamSS=0 
SET @Sklad=ISNULL(@Sklad, '') 
IF @RespekMnozNaOstatSkladech=0 SET @ZobrazitChybejiciKmenKarty=0 
SET @ZakazRozpaduPlanovaneVyroby=0 

IF @R_Plan=1 AND @ZakazRozpaduPlanovaneVyroby=0 
  BEGIN 
    EXEC @Ret=hp_VyrPlan_VypocetPlanovaneVyroby @DuvodGenerovani=1 
   END 

IF @ProSeznamSS=1 AND @RespekMnozNaOstatSkladech=1 AND @Sklad<>'' 
  BEGIN 
    INSERT INTO #TabOznacIDSS_GenBudPoh(ID) 
      SELECT DISTINCT SS2.ID 
        FROM #TabOznacIDSS_GenBudPoh G 
          INNER JOIN TabStavSkladu SS ON (SS.ID=G.ID) 
          INNER JOIN TabStavSkladu SS2 ON (SS2.IDKmenZbozi=SS.IDKmenZbozi AND SS2.IDSklad<>SS.IDSklad) 
        WHERE NOT EXISTS(SELECT * FROM #TabOznacIDSS_GenBudPoh G2 WHERE G2.ID=SS2.ID) 
  END 

IF @R_prijemky=1 OR @R_StornaPrijemek=1 OR @R_vydejky=1 OR @R_StornaVydejek=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    INSERT INTO #TabBudPohybyVOB (IDPohyb, IDPolKontraktu, PrKVDoklad, PrVPVDoklad, IDPrikaz, IDGprUlohyMatZdroje, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, 
                               Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT PZ.ID, 
             IDPolKontraktu=CASE WHEN PZ.TypVyrobnihoDokladu IN (7,8) THEN PZ.IDPrikaz ELSE NULL END, 
             PrKVDoklad=CASE WHEN PZ.TypVyrobnihoDokladu IN (1,2) THEN PZ.DokladPrikazu ELSE NULL END, 
             PrVPVDoklad=CASE WHEN PZ.TypVyrobnihoDokladu=3 THEN PZ.DokladPrikazu ELSE NULL END, 
             IDPrikaz=CASE WHEN PZ.TypVyrobnihoDokladu IN (0,1,2,3) THEN PZ.IDPrikaz ELSE NULL END, 
             IDGprUlohyMatZdroje=NULL, 
             Oblast=CASE PZ.DruhPohybuZbo WHEN 0 THEN 1 
                                          WHEN 1 THEN 28 
                                          WHEN 2 THEN 21 
                                          WHEN 3 THEN 7 
                                          WHEN 4 THEN 21 
                    END, 
             S.cislo, KZ.ID, NULL, 
             DZ.DatPorizeni_X, ISNULL(DZ.DatPorizeni_X, @DnesX), 
             (CASE WHEN PZ.DruhPohybuZbo IN (0,3) THEN 1.0 ELSE -1.0 END) * (PZ.mnozstvi * PZ.PrepMnozstvi), 
             (CASE WHEN PZ.DruhPohybuZbo IN (0,3) THEN 1.0 ELSE -1.0 END) * (PZ.mnozstvi * PZ.PrepMnozstvi), 
             CO.ID, Z.ID, 
             KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabPohybyZbozi PZ 
          INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0 AND DZ.realizovano=0) 
          INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad AND SS.blokovano=0) 
          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=ISNULL(PZ.CisloZakazky, DZ.CisloZakazky)) 
        WHERE (@R_prijemky=1 AND PZ.DruhPohybuZbo=0 OR 
               @R_StornaPrijemek=1 AND PZ.DruhPohybuZbo=1 OR 
               @R_vydejky=1 AND PZ.DruhPohybuZbo IN (2,4) OR 
               @R_StornaVydejek=1 AND PZ.DruhPohybuZbo=3) AND 
              PZ.mnozstvi>0.0 AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 

IF @R_EP=1 OR @R_Rez=1 OR @R_Obj=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    CREATE TABLE #TabPomVykryteIntObjed(IDPohybu int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPohybu)) 
    IF @R_Obj=1 AND @JenMaterialy=0 AND (@R_PredPlan>0 OR @R_Plan=1 OR @R_VyrPrik=1) 
      BEGIN 
        INSERT INTO #TabPomVykryteIntObjed(IDPohybu, vykryto) 
          SELECT X.IDPohybu, SUM(X.vykryto) 
            FROM 
              (SELECT IDPohybu=P.IDRezervace, vykryto=P.mnozstvi 
                 FROM TabZadVyp P 
                  INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=P.IDRezervace AND PZ.druhPohybuZbo=6) 
                 WHERE @R_PredPlan>0 AND P.autor=@SUSER_SNAME AND P.IDVarianta IS NULL AND P.mnozstvi>0.0 AND P.IDRezervace>0 
               UNION ALL 
               SELECT IDPohybu=P.IDRezervace, vykryto=P.mnozNeprev 
                 FROM TabPlan P 
                  INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=P.IDRezervace AND PZ.druhPohybuZbo=6) 
                 WHERE @R_Plan=1 AND P.mnozNeprev>0.0 AND P.IDRezervace>0 
               UNION ALL 
               SELECT IDPohybu=P.IDRezervace, vykryto=CASE WHEN P.StavPrikazu<30 THEN P.kusy_ciste ELSE P.kusy_zive_ciste END 
                 FROM TabPrikaz P 
                  INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=P.IDRezervace AND PZ.druhPohybuZbo=6) 
                 WHERE @R_VyrPrik=1 AND (P.StavPrikazu<30 OR P.kusy_zive>0.0) AND P.IDRezervace>0 
              ) X 
            GROUP BY X.IDPohybu 
      END 
    INSERT INTO #TabBudPohybyVOB (IDPohyb, IDPolKontraktu, PrKVDoklad, PrVPVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, 
                               Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT PZ.ID, 
             CASE WHEN PZ.TypVyrobnihoDokladu IN (7,8) THEN PZ.IDPrikaz ELSE NULL END, 
             CASE WHEN PZ.TypVyrobnihoDokladu IN (1,2) THEN PZ.DokladPrikazu ELSE NULL END, 
             CASE WHEN PZ.TypVyrobnihoDokladu=3 THEN PZ.DokladPrikazu ELSE NULL END, 
             CASE WHEN PZ.TypVyrobnihoDokladu IN (0,1,2,3) THEN PZ.IDPrikaz ELSE NULL END, 
             CASE PZ.DruhPohybuZbo WHEN 6 THEN 0 
                                   WHEN 9 THEN 22 
                                   WHEN 10 THEN 23 
             END, 
             S.cislo, KZ.ID, PZ.IDZakazModif, 
             ISNULL(PZ.PotvrzDatDod_X, ISNULL(PZ.PozadDatDod_X, DZ.TerminDodavkyDat_X)) + (CASE WHEN PZ.DruhPohybuZbo=6 THEN KZ.LhutaNaskladneni ELSE 0 END), 
             ISNULL(ISNULL(PZ.PotvrzDatDod_X, ISNULL(PZ.PozadDatDod_X, DZ.TerminDodavkyDat_X)) + (CASE WHEN PZ.DruhPohybuZbo=6 THEN KZ.LhutaNaskladneni ELSE 0 END), @DnesX ), 
             (CASE WHEN PZ.DruhPohybuZbo=6 THEN 1.0 ELSE -1.0 END) * ((PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi - ISNULL(VIO.vykryto,0.0)), 
             (CASE WHEN PZ.DruhPohybuZbo=6 THEN 1.0 ELSE -1.0 END) * ((PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi - ISNULL(VIO.vykryto,0.0)), 
             CO.ID, Z.ID, 
             KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabPohybyZbozi PZ 
          INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0 AND DZ.splneno=0) 
          INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad AND SS.blokovano=0) 
          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=ISNULL(PZ.CisloZakazky, DZ.CisloZakazky)) 
          LEFT OUTER JOIN #TabPomVykryteIntObjed VIO ON (VIO.IDPohybu=PZ.ID) 
        WHERE (@R_EP=1 AND PZ.DruhPohybuZbo=9 OR 
               @R_Rez=1 AND PZ.DruhPohybuZbo=10 OR 
               @R_Obj=1 AND PZ.DruhPohybuZbo=6) AND 
              PZ.mnozstvi>PZ.MnOdebrane AND 
              (PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > ISNULL(VIO.vykryto,0.0) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    DROP TABLE #TabPomVykryteIntObjed 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 

IF @R_Plan=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    IF @JenMaterialy=0 
      BEGIN 
        INSERT INTO #TabBudPohybyVOB (IDPlan, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT P.ID, 3, 
                 S.cislo, KZ_Odv.ID, NULL, 
                 P.datum_X, P.datum_X,  
                 P.mnozNeprev, P.mnozNeprev, 
                 CO.ID, P.IDZakazka, 
                 KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
            FROM TabPlan P 
             INNER JOIN TabRadyPlanu RP ON (RP.Rada=P.Rada AND (RP.ZahrnoutDoBilancovaniBudPoh=1 OR RP.ZahrnoutDoBilancovaniBudPoh=2 AND @ZakazRozpaduPlanovaneVyroby=1)) 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
             --LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=P.IDTabKmen) 
             INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
             LEFT OUTER JOIN TabStrom KmenS ON (KmenS.cislo=ISNULL(P.KmenoveStredisko,KZ.KmenoveStredisko)) 
             LEFT OUTER JOIN TabStrom S ON (S.cislo=ISNULL(PD.VychoziSklad, CASE WHEN ISNULL(PD.TypDilce,1)=0 THEN KmenS.Cislo_H ELSE KmenS.Cislo_M END)) 
             LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ_Odv.ID) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
            WHERE P.mnozNeprev>0.0 AND P.Datum IS NOT NULL AND 
                  ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        IF @ZakazRozpaduPlanovaneVyroby=0 
          BEGIN 
            INSERT INTO #TabBudPohybyVOB (IDPlan, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
              SELECT PL.ID, PR.ID, 8, 
                     S.cislo, KZ_Odv.ID, NULL, 
                     PR.Plan_ukonceni_X, PR.Plan_ukonceni_X,  
                     PR.kusy_ciste, PR.kusy_ciste, 
                     CO.ID, PL.IDZakazka, 
                     KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
                FROM TabPlanPrikaz PR 
                 INNER JOIN TabPlan PL ON (PL.ID=PR.IDPlan AND PL.Datum IS NOT NULL) 
                 INNER JOIN TabRadyPlanu RP ON (RP.Rada=PL.Rada AND RP.ZahrnoutDoBilancovaniBudPoh=2) 
                 INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PR.IDTabKmen) 
                 --LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=PR.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
                 LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=PR.IDTabKmen) 
                 INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
                 LEFT OUTER JOIN TabStrom S ON (S.cislo=PR.Sklad) 
                 LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ_Odv.ID) 
                 LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
                WHERE ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                      (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                      (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
                      (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                      (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
          END 
      END 
    IF @ZakazRozpaduPlanovaneVyroby=0 
      BEGIN 
        INSERT INTO #TabBudPohybyVOB (IDPlan, IDPlanPrikaz, PrVPVDoklad, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT PL.ID, PR.ID, PrVPV.Doklad, 9, 
                 S.cislo, KZ.ID, NULL, 
                 PR.Plan_ukonceni_X, PR.Plan_ukonceni_X,  
                 PrVPV.mnoz_zad, PrVPV.mnoz_zad, 
                 CO.ID, PL.IDZakazka, 
                 KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
            FROM TabPlanPrVPVazby PrVPV 
             INNER JOIN TabPlan PL ON (PL.ID=PrVPV.IDPlan AND PL.Datum IS NOT NULL) 
             INNER JOIN TabRadyPlanu RP ON (RP.Rada=PL.Rada AND RP.ZahrnoutDoBilancovaniBudPoh=2) 
             INNER JOIN TabPlanPrikaz PR ON (PR.ID=PrVPV.IDPlanPrikaz) 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrVPV.VedProdukt AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             LEFT OUTER JOIN TabStrom S ON (S.cislo=PrVPV.Sklad) 
             LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
            WHERE ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        INSERT INTO #TabBudPohybyVOB (IDPlan, IDPlanPrikaz, PrKVDoklad, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT PL.ID, PR.ID, PrKV.Doklad, 29, 
                 S.cislo, KZ.ID, NULL, 
                 PR.Plan_zadani_X, PR.Plan_zadani_X, 
                 (-1.0)*PrKV.mnoz_zad, (-1.0)*PrKV.mnoz_zad, 
                 CO.ID, PL.IDZakazka, 
                 KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
            FROM TabPlanPrKVazby PrKV 
             INNER JOIN TabPlan PL ON (PL.ID=PrKV.IDPlan AND PL.Datum IS NOT NULL) 
             INNER JOIN TabRadyPlanu RP ON (RP.Rada=PL.Rada AND RP.ZahrnoutDoBilancovaniBudPoh=2) 
             INNER JOIN TabPlanPrikaz PR ON (PR.ID=PrKV.IDPlanPrikaz) 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrKV.nizsi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             --LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=PR.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabStrom S ON (S.cislo=PrKV.Sklad) 
             LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
            WHERE PrKV.RezijniMat=0 AND 
                  ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
      END 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_VyrPrik=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    CREATE TABLE #TabPomVykrytePrKV(IDPrikaz int NOT NULL, Doklad int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz,Doklad)) 
    IF (@R_vydejky=1 OR @R_EP=1 OR @R_Rez=1) 
      INSERT INTO #TabPomVykrytePrKV(IDPrikaz, Doklad, vykryto) 
        SELECT X.IDPrikaz, X.DokladPrikazu, SUM(X.vykryto) 
          FROM (SELECT PZ.IDPrikaz, PZ.DokladPrikazu, vykryto=(PZ.mnozstvi-PZ.mnOdebrane)*PZ.PrepMnozstvi * PrKV.RefMnoz/PrKV.mnoz_zad 
                  FROM TabPrikaz P 
                    INNER JOIN TabPohybyZbozi PZ ON (PZ.TypVyrobnihoDokladu=1 AND PZ.IDPrikaz=P.ID AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>PZ.mnOdebrane) 
                    INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.splneno=0) 
                    INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad) 
                    INNER JOIN TabPrKVazby PrKV ON (PrKV.IDPrikaz=PZ.IDPrikaz AND PrKV.Doklad=PZ.DokladPrikazu AND PrKV.nizsi=SS.IDKmenZbozi AND PrKV.IDOdchylkyDo IS NULL) 
                  WHERE P.kusy_zive>0.0 AND 
                        (@R_vydejky=1 AND PZ.DruhPohybuZbo IN (2,4) OR 
                         @R_EP=1 AND PZ.DruhPohybuZbo=9 OR 
                         @R_Rez=1 AND PZ.DruhPohybuZbo=10) 
               ) X 
          GROUP BY X.IDPrikaz, X.DokladPrikazu 
    DECLARE crSezPrKVBudPoh CURSOR FAST_FORWARD LOCAL FOR 
      SELECT P.ID, PrKV.Doklad, KZ.ID, S.cislo, NULL, P.Plan_zadani_X, 
             (PrKV.RefMnoz - PrKV.VydanoRefMnoz - ISNULL(VPoz.vykryto,0.0)), 
             CO.ID, P.IDZakazka, KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabPrKVazby PrKV 
          INNER JOIN TabPrikaz P ON (P.ID=PrKV.IDPrikaz AND P.kusy_zive>0.0) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrKV.nizsi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          --LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
          LEFT OUTER JOIN TabStrom S ON (S.cislo=PrKV.Sklad) 
          LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=PrKV.Sklad AND SS.IDKmenZbozi=PrKV.nizsi) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN #TabPomVykrytePrKV VPoz ON (VPoz.IDPrikaz=PrKV.IDPrikaz AND VPoz.Doklad=PrKV.Doklad) 
          WHERE PrKV.Splneno=0 AND PrKV.prednastaveno=1 AND PrKV.IDOdchylkyDo IS NULL AND 
                PrKV.RefMnoz > (PrKV.VydanoRefMnoz + ISNULL(VPoz.vykryto,0.0)) AND 
                ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
                (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    OPEN crSezPrKVBudPoh 
    FETCH NEXT FROM crSezPrKVBudPoh INTO @IDPrikaz, @Doklad, @IDKmenZbozi, @SkladPozadavku, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
    WHILE @@fetch_status=0 
      BEGIN 
        IF @R_AdvKP=1 
          BEGIN 
            DECLARE crSezDavekzKP CURSOR FAST_FORWARD LOCAL FOR 
              SELECT DatumX=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasOd)))), SUM(KPM.Mnoz_Nevydane) 
                FROM TabAdvKPMaterialy KPM 
                  INNER JOIN TabAdvKPDavky KPD ON (KPD.IDAdvKapacPlan=@IDAdvKapacPlan AND KPD.LocalID=KPM.LocalIDDavky) 
                WHERE KPM.IDAdvKapacPlan=@IDAdvKapacPlan AND KPM.IDPrikaz=@IDPrikaz AND KPM.DokladPrKVazby=@Doklad AND KPM.IDKmenZbozi=@IDKmenZbozi AND KPM.Mnoz_Nevydane>0.0 
                GROUP BY CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasOd))) 
                ORDER BY DatumX DESC 
            OPEN crSezDavekzKP 
            FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
            WHILE (@@fetch_status=0) AND (@Pozadavek>0.0) 
              BEGIN 
                IF @PozadavekKP > @Pozadavek  SET @PozadavekKP=@Pozadavek 
                INSERT INTO #TabBudPohybyVOB (PrKVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                  VALUES(@Doklad, @IDPrikaz, 26, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavkuKP, @DatumPozadavkuKP, -1.0 * @PozadavekKP, -1.0 * @PozadavekKP, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
                SET @Pozadavek = @Pozadavek - @PozadavekKP 
                FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
              END 
            CLOSE crSezDavekzKP 
            DEALLOCATE crSezDavekzKP 
          END 
        IF @Pozadavek > 0.0 
          INSERT INTO #TabBudPohybyVOB (PrKVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
            VALUES(@Doklad, @IDPrikaz, 26, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @DatumPozadavku, -1.0 * @Pozadavek, -1.0 * @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
        FETCH NEXT FROM crSezPrKVBudPoh INTO @IDPrikaz, @Doklad, @IDKmenZbozi, @SkladPozadavku, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
      END 
    CLOSE crSezPrKVBudPoh 
    DEALLOCATE crSezPrKVBudPoh 
    DROP TABLE #TabPomVykrytePrKV 
    CREATE TABLE #TabPomVykrytePrVPV(IDPrikaz int NOT NULL, Doklad int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz,Doklad)) 
    IF (@R_prijemky=1) 
      INSERT INTO #TabPomVykrytePrVPV(IDPrikaz, Doklad, vykryto) 
        SELECT PZ.IDPrikaz, PZ.DokladPrikazu, SUM(PZ.mnozstvi*PZ.PrepMnozstvi) 
          FROM TabPrikaz P 
            INNER JOIN TabPohybyZbozi PZ ON (PZ.TypVyrobnihoDokladu=3 AND PZ.IDPrikaz=P.ID AND PZ.druhPohybuZbo=0 AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>0.0) 
          WHERE P.kusy_zive>0.0 
          GROUP BY PZ.IDPrikaz, PZ.DokladPrikazu 
    DECLARE crSezPrVPVazebBudPoh CURSOR FAST_FORWARD LOCAL FOR 
      SELECT PrVPV.ID, P.ID, PrVPV.Doklad, S.cislo, KZ.ID, P.Plan_ukonceni_X, 
             PrVPV.mnoz_zustatkove - ISNULL(VPoz.vykryto,0.0), 
             CO.ID, P.IDZakazka, KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni, 
             PrVPV.mnoz_zad 
        FROM TabPrVPVazby PrVPV 
          INNER JOIN TabPrikaz P ON (P.ID=PrVPV.IDPrikaz AND P.kusy_zive>0.0) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrVPV.VedProdukt AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabStrom S ON (S.cislo=PrVPV.Sklad) 
          LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=PrVPV.Sklad AND SS.IDKmenZbozi=PrVPV.VedProdukt) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN #TabPomVykrytePrVPV VPoz ON (VPoz.IDPrikaz=PrVPV.IDPrikaz AND VPoz.Doklad=PrVPV.Doklad) 
        WHERE PrVPV.Splneno=0 AND PrVPV.IDOdchylkyDo IS NULL AND 
              PrVPV.mnoz_zustatkove > ISNULL(VPoz.vykryto,0.0) AND 
              ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
              (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    OPEN crSezPrVPVazebBudPoh 
    FETCH NEXT FROM crSezPrVPVazebBudPoh INTO @RecID, @IDPrikaz, @Doklad, @SkladPozadavku, @IDKmenZbozi, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni, @MnozZad 
    WHILE @@fetch_status=0 
      BEGIN 
        IF @R_AdvKP=1 
          BEGIN 
            DECLARE crSezDavekzKP CURSOR FAST_FORWARD LOCAL FOR 
              SELECT DatumX=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo)))), SUM(@MnozZad * KPD.Mnozstvi_Zive / PrP.Kusy_zad) 
                FROM TabPrPostup PrP 
                  INNER JOIN TabAdvKPDavky KPD ON (KPD.IDAdvKapacPlan=@IDAdvKapacPlan AND KPD.IDPrikaz=PrP.IDPrikaz AND KPD.DokladPrPostup=PrP.Doklad AND KPD.Mnozstvi_Zive>0.0) 
                WHERE PrP.IDPrikaz=@IDPrikaz AND PrP.Doklad=dbo.hf_GetPrPDokladForPrVPV(@RecID) AND PrP.prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL 
                GROUP BY CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo))) 
                ORDER BY DatumX DESC 
            OPEN crSezDavekzKP 
            FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
            WHILE (@@fetch_status=0) AND (@Pozadavek>0.0) 
              BEGIN 
                IF @PozadavekKP > @Pozadavek  SET @PozadavekKP=@Pozadavek 
                INSERT INTO #TabBudPohybyVOB (PrVPVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                  VALUES(@Doklad, @IDPrikaz, 5, @SkladPozadavku, @IDKmenZbozi, NULL, @DatumPozadavkuKP, @DatumPozadavkuKP, @PozadavekKP, @PozadavekKP, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
                SET @Pozadavek = @Pozadavek - @PozadavekKP 
                FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
              END 
            CLOSE crSezDavekzKP 
            DEALLOCATE crSezDavekzKP 
          END 
        IF @Pozadavek > 0.0 
          INSERT INTO #TabBudPohybyVOB (PrVPVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
            VALUES(@Doklad, @IDPrikaz, 5, @SkladPozadavku, @IDKmenZbozi, NULL, @DatumPozadavku, @DatumPozadavku, @Pozadavek, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
        FETCH NEXT FROM crSezPrVPVazebBudPoh INTO @RecID, @IDPrikaz, @Doklad, @SkladPozadavku, @IDKmenZbozi, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni, @MnozZad 
      END 
    CLOSE crSezPrVPVazebBudPoh 
    DEALLOCATE crSezPrVPVazebBudPoh 
    DROP TABLE #TabPomVykrytePrVPV 
    IF @JenMaterialy=0 
      BEGIN 
        CREATE TABLE #TabPomVykrytePrik(IDPrikaz int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz)) 
        IF (@R_prijemky=1) 
          INSERT INTO #TabPomVykrytePrik(IDPrikaz, vykryto) 
            SELECT PZ.IDPrikaz, SUM(PZ.mnozstvi*PZ.PrepMnozstvi) 
              FROM TabPrikaz P 
                INNER JOIN TabPohybyZbozi PZ ON (PZ.TypVyrobnihoDokladu=0 AND PZ.IDPrikaz=P.ID AND PZ.druhPohybuZbo=0 AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>0.0) 
              WHERE P.kusy_zive>0.0 
              GROUP BY PZ.IDPrikaz 
        DECLARE crSezPrikBudPoh CURSOR FAST_FORWARD LOCAL FOR 
          SELECT P.ID, S.Cislo, KZ_Odv.ID, NULL, P.Plan_ukonceni_X, 
                 CASE WHEN P.StavPrikazu<30 THEN P.kusy_ciste ELSE P.kusy_zive_ciste - ISNULL(VPoz.vykryto,0.0) END, 
                 CO.ID, P.IDZakazka, KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
            FROM TabPrikaz P 
              INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
              --LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
              LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=P.IDTabKmen) 
              INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
              LEFT OUTER JOIN TabStrom S ON (S.cislo=P.Sklad) 
              LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=P.Sklad AND SS.IDKmenZbozi=KZ_Odv.ID) 
              LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
              LEFT OUTER JOIN #TabPomVykrytePrik VPoz ON (VPoz.IDPrikaz=P.ID) 
            WHERE (P.StavPrikazu<30 OR P.kusy_zive_ciste>ISNULL(VPoz.vykryto,0.0)) AND 
                  ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        OPEN crSezPrikBudPoh 
        FETCH NEXT FROM crSezPrikBudPoh INTO @IDPrikaz, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
        WHILE @@fetch_status=0 
          BEGIN 
            IF @R_AdvKP=1 
              BEGIN 
                DECLARE crSezDavekzKP CURSOR FAST_FORWARD LOCAL FOR 
                  SELECT DatumX=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo)))), SUM(KPD.Mnozstvi_Zive) 
                    FROM TabPrPostup PrPO 
                      INNER JOIN TabAdvKPDavky KPD ON (KPD.IDAdvKapacPlan=@IDAdvKapacPlan AND KPD.IDPrikaz=PrPO.IDPrikaz AND KPD.DokladPrPostup=PrPO.Doklad AND KPD.Mnozstvi_Zive>0.0) 
                    WHERE PrPO.IDPrikaz=@IDPrikaz AND PrPO.Odvadeci=1 AND PrPO.prednastaveno=1 AND PrPO.IDOdchylkyDo IS NULL 
                    GROUP BY CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo))) 
                    ORDER BY DatumX DESC 
                OPEN crSezDavekzKP 
                FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
                WHILE (@@fetch_status=0) AND (@Pozadavek>0.0) 
                  BEGIN 
                    IF @PozadavekKP > @Pozadavek  SET @PozadavekKP=@Pozadavek 
                    INSERT INTO #TabBudPohybyVOB (IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                      VALUES(@IDPrikaz, 4, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavkuKP, @DatumPozadavkuKP, @PozadavekKP, @PozadavekKP, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
                    SET @Pozadavek = @Pozadavek - @PozadavekKP 
                    FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
                  END 
                CLOSE crSezDavekzKP 
                DEALLOCATE crSezDavekzKP 
              END 
            IF @Pozadavek > 0.0 
              INSERT INTO #TabBudPohybyVOB (IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                VALUES(@IDPrikaz, 4, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @DatumPozadavku, @Pozadavek, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
            FETCH NEXT FROM crSezPrikBudPoh INTO @IDPrikaz, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
          END 
        CLOSE crSezPrikBudPoh 
        DEALLOCATE crSezPrikBudPoh 
        DROP TABLE #TabPomVykrytePrik 
      END 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 

IF @GenerovatNulovePohyby=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    IF @RespekMnozNaOstatSkladech=1 
      INSERT INTO #TabBudPohybyVOB (Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT 20, 
                 MIN(ISNULL(SS0.IDSklad,SS.IDSklad)), SS.IDKmenZbozi, NULL, 
                 (CASE MAX(KZ.TypDodaciLhuty) WHEN 0 THEN DATEADD(day, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 1 THEN DATEADD(month, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 2 THEN DATEADD(year, MAX(KZ.DodaciLhuta), @DnesX) 
                  END + MAX(KZ.LhutaNaskladneni)), 
                 (CASE MAX(KZ.TypDodaciLhuty) WHEN 0 THEN DATEADD(day, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 1 THEN DATEADD(month, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 2 THEN DATEADD(year, MAX(KZ.DodaciLhuta), @DnesX) 
                  END + MAX(KZ.LhutaNaskladneni)), 
                 0.0, 0.0, 
                 MAX(CO.ID), 
                 MAX(KZ.DodaciLhuta), MAX(KZ.TypDodaciLhuty), MAX(KZ.LhutaNaskladneni) 
            FROM TabStavSkladu SS 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
             LEFT OUTER JOIN TabStavSkladu SS0 ON (SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad) 
            WHERE SS.blokovano=0 AND 
                  (S.Cislo=@sklad OR @ZobrazitChybejiciKmenKarty=1) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
            GROUP BY SS.IDKmenZbozi 
            HAVING NOT EXISTS(SELECT * FROM #TabBudPohybyVOB BP WHERE BP.IDKmeneZbozi=SS.IDKmenZbozi AND BP.mnozstvi<0.0 AND 
                                                                   (@OkamziteDoplneniPojisZasob=0 OR BP.DatumPohybu<=(CASE MAX(KZ.TypDodaciLhuty) WHEN 0 THEN DATEADD(day, MAX(KZ.DodaciLhuta), @DnesX) 
                                                                                                                                                     WHEN 1 THEN DATEADD(month, MAX(KZ.DodaciLhuta), @DnesX) 
                                                                                                                                                     WHEN 2 THEN DATEADD(year, MAX(KZ.DodaciLhuta), @DnesX) 
                                                                                                                         END + MAX(KZ.LhutaNaskladneni)) 
                                                                   )) AND 
                   (SELECT ISNULL(SUM(SS2.mnozstvi),0.0) - SUM(CASE @DoplnitPod WHEN 0 THEN SS2.minimum WHEN 1 THEN SS2.maximum WHEN 2 THEN 0.0 END) 
                       FROM TabStavSkladu SS2 
                         INNER JOIN TabStrom S2 ON (S2.cislo=SS2.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S2.TypStrediska=0 OR @TypStrediska=2 AND S2.TypStrediska IS NOT NULL)) 
                       WHERE SS2.IDKmenZbozi=SS.IDKmenZbozi AND SS2.Blokovano=0) 
                     < 0.0 
     ELSE 
      INSERT INTO #TabBudPohybyVOB (Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT 20, 
                 SS.IDSklad, SS.IDKmenZbozi, NULL, 
                 (CASE KZ.TypDodaciLhuty WHEN 0 THEN DATEADD(day, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 1 THEN DATEADD(month, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 2 THEN DATEADD(year, KZ.DodaciLhuta, @DnesX) 
                  END + KZ.LhutaNaskladneni), 
                 (CASE KZ.TypDodaciLhuty WHEN 0 THEN DATEADD(day, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 1 THEN DATEADD(month, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 2 THEN DATEADD(year, KZ.DodaciLhuta, @DnesX) 
                  END + KZ.LhutaNaskladneni), 
                 0.0, 0.0, 
                 CO.ID, 
                 KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
            FROM TabStavSkladu SS 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
            WHERE SS.blokovano=0 AND 
                  (S.Cislo=@sklad OR @sklad='') AND 
                  NOT EXISTS(SELECT * FROM #TabBudPohybyVOB BP WHERE BP.IDKmeneZbozi=SS.IDKmenZbozi AND BP.Sklad=SS.IDSklad AND BP.mnozstvi<0.0 AND 
                                                                  (@OkamziteDoplneniPojisZasob=0 OR BP.DatumPohybu<=(CASE KZ.TypDodaciLhuty WHEN 0 THEN DATEADD(day, KZ.DodaciLhuta, @DnesX) 
                                                                                                                                               WHEN 1 THEN DATEADD(month, KZ.DodaciLhuta, @DnesX) 
                                                                                                                                               WHEN 2 THEN DATEADD(year, KZ.DodaciLhuta, @DnesX) 
                                                                                                                        END + KZ.LhutaNaskladneni) 
                                                                  )) AND 
                  SS.mnozstvi - CASE @DoplnitPod WHEN 0 THEN SS.minimum WHEN 1 THEN SS.maximum WHEN 2 THEN 0.0 END < 0.0 AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 


--upravíme pořadí pohybů
--EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
DECLARE
 @RespekZakazky bit=0, 
 @UprednostnitPlusy bit=0, 
 @JenPro_IDKmeneZbozi int=NULL, 
 @JenPro_Sklad nvarchar(30)=NULL;
SET @RespekMnozNaOstatSkladech=0;

DECLARE @ID INT, @IDKmeneZbozi int, @DatumPohybu datetime, 
        @OldSklad nvarchar(50), @OldIDKmeneZbozi int, @OldPoradi int, @Poradi int 
SELECT @OldSklad='', @OldIDKmeneZbozi=0 
DECLARE crPoradi CURSOR FAST_FORWARD LOCAL FOR 
  SELECT BP.ID, BP.Sklad, BP.IDKmeneZbozi, BP.PoradiPohybu 
    FROM #TabBudPohybyVOB BP 
    WHERE (@JenPro_IDKmeneZbozi IS NULL OR BP.IDKmeneZbozi=@JenPro_IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR BP.Sklad=@JenPro_Sklad)) 
    ORDER BY BP.IDKmeneZbozi, CASE WHEN @RespekMnozNaOstatSkladech=0 THEN BP.Sklad END, 
             CASE WHEN @RespekZakazky=1 AND BP.IDZakazka>0 THEN (SELECT MIN(BP2.DatumPohybu) FROM #TabBudPohybyVOB BP2 WHERE BP2.IDKmeneZbozi=BP.IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR BP2.Sklad=BP.Sklad) AND BP2.IDZakazka=BP.IDZakazka) END ASC, 
             CASE WHEN @RespekZakazky=1 THEN BP.IDZakazka END, 
             CASE WHEN @UprednostnitPlusy=1 AND BP.mnozstvi>0.0 THEN 1 ELSE 2 END ASC, 
             BP.DatumPohybu ASC, BP.Oblast ASC 
OPEN crPoradi 
FETCH NEXT FROM crPoradi INTO @ID, @Sklad, @IDKmeneZbozi, @OldPoradi 
WHILE @@fetch_status=0 
  BEGIN 
    IF @OldIDKmeneZbozi<>@IDKmeneZbozi OR (@RespekMnozNaOstatSkladech=0 AND @OldSklad<>@Sklad) 
      SELECT @Poradi=1, @OldSklad=@Sklad, @OldIDKmeneZbozi=@IDKmeneZbozi 
    IF @OldPoradi<>@Poradi UPDATE #TabBudPohybyVOB SET PoradiPohybu=@Poradi WHERE ID=@ID 
    SET @Poradi=@Poradi+1 
    FETCH NEXT FROM crPoradi INTO @ID, @Sklad, @IDKmeneZbozi, @OldPoradi 
  END 
CLOSE crPoradi 
DEALLOCATE crPoradi

--upravíme virtuální množství
--EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0

DECLARE @MnozPohybu numeric(19,6), @VirtSS numeric(19,6) 
SET @RespekMnozNaOstatSkladech=0;
SET @TypStrediska=0;
SET @JenPro_IDKmeneZbozi=NULL;
SET @JenPro_Sklad=NULL;
SELECT @OldSklad='', @OldIDKmeneZbozi=0 
DECLARE crVirtSS CURSOR FAST_FORWARD LOCAL FOR 
  SELECT BP.ID, BP.Sklad, BP.IDKmeneZbozi, BP.mnozstvi+BP.Objednat+BP.Generovano 
    FROM #TabBudPohybyVOB BP 
    WHERE (@JenPro_IDKmeneZbozi IS NULL OR BP.IDKmeneZbozi=@JenPro_IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR BP.Sklad=@JenPro_Sklad)) 
    ORDER BY BP.IDKmeneZbozi, CASE WHEN @RespekMnozNaOstatSkladech=0 THEN BP.Sklad END, BP.PoradiPohybu ASC 
OPEN crVirtSS 
FETCH NEXT FROM crVirtSS INTO @ID, @Sklad, @IDKmeneZbozi, @MnozPohybu 
WHILE @@fetch_status=0 
  BEGIN 
    IF @OldIDKmeneZbozi<>@IDKmeneZbozi OR (@RespekMnozNaOstatSkladech=0 AND @OldSklad<>@Sklad) 
      SELECT @OldSklad=@Sklad, @OldIDKmeneZbozi=@IDKmeneZbozi, 
             @VirtSS=(SELECT ISNULL(SUM(SS.mnozstvi),0) 
                        FROM TabStavSkladu SS 
                          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
                        WHERE SS.IDKmenZbozi=@IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR SS.IDSklad=@sklad) AND SS.Blokovano=0) 
    SET @VirtSS=@VirtSS+@MnozPohybu 
    UPDATE #TabBudPohybyVOB SET MnozstviNaSklade=@VirtSS WHERE ID=@ID 
    FETCH NEXT FROM crVirtSS INTO @ID, @Sklad, @IDKmeneZbozi, @MnozPohybu 
  END 
CLOSE crVirtSS 
DEALLOCATE crVirtSS

DECLARE @DatPohybu_new DATETIME, @IDZak INT, @CisloZak NVARCHAR(15)
SET @IDZak=(SELECT x.IDZakazka
FROM (SELECT tkz.SkupZbo,tkz.RegCis,tbp.IDKmeneZbozi,tbp.ID,tbp.IDPohyb,tbp.Oblast,tbp.Sklad,tbp.IDZakazka,tbp.DatumPohybu,tbp.PoradiPohybu,tbp.MnozstviNaSklade,ROW_NUMBER() OVER (ORDER BY tbp.PoradiPohybu) AS rn
FROM #TabBudPohybyVOB tbp
LEFT OUTER JOIN TabKmenZbozi tkz ON tbp.IDKmeneZbozi=tkz.ID
WHERE tbp.MnozstviNaSklade<0) x
WHERE x.rn=1);
SET @DatPohybu_new=(SELECT x.DatumPohybu
FROM (SELECT tkz.SkupZbo,tkz.RegCis,tbp.IDKmeneZbozi,tbp.ID,tbp.IDPohyb,tbp.Oblast,tbp.Sklad,tbp.IDZakazka,tbp.DatumPohybu,tbp.PoradiPohybu,tbp.MnozstviNaSklade,ROW_NUMBER() OVER (ORDER BY tbp.PoradiPohybu) AS rn
FROM #TabBudPohybyVOB tbp
LEFT OUTER JOIN TabKmenZbozi tkz ON tbp.IDKmeneZbozi=tkz.ID
WHERE tbp.MnozstviNaSklade<0) x
WHERE x.rn=1);
SET @CisloZak=(SELECT CisloZakazky FROM Tabzakazka WHERE ID=@IDZak);

IF @DatPohybu_new IS NOT NULL
UPDATE #TabBudPohyby SET #TabBudPohyby.DatumPohybu=@DatPohybu_new,#TabBudPohyby.IDZakazka=@IDZak WHERE #TabBudPohyby.ID=@IDradku




--původní kód
/*
ALTER PROCEDURE [dbo].[hpx_RS_prepocteni_polozek_generovani_VOB] @IDradku INT
AS
--smažeme, pokud existuje dočasnou tabulku s budoucími pohyby
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB')IS NOT NULL
DROP TABLE #TabBudPohybyVOB
--vytvoříme dočasnou tabulku s označenými řádky
IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh')IS NULL
CREATE TABLE #TabOznacIDSS_GenBudPoh(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TabOznacIDSS_GenBudPoh
--naplníme tabulku ID z kmenových karet z označených řádků
BEGIN TRAN
DECLARE @IDPol INT
SET @IDPol=(SELECT tss.ID FROM TabStavSkladu tss WITH(NOLOCK) LEFT OUTER JOIN #TabBudPohyby ON tss.IDSklad='100' AND #TabBudPohyby.IDKmeneZbozi=tss.IDKmenZbozi WHERE #TabBudPohyby.ID=@IDradku)
--SET @IDPol=15248--7023
IF @IDPol IS NOT NULL  INSERT #TabOznacIDSS_GenBudPoh(ID)VALUES(@IDPol)
/*
SET @ID=56
IF @ID IS NOT NULL  INSERT #TabOznacIDSS_GenBudPoh(ID)VALUES(@ID)
SET @ID=26939
IF @ID IS NOT NULL  INSERT #TabOznacIDSS_GenBudPoh(ID)VALUES(@ID)*/
COMMIT
--vytvoříme další dočasnou tabulku s budoucími pohyby
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB')IS NULL
CREATE TABLE dbo.#TabBudPohybyVOB(
ID INT IDENTITY NOT NULL,
Generuj BIT NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__Generuj */DEFAULT 1,
IDPohyb INT NULL,
GUIDDosObjR BINARY(16) NULL,
IDPolKontraktu INT NULL,
IDTermOdvolavky INT NULL,
IDOdvolavky INT NULL,
IDPlan INT NULL,
IDPredPlan INT NULL,
PrKVDoklad INT NULL,
PrVPVDoklad INT NULL,
IDPlanPrikaz INT NULL,
IDPrikaz INT NULL,
IDGprUlohyMatZdroje INT NULL,
Oblast TINYINT NOT NULL,
Sklad NVARCHAR(30) COLLATE database_default NULL,
IDKmeneZbozi INT NOT NULL,
IDZakazModif INT NULL,
DatumPohybu_Pl DATETIME NULL,
DatumPohybu DATETIME NOT NULL,
PoradiPohybu INT NOT NULL /*CONSTRAINT DF__#TabBudPohybyVOB__PoradiPohybu*/ DEFAULT 1,
MnozstviNaSklade NUMERIC(19,6) NOT NULL /*CONSTRAINT DF__#TabBudPohybyVOB__MnozstviNaSklade */DEFAULT 0,
Mnozstvi_Pl NUMERIC(19,6) NOT NULL,
Mnozstvi NUMERIC(19,6) NOT NULL,
IDPolDodavKontraktu INT NULL,
Dodavatel INT NULL,
Objednat NUMERIC(19,6) NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__Objednat*/ DEFAULT 0,
generovano NUMERIC(19,6) NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__generovano*/ DEFAULT 0,
IDZakazka INT NULL,
DodaciLhuta INT NOT NULL /*CONSTRAINT DF__#TabBudPohybyVOB__DodaciLhuta*/ DEFAULT 0,
TypDodaciLhuty TINYINT NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__TypDodaciLhuty*/ DEFAULT 0,
LhutaNaskladneni INT NOT NULL/* CONSTRAINT DF__#TabBudPohybyVOB__LhutaNaskladneni*/ DEFAULT 0,
DatumPohybu_Pl_D AS (DATEPART(DAY,[DatumPohybu_Pl])),
DatumPohybu_Pl_M AS (DATEPART(MONTH,[DatumPohybu_Pl])),
DatumPohybu_Pl_Y AS (DATEPART(YEAR,[DatumPohybu_Pl])),
DatumPohybu_Pl_Q AS (DATEPART(QUARTER,[DatumPohybu_Pl])),
DatumPohybu_Pl_W AS (DATEPART(WEEK,[DatumPohybu_Pl])),
DatumPohybu_Pl_X AS (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,[DatumPohybu_Pl])))),
DatumPohybu_D AS (DATEPART(DAY,[DatumPohybu])),
DatumPohybu_M AS (DATEPART(MONTH,[DatumPohybu])),
DatumPohybu_Y AS (DATEPART(YEAR,[DatumPohybu])),
DatumPohybu_Q AS (DATEPART(QUARTER,[DatumPohybu])),
DatumPohybu_W AS (DATEPART(WEEK,[DatumPohybu])),
DatumPohybu_X AS (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,[DatumPohybu])))),
ZmenaDatumuPohybu AS (CONVERT(bit,CASE WHEN (ISNULL([DatumPohybu],0) = ISNULL([DatumPohybu_Pl],0)) THEN 0 ELSE 1 END)),
ZmenaMnozstvi AS (CONVERT(bit,CASE WHEN ([Mnozstvi] = [Mnozstvi_Pl]) THEN 0 ELSE 1 END)),
DatumObjednani AS (CASE [TypDodaciLhuty] WHEN 0 THEN DATEADD(day, -1 * [DodaciLhuta], [DatumPohybu])  WHEN 1 THEN DATEADD(month, -1 * [DodaciLhuta], [DatumPohybu])  WHEN 2 THEN DATEADD(year, -1 * [DodaciLhuta], [DatumPohybu]) END - [LhutaNaskladneni]),
PozadDatDod AS ([DatumPohybu] - [LhutaNaskladneni]),
--CONSTRAINT PK__#TabBudPohybyVOB__ID PRIMARY KEY(ID),
--CONSTRAINT CK__#TabBudPohybyVOB__Objednat CHECK(Objednat >=0)
)
CREATE NONCLUSTERED INDEX IX__#TabBudPohybyVOB__IDKmeneZbozi__Sklad__IDZakazka ON #TabBudPohybyVOB(IDKmeneZbozi,Sklad,IDZakazka) 
CREATE NONCLUSTERED INDEX IX__#TabBudPohybyVOB__Oblast ON #TabBudPohybyVOB(Oblast)
--nasypeme do tabulky s dočasnými pohyby řádky pohybů
--EXEC hp_GenerovaniBudPohybu N'100', 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 6, 0, 0

DECLARE
 @Sklad nvarchar(50)='100', 
 @RespekMnozNaOstatSkladech bit=0, 
 @ZobrazitChybejiciKmenKarty bit=0, 
 @DoplnitPod int=0, 
 @TypStrediska int=0, 
 @R_prijemky bit=1, 
 @R_vydejky bit=1, 
 @R_EP bit=1, 
 @R_Rez bit=0, 
 @R_Obj bit=1, 
 @R_OdvPrijate bit=0, 
 @R_PredPlan int=0, 
 @R_Plan bit=1, 
 @R_VyrPrik bit=1, 
 @JenMaterialy bit=0, 
 @JenDilce bit=0, 
 @GenerovatNulovePohyby bit=1, 
 @ProSeznamKZ bit=0, 
 @R_OdvVydane bit=0, 
 @OkamziteDoplneniPojisZasob bit=0, 
 @R_DosObj bit=0, 
 @R_StornaPrijemek bit=0, 
 @R_StornaVydejek bit=0, 
 @TypFormulare int=6, 
 @R_AdvKP bit=0, 
 @R_ProjRizeni bit=0 

SET NOCOUNT ON 
DECLARE @Ret int 
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB') IS NOT NULL AND COL_LENGTH(N'tempdb..#TabBudPohybyVOB', N'IDZakazModif') IS NULL  ALTER TABLE #TabBudPohybyVOB ADD IDZakazModif int NULL 
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB') IS NOT NULL AND COL_LENGTH(N'tempdb..#TabBudPohybyVOB', N'IDPlanPrikaz') IS NULL  ALTER TABLE #TabBudPohybyVOB ADD IDPlanPrikaz int NULL 
IF OBJECT_ID(N'tempdb..#TabBudPohybyVOB') IS NOT NULL AND COL_LENGTH(N'tempdb..#TabBudPohybyVOB', N'IDGprUlohyMatZdroje') IS NULL  ALTER TABLE #TabBudPohybyVOB ADD IDGprUlohyMatZdroje int NULL 

SET NOCOUNT ON 
DECLARE @SUSER_SNAME nvarchar(150), @DnesX datetime, @ProSeznamSS bit, 
        @PozadavekKP numeric(19,6), @DatumPozadavkuKP datetime, 
        @Pozadavek numeric(19,6), @Vykryto numeric(19,6), @VykrytoJemnouOdv numeric(19,6), @IDPolKontraktu int, @IDTermOdvolavky int, @IDOdvolavky int, 
        @SkladPozadavku nvarchar(30), @IDKmenZbozi int, @IDZakazModif int, @DatumPozadavku datetime, 
        @MasterOdv bit, @JemnaOdv bit, @IDZakazka int, @IDOrg int, @DodaciLhuta int, @TypDodaciLhuty TINYINT, @LhutaNaskladneni int, 
        @IDAdvKapacPlan int, @IDPrikaz int, @Doklad int, @RecID int, @MnozZad numeric(19,6), 
        @ZakazRozpaduPlanovaneVyroby bit 
SET @Sklad='100';
SET @RespekMnozNaOstatSkladech=0;
SET @ZobrazitChybejiciKmenKarty=0;
SET @DoplnitPod=0;
SET @TypStrediska=0;
SELECT @IDAdvKapacPlan=NULL, @SUSER_SNAME=SUSER_SNAME() 
EXEC hp_GetDnesniDatumX @DnesX OUT 
--IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh') IS NULL   CREATE TABLE #TabOznacIDSS_GenBudPoh(ID INT NOT NULL PRIMARY KEY) 
SET @ProSeznamSS= @ProSeznamKZ ^ 1 
IF NOT EXISTS(SELECT * FROM #TabOznacIDSS_GenBudPoh) SELECT @ProSeznamKZ=0, @ProSeznamSS=0 
SET @Sklad=ISNULL(@Sklad, '') 
IF @RespekMnozNaOstatSkladech=0 SET @ZobrazitChybejiciKmenKarty=0 
SET @ZakazRozpaduPlanovaneVyroby=0 
IF @R_Plan=1 AND @ZakazRozpaduPlanovaneVyroby=0 
  BEGIN 
    EXEC @Ret=hp_VyrPlan_VypocetPlanovaneVyroby @DuvodGenerovani=1 
 --   IF @@error<>0 RETURN 1 
  END 
IF @R_VyrPrik=1 AND @R_AdvKP=1 
  BEGIN 
    SELECT @IDAdvKapacPlan=MIN(ID) FROM TabAdvKapacPlan WHERE Aktivni=1 
    IF @IDAdvKapacPlan>0 
      BEGIN 
        EXEC @Ret=hp_AdvKPAktualizaceStavuOperaci @IDAdvKapacPlan 
 --       IF @@error<>0 OR @Ret<>0 RETURN 1 
      END  ELSE  SET @R_AdvKP=0 
  END 
IF @ProSeznamSS=1 AND @RespekMnozNaOstatSkladech=1 AND @Sklad<>'' 
  BEGIN 
    INSERT INTO #TabOznacIDSS_GenBudPoh(ID) 
      SELECT DISTINCT SS2.ID 
        FROM #TabOznacIDSS_GenBudPoh G 
          INNER JOIN TabStavSkladu SS ON (SS.ID=G.ID) 
          INNER JOIN TabStavSkladu SS2 ON (SS2.IDKmenZbozi=SS.IDKmenZbozi AND SS2.IDSklad<>SS.IDSklad) 
        WHERE NOT EXISTS(SELECT * FROM #TabOznacIDSS_GenBudPoh G2 WHERE G2.ID=SS2.ID) 
  END 
IF @R_prijemky=1 OR @R_StornaPrijemek=1 OR @R_vydejky=1 OR @R_StornaVydejek=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    INSERT INTO #TabBudPohybyVOB (IDPohyb, IDPolKontraktu, PrKVDoklad, PrVPVDoklad, IDPrikaz, IDGprUlohyMatZdroje, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, 
                               Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT PZ.ID, 
             IDPolKontraktu=CASE WHEN PZ.TypVyrobnihoDokladu IN (7,8) THEN PZ.IDPrikaz ELSE NULL END, 
             PrKVDoklad=CASE WHEN PZ.TypVyrobnihoDokladu IN (1,2) THEN PZ.DokladPrikazu ELSE NULL END, 
             PrVPVDoklad=CASE WHEN PZ.TypVyrobnihoDokladu=3 THEN PZ.DokladPrikazu ELSE NULL END, 
             IDPrikaz=CASE WHEN PZ.TypVyrobnihoDokladu IN (0,1,2,3) THEN PZ.IDPrikaz ELSE NULL END, 
             IDGprUlohyMatZdroje=(SELECT MAX(VN.IDGprUlohyMatZdroje) FROM TabGprNavazneDoklady ND INNER JOIN TabGprVykazNakladuMatZdr VN ON (VN.ID = ND.IDZdroje) WHERE ND.IDPolozkyDokladu=PZ.ID AND ND.TypZdroje=3), 
             Oblast=CASE PZ.DruhPohybuZbo WHEN 0 THEN 1 
                                          WHEN 1 THEN 28 
                                          WHEN 2 THEN 21 
                                          WHEN 3 THEN 7 
                                          WHEN 4 THEN 21 
                    END, 
             S.cislo, KZ.ID, PZ.IDZakazModif, 
             DZ.DatPorizeni_X, ISNULL(DZ.DatPorizeni_X, @DnesX), 
             (CASE WHEN PZ.DruhPohybuZbo IN (0,3) THEN 1.0 ELSE -1.0 END) * (PZ.mnozstvi * PZ.PrepMnozstvi), 
             (CASE WHEN PZ.DruhPohybuZbo IN (0,3) THEN 1.0 ELSE -1.0 END) * (PZ.mnozstvi * PZ.PrepMnozstvi), 
             CO.ID, Z.ID, 
             KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabPohybyZbozi PZ 
          INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0 AND DZ.realizovano=0) 
          INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad AND SS.blokovano=0) 
          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=ISNULL(PZ.CisloZakazky, DZ.CisloZakazky)) 
        WHERE (@R_prijemky=1 AND PZ.DruhPohybuZbo=0 OR 
               @R_StornaPrijemek=1 AND PZ.DruhPohybuZbo=1 OR 
               @R_vydejky=1 AND PZ.DruhPohybuZbo IN (2,4) OR 
               @R_StornaVydejek=1 AND PZ.DruhPohybuZbo=3) AND 
              PZ.mnozstvi>0.0 AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_EP=1 OR @R_Rez=1 OR @R_Obj=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    CREATE TABLE #TabPomVykryteIntObjed(IDPohybu int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPohybu)) 
    IF @R_Obj=1 AND @JenMaterialy=0 AND (@R_PredPlan>0 OR @R_Plan=1 OR @R_VyrPrik=1) 
      BEGIN 
        INSERT INTO #TabPomVykryteIntObjed(IDPohybu, vykryto) 
          SELECT X.IDPohybu, SUM(X.vykryto) 
            FROM 
              (SELECT IDPohybu=P.IDRezervace, vykryto=P.mnozstvi 
                 FROM TabZadVyp P 
                  INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=P.IDRezervace AND PZ.druhPohybuZbo=6) 
                 WHERE @R_PredPlan>0 AND P.autor=@SUSER_SNAME AND P.IDVarianta IS NULL AND P.mnozstvi>0.0 AND P.IDRezervace>0 
               UNION ALL 
               SELECT IDPohybu=P.IDRezervace, vykryto=P.mnozNeprev 
                 FROM TabPlan P 
                  INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=P.IDRezervace AND PZ.druhPohybuZbo=6) 
                 WHERE @R_Plan=1 AND P.mnozNeprev>0.0 AND P.IDRezervace>0 
               UNION ALL 
               SELECT IDPohybu=P.IDRezervace, vykryto=CASE WHEN P.StavPrikazu<30 THEN P.kusy_ciste ELSE P.kusy_zive_ciste END 
                 FROM TabPrikaz P 
                  INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=P.IDRezervace AND PZ.druhPohybuZbo=6) 
                 WHERE @R_VyrPrik=1 AND (P.StavPrikazu<30 OR P.kusy_zive>0.0) AND P.IDRezervace>0 
              ) X 
            GROUP BY X.IDPohybu 
      END 
    INSERT INTO #TabBudPohybyVOB (IDPohyb, IDPolKontraktu, PrKVDoklad, PrVPVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, 
                               Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT PZ.ID, 
             CASE WHEN PZ.TypVyrobnihoDokladu IN (7,8) THEN PZ.IDPrikaz ELSE NULL END, 
             CASE WHEN PZ.TypVyrobnihoDokladu IN (1,2) THEN PZ.DokladPrikazu ELSE NULL END, 
             CASE WHEN PZ.TypVyrobnihoDokladu=3 THEN PZ.DokladPrikazu ELSE NULL END, 
             CASE WHEN PZ.TypVyrobnihoDokladu IN (0,1,2,3) THEN PZ.IDPrikaz ELSE NULL END, 
             CASE PZ.DruhPohybuZbo WHEN 6 THEN 0 
                                   WHEN 9 THEN 22 
                                   WHEN 10 THEN 23 
             END, 
             S.cislo, KZ.ID, PZ.IDZakazModif, 
             ISNULL(PZ.PotvrzDatDod_X, ISNULL(PZ.PozadDatDod_X, DZ.TerminDodavkyDat_X)) + (CASE WHEN PZ.DruhPohybuZbo=6 THEN KZ.LhutaNaskladneni ELSE 0 END), 
             ISNULL(ISNULL(PZ.PotvrzDatDod_X, ISNULL(PZ.PozadDatDod_X, DZ.TerminDodavkyDat_X)) + (CASE WHEN PZ.DruhPohybuZbo=6 THEN KZ.LhutaNaskladneni ELSE 0 END), @DnesX ), 
             (CASE WHEN PZ.DruhPohybuZbo=6 THEN 1.0 ELSE -1.0 END) * ((PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi - ISNULL(VIO.vykryto,0.0)), 
             (CASE WHEN PZ.DruhPohybuZbo=6 THEN 1.0 ELSE -1.0 END) * ((PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi - ISNULL(VIO.vykryto,0.0)), 
             CO.ID, Z.ID, 
             KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabPohybyZbozi PZ 
          INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0 AND DZ.splneno=0) 
          INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad AND SS.blokovano=0) 
          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=ISNULL(PZ.CisloZakazky, DZ.CisloZakazky)) 
          LEFT OUTER JOIN #TabPomVykryteIntObjed VIO ON (VIO.IDPohybu=PZ.ID) 
        WHERE (@R_EP=1 AND PZ.DruhPohybuZbo=9 OR 
               @R_Rez=1 AND PZ.DruhPohybuZbo=10 OR 
               @R_Obj=1 AND PZ.DruhPohybuZbo=6) AND 
              PZ.mnozstvi>PZ.MnOdebrane AND 
              (PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > ISNULL(VIO.vykryto,0.0) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    DROP TABLE #TabPomVykryteIntObjed 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_DosObj=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    CREATE TABLE #TabPomVykryteDosObj(IDDosObjR int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDDosObjR)) 
    IF (@R_vydejky=1 OR @R_EP=1 OR @R_Rez=1) 
      INSERT INTO #TabPomVykryteDosObj(IDDosObjR, vykryto) 
        SELECT ND.IDDoslaObjR, SUM((PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi) 
          FROM TabDosleObjNavazDok02 ND 
            INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=ND.IDNavazPol AND PZ.DruhPohybuZbo=ND.DruhPohybuZbo AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>PZ.MnOdebrane) 
            INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.Splneno=0) 
          WHERE (@R_vydejky=1 AND ND.DruhPohybuZbo IN (2,4) OR 
                 @R_EP=1 AND ND.DruhPohybuZbo=9 OR 
                 @R_Rez=1 AND ND.DruhPohybuZbo=10) 
          GROUP BY ND.IDDoslaObjR 
    INSERT INTO #TabBudPohybyVOB (GUIDDosObjR, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT R.GUIDPolozky, 27, S.cislo, KZ.ID, R.IDZakazModif, 
             ISNULL(R.PotvrzDatDod_X, ISNULL(R.PozadDatDod_X, H.DatumDodavky_X)), 
             ISNULL( ISNULL(R.PotvrzDatDod_X, ISNULL(R.PozadDatDod_X, H.DatumDodavky_X)), @DnesX ), 
             (-1.0)*((R.mnozstvi-R.MnozstviRealVydej)*R.PrepMnozstvi - ISNULL(VDO.vykryto,0.0)), 
             (-1.0)*((R.mnozstvi-R.MnozstviRealVydej)*R.PrepMnozstvi - ISNULL(VDO.vykryto,0.0)), 
             CO.ID, ISNULL(R.IDZakazka, H.IDZakazka), 
             KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabDosleObjR02 R 
          INNER JOIN TabDosleObjH02 H ON (H.ID=R.IDHlava) 
          INNER JOIN TabStavSkladu SS ON (SS.ID=R.IDZboSklad AND SS.blokovano=0) 
          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN #TabPomVykryteDosObj VDO ON (VDO.IDDosObjR=R.ID) 
        WHERE R.JeStin=0 AND R.Splneno=0 AND 
              (R.mnozstvi-R.MnozstviRealVydej)*R.PrepMnozstvi > ISNULL(VDO.vykryto,0.0) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    DROP TABLE #TabPomVykryteDosObj 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_OdvPrijate=1 OR @R_OdvVydane=1 
  BEGIN 
    CREATE TABLE #TabPomVykrytePolKontr(IDPolKontraktu int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPolKontraktu)) 
    CREATE TABLE #TabPomVykrytePKJemnouOdv(IDPolKontraktu int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPolKontraktu)) 
    IF @R_OdvPrijate=1 AND (@R_vydejky=1 OR @R_EP=1 OR @R_Rez=1) 
      INSERT INTO #TabPomVykrytePolKontr(IDPolKontraktu, vykryto) 
        SELECT PZ.IDPrikaz, SUM((PZ.mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi) 
          FROM TabPohybyZbozi PZ WITH(READUNCOMMITTED) 
            INNER JOIN TabDokladyZbozi DZ WITH(READUNCOMMITTED) ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0 AND DZ.splneno=0) 
            INNER JOIN TabParPolKontr ParK WITH(READUNCOMMITTED) ON (ParK.IDPolozka=PZ.IDPrikaz AND ParK.M=0) 
          WHERE PZ.TypVyrobnihoDokladu=7 AND 
                (@R_vydejky=1 AND PZ.DruhPohybuZbo IN (2,4) OR 
                 @R_EP=1 AND PZ.DruhPohybuZbo=9 OR 
                 @R_Rez=1 AND PZ.DruhPohybuZbo=10) AND 
                PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>PZ.MnOdebrane 
          GROUP BY PZ.IDPrikaz 
    IF @R_OdvVydane=1 AND @R_prijemky=1 
      INSERT INTO #TabPomVykrytePolKontr(IDPolKontraktu, vykryto) 
        SELECT PZ.IDPrikaz, SUM(PZ.mnozstvi*PZ.PrepMnozstvi) 
          FROM TabPohybyZbozi PZ WITH(READUNCOMMITTED) 
            INNER JOIN TabDokladyZbozi DZ WITH(READUNCOMMITTED) ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0) 
            INNER JOIN TabParPolKontr ParK WITH(READUNCOMMITTED) ON (ParK.IDPolozka=PZ.IDPrikaz AND ParK.M=1) 
          WHERE PZ.TypVyrobnihoDokladu=8 AND PZ.DruhPohybuZbo=0 AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>0.0 
          GROUP BY PZ.IDPrikaz 
    DECLARE crSezTermOdv CURSOR FAST_FORWARD LOCAL FOR 
      SELECT O.M, O.Jemna, O.IDPolKontraktu, T.ID, T.IDOdvolavky, SS.IDSklad, O.IDKmenZbozi, PK.IDZakazModif, DatumPozadavku=CASE WHEN O.M=1 THEN T.PlanDodaniOd_X ELSE T.DatumExpediceOd_X END, 
             T.Mnozstvi_Zive * PK.PrepMnozstvi, Z.ID, CO.ID, KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabOdvolavky O 
          INNER JOIN TabTermOdvolavky T ON (T.IDOdvolavky=O.ID AND T.splneno=0) 
          INNER JOIN TabPohybyZbozi PK WITH(READUNCOMMITTED) ON (PK.ID=O.IDPolKontraktu) 
          INNER JOIN TabDokladyZbozi HK WITH(READUNCOMMITTED) ON (HK.ID=O.IDKontrakt AND HK.splneno=0) 
          INNER JOIN TabStavSkladu SS WITH(READUNCOMMITTED) ON (SS.ID=O.IDStavSkladu AND SS.blokovano=0) 
          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=O.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=ISNULL(PK.CisloZakazky, HK.CisloZakazky)) 
        WHERE O.aktivni=1 AND 
              (@R_OdvPrijate=1 AND O.M=0 OR @R_OdvVydane=1 AND O.M=1) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        ORDER BY O.Jemna DESC, DatumPozadavku ASC 
    OPEN crSezTermOdv 
    FETCH NEXT FROM crSezTermOdv INTO @MasterOdv, @JemnaOdv, @IDPolKontraktu, @IDTermOdvolavky, @IDOdvolavky, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, 
                                      @DatumPozadavku, @Pozadavek, @IDZakazka, @IDOrg, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
    WHILE @@fetch_status=0 
      BEGIN 
        IF @JemnaOdv=1 
          BEGIN 
            UPDATE #TabPomVykrytePKJemnouOdv SET Vykryto=Vykryto+@Pozadavek WHERE IDPolKontraktu=@IDPolKontraktu 
            IF @@rowcount=0 INSERT INTO #TabPomVykrytePKJemnouOdv(IDPolKontraktu, Vykryto) VALUES(@IDPolKontraktu, @Pozadavek) 
          END ELSE 
          BEGIN 
            SET @VykrytoJemnouOdv=ISNULL((SELECT Vykryto FROM #TabPomVykrytePKJemnouOdv WHERE IDPolKontraktu=@IDPolKontraktu), 0.0) 
            IF @VykrytoJemnouOdv>@Pozadavek SET @VykrytoJemnouOdv=@Pozadavek 
            IF @VykrytoJemnouOdv>0.0 UPDATE #TabPomVykrytePKJemnouOdv SET Vykryto=Vykryto-@VykrytoJemnouOdv WHERE IDPolKontraktu=@IDPolKontraktu 
            SET @Pozadavek=@Pozadavek - @VykrytoJemnouOdv 
          END 
        SET @Vykryto=ISNULL((SELECT Vykryto FROM #TabPomVykrytePolKontr WHERE IDPolKontraktu=@IDPolKontraktu), 0.0) 
        IF @Vykryto>@Pozadavek SET @Vykryto=@Pozadavek 
        IF @Vykryto>0.0 UPDATE #TabPomVykrytePolKontr SET Vykryto=Vykryto-@Vykryto WHERE IDPolKontraktu=@IDPolKontraktu 
        SET @Pozadavek=@Pozadavek-@Vykryto 
        IF @Pozadavek>0.0  
          INSERT INTO #TabBudPohybyVOB (IDPolKontraktu, IDPohyb, IDTermOdvolavky, IDOdvolavky, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, 
                                     Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
            SELECT @IDPolKontraktu, @IDPolKontraktu, @IDTermOdvolavky, @IDOdvolavky, CASE WHEN @MasterOdv=1 THEN 6 ELSE 24 END, 
                   @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @DatumPozadavku, 
                   CASE WHEN @MasterOdv=1 THEN 1.0 ELSE -1.0 END * @Pozadavek, CASE WHEN @MasterOdv=1 THEN 1.0 ELSE -1.0 END * @Pozadavek, 
                   @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
        FETCH NEXT FROM crSezTermOdv INTO @MasterOdv, @JemnaOdv, @IDPolKontraktu, @IDTermOdvolavky, @IDOdvolavky, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, 
                                          @DatumPozadavku, @Pozadavek, @IDZakazka, @IDOrg, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
      END 
    CLOSE crSezTermOdv 
    DEALLOCATE crSezTermOdv 
    DROP TABLE #TabPomVykrytePolKontr 
    DROP TABLE #TabPomVykrytePKJemnouOdv 
    IF @R_OdvVydane=1 AND OBJECT_ID(N'tempdb..#TabSeznamPolDodavKontr') IS NOT NULL 
      DELETE #TabBudPohybyVOB WHERE Oblast=6 AND IDPohyb IN (SELECT IDPolKontr FROM #TabSeznamPolDodavKontr) 
  END 

IF @R_PredPlan>0 AND @JenMaterialy=0 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    INSERT INTO #TabBudPohybyVOB (IDPredPlan, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT P.ID, 2, 
             S.cislo, KZ_Odv.ID, ZMD.IDZakazModif, 
             P.datum_X, P.datum_X,  
             P.mnozstvi, P.mnozstvi, 
             CO.ID, P.IDZakazka, 
             KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
        FROM TabZadVyp P 
         INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.Dilec) 
         LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=KZ.ID) 
         LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
         INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
         LEFT OUTER JOIN TabStrom KmenS ON (KmenS.cislo=ISNULL(P.KmenoveStredisko,KZ.KmenoveStredisko)) 
         LEFT OUTER JOIN TabStrom S ON (S.cislo=ISNULL(PD.VychoziSklad, CASE WHEN ISNULL(PD.TypDilce,1)=0 THEN KmenS.Cislo_H ELSE KmenS.Cislo_M END)) 
         LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ_Odv.ID) 
         LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
        WHERE P.autor=@SUSER_SNAME AND P.IDVarianta IS NULL AND P.mnozstvi>0.0 AND 
              ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
              (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_PredPlan=1 AND @JenDilce=0 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    INSERT INTO #TabBudPohybyVOB (IDPredPlan, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
     SELECT K.IDZadani, 25, 
            S.cislo, KZ.ID, NULL, 
            ZV.datum_X, ZV.datum_X, 
            (-1.0)*K.mnf, (-1.0)*K.mnf, 
            CO.ID, ZV.IDZakazka, 
            KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
       FROM TabKusovnik K 
        INNER JOIN TabZadVyp ZV ON (ZV.ID=K.IDZadani) 
        INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.blokovano=0 AND KZ.material=1 AND KZ.sluzba=0) 
        LEFT OUTER JOIN TabStrom S ON (S.cislo=K.Sklad) 
        LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=K.Sklad AND SS.IDKmenZbozi=K.IDKmenZbozi) 
        LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
       WHERE K.autor=@SUSER_SNAME AND K.mnf>0.0 AND K.Final=0 AND 
             ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
             (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
             (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
             (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
             (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_PredPlan=2 AND @JenDilce=0 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    INSERT INTO #TabBudPohybyVOB (IDPredPlan, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
     SELECT K.IDZadani, 25, 
            S.cislo, KZ.ID, NULL, 
            SK_R.TerminZahajeni_X, SK_R.TerminZahajeni_X, 
            (-1.0)*ISNULL(K.Pozadovano,K.Mnf), (-1.0)*ISNULL(K.Pozadovano,K.Mnf), 
            CO.ID, ZV.IDZakazka, 
            KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
       FROM TabStrukKusovZV K 
        INNER JOIN TabZadVyp ZV ON (ZV.ID=K.IDZadani) 
        INNER JOIN TabKmenZbozi KZ ON (KZ.ID=K.IDKmenZbozi AND KZ.blokovano=0 AND KZ.material=1 AND KZ.sluzba=0) 
        INNER JOIN TabStrukKusovZV SK_R ON (SK_R.ID=K.IDRodic) 
        LEFT OUTER JOIN TabStrom S ON (S.cislo=K.SkladProVydej) 
        LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=K.SkladProVydej AND SS.IDKmenZbozi=K.IDKmenZbozi) 
        LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
       WHERE K.autor=@SUSER_SNAME AND ISNULL(K.Pozadovano,K.Mnf)>0.0 AND 
             ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
             (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
             (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
             (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
             (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_Plan=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    IF @JenMaterialy=0 
      BEGIN 
        INSERT INTO #TabBudPohybyVOB (IDPlan, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT P.ID, 3, 
                 S.cislo, KZ_Odv.ID, ZMD.IDZakazModif, 
                 P.datum_X, P.datum_X,  
                 P.mnozNeprev, P.mnozNeprev, 
                 CO.ID, P.IDZakazka, 
                 KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
            FROM TabPlan P 
             INNER JOIN TabRadyPlanu RP ON (RP.Rada=P.Rada AND (RP.ZahrnoutDoBilancovaniBudPoh=1 OR RP.ZahrnoutDoBilancovaniBudPoh=2 AND @ZakazRozpaduPlanovaneVyroby=1)) 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
             LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=P.IDTabKmen) 
             INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
             LEFT OUTER JOIN TabStrom KmenS ON (KmenS.cislo=ISNULL(P.KmenoveStredisko,KZ.KmenoveStredisko)) 
             LEFT OUTER JOIN TabStrom S ON (S.cislo=ISNULL(PD.VychoziSklad, CASE WHEN ISNULL(PD.TypDilce,1)=0 THEN KmenS.Cislo_H ELSE KmenS.Cislo_M END)) 
             LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ_Odv.ID) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
            WHERE P.mnozNeprev>0.0 AND P.Datum IS NOT NULL AND 
                  ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        IF @ZakazRozpaduPlanovaneVyroby=0 
          BEGIN 
            INSERT INTO #TabBudPohybyVOB (IDPlan, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
              SELECT PL.ID, PR.ID, 8, 
                     S.cislo, KZ_Odv.ID, ZMD.IDZakazModif, 
                     PR.Plan_ukonceni_X, PR.Plan_ukonceni_X,  
                     PR.kusy_ciste, PR.kusy_ciste, 
                     CO.ID, PL.IDZakazka, 
                     KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
                FROM TabPlanPrikaz PR 
                 INNER JOIN TabPlan PL ON (PL.ID=PR.IDPlan AND PL.Datum IS NOT NULL) 
                 INNER JOIN TabRadyPlanu RP ON (RP.Rada=PL.Rada AND RP.ZahrnoutDoBilancovaniBudPoh=2) 
                 INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PR.IDTabKmen) 
                 LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=PR.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
                 LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=PR.IDTabKmen) 
                 INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
                 LEFT OUTER JOIN TabStrom S ON (S.cislo=PR.Sklad) 
                 LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ_Odv.ID) 
                 LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
                WHERE ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                      (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                      (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
                      (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                      (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
          END 
      END 
    IF @ZakazRozpaduPlanovaneVyroby=0 
      BEGIN 
        INSERT INTO #TabBudPohybyVOB (IDPlan, IDPlanPrikaz, PrVPVDoklad, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT PL.ID, PR.ID, PrVPV.Doklad, 9, 
                 S.cislo, KZ.ID, NULL, 
                 PR.Plan_ukonceni_X, PR.Plan_ukonceni_X,  
                 PrVPV.mnoz_zad, PrVPV.mnoz_zad, 
                 CO.ID, PL.IDZakazka, 
                 KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
            FROM TabPlanPrVPVazby PrVPV 
             INNER JOIN TabPlan PL ON (PL.ID=PrVPV.IDPlan AND PL.Datum IS NOT NULL) 
             INNER JOIN TabRadyPlanu RP ON (RP.Rada=PL.Rada AND RP.ZahrnoutDoBilancovaniBudPoh=2) 
             INNER JOIN TabPlanPrikaz PR ON (PR.ID=PrVPV.IDPlanPrikaz) 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrVPV.VedProdukt AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             LEFT OUTER JOIN TabStrom S ON (S.cislo=PrVPV.Sklad) 
             LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
            WHERE ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        INSERT INTO #TabBudPohybyVOB (IDPlan, IDPlanPrikaz, PrKVDoklad, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT PL.ID, PR.ID, PrKV.Doklad, 29, 
                 S.cislo, KZ.ID, ZMD.IDZakazModif, 
                 PR.Plan_zadani_X, PR.Plan_zadani_X, 
                 (-1.0)*PrKV.mnoz_zad, (-1.0)*PrKV.mnoz_zad, 
                 CO.ID, PL.IDZakazka, 
                 KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
            FROM TabPlanPrKVazby PrKV 
             INNER JOIN TabPlan PL ON (PL.ID=PrKV.IDPlan AND PL.Datum IS NOT NULL) 
             INNER JOIN TabRadyPlanu RP ON (RP.Rada=PL.Rada AND RP.ZahrnoutDoBilancovaniBudPoh=2) 
             INNER JOIN TabPlanPrikaz PR ON (PR.ID=PrKV.IDPlanPrikaz) 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrKV.nizsi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=PR.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabStrom S ON (S.cislo=PrKV.Sklad) 
             LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=S.Cislo AND SS.IDKmenZbozi=KZ.ID) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
            WHERE PrKV.RezijniMat=0 AND 
                  ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
      END 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_VyrPrik=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    CREATE TABLE #TabPomVykrytePrKV(IDPrikaz int NOT NULL, Doklad int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz,Doklad)) 
    IF (@R_vydejky=1 OR @R_EP=1 OR @R_Rez=1) 
      INSERT INTO #TabPomVykrytePrKV(IDPrikaz, Doklad, vykryto) 
        SELECT X.IDPrikaz, X.DokladPrikazu, SUM(X.vykryto) 
          FROM (SELECT PZ.IDPrikaz, PZ.DokladPrikazu, vykryto=(PZ.mnozstvi-PZ.mnOdebrane)*PZ.PrepMnozstvi * PrKV.RefMnoz/PrKV.mnoz_zad 
                  FROM TabPrikaz P 
                    INNER JOIN TabPohybyZbozi PZ ON (PZ.TypVyrobnihoDokladu=1 AND PZ.IDPrikaz=P.ID AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>PZ.mnOdebrane) 
                    INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.splneno=0) 
                    INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad) 
                    INNER JOIN TabPrKVazby PrKV ON (PrKV.IDPrikaz=PZ.IDPrikaz AND PrKV.Doklad=PZ.DokladPrikazu AND PrKV.nizsi=SS.IDKmenZbozi AND PrKV.IDOdchylkyDo IS NULL) 
                  WHERE P.kusy_zive>0.0 AND 
                        (@R_vydejky=1 AND PZ.DruhPohybuZbo IN (2,4) OR 
                         @R_EP=1 AND PZ.DruhPohybuZbo=9 OR 
                         @R_Rez=1 AND PZ.DruhPohybuZbo=10) 
               ) X 
          GROUP BY X.IDPrikaz, X.DokladPrikazu 
    DECLARE crSezPrKVBudPoh CURSOR FAST_FORWARD LOCAL FOR 
      SELECT P.ID, PrKV.Doklad, KZ.ID, S.cislo, ZMD.IDZakazModif, P.Plan_zadani_X, 
             (PrKV.RefMnoz - PrKV.VydanoRefMnoz - ISNULL(VPoz.vykryto,0.0)), 
             CO.ID, P.IDZakazka, KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabPrKVazby PrKV 
          INNER JOIN TabPrikaz P ON (P.ID=PrKV.IDPrikaz AND P.kusy_zive>0.0) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrKV.nizsi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
          LEFT OUTER JOIN TabStrom S ON (S.cislo=PrKV.Sklad) 
          LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=PrKV.Sklad AND SS.IDKmenZbozi=PrKV.nizsi) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN #TabPomVykrytePrKV VPoz ON (VPoz.IDPrikaz=PrKV.IDPrikaz AND VPoz.Doklad=PrKV.Doklad) 
          WHERE PrKV.Splneno=0 AND PrKV.prednastaveno=1 AND PrKV.IDOdchylkyDo IS NULL AND 
                PrKV.RefMnoz > (PrKV.VydanoRefMnoz + ISNULL(VPoz.vykryto,0.0)) AND 
                ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
                (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    OPEN crSezPrKVBudPoh 
    FETCH NEXT FROM crSezPrKVBudPoh INTO @IDPrikaz, @Doklad, @IDKmenZbozi, @SkladPozadavku, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
    WHILE @@fetch_status=0 
      BEGIN 
        IF @R_AdvKP=1 
          BEGIN 
            DECLARE crSezDavekzKP CURSOR FAST_FORWARD LOCAL FOR 
              SELECT DatumX=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasOd)))), SUM(KPM.Mnoz_Nevydane) 
                FROM TabAdvKPMaterialy KPM 
                  INNER JOIN TabAdvKPDavky KPD ON (KPD.IDAdvKapacPlan=@IDAdvKapacPlan AND KPD.LocalID=KPM.LocalIDDavky) 
                WHERE KPM.IDAdvKapacPlan=@IDAdvKapacPlan AND KPM.IDPrikaz=@IDPrikaz AND KPM.DokladPrKVazby=@Doklad AND KPM.IDKmenZbozi=@IDKmenZbozi AND KPM.Mnoz_Nevydane>0.0 
                GROUP BY CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasOd))) 
                ORDER BY DatumX DESC 
            OPEN crSezDavekzKP 
            FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
            WHILE (@@fetch_status=0) AND (@Pozadavek>0.0) 
              BEGIN 
                IF @PozadavekKP > @Pozadavek  SET @PozadavekKP=@Pozadavek 
                INSERT INTO #TabBudPohybyVOB (PrKVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                  VALUES(@Doklad, @IDPrikaz, 26, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavkuKP, @DatumPozadavkuKP, -1.0 * @PozadavekKP, -1.0 * @PozadavekKP, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
                SET @Pozadavek = @Pozadavek - @PozadavekKP 
                FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
              END 
            CLOSE crSezDavekzKP 
            DEALLOCATE crSezDavekzKP 
          END 
        IF @Pozadavek > 0.0 
          INSERT INTO #TabBudPohybyVOB (PrKVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
            VALUES(@Doklad, @IDPrikaz, 26, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @DatumPozadavku, -1.0 * @Pozadavek, -1.0 * @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
        FETCH NEXT FROM crSezPrKVBudPoh INTO @IDPrikaz, @Doklad, @IDKmenZbozi, @SkladPozadavku, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
      END 
    CLOSE crSezPrKVBudPoh 
    DEALLOCATE crSezPrKVBudPoh 
    DROP TABLE #TabPomVykrytePrKV 
    CREATE TABLE #TabPomVykrytePrVPV(IDPrikaz int NOT NULL, Doklad int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz,Doklad)) 
    IF (@R_prijemky=1) 
      INSERT INTO #TabPomVykrytePrVPV(IDPrikaz, Doklad, vykryto) 
        SELECT PZ.IDPrikaz, PZ.DokladPrikazu, SUM(PZ.mnozstvi*PZ.PrepMnozstvi) 
          FROM TabPrikaz P 
            INNER JOIN TabPohybyZbozi PZ ON (PZ.TypVyrobnihoDokladu=3 AND PZ.IDPrikaz=P.ID AND PZ.druhPohybuZbo=0 AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>0.0) 
          WHERE P.kusy_zive>0.0 
          GROUP BY PZ.IDPrikaz, PZ.DokladPrikazu 
    DECLARE crSezPrVPVazebBudPoh CURSOR FAST_FORWARD LOCAL FOR 
      SELECT PrVPV.ID, P.ID, PrVPV.Doklad, S.cislo, KZ.ID, P.Plan_ukonceni_X, 
             PrVPV.mnoz_zustatkove - ISNULL(VPoz.vykryto,0.0), 
             CO.ID, P.IDZakazka, KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni, 
             PrVPV.mnoz_zad 
        FROM TabPrVPVazby PrVPV 
          INNER JOIN TabPrikaz P ON (P.ID=PrVPV.IDPrikaz AND P.kusy_zive>0.0) 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=PrVPV.VedProdukt AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabStrom S ON (S.cislo=PrVPV.Sklad) 
          LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=PrVPV.Sklad AND SS.IDKmenZbozi=PrVPV.VedProdukt) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
          LEFT OUTER JOIN #TabPomVykrytePrVPV VPoz ON (VPoz.IDPrikaz=PrVPV.IDPrikaz AND VPoz.Doklad=PrVPV.Doklad) 
        WHERE PrVPV.Splneno=0 AND PrVPV.IDOdchylkyDo IS NULL AND 
              PrVPV.mnoz_zustatkove > ISNULL(VPoz.vykryto,0.0) AND 
              ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
              (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    OPEN crSezPrVPVazebBudPoh 
    FETCH NEXT FROM crSezPrVPVazebBudPoh INTO @RecID, @IDPrikaz, @Doklad, @SkladPozadavku, @IDKmenZbozi, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni, @MnozZad 
    WHILE @@fetch_status=0 
      BEGIN 
        IF @R_AdvKP=1 
          BEGIN 
            DECLARE crSezDavekzKP CURSOR FAST_FORWARD LOCAL FOR 
              SELECT DatumX=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo)))), SUM(@MnozZad * KPD.Mnozstvi_Zive / PrP.Kusy_zad) 
                FROM TabPrPostup PrP 
                  INNER JOIN TabAdvKPDavky KPD ON (KPD.IDAdvKapacPlan=@IDAdvKapacPlan AND KPD.IDPrikaz=PrP.IDPrikaz AND KPD.DokladPrPostup=PrP.Doklad AND KPD.Mnozstvi_Zive>0.0) 
                WHERE PrP.IDPrikaz=@IDPrikaz AND PrP.Doklad=dbo.hf_GetPrPDokladForPrVPV(@RecID) AND PrP.prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL 
                GROUP BY CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo))) 
                ORDER BY DatumX DESC 
            OPEN crSezDavekzKP 
            FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
            WHILE (@@fetch_status=0) AND (@Pozadavek>0.0) 
              BEGIN 
                IF @PozadavekKP > @Pozadavek  SET @PozadavekKP=@Pozadavek 
                INSERT INTO #TabBudPohybyVOB (PrVPVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                  VALUES(@Doklad, @IDPrikaz, 5, @SkladPozadavku, @IDKmenZbozi, NULL, @DatumPozadavkuKP, @DatumPozadavkuKP, @PozadavekKP, @PozadavekKP, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
                SET @Pozadavek = @Pozadavek - @PozadavekKP 
                FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
              END 
            CLOSE crSezDavekzKP 
            DEALLOCATE crSezDavekzKP 
          END 
        IF @Pozadavek > 0.0 
          INSERT INTO #TabBudPohybyVOB (PrVPVDoklad, IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
            VALUES(@Doklad, @IDPrikaz, 5, @SkladPozadavku, @IDKmenZbozi, NULL, @DatumPozadavku, @DatumPozadavku, @Pozadavek, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
        FETCH NEXT FROM crSezPrVPVazebBudPoh INTO @RecID, @IDPrikaz, @Doklad, @SkladPozadavku, @IDKmenZbozi, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni, @MnozZad 
      END 
    CLOSE crSezPrVPVazebBudPoh 
    DEALLOCATE crSezPrVPVazebBudPoh 
    DROP TABLE #TabPomVykrytePrVPV 
    IF @JenMaterialy=0 
      BEGIN 
        CREATE TABLE #TabPomVykrytePrik(IDPrikaz int NOT NULL, vykryto numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz)) 
        IF (@R_prijemky=1) 
          INSERT INTO #TabPomVykrytePrik(IDPrikaz, vykryto) 
            SELECT PZ.IDPrikaz, SUM(PZ.mnozstvi*PZ.PrepMnozstvi) 
              FROM TabPrikaz P 
                INNER JOIN TabPohybyZbozi PZ ON (PZ.TypVyrobnihoDokladu=0 AND PZ.IDPrikaz=P.ID AND PZ.druhPohybuZbo=0 AND PZ.SkutecneDatReal IS NULL AND PZ.mnozstvi>0.0) 
              WHERE P.kusy_zive>0.0 
              GROUP BY PZ.IDPrikaz 
        DECLARE crSezPrikBudPoh CURSOR FAST_FORWARD LOCAL FOR 
          SELECT P.ID, S.Cislo, KZ_Odv.ID, ZMD.IDZakazModif, P.Plan_ukonceni_X, 
                 CASE WHEN P.StavPrikazu<30 THEN P.kusy_ciste ELSE P.kusy_zive_ciste - ISNULL(VPoz.vykryto,0.0) END, 
                 CO.ID, P.IDZakazka, KZ_Odv.DodaciLhuta, KZ_Odv.TypDodaciLhuty, KZ_Odv.LhutaNaskladneni 
            FROM TabPrikaz P 
              INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
              LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=P.IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID) 
              LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=P.IDTabKmen) 
              INNER JOIN TabKmenZbozi KZ_Odv ON (KZ_Odv.ID=CASE WHEN ISNULL(PD.OdvadetNaZaklVari,0)=1 THEN KZ.IDKusovnik ELSE KZ.ID END AND KZ_Odv.blokovano=0 AND KZ_Odv.sluzba=0) 
              LEFT OUTER JOIN TabStrom S ON (S.cislo=P.Sklad) 
              LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=P.Sklad AND SS.IDKmenZbozi=KZ_Odv.ID) 
              LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ_Odv.Aktualni_Dodavatel) 
              LEFT OUTER JOIN #TabPomVykrytePrik VPoz ON (VPoz.IDPrikaz=P.ID) 
            WHERE (P.StavPrikazu<30 OR P.kusy_zive_ciste>ISNULL(VPoz.vykryto,0.0)) AND 
                  ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
                  (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
                  (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ_Odv.ID AND SS0.IDSklad=@sklad)) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ_Odv.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
        OPEN crSezPrikBudPoh 
        FETCH NEXT FROM crSezPrikBudPoh INTO @IDPrikaz, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
        WHILE @@fetch_status=0 
          BEGIN 
            IF @R_AdvKP=1 
              BEGIN 
                DECLARE crSezDavekzKP CURSOR FAST_FORWARD LOCAL FOR 
                  SELECT DatumX=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo)))), SUM(KPD.Mnozstvi_Zive) 
                    FROM TabPrPostup PrPO 
                      INNER JOIN TabAdvKPDavky KPD ON (KPD.IDAdvKapacPlan=@IDAdvKapacPlan AND KPD.IDPrikaz=PrPO.IDPrikaz AND KPD.DokladPrPostup=PrPO.Doklad AND KPD.Mnozstvi_Zive>0.0) 
                    WHERE PrPO.IDPrikaz=@IDPrikaz AND PrPO.Odvadeci=1 AND PrPO.prednastaveno=1 AND PrPO.IDOdchylkyDo IS NULL 
                    GROUP BY CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,KPD.CCasDo))) 
                    ORDER BY DatumX DESC 
                OPEN crSezDavekzKP 
                FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
                WHILE (@@fetch_status=0) AND (@Pozadavek>0.0) 
                  BEGIN 
                    IF @PozadavekKP > @Pozadavek  SET @PozadavekKP=@Pozadavek 
                    INSERT INTO #TabBudPohybyVOB (IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                      VALUES(@IDPrikaz, 4, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavkuKP, @DatumPozadavkuKP, @PozadavekKP, @PozadavekKP, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
                    SET @Pozadavek = @Pozadavek - @PozadavekKP 
                    FETCH NEXT FROM crSezDavekzKP INTO @DatumPozadavkuKP, @PozadavekKP 
                  END 
                CLOSE crSezDavekzKP 
                DEALLOCATE crSezDavekzKP 
              END 
            IF @Pozadavek > 0.0 
              INSERT INTO #TabBudPohybyVOB (IDPrikaz, Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
                VALUES(@IDPrikaz, 4, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @DatumPozadavku, @Pozadavek, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni) 
            FETCH NEXT FROM crSezPrikBudPoh INTO @IDPrikaz, @SkladPozadavku, @IDKmenZbozi, @IDZakazModif, @DatumPozadavku, @Pozadavek, @IDOrg, @IDZakazka, @DodaciLhuta, @TypDodaciLhuty, @LhutaNaskladneni 
          END 
        CLOSE crSezPrikBudPoh 
        DEALLOCATE crSezPrikBudPoh 
        DROP TABLE #TabPomVykrytePrik 
      END 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @R_ProjRizeni=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    INSERT INTO #TabBudPohybyVOB (IDGprUlohyMatZdroje, Oblast, Sklad, IDKmeneZbozi, DatumPohybu_Pl, DatumPohybu, 
                               Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
      SELECT MP.ID, 30, MP.Sklad, KZ.ID, 
             ISNULL(U.PlanZahajeni_X, PV.DatumStartPlan), ISNULL(ISNULL(U.PlanZahajeni_X, PV.DatumStartPlan), @DnesX), 
             -SV.Zbyva, -SV.Zbyva, 
             CO.ID, U.IDZakazka, 
             KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
        FROM TabGprProjektyView PV 
          INNER JOIN TabGprUlohy U ON (U.IDZakazka=PV.ID AND dbo.hf_GprUlohy_Splneno(U.ID)=0) 
          INNER JOIN TabGprUlohyMatZdroje MP ON (MP.IDGprUlohy=U.ID AND MP.Uzavreno=0) 
          CROSS APPLY (SELECT Zbyva = ROUND(MP.Mnozstvi*MP.PrepocetMnozstvi - ISNULL(SUM(V.Mnozstvi*V.PrepocetMnozstvi),0.0), 4) 
                         FROM TabGprVykazNakladuMatZdr V 
                         WHERE V.IDGprUlohyMatZdroje=MP.ID) SV 
          INNER JOIN TabKmenZbozi KZ ON (KZ.ID=MP.IDMatZdroje AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
          LEFT OUTER JOIN TabStrom S ON (S.cislo=MP.Sklad) 
          LEFT OUTER JOIN TabStavSkladu SS ON (SS.IDSklad=MP.Sklad AND SS.IDKmenZbozi=KZ.ID) 
          LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
        WHERE PV.Ukonceno=0 AND SV.Zbyva>0.0 AND 
              ISNULL(SS.blokovano,0)=0 AND (S.Cislo IS NULL OR @TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL) AND 
              (@RespekMnozNaOstatSkladech=1 OR S.Cislo IS NOT NULL) AND 
              (S.Cislo=@sklad OR @sklad='' OR @ZobrazitChybejiciKmenKarty=1 OR @RespekMnozNaOstatSkladech=1 AND EXISTS(SELECT * FROM TabStavSkladu SS0 WHERE SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad)) AND 
              (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
              (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF @GenerovatNulovePohyby=1 
  BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    IF @RespekMnozNaOstatSkladech=1 
      INSERT INTO #TabBudPohybyVOB (Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT 20, 
                 MIN(ISNULL(SS0.IDSklad,SS.IDSklad)), SS.IDKmenZbozi, NULL, 
                 (CASE MAX(KZ.TypDodaciLhuty) WHEN 0 THEN DATEADD(day, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 1 THEN DATEADD(month, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 2 THEN DATEADD(year, MAX(KZ.DodaciLhuta), @DnesX) 
                  END + MAX(KZ.LhutaNaskladneni)), 
                 (CASE MAX(KZ.TypDodaciLhuty) WHEN 0 THEN DATEADD(day, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 1 THEN DATEADD(month, MAX(KZ.DodaciLhuta), @DnesX) 
                                              WHEN 2 THEN DATEADD(year, MAX(KZ.DodaciLhuta), @DnesX) 
                  END + MAX(KZ.LhutaNaskladneni)), 
                 0.0, 0.0, 
                 MAX(CO.ID), 
                 MAX(KZ.DodaciLhuta), MAX(KZ.TypDodaciLhuty), MAX(KZ.LhutaNaskladneni) 
            FROM TabStavSkladu SS 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
             LEFT OUTER JOIN TabStavSkladu SS0 ON (SS0.IDKmenZbozi=KZ.ID AND SS0.IDSklad=@sklad) 
            WHERE SS.blokovano=0 AND 
                  (S.Cislo=@sklad OR @ZobrazitChybejiciKmenKarty=1) AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
            GROUP BY SS.IDKmenZbozi 
            HAVING NOT EXISTS(SELECT * FROM #TabBudPohybyVOB BP WHERE BP.IDKmeneZbozi=SS.IDKmenZbozi AND BP.mnozstvi<0.0 AND 
                                                                   (@OkamziteDoplneniPojisZasob=0 OR BP.DatumPohybu<=(CASE MAX(KZ.TypDodaciLhuty) WHEN 0 THEN DATEADD(day, MAX(KZ.DodaciLhuta), @DnesX) 
                                                                                                                                                     WHEN 1 THEN DATEADD(month, MAX(KZ.DodaciLhuta), @DnesX) 
                                                                                                                                                     WHEN 2 THEN DATEADD(year, MAX(KZ.DodaciLhuta), @DnesX) 
                                                                                                                         END + MAX(KZ.LhutaNaskladneni)) 
                                                                   )) AND 
                   (SELECT ISNULL(SUM(SS2.mnozstvi),0.0) - SUM(CASE @DoplnitPod WHEN 0 THEN SS2.minimum WHEN 1 THEN SS2.maximum WHEN 2 THEN 0.0 END) 
                       FROM TabStavSkladu SS2 
                         INNER JOIN TabStrom S2 ON (S2.cislo=SS2.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S2.TypStrediska=0 OR @TypStrediska=2 AND S2.TypStrediska IS NOT NULL)) 
                       WHERE SS2.IDKmenZbozi=SS.IDKmenZbozi AND SS2.Blokovano=0) 
                     < 0.0 
     ELSE 
      INSERT INTO #TabBudPohybyVOB (Oblast, Sklad, IDKmeneZbozi, IDZakazModif, DatumPohybu_Pl, DatumPohybu, Mnozstvi_Pl, Mnozstvi, Dodavatel, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni) 
          SELECT 20, 
                 SS.IDSklad, SS.IDKmenZbozi, NULL, 
                 (CASE KZ.TypDodaciLhuty WHEN 0 THEN DATEADD(day, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 1 THEN DATEADD(month, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 2 THEN DATEADD(year, KZ.DodaciLhuta, @DnesX) 
                  END + KZ.LhutaNaskladneni), 
                 (CASE KZ.TypDodaciLhuty WHEN 0 THEN DATEADD(day, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 1 THEN DATEADD(month, KZ.DodaciLhuta, @DnesX) 
                                         WHEN 2 THEN DATEADD(year, KZ.DodaciLhuta, @DnesX) 
                  END + KZ.LhutaNaskladneni), 
                 0.0, 0.0, 
                 CO.ID, 
                 KZ.DodaciLhuta, KZ.TypDodaciLhuty, KZ.LhutaNaskladneni 
            FROM TabStavSkladu SS 
             INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.blokovano=0 AND (@JenMaterialy=0 OR KZ.material=1) AND (@JenDilce=0 OR KZ.dilec=1) AND KZ.sluzba=0) 
             INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
             LEFT OUTER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel) 
            WHERE SS.blokovano=0 AND 
                  (S.Cislo=@sklad OR @sklad='') AND 
                  NOT EXISTS(SELECT * FROM #TabBudPohybyVOB BP WHERE BP.IDKmeneZbozi=SS.IDKmenZbozi AND BP.Sklad=SS.IDSklad AND BP.mnozstvi<0.0 AND 
                                                                  (@OkamziteDoplneniPojisZasob=0 OR BP.DatumPohybu<=(CASE KZ.TypDodaciLhuty WHEN 0 THEN DATEADD(day, KZ.DodaciLhuta, @DnesX) 
                                                                                                                                               WHEN 1 THEN DATEADD(month, KZ.DodaciLhuta, @DnesX) 
                                                                                                                                               WHEN 2 THEN DATEADD(year, KZ.DodaciLhuta, @DnesX) 
                                                                                                                        END + KZ.LhutaNaskladneni) 
                                                                  )) AND 
                  SS.mnozstvi - CASE @DoplnitPod WHEN 0 THEN SS.minimum WHEN 1 THEN SS.maximum WHEN 2 THEN 0.0 END < 0.0 AND 
                  (@ProSeznamSS=0 OR SS.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) AND 
                  (@ProSeznamKZ=0 OR KZ.ID IN (SELECT ID FROM #TabOznacIDSS_GenBudPoh)) 
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
  END 
IF OBJECT_ID(N'dbo.EP2_GenerovaniBudPohybu',N'P') IS NOT NULL 
  BEGIN 
    SELECT TypFormulare=@TypFormulare, 
           Sklad=@sklad, 
           RespekMnozNaOstatSkladech=@RespekMnozNaOstatSkladech, 
           ZobrazitChybejiciKmenKarty=@ZobrazitChybejiciKmenKarty, 
           DoplnitPod=@DoplnitPod, 
           TypStrediska=@TypStrediska, 
           R_prijemky=@R_prijemky, 
           R_StornaPrijemek=@R_StornaPrijemek, 
           R_vydejky=@R_vydejky, 
           R_StornaVydejek=@R_StornaVydejek, 
           R_EP=@R_EP, 
           R_Rez=@R_Rez, 
           R_Obj=@R_Obj, 
           R_DosObj=@R_DosObj, 
           R_OdvPrijate=@R_OdvPrijate, 
           R_OdvVydane=@R_OdvVydane, 
           R_ProjRizeni=@R_ProjRizeni, 
           R_PredPlan=@R_PredPlan, 
           R_Plan=@R_Plan, 
           R_VyrPrik=@R_VyrPrik, 
           R_AdvKP=@R_AdvKP, 
           JenMaterialy=@JenMaterialy, 
           JenDilce=@JenDilce, 
           GenerovatNulovePohyby=@GenerovatNulovePohyby, 
           ProSeznamKZ=@ProSeznamKZ, 
           ProSeznamSS=@ProSeznamSS, 
           OkamziteDoplneniPojisZasob=@OkamziteDoplneniPojisZasob 
      INTO #TabParEP2_GenerovaniBudPohybu 
    EXEC @Ret=dbo.EP2_GenerovaniBudPohybu 
    DROP TABLE #TabParEP2_GenerovaniBudPohybu 
 --   IF /*@@error<>0 OR*/ @Ret<>0 RETURN 1 
  END ELSE 

--upravíme pořadí pohybů
--EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
DECLARE
 @RespekZakazky bit=0, 
 @UprednostnitPlusy bit=0, 
 @JenPro_IDKmeneZbozi int=NULL, 
 @JenPro_Sklad nvarchar(30)=NULL;
SET @RespekMnozNaOstatSkladech=0;
SET NOCOUNT ON 
DECLARE @ID INT, @IDKmeneZbozi int, @DatumPohybu datetime, 
        @OldSklad nvarchar(50), @OldIDKmeneZbozi int, @OldPoradi int, @Poradi int 
SELECT @OldSklad='', @OldIDKmeneZbozi=0 
DECLARE crPoradi CURSOR FAST_FORWARD LOCAL FOR 
  SELECT BP.ID, BP.Sklad, BP.IDKmeneZbozi, BP.PoradiPohybu 
    FROM #TabBudPohybyVOB BP 
    WHERE (@JenPro_IDKmeneZbozi IS NULL OR BP.IDKmeneZbozi=@JenPro_IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR BP.Sklad=@JenPro_Sklad)) 
    ORDER BY BP.IDKmeneZbozi, CASE WHEN @RespekMnozNaOstatSkladech=0 THEN BP.Sklad END, 
             CASE WHEN @RespekZakazky=1 AND BP.IDZakazka>0 THEN (SELECT MIN(BP2.DatumPohybu) FROM #TabBudPohybyVOB BP2 WHERE BP2.IDKmeneZbozi=BP.IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR BP2.Sklad=BP.Sklad) AND BP2.IDZakazka=BP.IDZakazka) END ASC, 
             CASE WHEN @RespekZakazky=1 THEN BP.IDZakazka END, 
             CASE WHEN @UprednostnitPlusy=1 AND BP.mnozstvi>0.0 THEN 1 ELSE 2 END ASC, 
             BP.DatumPohybu ASC, BP.Oblast ASC 
OPEN crPoradi 
FETCH NEXT FROM crPoradi INTO @ID, @Sklad, @IDKmeneZbozi, @OldPoradi 
WHILE @@fetch_status=0 
  BEGIN 
    IF @OldIDKmeneZbozi<>@IDKmeneZbozi OR (@RespekMnozNaOstatSkladech=0 AND @OldSklad<>@Sklad) 
      SELECT @Poradi=1, @OldSklad=@Sklad, @OldIDKmeneZbozi=@IDKmeneZbozi 
    IF @OldPoradi<>@Poradi UPDATE #TabBudPohybyVOB SET PoradiPohybu=@Poradi WHERE ID=@ID 
    SET @Poradi=@Poradi+1 
    FETCH NEXT FROM crPoradi INTO @ID, @Sklad, @IDKmeneZbozi, @OldPoradi 
  END 
CLOSE crPoradi 
DEALLOCATE crPoradi
--upravíme virtuální množství
--EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0

DECLARE @MnozPohybu numeric(19,6), @VirtSS numeric(19,6) 
SET @RespekMnozNaOstatSkladech=0;
SET @TypStrediska=0;
SET @JenPro_IDKmeneZbozi=NULL;
SET @JenPro_Sklad=NULL;
SELECT @OldSklad='', @OldIDKmeneZbozi=0 
DECLARE crVirtSS CURSOR FAST_FORWARD LOCAL FOR 
  SELECT BP.ID, BP.Sklad, BP.IDKmeneZbozi, BP.mnozstvi+BP.Objednat+BP.Generovano 
    FROM #TabBudPohybyVOB BP 
    WHERE (@JenPro_IDKmeneZbozi IS NULL OR BP.IDKmeneZbozi=@JenPro_IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR BP.Sklad=@JenPro_Sklad)) 
    ORDER BY BP.IDKmeneZbozi, CASE WHEN @RespekMnozNaOstatSkladech=0 THEN BP.Sklad END, BP.PoradiPohybu ASC 
OPEN crVirtSS 
FETCH NEXT FROM crVirtSS INTO @ID, @Sklad, @IDKmeneZbozi, @MnozPohybu 
WHILE @@fetch_status=0 
  BEGIN 
    IF @OldIDKmeneZbozi<>@IDKmeneZbozi OR (@RespekMnozNaOstatSkladech=0 AND @OldSklad<>@Sklad) 
      SELECT @OldSklad=@Sklad, @OldIDKmeneZbozi=@IDKmeneZbozi, 
             @VirtSS=(SELECT ISNULL(SUM(SS.mnozstvi),0) 
                        FROM TabStavSkladu SS 
                          INNER JOIN TabStrom S ON (S.cislo=SS.IDSklad AND (@TypStrediska=0 OR @TypStrediska=1 AND S.TypStrediska=0 OR @TypStrediska=2 AND S.TypStrediska IS NOT NULL)) 
                        WHERE SS.IDKmenZbozi=@IDKmeneZbozi AND (@RespekMnozNaOstatSkladech=1 OR SS.IDSklad=@sklad) AND SS.Blokovano=0) 
    SET @VirtSS=@VirtSS+@MnozPohybu 
    UPDATE #TabBudPohybyVOB SET MnozstviNaSklade=@VirtSS WHERE ID=@ID 
    FETCH NEXT FROM crVirtSS INTO @ID, @Sklad, @IDKmeneZbozi, @MnozPohybu 
  END 
CLOSE crVirtSS 
DEALLOCATE crVirtSS
--zobrazíme
SELECT
tkz.SkupZbo,tkz.RegCis,tbp.IDKmeneZbozi,tbp.ID,tbp.IDPohyb,tbp.IDPlan,tbp.PrKVDoklad,tbp.PrVPVDoklad,tbp.IDPlanPrikaz
,tbp.IDPrikaz,tbp.Oblast,tbp.Sklad,tbp.Dodavatel,tbp.IDZakazka,tbp.DatumPohybu,tbp.PoradiPohybu,tbp.Mnozstvi,tbp.MnozstviNaSklade
FROM #TabBudPohybyVOB tbp
LEFT OUTER JOIN TabKmenZbozi tkz ON tbp.IDKmeneZbozi=tkz.ID
ORDER BY tkz.SkupZbo,tkz.RegCis,tbp.PoradiPohybu

DECLARE @DatPohybu_new DATETIME, @IDZak INT, @CisloZak NVARCHAR(15)
SET @IDZak=(SELECT x.IDZakazka
FROM (SELECT tkz.SkupZbo,tkz.RegCis,tbp.IDKmeneZbozi,tbp.ID,tbp.IDPohyb,tbp.Oblast,tbp.Sklad,tbp.IDZakazka,tbp.DatumPohybu,tbp.PoradiPohybu,tbp.MnozstviNaSklade,ROW_NUMBER() OVER (ORDER BY tbp.PoradiPohybu) AS rn
FROM #TabBudPohybyVOB tbp
LEFT OUTER JOIN TabKmenZbozi tkz ON tbp.IDKmeneZbozi=tkz.ID
WHERE tbp.MnozstviNaSklade<0) x
WHERE x.rn=1);
SET @DatPohybu_new=(SELECT x.DatumPohybu
FROM (SELECT tkz.SkupZbo,tkz.RegCis,tbp.IDKmeneZbozi,tbp.ID,tbp.IDPohyb,tbp.Oblast,tbp.Sklad,tbp.IDZakazka,tbp.DatumPohybu,tbp.PoradiPohybu,tbp.MnozstviNaSklade,ROW_NUMBER() OVER (ORDER BY tbp.PoradiPohybu) AS rn
FROM #TabBudPohybyVOB tbp
LEFT OUTER JOIN TabKmenZbozi tkz ON tbp.IDKmeneZbozi=tkz.ID
WHERE tbp.MnozstviNaSklade<0) x
WHERE x.rn=1);
SET @CisloZak=(SELECT CisloZakazky FROM Tabzakazka WHERE ID=@IDZak);
--PRINT @DatPohybu_new;
--PRINT @CisloZak;
IF @DatPohybu_new IS NOT NULL
UPDATE #TabBudPohyby SET #TabBudPohyby.DatumPohybu=@DatPohybu_new,#TabBudPohyby.IDZakazka=@IDZak WHERE #TabBudPohyby.ID=@IDradku
*/
GO

