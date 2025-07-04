USE [RayService]
GO

/****** Object:  View [dbo].[TabSTDDenikStandardView]    Script Date: 04.07.2025 12:56:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabSTDDenikStandardView]    -- UPDATED 20250603
(OperaceStandard,DenikUnionID,Sbornik,CisloDokladu,CisloRadku,Popis,
CisloUcet,CisloUctu01,Strana, Castka,CastkaMD,CastkaDal,CastkaZust,CastkaMena,
CastkaMenaMD,CastkaMenaDal,CastkaMenaZust,Mena,Kurz,JednotkaMeny,KurzEuro,
DatumKurz,Stav,IdObdobi,IdObdobiStavu,IdObdobiVykazu,IdObdobiVykazuDetail,Utvar,
CisloZakazky,CisloNakladovyOkruh,CisloOrg,IdSegment,IdStandard,IdStandardCislo,
IdStandardOblast,DatumPripad,DatumPripad_X,DatumPripad_Y,DatumPripad_M,
DatumPripad_D,DatumPripad_Q,DatumPripad_W,DatumPripad_YM,CastkaMenaB,
CastkaMenaBMD,CastkaMenaBDal,CastkaMenaBZust,MenaB,KurzB,JednotkaMenyB,TypKurzu,
ParovaciZnak,Autor,DatPorizeni,Zmenil,DatZmeny,IdDenikStorno)
AS SELECT
CAST(0 AS TINYINT),
D.Id,
D.Sbornik,
D.CisloDokladu,
D.CisloRadku,
D.Popis,
D.CisloUcet,
U.MRCisloUctu01,
D.Strana,
D.Castka,
(SELECT CASE D.Strana WHEN 0 THEN D.CastkaMD ELSE 0 END),
(SELECT CASE D.Strana WHEN 1 THEN D.CastkaDal ELSE 0 END),
D.CastkaZust,
D.CastkaMena,
(SELECT CASE D.Strana WHEN 0 THEN D.CastkaMenaMD ELSE 0 END),
(SELECT CASE D.Strana WHEN 1 THEN D.CastkaMenaDal ELSE 0 END),
D.CastkaMenaZust,
D.Mena,
D.Kurz,
D.JednotkaMeny,
D.KurzEuro,
D.DatumKurz,
D.Stav,
D.IdObdobi,
D.IdObdobiStavu,
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
D.DatumPripad,
D.DatumPripad_X,
D.DatumPripad_Y,
D.DatumPripad_M,
D.DatumPripad_D,
D.DatumPripad_Q,
D.DatumPripad_W,
(SELECT CASE D.Stav WHEN 0 THEN
D.DatumPripad_Y*100+D.DatumPripad_M WHEN 1 THEN
D.DatumPripad_Y*100 ELSE D.DatumPripad_Y*100 + 99 END),
CASE WHEN ((S.MenaBDenik = 0) OR (ISNULL(D.BilancniMena,0) = 0 AND S.MenaBDenik = 2)) THEN
CONVERT(NUMERIC(19,6),ROUND(D.Castka*(CASE P.ZpusobKurzuB WHEN 0 THEN K.JednotkaMeny/K.Kurz ELSE K.Kurz/K.JednotkaMeny END),2))
ELSE CONVERT(NUMERIC(19,6),ISNULL(D.BilancniMena,0)) END,
CASE WHEN ((S.MenaBDenik = 0) OR (ISNULL(D.BilancniMena,0) = 0 AND S.MenaBDenik = 2)) THEN
CONVERT(NUMERIC(19,6),ROUND(D.Castka*(CASE P.ZpusobKurzuB WHEN 0 THEN K.JednotkaMeny/K.Kurz ELSE K.Kurz/K.JednotkaMeny END),2)*(-D.Strana+1))
ELSE CONVERT(NUMERIC(19,6),ISNULL(D.BilancniMena,0)*(-D.Strana+1)) END,
CASE WHEN ((S.MenaBDenik = 0) OR (ISNULL(D.BilancniMena,0) = 0 AND S.MenaBDenik = 2)) THEN
CONVERT(NUMERIC(19,6),ROUND(D.Castka*(CASE P.ZpusobKurzuB WHEN 0 THEN K.JednotkaMeny/K.Kurz ELSE K.Kurz/K.JednotkaMeny END),2)*D.Strana)
ELSE CONVERT(NUMERIC(19,6),ISNULL(D.BilancniMena,0)*D.Strana) END,
CASE WHEN ((S.MenaBDenik = 0) OR (ISNULL(D.BilancniMena,0) = 0 AND S.MenaBDenik = 2)) THEN
CONVERT(NUMERIC(19,6),ROUND(D.Castka*(CASE P.ZpusobKurzuB WHEN 0 THEN K.JednotkaMeny/K.Kurz ELSE K.Kurz/K.JednotkaMeny END),2)*(D.Strana*-2+1))
ELSE CONVERT(NUMERIC(19,6),ISNULL(D.BilancniMena,0)*(D.Strana*-2+1)) END,
P.MenaB,
K.Kurz,
K.JednotkaMeny,
U.TypKurzu,
D.ParovaciZnak,
D.Autor,
D.DatPorizeni,
D.Zmenil,
D.DatZmeny,
D.Id
FROM TabDenik AS D
LEFT JOIN TabSTDParam AS P ON P.Cislo=1
LEFT JOIN TabSTDStandard AS S ON S.ID=P.IdStandard
LEFT JOIN TabSTDObdobiVykazu AS OV ON OV.ID=P.IdObdobiVykazu
LEFT JOIN TabSTDUctovyRozvrhVstup AS UVs ON
D.CisloUcet=UVs.MRCisloUcet AND
UVs.IdObdobiVykazu=P.IdObdobiVykazu AND
UVs.IdStandard=P.IdStandard
LEFT JOIN TabSTDUctovyRozvrhStandard AS U ON
UVS.CisloUctu01=U.MRCisloUctu01 AND
U.IdObdobiVykazu=P.IdObdobiVykazu AND
U.IdStandard=P.IdStandard
LEFT JOIN TabSTDKurzy AS K
ON(((U.TypKurzu=K.TypKurzu)AND((D.DatumPripad_X=(CASE OV.KurzPredchozihoDne WHEN 0 THEN K.Datum_X ELSE DATEADD(DAY,1,K.Datum_X)END))
OR((U.TypKurzu<2)AND(K.Datum_X BETWEEN OV.ObdobiOd AND OV.ObdobiDo)))
AND(K.Mena=P.MenaB)AND(P.MenaB IS NOT
NULL))OR((K.Id=1)AND(P.MenaB IS NULL)))
LEFT JOIN TabObdobiStavu AS OS ON
OS.ID=D.IdObdobiStavu
LEFT JOIN TabSTDObdobiVykazuDetail AS O
ON(((OS.ID=O.IdObdobiStavu)AND(O.