USE [RayService]
GO

/****** Object:  View [dbo].[TabSTDDenikStandardKonsolView]    Script Date: 04.07.2025 12:54:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabSTDDenikStandardKonsolView]  -- UPDATED 20150926
(OperaceStandard,
ID,
Sbornik,
CisloDokladu,
CisloRadku,
Popis,
DatumKurz,
Kurz,
JednotkaMeny,
CisloUcet,
CisloUctu01,
Strana,
Castka,
CastkaMena,
CastkaMenaFunk,
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
IdStandard,
IdStandardCislo,
IdStandardOblast,
DatumPripad,
DruhyUcet,
DruhData,
DatumSplatno,
ParovaciZnak)
AS SELECT
CAST(0 AS TINYINT),
D.ID,
D.Sbornik,
D.CisloDokladu,
D.CisloRadku,
D.Popis,
D.DatumKurz,
D.Kurz,
D.JednotkaMeny,
D.CisloUcet,
U.CisloUctu01,
D.Strana,
D.Castka,
D.CastkaMena,
ISNULL(CASE D.Strana WHEN 0 THEN D.BilancniMena ELSE -D.BilancniMena END,0),
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
U.IdStandard,
NULL,
NULL,
D.DatumPripad_X,
U.DruhyUcet,
D.DruhData,
D.DatumSplatno_X,
D.ParovaciZnak
FROM TabDenik AS D
LEFT OUTER JOIN TabObdobi AS Obd ON Obd.ID=D.IdObdobi
LEFT OUTER JOIN TabSTDObdobiVykazu AS OV ON
(((D.Stav=0)AND(D.DatumPripad_X BETWEEN OV.ObdobiOd_X AND OV.ObdobiDo))
OR((D.Stav=1)AND(OV.PocStavAno=1)
AND((((OV.IdObdobiPocStav IS NULL)AND(Obd.DatumOd_X=OV.ObdobiOd_X))
OR ((OV.IdObdobiPocStav IS NOT NULL)AND(OV.IdObdobiPocStav=D.IdObdobi))))))
LEFT OUTER JOIN TabSTDUctovyRozvrhVstup AS U ON
D.CisloUcet=U.MRCisloUcet AND
U.IdObdobiVykazu=OV.ID 
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
DV.ID,
SC.MRCisloStandardu,
DV.CisloDokladu,
DV.CisloRadku,
DV.Popis,
DV.DatumKurz,
DV.Kurz,
DV.JednotkaMeny,
DV.MRCisloUcet,
RV.CisloUctu01,
DV.Strana,
DV.Castka,
ISNULL(DV.CastkaMena,0),
ISNULL(DV.CastkaMenaFunk,0),
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
DV.IdStandard,
DV.IdStandardCislo,
DV.IdStandardOblast,
DV.DatumPripad_X,
NULL,
CASE WHEN DV.ParovaciZnak IS NULL THEN 0 ELSE 3 END,
NULL,
DV.ParovaciZnak
FROM TabSTDDenikVstup AS DV
LEFT OUTER JOIN TabObdobi AS O ON DV.DatumPripad BETWEEN O.DatumOd AND O.DatumDo
LEFT OUTER JOIN TabSTDObdobiVykazu AS OVyk ON DV.IdObdobiVykazu=OVyk.ID
LEFT OUTER JOIN TabSTDObdobiVykazuDetail AS OVD ON DV.IdObdobiVykazuDetail=OVD.ID
LEFT OUTER JOIN TabSTDStandard AS SS ON SS.ID=DV.IdStandard
LEFT OUTER JOIN TabSTDStandardCislo AS SC ON SC.ID=DV.IdStandardCislo
LEFT OUTER JOIN TabSTDUctovyRozvrhVstup AS RV ON((DV.MRCisloUcet=RV.MRCisloUcet)AND(RV.IdObdobiVykazu=DV.IdObdobiVykazu)AND(RV.IdStandard=SS.ID))
WHERE NOT DV.Stav=2
GO

