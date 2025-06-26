USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ASOL_HodnoceniZakazek]    Script Date: 26.06.2025 13:54:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_ASOL_HodnoceniZakazek]
AS
BEGIN -- begin procedure

SET NOCOUNT ON
DECLARE @IdKalkVzor INT=(SELECT MAX(ID) FROM TabCKalkVzor)	-- identifikátor kalkulačního vzorce (lze to předělat jako parametr akce)

-- temporary table pro výpočet plánovaných a skutečných nákladů
IF (OBJECT_ID(N'tempdb..#TabPorPS',N'U') IS NOT NULL) DROP TABLE dbo.#TabPorPS
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
cas_Pl_T TINYINT NOT NULL DEFAULT 1,
cas_Sk NUMERIC(19,6) NOT NULL,
cas_Sk_T TINYINT NOT NULL DEFAULT 1,
OdpracovanyCas NUMERIC(19,6) NOT NULL,
OdpracovanyCas_T TINYINT NOT NULL DEFAULT 1,
ZaplacenyCas NUMERIC(19,6) NOT NULL,
ZaplacenyCas_T TINYINT NOT NULL DEFAULT 1,
cas_Obsluhy_Pl NUMERIC(19,6) NOT NULL,
cas_Obsluhy_Pl_T TINYINT NOT NULL DEFAULT 1,
cas_Obsluhy_Sk NUMERIC(19,6) NOT NULL,
cas_Obsluhy_Sk_T TINYINT NOT NULL DEFAULT 1,
OdpracovanyCas_Obsluhy NUMERIC(19,6) NOT NULL,
OdpracovanyCas_Obsluhy_T TINYINT NOT NULL DEFAULT 1,
ZaplacenyCas_Obsluhy NUMERIC(19,6) NOT NULL,
ZaplacenyCas_Obsluhy_T TINYINT NOT NULL DEFAULT 1,
UhradaZmetku NUMERIC(19,6) NOT NULL,
Prikaz_ukonceno BIT NOT NULL,
Celkem_Pl AS (convert(Numeric(19,6),([mat_Pl] + [MatRezie_Pl] + [koop_Pl] + [mzda_Pl] + [rezies_Pl] + [reziep_Pl] + [reziePrac_Pl] + [NakladyPrac_Pl] + [OPN_Pl] - [VedProdukt_Pl] + [naradi_Pl]))),
Celkem_P_Pl AS (convert(Numeric(19,6),([mat_P_Pl] + [MatRezie_P_Pl] + [koop_P_Pl] + [mzda_P_Pl] + [rezies_P_Pl] + [reziep_P_Pl] + [reziePrac_P_Pl] + [NakladyPrac_P_Pl] + [OPN_P_Pl] - [VedProdukt_P_Pl] + [naradi_P_Pl]))),
Celkem AS (convert(Numeric(19,6),([mat] + [MatRezie] + [koop] + [mzda] + [rezies] + [reziep] + [reziePrac] + [NakladyPrac] + [OPN] - [VedProdukt] + [naradi] + [NespecNakl]))),
Celkem_P AS (convert(Numeric(19,6),([mat_P] + [MatRezie_P] + [koop_P] + [mzda_P] + [rezies_P] + [reziep_P] + [reziePrac_P] + [NakladyPrac_P] + [OPN_P] - [VedProdukt_P] + [naradi_P]))),
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
CHECK(cas_Pl_T BETWEEN 0 AND 2),
CHECK(cas_Sk_T BETWEEN 0 AND 2),
CHECK(OdpracovanyCas_T BETWEEN 0 AND 2),
CHECK(ZaplacenyCas_T BETWEEN 0 AND 2),
CHECK(cas_Obsluhy_Pl_T BETWEEN 0 AND 2),
CHECK(cas_Obsluhy_Sk_T BETWEEN 0 AND 2),
CHECK(OdpracovanyCas_Obsluhy_T BETWEEN 0 AND 2),
CHECK(ZaplacenyCas_Obsluhy_T BETWEEN 0 AND 2))

-- Výpočet plánovaných a skutečných nákladů ve výrobních zakázkách
DECLARE @IDPrikaz INT
DECLARE CursorPrik CURSOR LOCAL FAST_FORWARD FOR SELECT ID FROM TabPrikaz WHERE IDZakazka IN (SELECT ID FROM #TabExtKomID)
OPEN CursorPrik
WHILE 1=1
BEGIN
 FETCH NEXT FROM CursorPrik INTO @IDPrikaz
 IF @@FETCH_STATUS<>0
  BREAK
 EXEC hp_PorovPlanSkutecNaklVyrPrik @IDPrikaz,@IdKalkVzor
END
CLOSE CursorPrik
DEALLOCATE CursorPrik

INSERT INTO Tabx_ASOL_HodnoceniZakazek (IDZakazka,Autor,mat_Pl,matA_Pl,matB_Pl,matC_Pl,MatRezie_Pl,koop_Pl,mzda_Pl,rezieS_Pl,rezieP_Pl,
 ReziePrac_Pl,NakladyPrac_Pl,OPN_Pl,VedProdukt_Pl,naradi_Pl,mat_P_Pl,matA_P_Pl,matB_P_Pl,matC_P_Pl,MatRezie_P_Pl,koop_P_Pl,
 Mzda_P_Pl,rezieS_P_Pl,rezieP_P_Pl,ReziePrac_P_Pl,NakladyPrac_P_Pl,OPN_P_Pl,VedProdukt_P_Pl,naradi_P_Pl,mat,matA,matB,matC,MatRezie,
 koop,mzda,rezieS,rezieP,ReziePrac,NakladyPrac,OPN,VedProdukt,naradi,NespecNakl,mat_P,matA_P,matB_P,matC_P,MatRezie_P,koop_P,
 Mzda_P,rezieS_P,rezieP_P,ReziePrac_P,NakladyPrac_P,OPN_P,VedProdukt_P,naradi_P,cas_Pl,cas_Sk,OdpracovanyCas,ZaplacenyCas,
 cas_Obsluhy_Pl,cas_Obsluhy_Sk,OdpracovanyCas_Obsluhy,ZaplacenyCas_Obsluhy,UhradaZmetku)
SELECT IDZakazka,(SELECT @@spid),SUM(mat_Pl),SUM(matA_Pl),SUM(matB_Pl),SUM(matC_Pl),SUM(MatRezie_Pl),SUM(koop_Pl),SUM(mzda_Pl),
 SUM(rezieS_Pl),SUM(rezieP_Pl),SUM(ReziePrac_Pl),SUM(NakladyPrac_Pl),SUM(OPN_Pl),SUM(VedProdukt_Pl),SUM(naradi_Pl),SUM(mat_P_Pl),
 SUM(matA_P_Pl),SUM(matB_P_Pl),SUM(matC_P_Pl),SUM(MatRezie_P_Pl),SUM(koop_P_Pl),SUM(Mzda_P_Pl),SUM(rezieS_P_Pl),SUM(rezieP_P_Pl),
 SUM(ReziePrac_P_Pl),SUM(NakladyPrac_P_Pl),SUM(OPN_P_Pl),SUM(VedProdukt_P_Pl),SUM(naradi_P_Pl),SUM(mat),SUM(matA),SUM(matB),
 SUM(matC),SUM(MatRezie),SUM(koop),SUM(mzda),SUM(rezieS),SUM(rezieP),SUM(ReziePrac),SUM(NakladyPrac),SUM(OPN),SUM(VedProdukt),
 SUM(naradi),SUM(NespecNakl),SUM(mat_P),SUM(matA_P),SUM(matB_P),SUM(matC_P),SUM(MatRezie_P),SUM(koop_P),SUM(Mzda_P),SUM(rezieS_P),
 SUM(rezieP_P),SUM(ReziePrac_P),SUM(NakladyPrac_P),SUM(OPN_P),SUM(VedProdukt_P),SUM(naradi_P),SUM(cas_Pl_N),SUM(cas_Sk_N),
 SUM(OdpracovanyCas_N),SUM(ZaplacenyCas_N),SUM(cas_Obsluhy_Pl_N),SUM(cas_Obsluhy_Sk_N),SUM(OdpracovanyCas_Obsluhy_N),
 SUM(ZaplacenyCas_Obsluhy_N),SUM(UhradaZmetku)
 FROM #TabPorPS GROUP BY IDZakazka
END -- end procedure
GO

