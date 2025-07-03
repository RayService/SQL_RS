USE [RayService]
GO

/****** Object:  View [dbo].[hvw_503D6BCBC29843678CEBF2D8B40C22A5]    Script Date: 03.07.2025 11:08:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_503D6BCBC29843678CEBF2D8B40C22A5] AS SELECT
tp.ID, tp.Rada, tp.IDTabKmen, tp.IDZakazka, tp.mnozstvi, tp.datum, (SUBSTRING(REPLACE(SUBSTRING(tp.[Poznamka],1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) AS Poznamka_255, tp.IDRezervace, tp.DatPorizeni, tp.Autor, tp.Zmenil, tp.StavPrevodu, tcz.LoginId, tkze._TechnikTPV100, tkze._TechnikTPV200, tkz.Nazev1, tkz.Nazev2, tz.CisloZakazky, tz.Nazev, tco.Nazev AS Prijemce
FROM TabPlan AS tp
  LEFT OUTER JOIN TabKmenZbozi AS tkz ON tp.IDTabKmen = tkz.ID
  LEFT OUTER JOIN TabKmenZbozi_EXT AS tkze ON tkz.ID = tkze.ID
   LEFT OUTER JOIN TabZakazka AS tz ON tp.IDZakazka = tz.ID
   LEFT OUTER JOIN TabCisOrg AS tco ON tz.Prijemce=tco.CisloOrg
  LEFT OUTER JOIN TabCisZam AS tcz ON tkze._TechnikTPV100 = tcz.PrijmeniJmeno
WHERE tp.InterniZaznam = 0/* AND tp.Rada = 'Plan_quick'*/
      AND (
          tcz.ID IN (SELECT MAX(ID)
                     FROM TabCisZam
                     WHERE PrijmeniJmeno = tkze._TechnikTPV100)
      )
UNION
SELECT
tp.ID, tp.Rada, tp.IDTabKmen, tp.IDZakazka, tp.mnozstvi, tp.datum, (SUBSTRING(REPLACE(SUBSTRING(tp.[Poznamka],1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) AS Poznamka_255, tp.IDRezervace, tp.DatPorizeni, tp.Autor, tp.Zmenil, StavPrevodu, tcz.LoginId, tkze._TechnikTPV100, tkze._TechnikTPV200, tkz.Nazev1, tkz.Nazev2, tz.CisloZakazky, tz.Nazev, tco.Nazev AS Prijemce
FROM TabPlan AS tp
  LEFT OUTER JOIN TabKmenZbozi AS tkz ON tp.IDTabKmen = tkz.ID
  LEFT OUTER JOIN TabKmenZbozi_EXT AS tkze ON tkz.ID = tkze.ID
   LEFT OUTER JOIN TabZakazka AS tz ON tp.IDZakazka = tz.ID
   LEFT OUTER JOIN TabCisOrg AS tco ON tz.Prijemce=tco.CisloOrg
  LEFT OUTER JOIN TabCisZam AS tcz ON tkze._TechnikTPV200 = tcz.PrijmeniJmeno
WHERE tp.InterniZaznam = 0/* AND tp.Rada = 'Plan_fix'*/
      AND (
          tcz.ID IN (SELECT MAX(ID)
                     FROM TabCisZam
                     WHERE PrijmeniJmeno = tkze._TechnikTPV200)
      )
GO

