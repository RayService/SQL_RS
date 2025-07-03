USE [RayService]
GO

/****** Object:  View [dbo].[hvw_EIRADetailyDokladu]    Script Date: 03.07.2025 14:44:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_EIRADetailyDokladu] AS SELECT TabDokladyZbozi.ID, CisloZakazky, TabDokladyZbozi.PoradoveCislo, Mena, SumaKc, DruhPohybuZbo, IDSklad, RadaDokladu, 
       DatPorizeni, DatZmeny, DatPovinnostiFa, 
       StredNaklad,FormaUhrady,Poznamka, NavaznaObjednavka, DIC,
	    (select NAZEV from RayService.dbo.TabZakazka where TabZakazka.CisloZakazky=TabDokladyZbozi.CisloZakazky) as ZAKAZKANAZEV 
 FROM RayService.dbo.TabDokladyZbozi WITH(NOLOCK) 
 LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi_EXT WITH(NOLOCK) ON TabDokladyZbozi_EXT.ID=TabDokladyZbozi.ID 
 WHERE 
 ((TabDokladyZbozi.DruhPohybuZbo=9)AND(TabDokladyZbozi.IDSklad='200')AND 
 (TabDokladyZbozi.PoradoveCislo>=0)AND(TabDokladyZbozi.Splneno=0)AND(TabDokladyZbozi.StavRezervace<>N'x'))
GO

