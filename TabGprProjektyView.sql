USE [RayService]
GO

/****** Object:  View [dbo].[TabGprProjektyView]    Script Date: 04.07.2025 11:20:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprProjektyView] AS 
SELECT ID=Z.ID, 
       Rada=Z.Rada, 
       CisloZakazky=Z.CisloZakazky, 
       Nazev=Z.Nazev, 
       DruhyNazev=Z.DruhyNazev, 
       Zadavatel=Z.Zadavatel, 
       Prijemce=Z.Prijemce, 
       PrijemceMU=Z.PrijemceMU, 
       KontaktOsoba=Z.KontaktOsoba, 
       Zodpovida=Z.Zodpovida, 
       Stredisko=Z.Stredisko, 
       DatumStartPlan=Z.DatumStartPlan, 
       DatumKonecPlan=Z.DatumKonecPlan, 
       Ukonceno=Z.Ukonceno, 
       Stav=Z.Stav, 
       Priorita=Z.Priorita, 
       NadrizenaZak=Z.NadrizenaZak, 
       NavaznaZak=Z.NavaznaZak, 
       Identifikator=Z.Identifikator, 
       CisloObjednavky=Z.CisloObjednavky, 
       CisloNabidky=Z.CisloNabidky, 
       CisloSmlouvy=Z.CisloSmlouvy, 
       Upozorneni=Z.Upozorneni, 
       GPSZemepisnaSirka=Z.GPSZemepisnaSirka, 
       GPSZemepisnaDelka=Z.GPSZemepisnaDelka, 
       ZakKalCislo=Z.ZakKalCislo, 
       Poznamka=Z.Poznamka, 
       DatPorizeni=Z.DatPorizeni, 
       Autor=Z.Autor, 
       Zmenil=Z.Zmenil, 
       DatZmeny=Z.DatZmeny, 
       BlokovaniEditoru=Z.BlokovaniEditoru 
  FROM  TabZakazka Z
GO

