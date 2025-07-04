USE [RayService]
GO

/****** Object:  View [dbo].[TabGprRadyProjektuView]    Script Date: 04.07.2025 11:21:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprRadyProjektuView] AS 
SELECT ID=RZ.ID, 
       Rada=RZ.Rada, 
       Nazev=RZ.Nazev, 
       CisloPrefixDef=RZ.CisloPrefixDef, 
       CisloDelka=RZ.CisloDelka, 
       Stav=RZ.Stav, 
       Priorita=RZ.Priorita, 
       Identifikator=RZ.Identifikator, 
       PrenosPrijemceZadavatel=RZ.PrenosPrijemceZadavatel, 
       DatPorizeni=RZ.DatPorizeni, 
       Autor=RZ.Autor, 
       Zmenil=RZ.Zmenil, 
       DatZmeny=RZ.DatZmeny, 
       BlokovaniEditoru=RZ.BlokovaniEditoru 
  FROM TabZakazkaRada RZ
GO

