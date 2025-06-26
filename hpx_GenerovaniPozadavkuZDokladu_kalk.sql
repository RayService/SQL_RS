USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_GenerovaniPozadavkuZDokladu_kalk]    Script Date: 26.06.2025 10:10:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_GenerovaniPozadavkuZDokladu_kalk] 
 @Sklad nvarchar(50) = N'200',
 @Oblast_Rez bit = 0,
 @Oblast_EP bit = 1,
 @Oblast_Obj bit = 0,
 @Oblast_DosObj bit = 0,
 @Oblast_NabSes bit = 1,
 @Oblast_Kontr bit = 0,
 @Oblast_Odv bit = 0, 
 @RespPredbPlan int = 0,
 @RespPlan int = 0,
 @RespPrikaz int = 0,
 @RespSklad int = 0,
 @RespVedProd int = 0 
AS 
SET NOCOUNT ON 
DELETE TabPozaZDok_kalk 
DECLARE @SUSER_SNAME nvarchar(150) 
SET @SUSER_SNAME=SUSER_SNAME() 
DECLARE @ID int, @IDZboSklad int, @IDKmenZbozi int, @IDZakazModif int, @Oblast int, @Ret int, 
        @Vykryto numeric(19,6), @VykrytoJemnouOdv numeric(19,6), @JemnaOdv bit, @IDPolKontraktu int, @IDTermOdvolavky int, @IDOdvolavky int, @IDKontraktu int, @IDZakazka int, @CisloOrg int, @DatumPozadavku datetime, 
        @IDZadVyp int, @IDPlan int, @IDPrikaz int, 
        @Pozadavek numeric(19,6), 
        @Rmnoz_ZadVyp numeric(19,6), @Rmnoz_Plan numeric(19,6), @Rmnoz_Prikaz numeric(19,6), 
        @Smnoz_sklad numeric(19,6), @Smnoz_Prikaz numeric(19,6), @Smnoz_VedProd numeric(19,6), 
        @Kmnoz_ZadVyp numeric(19,6), @Kmnoz_Plan numeric(19,6) 
IF @Oblast_Rez=1 OR @Oblast_EP=1 OR @Oblast_Obj=1 OR @Oblast_NabSes=1 OR @Oblast_Kontr=1 
 INSERT INTO TabPozaZDok_kalk (Oblast, IDPohyb, IDPohyb_Pom, IDZboSklad, IDKmenZbozi, IDZakazModif, IDDoklad, IDZakazka, CisloOrg, mnoz_ZadVyp, mnoz_Plan, mnoz_Prikaz, mnoz_VedProd, mnoz_sklad, Mnozstvi, Pozadavek, Termin) 
  SELECT CASE PZ.druhPohybuZbo WHEN 10 THEN 0 
                               WHEN  9 THEN 1 
                               WHEN  6 THEN 2 
                               WHEN 11 THEN (CASE WHEN ParK.M IS NULL THEN 3 ELSE 4 END) END, 
         PZ.ID, CASE WHEN PZ.TypVyrobnihoDokladu=4 AND 1=0 THEN PZ.DokladPrikazu ELSE PZ.ID END, PZ.IDZboSklad, SS.IDKmenZbozi, PZ.IDZakazModif, PZ.IDDoklad, Z.ID, DZ.CisloOrg, 
         0.0, 0.0, 0.0, 0.0, 0.0,  
         (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi, (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi, 
         CONVERT(datetime,CONVERT(int,CONVERT(FLOAT, ISNULL(ISNULL(PZ.PotvrzDatDod,ISNULL(PZ.PozadDatDod,DZ.TerminDodavkyDat))-KZ.LhutaNaskladneni,getdate()) ))) 
    FROM TabPohybyZbozi PZ 
      INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.PoradoveCislo>=0 AND DZ.splneno=0) 
      INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad) 
      INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.dilec=1) 
      LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=ISNULL(PZ.CisloZakazky, DZ.CisloZakazky)) 
      LEFT OUTER JOIN TabParKontr ParK ON (ParK.IDDoklad=PZ.IDDoklad) 
    WHERE (@Sklad IS NULL OR SS.IDSklad=@Sklad) AND DZ.RadaDokladu IN ('320','330','420','430','374') AND PZ.Mnozstvi>PZ.MnOdebrane AND 
          (@Oblast_Rez=1 AND PZ.DruhPohybuZbo=10 OR 
           @Oblast_EP=1 AND PZ.DruhPohybuZbo=9 OR 
           @Oblast_Obj=1 AND PZ.DruhPohybuZbo=6 OR 
           @Oblast_NabSes=1 AND PZ.DruhPohybuZbo=11 AND ParK.M IS NULL OR 
           @Oblast_Kontr=1 AND PZ.DruhPohybuZbo=11 AND ParK.M=0) 

IF NOT EXISTS(SELECT * FROM TabPozaZDok_kalk) RETURN 0 

IF @RespPredbPlan=0 AND @RespPlan=0 AND @RespPrikaz=0 AND @RespSklad=0 AND @RespVedProd=0 RETURN 0 
CREATE TABLE #TabAdresZadVyp_Map(IDPozaZDok int NOT NULL, IDZadVyp int NOT NULL) 
 CREATE TABLE #TabAdresZadVyp_Stav(IDZadVyp int NOT NULL, IDKmenZbozi int NOT NULL, Mnozstvi numeric(19,6) NOT NULL, PRIMARY KEY(IDZadVyp)) 
 CREATE INDEX ix_TabAdresZadVyp_Stav_IDKmenZbozi ON #TabAdresZadVyp_Stav (IDKmenZbozi) ON [PRIMARY] 
CREATE TABLE #TabAdresPlan_Map(IDPozaZDok int NOT NULL, IDPlan int NOT NULL) 
 CREATE TABLE #TabAdresPlan_Stav(IDPlan int NOT NULL, IDKmenZbozi int NOT NULL, Mnozstvi numeric(19,6) NOT NULL, PRIMARY KEY(IDPlan)) 
 CREATE INDEX ix_TabAdresPlan_Stav_IDKmenZbozi ON #TabAdresPlan_Stav (IDKmenZbozi) ON [PRIMARY] 
CREATE TABLE #TabAdresPrikaz_Map(IDPozaZDok int NOT NULL, IDPrikaz int NOT NULL) 
 CREATE INDEX ix_TabAdresPrikaz_Map_IDPozaZDok ON #TabAdresPrikaz_Map (IDPozaZDok) ON [PRIMARY] 
 CREATE TABLE #TabAdresPrikaz_Stav(IDPrikaz int NOT NULL, IDZboSklad int NULL, Mnozstvi numeric(19,6) NOT NULL, MnozstviZive numeric(19,6) NOT NULL, PRIMARY KEY(IDPrikaz)) 
 CREATE INDEX ix_TabAdresPrikaz_Stav_IDZboSklad ON #TabAdresPrikaz_Stav (IDZboSklad) ON [PRIMARY] 
CREATE TABLE #TabVirtStavyS(IDZboSklad int NOT NULL, mnoz_sklad numeric(19,6) NOT NULL, mnoz_Prikaz numeric(19,6) NOT NULL, mnoz_VedProd numeric(19,6) NOT NULL, PRIMARY KEY(IDZboSklad)) 
CREATE TABLE #TabVirtStavyK(IDKmenZbozi int NOT NULL, mnoz_ZadVyp numeric(19,6) NOT NULL, mnoz_Plan numeric(19,6) NOT NULL, PRIMARY KEY(IDKmenZbozi)) 

DECLARE crPozZOdv1 CURSOR FAST_FORWARD LOCAL FOR 
  SELECT PD.ID, X.IDZadVyp, X.IDPlan, X.IDPrikaz 
    FROM (      (SELECT IDPozaZDok, IDZadVyp=IDZadVyp, IDPlan=NULL, IDPrikaz=NULL FROM #TabAdresZadVyp_Map) 
          UNION (SELECT IDPozaZDok, IDZadVyp=NULL, IDPlan=IDPlan, IDPrikaz=NULL FROM #TabAdresPlan_Map) 
          UNION (SELECT IDPozaZDok, IDZadVyp=NULL, IDPlan=NULL, IDPrikaz=IDPrikaz FROM #TabAdresPrikaz_Map) ) X 
      INNER JOIN TabPozaZDok_kalk PD ON (PD.ID=X.IDPozaZDok) 
    ORDER BY CASE WHEN PD.Oblast<>5 AND EXISTS(SELECT * FROM #TabAdresPrikaz_Map P_M INNER JOIN TabPrikaz P ON (P.ID=P_M.IDPrikaz) WHERE P_M.IDPozaZDok=PD.ID AND P.kusy_odved>0.0) THEN 1 ELSE 2 END ASC, 
             PD.termin ASC, PD.mnozstvi ASC 
OPEN crPozZOdv1 
FETCH NEXT FROM crPozZOdv1 INTO @ID, @IDZadVyp, @IDPlan, @IDPrikaz 

WHILE @@fetch_status=0 
  BEGIN 
    SELECT @Rmnoz_ZadVyp=0.0, @Rmnoz_Plan=0.0, @Rmnoz_Prikaz=0.0, @Pozadavek=Pozadavek FROM TabPozaZDok_kalk WHERE ID=@ID 
    IF @Pozadavek>0 
      BEGIN 
        IF @IDZadVyp IS NOT NULL 
          BEGIN 
            SELECT @Rmnoz_ZadVyp=Mnozstvi FROM #TabAdresZadVyp_Stav WHERE IDZadVyp=@IDZadVyp 
            IF @Rmnoz_ZadVyp>@Pozadavek SET @Rmnoz_ZadVyp=@Pozadavek 
            SET @Pozadavek=@Pozadavek-@Rmnoz_ZadVyp 
            UPDATE #TabAdresZadVyp_Stav SET Mnozstvi=Mnozstvi - @Rmnoz_ZadVyp WHERE IDZadVyp=@IDZadVyp 
          END 
        IF @IDPlan IS NOT NULL 
          BEGIN 
            SELECT @Rmnoz_Plan=Mnozstvi FROM #TabAdresPlan_Stav WHERE IDPlan=@IDPlan 
            IF @Rmnoz_Plan>@Pozadavek SET @Rmnoz_Plan=@Pozadavek 
            SET @Pozadavek=@Pozadavek-@Rmnoz_Plan 
            UPDATE #TabAdresPlan_Stav SET Mnozstvi=Mnozstvi - @Rmnoz_Plan WHERE IDPlan=@IDPlan 
          END 
        IF @IDPrikaz IS NOT NULL 
          BEGIN 
            SELECT @Rmnoz_Prikaz=Mnozstvi FROM #TabAdresPrikaz_Stav WHERE IDPrikaz=@IDPrikaz 
            IF @Rmnoz_Prikaz>@Pozadavek SET @Rmnoz_Prikaz=@Pozadavek 
            SET @Pozadavek=@Pozadavek-@Rmnoz_Prikaz 
            UPDATE #TabAdresPrikaz_Stav SET Mnozstvi=Mnozstvi - @Rmnoz_Prikaz, MnozstviZive=CASE WHEN MnozstviZive - @Rmnoz_Prikaz < 0.0 THEN 0.0 ELSE MnozstviZive - @Rmnoz_Prikaz END WHERE IDPrikaz=@IDPrikaz 
          END 
        UPDATE TabPozaZDok_kalk SET mnoz_ZadVyp=mnoz_ZadVyp + @Rmnoz_ZadVyp, mnoz_Plan=mnoz_Plan + @Rmnoz_Plan, mnoz_Prikaz=mnoz_Prikaz + @Rmnoz_Prikaz, pozadavek=@Pozadavek WHERE ID=@ID 
      END 
    FETCH NEXT FROM crPozZOdv1 INTO @ID, @IDZadVyp, @IDPlan, @IDPrikaz 
  END 
CLOSE crPozZOdv1 
DEALLOCATE crPozZOdv1 

DECLARE crPozZOdv2 CURSOR FAST_FORWARD LOCAL FOR 
    SELECT PD.ID, PD.Oblast, PD.IDKmenZbozi, PD.IDZboSklad, PD.pozadavek 
      FROM TabPozaZDok_kalk PD 
      ORDER BY CASE WHEN PD.Oblast<>5 AND EXISTS(SELECT * FROM #TabAdresPrikaz_Map P_M INNER JOIN TabPrikaz P ON (P.ID=P_M.IDPrikaz) WHERE P_M.IDPozaZDok=PD.ID AND P.kusy_odved>0.0) THEN 1 ELSE 2 END ASC, 
               PD.termin ASC, PD.mnozstvi ASC 
OPEN crPozZOdv2 
FETCH NEXT FROM crPozZOdv2 INTO @ID, @Oblast, @IDKmenZbozi, @IDZboSklad, @Pozadavek 
WHILE @@fetch_status=0 
  BEGIN 
    SELECT @Smnoz_sklad=0.0, @Smnoz_Prikaz=0.0, @Smnoz_VedProd=0.0, 
           @Kmnoz_ZadVyp=0.0, @Kmnoz_Plan=0.0 
    SELECT @Smnoz_sklad=mnoz_sklad, @Smnoz_Prikaz=mnoz_Prikaz, @Smnoz_VedProd=mnoz_VedProd FROM #TabVirtStavyS WHERE IDZboSklad=@IDZboSklad 
    SELECT @Kmnoz_ZadVyp=mnoz_ZadVyp, @Kmnoz_Plan=mnoz_Plan FROM #TabVirtStavyK WHERE IDKmenZbozi=@IDKmenZBozi 
    IF @Kmnoz_ZadVyp>@Pozadavek SET @Kmnoz_ZadVyp=@Pozadavek 
    SET @Pozadavek=@Pozadavek-@Kmnoz_ZadVyp 
    IF @Kmnoz_Plan>@Pozadavek SET @Kmnoz_Plan=@Pozadavek 
    SET @Pozadavek=@Pozadavek-@Kmnoz_Plan 
    IF @Smnoz_Prikaz>@Pozadavek SET @Smnoz_Prikaz=@Pozadavek 
    SET @Pozadavek=@Pozadavek-@Smnoz_Prikaz 
    IF @Smnoz_VedProd>@Pozadavek SET @Smnoz_VedProd=@Pozadavek 
    SET @Pozadavek=@Pozadavek-@Smnoz_VedProd 
    IF @Smnoz_sklad<0.0 SET @Smnoz_sklad=0.0 
    IF @Smnoz_sklad>@Pozadavek SET @Smnoz_sklad=@Pozadavek 
    SET @Pozadavek=@Pozadavek-@Smnoz_sklad 
    UPDATE TabPozaZDok_kalk SET mnoz_ZadVyp=mnoz_ZadVyp + @Kmnoz_ZadVyp, mnoz_Plan=mnoz_Plan + @Kmnoz_Plan, mnoz_Prikaz=mnoz_Prikaz + @Smnoz_Prikaz, mnoz_VedProd=@Smnoz_VedProd, mnoz_sklad=@Smnoz_sklad, pozadavek=@Pozadavek WHERE ID=@ID 
    UPDATE #TabVirtStavyS SET mnoz_sklad=mnoz_sklad-@Smnoz_sklad, mnoz_Prikaz=mnoz_Prikaz-@Smnoz_Prikaz, mnoz_VedProd=mnoz_VedProd-@Smnoz_VedProd WHERE IDZboSklad=@IDZboSklad 
    UPDATE #TabVirtStavyK SET mnoz_ZadVyp=mnoz_ZadVyp-@Kmnoz_ZadVyp, mnoz_Plan=mnoz_Plan-@Kmnoz_Plan WHERE IDKmenZBozi=@IDKmenZBozi 
    FETCH NEXT FROM crPozZOdv2 INTO @ID, @Oblast, @IDKmenZbozi, @IDZboSklad, @Pozadavek 
  END 
CLOSE crPozZOdv2 
DEALLOCATE crPozZOdv2 
DROP TABLE #TabAdresZadVyp_Map 
 DROP TABLE #TabAdresZadVyp_Stav 
DROP TABLE #TabAdresPlan_Map 
 DROP TABLE #TabAdresPlan_Stav 
DROP TABLE #TabAdresPrikaz_Map 
 DROP TABLE #TabAdresPrikaz_Stav 
DROP TABLE #TabVirtStavyS 
DROP TABLE #TabVirtStavyK 
GO

