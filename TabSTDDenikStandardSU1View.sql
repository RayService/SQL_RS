USE [RayService]
GO

/****** Object:  View [dbo].[TabSTDDenikStandardSU1View]    Script Date: 04.07.2025 12:55:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabSTDDenikStandardSU1View]    -- UPDATED 20210625
(OperaceStandard,Stav,CisloUcet,CisloUctu01,Castka,CastkaMD,CastkaDal,CastkaZust,CastkaMena,
CastkaMenaMD,CastkaMenaDal,CastkaMenaZust,Mena,
IdObdobiVykazu,IdObdobiVykazuDetail,Utvar,
CisloZakazky,CisloNakladovyOkruh,CisloOrg,IdSegment,IdStandard,IdStandardCislo,
IdStandardOblast,
DatumPripad)
AS SELECT
0,
D.Stav,
D.CisloUcet,
U.CisloUctu01,
D.Castka,
(SELECT CASE D.Strana WHEN 0 THEN D.CastkaMD ELSE 0 END),
(SELECT CASE D.Strana WHEN 1 THEN D.CastkaDal ELSE 0 END),
D.CastkaZust,
D.CastkaMena,
(SELECT CASE D.Strana WHEN 0 THEN D.CastkaMenaMD ELSE 0 END),
(SELECT CASE D.Strana WHEN 1 THEN D.CastkaMenaDal ELSE 0 END),
D.CastkaMenaZust,
D.Mena,
P.IdObdobiVykazu,
O.ID,
D.Utvar,
D.CisloZakazky,
D.CisloNakladovyOkruh,
D.CisloOrg,
NULL,
P.IdStandard,
NULL,
NULL,
D.DatumPripad
FROM TabDenik AS D
LEFT JOIN TabSTDParam AS P ON P.Cislo=1
LEFT JOIN TabSTDStandard AS S ON S.ID=P.IdStandard
LEFT JOIN TabSTDObdobiVykazu AS OV ON OV.ID=P.IdObdobiVykazu
LEFT JOIN TabSTDUctovyRozvrhVstup AS U ON
D.CisloUcet=U.MRCisloUcet AND
U.IdObdobiVykazu=P.IdObdobiVykazu AND
U.IdStandard=P.IdStandard
LEFT JOIN TabObdobiStavu AS OS ON
OS.ID=D.IdObdobiStavu
LEFT JOIN TabSTDObdobiVykazuDetail AS O
ON(((OS.ID=O.IdObdobiStavu)AND(O.IdObdobiStavu IS NOT NULL))
OR((((D.DatumPripad_X BETWEEN O.ObdobiOd AND
O.ObdobiDo)AND(D.Stav=0)AND(O.Stav=0))OR((D.Stav>0)AND(D.Stav=O.Stav)))AND(O.IdObdobiStavu
IS NULL)AND(O.IdObdobiVykazu=P.IdObdobiVykazu)))
WHERE(D.Zaknihovano>0)
AND(D.Oddeleno=0)
AND(D.Sbornik NOT IN(SELECT CisloSbornik FROM TabSTDSbornik
WHERE TabSTDSbornik.IdObdobiVykazu=P.IdObdobiVykazu))
AND((D.DatumPripad_X BETWEEN OV.ObdobiOd_X AND OV.ObdobiDo_X AND D.Stav=0)
OR(((((D.IdObdobi=OV.IdObdobiPocStav)
AND(D.Stav=1))
AND OV.IdObdobiPocStav IS NOT NULL)
OR(((D.IdObdobi=(SELECT TOP 1 ID FROM TabObdobi WHERE
TabObdobi.DatumOd_X BETWEEN OV.ObdobiOd_X AND OV.ObdobiDo_X)AND(D.Stav=1))
AND OV.IdObdobiPocStav IS NULL)))
AND(OV.PocStavAno=1)))
AND OV.RezimKopieDenik=0
UNION ALL
SELECT
1,
DV.Stav,
DV.MRCisloUcet,
RV.CisloUctu01,
DV.Castka,
(SELECT CASE DV.Strana WHEN 0 THEN DV.CastkaMD ELSE 0 END),
(SELECT CASE DV.Strana WHEN 1 THEN DV.CastkaDal ELSE 0 END),
DV.CastkaZust,
ISNULL(DV.CastkaMena,0),
ISNULL((SELECT CASE DV.Strana WHEN 0 THEN DV.CastkaMenaMD
ELSE 0 END),0),
ISNULL((SELECT CASE DV.Strana WHEN 1 THEN DV.CastkaMenaDal
ELSE 0 END),0),
ISNULL(DV.CastkaMenaZust,0),
DV.Mena,
DV.IdObdobiVykazu,
DV.IdObdobiVykazuDetail,
DV.Utvar,
DV.CisloZakazky,
DV.CisloNakladovyOkruh,
DV.CisloOrg,
DV.IdSegment,
DV.IdStandard,
DV.IdStandardCislo,
DV.IdStandardOblast,
DV.DatumPripad
FROM TabSTDDenikVstup AS DV
LEFT JOIN TabSTDParam AS SP ON SP.Cislo=1
LEFT JOIN TabSTDStandard AS SS ON SS.ID=SP.IdStandard
LEFT JOIN TabSTDObdobiVykazu AS SOV ON SOV.ID=SP.IdObdobiVykazu
LEFT JOIN TabSTDUctovyRozvrhVstup AS RV ON
DV.MRCisloUcet=RV.MRCisloUcet
AND(RV.IdObdobiVykazu=SP.IdObdobiVykazu)
AND(RV.IdStandard=SP.IdStandard)
WHERE(DV.IdObdobiVykazu=SP.IdObdobiVykazu)
AND(DV.IdStandard=SP.IdStandard)
GO

