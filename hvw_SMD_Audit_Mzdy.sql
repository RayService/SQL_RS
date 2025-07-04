USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Mzdy]    Script Date: 04.07.2025 8:32:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Mzdy] AS SELECT ROW_NUMBER() OVER(ORDER BY o.Rok, o.Mesic) as row,
       o.Rok,
	   o.Mesic, 
	   SUM(CASE WHEN m.DruhPP IN (9,13) THEN l.HrubaMzda ELSE 0 END) as HM_DPP,
       SUM(CASE WHEN m.DruhPP NOT IN (9,13) THEN l.HrubaMzda ELSE 0 END) as HM,
       (SELECT SUM(Koruny) FROM TabMzSloz WHERE idObdobi = m.IdObdobi AND CisloMS IN (213,216,218)) as Nemocenska,
	   SUM(l.ZdrPojZam) as ZP_zam,
       SUM(l.SocPojZam) as SP_zam,
       SUM(l.ZdrPojFirma) as ZP_firma,
       SUM(l.SocPojFirma) as SP_firma,
       SUM(l.ZalohaNaDan) as DanZalohova,
	   SUM(l.DanSrazkova) as DanSrazkova,
       (SELECT COUNT(id) FROM TabZamMzd m2 WHERE m2.IdObdobi = m.IdObdobi AND m2.StavES = 0 AND m2.DruhPP IN (0,1))  as Pocet 
  FROM TabZamMzd m
  LEFT OUTER JOIN TabMzdObd o ON o.IdObdobi = m.IdObdobi  
  LEFT OUTER JOIN TabMzdList l ON l.IdObdobi = m.IdObdobi AND l.ZamestnanecId = m.ZamestnanecId  
  WHERE o.MzdObd_DatumOd_X > = (SELECT DatumOd FROM SMDTabVyberObdobi) 
    AND o.MzdObd_DatumDo_X < = (SELECT DatumDo FROM SMDTabVyberObdobi)
GROUP BY m.idObdobi, o.Rok, o.Mesic
GO

