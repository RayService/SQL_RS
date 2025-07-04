USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Obratova_predvaha]    Script Date: 04.07.2025 8:33:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Obratova_predvaha] AS SELECT dat.Rok,  dat.CisloUcet, u.NazevUctu, 
           SUM(PocStav) as PocStav,
           SUM(CastkaMD) as CastkaMD,
           SUM(CastkaDal) as CastkaDal,
           SUM(ISNULL(PocStav,0)) + SUM(ISNULL(CastkaMD,0)) - SUM(ISNULL(CastkaDal,0)) as KonStav

FROM

(SELECT idObdobi, d.DatumPripad_Y as Rok,  d.CisloUcet,  SUM(CastkaZust) as PocStav, 0 as CastkaMD, 0 as CastkaDal 
 FROM TabDenik d
 WHERE d.Stav = 1  -- počáteční stav
    AND Zaknihovano > 0
    AND DatumPripad_X  > =  (SELECT DatumOd FROM SMDTabVyberObdobi) 
    AND DatumPripad_X < = (SELECT DatumDo FROM SMDTabVyberObdobi) 
 GROUP BY idObdobi, d.DatumPripad_Y, d.CisloUcet

UNION ALL

SELECT idObdobi,d.DatumPripad_Y as Rok,  d.CisloUcet,  0 as PocStav, SUM(CastkaMD) as CastkaMD, SUM(CastkaDal) as CastkaDal 
 FROM TabDenik d
 WHERE d.Stav = 0  -- běžný stav
    AND Zaknihovano > 0
    AND DatumPripad_X  > =  (SELECT DatumOd FROM SMDTabVyberObdobi) 
    AND DatumPripad_X < = (SELECT DatumDo FROM SMDTabVyberObdobi) 
 GROUP BY idObdobi,d.DatumPripad_Y, d.CisloUcet) dat

LEFT OUTER JOIN TabCisUctDef u ON u.CisloUcet = dat.CisloUcet AND u.idObdobi = dat.idObdobi

GROUP BY dat.Rok, dat.CisloUcet, u.NazevUctu
GO

