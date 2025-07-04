USE [RayService]
GO

/****** Object:  View [dbo].[TabSTDDenikStandardDataView]    Script Date: 04.07.2025 12:53:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabSTDDenikStandardDataView]  -- UPDATED 20110318
(OperaceStandard,
Sbornik,
CisloUcet,
CisloUctu01,
Strana,
CastkaZust,
CastkaMenaZust,
Mena,
Stav,
IdObdobi,
IdObdobiStavu,
IdObdobiVykazu,
IdObdobiVykazuDetail,
Utvar,
CisloZakazky,
CisloNakladovyOkruh,
CisloOrg,
IdSegment,
IdStandardCislo,
IdStandardOblast,
DatumPripad_X,
DruhyUcet)
AS SELECT
CAST(0 AS TINYINT),
D.Sbornik,
D.CisloUcet,
U.CisloUctu01,
D.Strana,
D.CastkaZust,
D.CastkaMenaZust,
D.Mena,
D.Stav,
D.IdObdobi,
D.IdObdobiStavu,
OV.ID,
O.ID,
D.Utvar,
D.CisloZakazky,
D.CisloNakladovyOkruh,
D.CisloOrg,
NULL,
NULL,
NULL,
D.DatumPripad_X,
U.DruhyUcet
FROM TabDenik AS D
LEFT OUTER JOIN TabSTDParam AS P ON P.Cislo=1
LEFT OUTER JOIN TabSTDStandard AS S ON S.ID=P.IdStandardData
LEFT OUTER JOIN TabObdobi AS Obd ON Obd.ID=D.IdObdobi
LEFT OUTER JOIN TabSTDObdobiVykazu AS OV ON
(((D.Stav=0)AND(D.DatumPripad_X BETWEEN OV.ObdobiOd_X AND OV.ObdobiDo))
OR((D.Stav=1)AND(OV.PocStavAno=1)
AND((((OV.IdObdobiPocStav IS NULL)AND(Obd.DatumOd_X=OV.ObdobiOd_X))
OR ((OV.IdObdobiPocStav IS NOT NULL)AND(OV.IdObdobiPocStav=D.IdObdobi))))))
LEFT OUTER JOIN TabSTDUctovyRozvrhVstup AS U ON
D.CisloUcet=U.MRCisloUcet AND
U.IdObdobiVykazu=OV.ID AND
U.IdStandard=P.IdStandardData
LEFT OUTER JOIN TabObdobiStavu AS OS ON
OS.ID=D.IdObdobiStavu
LEFT OUTER JOIN TabSTDObdobiVykazuDetail AS O
ON(((OS.ID=O.IdObdobiStavu)AND(O.IdObdobiStavu IS NOT NULL))
OR((((D.DatumPripad_X BETWEEN O.ObdobiOd AND
O.ObdobiDo)AND(D.Stav=0)AND(O.Stav=0))OR((D.Stav>0)AND(D.Stav=O.Stav)))AND(O.IdObdobiStavu
IS NULL)AND(O.IdObdobiVykazu=OV.ID)))
WHERE(D.Zaknihovano>0)
AND(D.Oddeleno=0)
AND(NOT D.Stav=2)
AND(D.Sbornik NOT IN(SELECT CisloSbornik FROM TabSTDSbornik
WHERE TabSTDSbornik.IdObdobiVykazu=OV.ID))
AND ((D.Stav=0)
OR((D.Stav=1)AND(OV.PocStavAno=1)))
AND OV.RezimKopieDenik=0
UNION ALL
SELECT
CAST(1 AS TINYINT),
SC.MRCisloStandardu,
DV.MRCisloUcet,
RV.CisloUctu01,
DV.Strana,
DV.CastkaZust,
ISNULL(DV.CastkaMenaZust,0),
DV.Mena,
DV.Stav,
O.ID,
OVD.IdObdobiStavu,
DV.IdObdobiVykazu,
DV.IdObdobiVykazuDetail,
DV.Utvar,
DV.CisloZakazky,
DV.CisloNakladovyOkruh,
DV.CisloOrg,
DV.IdSegment,
DV.IdStandardCislo,
DV.IdStandardOblast,
DV.DatumPripad_X,
RV.DruhyUcet
FROM TabSTDDenikVstup AS DV
LEFT OUTER JOIN TabObdobi AS O ON DV.DatumPripad BETWEEN O.DatumOd AND O.DatumDo
LEFT OUTER JOIN TabSTDObdobiVykazu AS OVyk ON DV.IdObdobiVykazu=OVyk.ID
LEFT OUTER JOIN TabSTDObdobiVykazuDetail AS OVD ON DV.IdObdobiVykazuDetail=OVD.ID
LEFT OUTER JOIN TabSTDParam AS SP ON SP.Cislo=1
LEFT OUTER JOIN TabSTDStandard AS SS ON SS.ID=SP.IdStandardData
LEFT OUTER JOIN TabSTDStandardCislo AS SC ON SC.ID=DV.IdStandardCislo
LEFT OUTER JOIN TabSTDUctovyRozvrhVstup AS RV ON((DV.MRCisloUcet=RV.MRCisloUcet)AND(RV.IdObdobiVykazu=DV.IdObdobiVykazu)AND(RV.IdStandard=SP.IdStandard))
WHERE DV.IdStandard=SP.IdStandard
AND(NOT DV.Stav=2)
GO

