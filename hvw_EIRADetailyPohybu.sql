USE [RayService]
GO

/****** Object:  View [dbo].[hvw_EIRADetailyPohybu]    Script Date: 03.07.2025 14:44:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_EIRADetailyPohybu] AS  SELECT TabPohybyZbozi.ID, 
 TabPohybyZbozi.Poradi,TabPohybyZbozi.DruhPohybuZbo,TabPohybyZbozi.SkutecneDatReal,tkz.KmenoveStredisko,tco_EXT._backOffice,tz.CisloZakazky 
 ,TabPohybyZbozi.Autor,tdz.RadaDokladu,tdz.PoradoveCislo,tco.Nazev,TabPohybyZbozi.SkupZbo,TabPohybyZbozi.RegCis,TabPohybyZbozi.Nazev1 
 ,TabPohybyZbozi.Mnozstvi AS MnozstviPohybu,tkz.MJEvidence,TabPohybyZbozi.Mnozstvi - TabPohybyZbozi.MnOdebrane AS _U_S1 
 ,tss.Mnozstvi AS MnozstviSklad,tss.MnozstviKPrijmu,tss.MnozstviKVydeji,TabPohybyZbozi.PotvrzDatDod,tpze._dat_dod,tz.CisloObjednavky 
 ,(SUBSTRING(REPLACE(SUBSTRING(TabPohybyZbozi.[Poznamka],1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) AS Poznamka_255,tpze._LCS_PFA_DuvodOpozdeniExp 
 ,tdzorig.DatPovinnostiFa_X,tdz.DatPorizeni_X,TabPohybyZbozi.PozadDatDod_X,TabPohybyZbozi.IDDOKLAD 
 FROM RayService.dbo.TabPohybyZbozi WITH(NOLOCK) 
 LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=TabPohybyZbozi.IDDoklad 
 LEFT OUTER JOIN RayService.dbo.TabStavSkladu tss WITH(NOLOCK) ON TabPohybyZbozi.IDZboSklad=tss.ID 
 LEFT OUTER JOIN RayService.dbo.TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID= 
  (SELECT TabStavSkladu.IDKmenZbozi FROM RayService.dbo.TabStavSkladu WHERE TabStavSkladu.ID=TabPohybyZbozi.IDZboSklad) 
 LEFT OUTER JOIN RayService.dbo.TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg IN 
  (SELECT TabDokladyZbozi.CisloOrg FROM RayService.dbo.TabDokladyZbozi WHERE TabDokladyZbozi.ID=TabPohybyZbozi.IDDoklad) 
 LEFT OUTER JOIN RayService.dbo.TabZakazka tz WITH(NOLOCK) ON TabPohybyZbozi.CisloZakazky=tz.CisloZakazky 
 LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi tdzorig WITH(NOLOCK) ON tdzorig.ID IN 
  (SELECT OldPohyb.IDDoklad FROM RayService.dbo.TabPohybyZbozi OldPohyb WHERE OldPohyb.ID=TabPohybyZbozi.IDOldPolozka) 
 LEFT OUTER JOIN RayService.dbo.TabCisOrg_EXT tco_EXT WITH(NOLOCK) ON tco_EXT.ID=tco.ID 
 LEFT OUTER JOIN RayService.dbo.TabPohybyZbozi_EXT tpze WITH(NOLOCK) ON tpze.ID=TabPohybyZbozi.ID 
 WHERE ((tdz.DruhPohybuZbo=9)AND(tss.IDSklad=N'200')AND(tdz.DatPovinnostiFa_Y>=2021))AND((((TabPohybyZbozi.Mnozstvi-TabPohybyZbozi.MnOdebrane)>0))AND(tdz.Splneno=0))
GO

