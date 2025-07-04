USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAEDenikView]    Script Date: 04.07.2025 10:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAEDenikView]  -- UPDATED 20180808
(Zdroj,ID,IdObdobi,IdFIAEDruhyKonsOperaci,Sbornik,CisloDokladu,CisloRadku,IdDenikSource,IdFIAEUcJednKonsolIntercomp,DatumPripad,
PopisSource,PopisKonsol,CisloPolozkyKonsVykazu,Strana,Castka,CastkaMena,CastkaMenaFunk,Mena,Kurz,JednotkaMeny,DatumKurz,
Stav,CisloOrg,Utvar,CisloZakazky,CisloNakladovyOkruh,ParovaciZnak,MRCisloSegmentu,DruhData,DatumSplatno,
IdFIAEUcJednKonsol,UcetMD,UcetDAL,CastkaMD,CastkaDAL,CastkaZust,CastkaMenaMD,CastkaMenaDAL,CastkaMenaZust,
CastkaMenaFunkMD,CastkaMenaFunkDal,CastkaMenaFunkZust,Intercomp,ICOOrgSource,
CastkaUplat,CastkaUplatMD,CastkaUplatDAL,CastkaUplatZust,Partner)
AS
SELECT 
0,D.ID+1000000000,D.IdObdobi,D.IdFIAEDruhyKonsOperaci,CAST(DKO.CisloDruhuKonsOperace AS NVARCHAR(3)),D.CisloDokladu,D.CisloRadku,D.IdDenikSource,D.IdFIAEUcJednKonsolIntercomp,
CONVERT(DATETIME,CONVERT(DATE,D.DatumPripad)),D.PopisSource,D.PopisKonsol,D.CisloPolozkyKonsVykazu,D.Strana,
ISNULL(D.Castka,0),ISNULL(D.CastkaMena,0),ISNULL(D.CastkaMenaFunk,0),D.Mena,D.Kurz,D.JednotkaMeny,CONVERT(DATETIME,CONVERT(DATE,D.DatumKurz)),
D.Stav,D.CisloOrg,D.Utvar,D.CisloZakazky,D.CisloNakladovyOkruh,D.ParovaciZnak,D.MRCisloSegmentu,D.DruhData,CONVERT(DATETIME,CONVERT(DATE,D.DatumSplatno)),
D.IdFIAEUcJednKonsol,D.UcetMD,D.UcetDAL,ISNULL(D.CastkaMD,0),ISNULL(D.CastkaDAL,0),ISNULL(D.CastkaZust,0),ISNULL(D.CastkaMenaMD,0),
ISNULL(D.CastkaMenaDAL,0),ISNULL(D.CastkaMenaZust,0),ISNULL(D.CastkaMenaFunkMD,0),ISNULL(D.CastkaMenaFunkDal,0),ISNULL(D.CastkaMenaFunkZust,0), 
ISNULL(PKV.Intercomp,0),CAST(D.ICOOrgSource AS NVARCHAR(20)),
ISNULL(D.Castka,0),ISNULL(D.CastkaMD,0),ISNULL(D.CastkaDAL,0),ISNULL(D.CastkaZust,0),D.Partner
FROM TabFIAEDenik AS D
LEFT OUTER JOIN TabFIAEPolozkyKonsVykazu AS PKV ON PKV.CisloPolozkyKonsVykazu=D.CisloPolozkyKonsVykazu AND PKV.IdObdobi=D.IdObdobi
LEFT OUTER JOIN TabFIAEDruhyKonsOperaci AS DKO ON DKO.ID=D.IdFIAEDruhyKonsOperaci
UNION ALL
SELECT 
1,DM.ID,DM.IdObdobi,0,DM.Sbornik,DM.CisloDokladu,DM.CisloRadku,DM.IdDenikSource,DM.IdFIAEUcJednKonsolIntercomp,CONVERT(DATETIME,CONVERT(DATE,DM.DatumPripad)),
DM.PopisSource,DM.PopisKonsol,DM.CisloPolozkyKonsVykazu,DM.Strana,DM.Castka,DM.CastkaMena,DM.CastkaMenaFunk,DM.Mena,DM.Kurz,DM.JednotkaMeny,CONVERT(DATETIME,CONVERT(DATE,DM.DatumKurz)),
DM.Stav,DM.CisloOrg,DM.Utvar,DM.CisloZakazky,DM.CisloNakladovyOkruh,DM.ParovaciZnak,DM.MRCisloSegmentu,DM.DruhData,CONVERT(DATETIME,CONVERT(DATE,DM.DatumSplatno)),
(SELECT TOP 1 ID FROM TabFIAEUcJednKonsol WHERE TabFIAEUcJednKonsol.IdObdobi=DM.IdObdobi AND TabFIAEUcJednKonsol.ActualComp = 1),
CASE DM.Strana WHEN 0 THEN DM.CisloPolozkyKonsVykazu ELSE NULL END,
CASE DM.Strana WHEN 1 THEN DM.CisloPolozkyKonsVykazu ELSE NULL END,
ISNULL(CASE DM.Strana WHEN 0 THEN DM.Castka ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 1 THEN DM.Castka ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.Castka ELSE -DM.Castka END,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.CastkaMena ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 1 THEN DM.CastkaMena ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.CastkaMena ELSE -DM.CastkaMena END,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.CastkaMenaFunk ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 1 THEN DM.CastkaMenaFunk ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.CastkaMenaFunk ELSE -DM.CastkaMenaFunk END,0),
ISNULL(PKV.Intercomp,0),
CAST(DM.ICOOrgSource AS NVARCHAR(20)),
ISNULL(DM.Castka,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.Castka ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 1 THEN DM.Castka ELSE 0 END,0),
ISNULL(CASE DM.Strana WHEN 0 THEN DM.Castka ELSE -DM.Castka END,0),
DM.Partner
FROM TabFIAEDenikSourceMatka AS DM 
LEFT OUTER JOIN TabFIAEPolozkyKonsVykazu AS PKV 
ON PKV.CisloPolozkyKonsVykazu=DM.CisloPolozkyKonsVykazu AND PKV.IdObdobi=DM.IdObdobi
UNION ALL
SELECT 
2,-DS.ID,DS.IdObdobi,0,DS.Sbornik,DS.CisloDokladu,DS.CisloRadku,DS.IdDenikSource,DS.IdFIAEUcJednKonsolIntercomp,CONVERT(DATETIME,CONVERT(DATE,DS.DatumPripad)),
DS.PopisSource,DS.PopisKonsol,DS.CisloPolozkyKonsVykazu,DS.Strana,DS.Castka,DS.CastkaMena,DS.CastkaMenaFunk,DS.Mena,DS.Kurz,DS.JednotkaMeny,CONVERT(DATETIME,CONVERT(DATE,DS.DatumKurz)),
DS.Stav,DS.CisloOrg,DS.Utvar,DS.CisloZakazky,DS.CisloNakladovyOkruh,DS.ParovaciZnak,DS.MRCisloSegmentu,DS.DruhData,CONVERT(DATETIME,CONVERT(DATE,DS.DatumSplatno)),DS.IdFIAEUcJednKonsol,
CASE DS.Strana WHEN 0 THEN DS.CisloPolozkyKonsVykazu ELSE NULL END,
CASE DS.Strana WHEN 1 THEN DS.CisloPolozkyKonsVykazu ELSE NULL END,
ISNULL(CASE DS.Strana WHEN 0 THEN DS.Castka ELSE 0 END,0),
ISNULL(CASE DS.Strana WHEN 1 THEN DS.Castka ELSE 0 END,0),
ISNULL(CASE DS.Strana WHEN 0 THEN DS.Castka ELSE -DS.Castka END,0),
ISNULL(CASE DS.Strana WHEN 0 THEN DS.CastkaMena ELSE 0 END,0),
ISNULL(CASE DS.Strana WHEN 1 THEN DS.CastkaMena ELSE 0 END,0),
ISNULL(CASE DS.Strana WHEN 0 THEN DS.CastkaMena ELSE -DS.CastkaMena END,0),
ISNULL(CASE DS.Strana WHEN 0 THEN DS.CastkaMenaFunk ELSE 0 END,0),
ISNULL(CASE DS.Strana WHEN 1 THEN DS.CastkaMenaFunk ELSE 0 END,0),
ISNULL(CASE DS.Strana WHEN 0 THEN DS.CastkaMenaFunk ELSE -DS.CastkaMenaFunk END,0),
ISNULL(PKV.Intercomp,0),
CAST(DS.ICOOrgSource AS NVARCHAR(20)),
ISNULL(CAST(DS.Castka * UJK.ProcentoDoKonsolidace/100 AS NUMERIC(19,6)),0),
ISNULL(CAST((CASE DS.Strana WHEN 0 THEN DS.Castka * UJK.ProcentoDoKonsolidace/100 ELSE 0 END) AS NUMERIC(19,6)),0),
ISNULL(CAST((CASE DS.Strana WHEN 1 THEN DS.Castka * UJK.ProcentoDoKonsolidace/100 ELSE 0 END) AS NUMERIC(19,6)),0),
ISNULL(CAST((CASE DS.Strana WHEN 0 THEN DS.Castka * UJK.ProcentoDoKonsolidace/100 ELSE -DS.Castka * UJK.ProcentoDoKonsolidace/100 END) AS NUMERIC(19,6)),0),
DS.Partner
FROM TabFIAEDenikSource AS DS
LEFT OUTER JOIN TabFIAEPolozkyKonsVykazu AS PKV ON PKV.CisloPolozkyKonsVykazu=DS.CisloPolozkyKonsVykazu AND PKV.IdObdobi=DS.IdObdobi
LEFT OUTER JOIN TabFIAEUcJednKonsol AS UJK ON DS.IdFIAEUcJednKonsol=UJK.ID
GO

