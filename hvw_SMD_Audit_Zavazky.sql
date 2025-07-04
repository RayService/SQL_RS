USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Zavazky]    Script Date: 04.07.2025 8:36:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Zavazky] AS SELECT * FROM 

(SELECT (SELECT DatumDo FROM SMDTabVyberObdobi) as KeDni,
       MAX(CisloDokladu) as CisloDokladu,
       Nazev, 
       MIN(DatumPripad) as DatumPripad,
       ParovaciZnak,
       SUM(CastkaSplatno) as CastkaCelkem, 
       SUM(CastkaUhrazeno) as CastkaUhrazeno, 
       SUM(CastkaZust *-1) as Neuhrazeno, 
       MAX(DatumSplatno) as DatumSplatno, 
       MAX(Mena) as Mena ,
       SUM(CastkaSplatnoMena) as CastkaCelkemMena, 
       SUM(CastkaUhrazenoMena) as CastkaUhrazenoMena, 
       CisloUcet,
       ICO

FROM 

(SELECT DatumPripad_X as DatumPripad, CisloUcet, CastkaMD, CastkaDAL, CastkaZust, UcetDPH, d.Mena, Kurz, CastkaMenaZust, DatumPripad_M, DatumPripad_Y, DatumDUZP_X as DatumDuzp,
 Utvar, Popis, ParovaciZnak, PZ2, d.CisloOrg, d.CisloZakazky, o.ICO, o.Nazev, d.DruhData, 
 CASE WHEN D.Strana = 1 THEN CAST(Sbornik as NVARCHAR)+'/'+CAST(CisloDokladu as NVARCHAR)  ELSE NULL END as CisloDokladu,
 CASE WHEN d.DruhData = 1 THEN DatumSplatno_X  ELSE NULL END as DatumSplatno,
 CASE WHEN d.DruhData = 2 THEN DatumSplatno_X  ELSE NULL END as DatumUhrady,
 CASE WHEN d.DruhData IN (1,3) THEN CastkaZust * -1  ELSE 0 END as CastkaSplatno,
 CASE WHEN d.DruhData = 2 THEN CastkaZust   ELSE 0 END as CastkaUhrazeno,
 CASE WHEN d.DruhData IN (1,3) THEN CastkaMenaZust * -1  ELSE 0 END as CastkaSplatnoMena,
 CASE WHEN d.DruhData = 2 THEN CastkaMenaZust  ELSE 0 END as CastkaUhrazenoMena
 FROM TabDenik d
 LEFT JOIN TabCisOrg o ON o.CisloOrg = d.CisloOrg 
 WHERE Zaknihovano > 0) as denik

WHERE LEFT(CisloUcet,3) = '321' 
    AND DruhData IN (1,2,3)
    AND  DatumPripad < = (SELECT DatumDo FROM SMDTabVyberObdobi) 
GROUP BY  Nazev, ParovaciZnak, CisloUcet, ICO) saldo

WHERE Neuhrazeno <> 0
GO

