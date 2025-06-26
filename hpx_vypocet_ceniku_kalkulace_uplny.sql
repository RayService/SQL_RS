USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_vypocet_ceniku_kalkulace_uplny]    Script Date: 26.06.2025 11:46:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_vypocet_ceniku_kalkulace_uplny]
@ID INT
AS
SET NOCOUNT ON
-- =============================================
-- Author:		MŽ
-- Create date:            5.6.2019
-- Description:	Generování kusovníku (ceníku) pro označené záznamy v položkách pro kalkulaci.
-- =============================================
DECLARE @IDPol INT
SELECT @IDPol = (SELECT IDKmenZbozi FROM TabPozaZDok_kalk WHERE ID = @ID)
DECLARE @IDParNapoctu int, @IDZakazModif int, @datumTPV datetime, @DatumKalkCen datetime, @Mnozstvi numeric(19,6), @Err int, @RespekPlanZtratyPriVyrobeDilcu bit, @DelitFixniMnozstviOptDavkou bit, @KalkCenyKDnesku bit, 
          @RespekNedelitMJ bit, @VcetneNulovychKV bit, @RespekDodatecneProcZtratKV bit, @IDZakazka INT
  SELECT @IDParNapoctu=2, @IDZakazModif=NULL, @datumTPV=GETDATE(), @Mnozstvi=1, @RespekPlanZtratyPriVyrobeDilcu=1, @DelitFixniMnozstviOptDavkou=0, @KalkCenyKDnesku=1, @RespekNedelitMJ=0, @VcetneNulovychKV=0, @RespekDodatecneProcZtratKV=1, @IDZakazka = (SELECT IDZakazka FROM TabPozaZDok_kalk WHERE ID = @ID)
  IF @KalkCenyKDnesku=1 EXEC hp_GetDnesniDatumX @DatumKalkCen OUTPUT 
                   ELSE SET @DatumKalkCen=@datumTPV 

--smazání tabulky pro označenou položku a zakázku
DELETE TabStrukKusovnik_kalk FROM TabStrukKusovnik_kalk
JOIN TabPozaZDok_kalk ON TabPozaZDok_kalk.IDKmenZbozi = TabStrukKusovnik_kalk.IDFinal
WHERE TabStrukKusovnik_kalk.IDFinal = @IDPol AND TabStrukKusovnik_kalk.IDZakazka = @IDZakazka


--naplnění tabulky kusovníku
CREATE TABLE #tabKusovnik_ProStrukKus (vyssi integer NULL, IDKmenZbozi integer NOT NULL, uroven integer NOT NULL, poradi integer NOT NULL, IDKVazby integer NULL, mnozstvi numeric(20,6) NOT NULL, prirez numeric(20,6) NULL, RezijniMat bit NOT NULL, VyraditZKalkulace bit NOT NULL, Strom nvarchar(1000) COLLATE database_default NOT NULL) 
  INSERT INTO #tabKusovnik_ProStrukKus EXEC @Err=hp_generujKusovnik @IDPol, @Mnozstvi, @DatumTPV, 1, 0, 1, 0, 1, @RespekPlanZtratyPriVyrobeDilcu=@RespekPlanZtratyPriVyrobeDilcu, @DelitFixniMnozstviOptDavkou=@DelitFixniMnozstviOptDavkou, 
                                                                    @RespekNedelitMJ=@RespekNedelitMJ, @IDZakazModif=@IDZakazModif, @RespekDodatecneProcZtratKV=@RespekDodatecneProcZtratKV, @VcetneNulovychKV=@VcetneNulovychKV 
  INSERT INTO TabStrukKusovnik_kalk (IDZakazka,IDParNapoctu,IDFinal,IDNizsi,mnf,CPrirez,Autor,Dat_vypoctu,dilec,material,Vypocteny_prumer,Cena_2,Cena_dilec,Cena_vypoctena)  
        SELECT @IDZakazka, @IDParNapoctu, @IDPol, GK.IDKmenZbozi, SUM(GK.mnozstvi), SUM(GK.prirez), SUSER_SNAME(),GETDATE(),KZ.Dilec,KZ.Material,0,0,0,0
          FROM #tabKusovnik_ProStrukKus GK 
            INNER JOIN TabKmenZbozi KZ ON (KZ.ID=GK.IDKmenZbozi) 
            LEFT OUTER JOIN TabKalkCe KC_M ON (KZ.Material=1 AND KC_M.IDKmenZbozi=GK.IDKmenZbozi AND KC_M.IDZakazModif=@IDZakazModif) 
            LEFT OUTER JOIN TabKalkCe KC ON (KZ.Material=1 AND KC_M.ID IS NULL AND KC.IDKmenZbozi=GK.IDKmenZbozi AND EXISTS(SELECT * FROM tabczmeny ZodKC  
                                                                                       LEFT OUTER JOIN tabczmeny ZdoKC ON (ZDoKC.ID=KC.zmenaDo) 
                                                                                      WHERE ZodKC.ID=KC.zmenaOd AND ZodKC.platnostTPV=1 AND @DatumKalkCen>=ZodKC.datum AND 
                                                                                            (KC.ZmenaDo IS NULL OR ZdoKC.platnostTPV=0 OR (ZDoKC.platnostTPV=1 AND @DatumKalkCen<ZDoKC.datum)) 
                                                                                    ) ) 
            LEFT OUTER JOIN TabZakazModifDilce ZMD ON (KZ.Dilec=1 AND ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=GK.IDKmenZbozi AND ZMD.ZKalkulModif=1) 
            LEFT OUTER JOIN TabZKalkulace ZK1 ON (KZ.Dilec=1 AND ZMD.ID IS NULL AND ZK1.Dilec=GK.IDKmenZbozi AND ZK1.IDZakazModif IS NULL AND 
                                                     EXISTS(SELECT * FROM tabczmeny ZodZK 
                                                                LEFT OUTER JOIN tabczmeny ZdoZK ON (ZDoZK.ID=ZK1.zmenaDo) 
                                                              WHERE ZodZK.ID=ZK1.zmenaOd AND ZodZK.platnostTPV=1 AND @DatumKalkCen>=ZodZK.datum AND 
                                                                    (ZK1.ZmenaDo IS NULL OR ZdoZK.platnostTPV=0 OR (ZDoZK.platnostTPV=1 AND @DatumKalkCen<ZDoZK.datum)) ) ) 
            LEFT OUTER JOIN TabZKalkulace ZK2 ON (KZ.Dilec=1 AND ZMD.ID IS NOT NULL AND ZK2.Dilec=GK.IDKmenZbozi AND ZK2.IDZakazModif=ZMD.IDZakazModif) 
            LEFT OUTER JOIN TabZKalkulace ZK ON (KZ.Dilec=1 AND ZK.ID=(SELECT ZK1.ID WHERE ZK1.ID IS NOT NULL UNION ALL SELECT ZK2.ID WHERE ZK2.ID IS NOT NULL))
		GROUP BY GK.IDKmenZbozi, KZ.Dilec, KZ.Material

--smazání po sobě dočasné tabulky
IF OBJECT_ID(N'tempdb..#tabKusovnik_ProStrukKus') IS NOT NULL DROP TABLE #tabKusovnik_ProStrukKus			


/*
INSERT INTO TabStrukKusovnik_kalk (IDZakazka,IDNizsi,IDVyssi,mnf,patro,strom,Autor,Dat_vypoctu,dilec,material,Vypocteny_prumer,Cena_2,Cena_dilec,Cena_vypoctena)  
SELECT tpzdk.IDZakazka,tkv.nizsi, tkv.vyssi, tkv.pozice, SUM(tkv.mnozstviSeZtratou), SUSER_SNAME(),GETDATE(),KZ.Dilec,KZ.Material,0,0,0,0
FROM TabPozaZDok_kalk tpzdk
LEFT OUTER JOIN TabKvazby tkv ON tpzdk.IDKmenZbozi = tkv.vyssi
LEFT OUTER JOIN TabKmenZbozi KZ ON KZ.ID = tkv.nizsi AND tkv.ZmenaDo IS NULL
WHERE tkv.ZmenaDo IS NULL
GROUP BY tpzdk.IDZakazka,tkv.nizsi, tkv.vyssi,tkv.pozice,KZ.Dilec,KZ.Material
*/
GO

