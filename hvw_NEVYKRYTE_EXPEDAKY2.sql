USE [RayService]
GO

/****** Object:  View [dbo].[hvw_NEVYKRYTE_EXPEDAKY2]    Script Date: 03.07.2025 15:28:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_NEVYKRYTE_EXPEDAKY2] AS SELECT 
tdz.CisloOrg, 
O.Nazev,
tdz.RadaDokladu, 
tdz.DatPorizeni_Y, 
tss.IDSklad, 
tpz.SkupZbo,
(tpz.Mnozstvi -  tpz.MnOdebrane)  * tpz.JCbezDaniKCPoS Neodebrano, 
(DATEPART(MONTH,tpz.PotvrzDatDod_X)) as PotvrzenyMesic,
(DATEPART(YEAR,tpz.PotvrzDatDod_X)) as PotvrzenyRok,
(DATEPART(MONTH,tpz.PozadDatDod_X)) as PozadovanyMesic,
(DATEPART(YEAR,tpz.PozadDatDod_X)) as PozadovanyRok,
tdz.CisloZakazky,
C.PrijmeniJmeno

FROM TabPohybyZbozi tpz 

LEFT OUTER JOIN TabStavSkladu tss ON tpz.IDZboSklad=tss.ID 
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad 
LEFT OUTER JOIN TabCisOrg O ON O.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabZakazka Z ON Z.CisloZakazky=tdz.CisloZakazky
LEFT OUTER JOIN TabCisZam C ON C.Cislo=Z.Zodpovida

WHERE tpz.DruhPohybuZbo = 9 AND (tpz.Mnozstvi -  tpz.MnOdebrane)  > 0 AND tdz.CisloOrg<>0



/*
-          Číslo organizace

-          Název organizace

-          ID sklad

-          Název 1 materiálu

-          Skupina materiálu

-          Neodebraná hodnota

-          Požadované datum dodání (ve tvaru roku a měsíci)

-          Potvrzené datum dodání     (ve tvaru roku a měsíci)

-          Odpovědná osoba (ze zakázky)

*/
 
GO

