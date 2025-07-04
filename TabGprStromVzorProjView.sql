USE [RayService]
GO

/****** Object:  View [dbo].[TabGprStromVzorProjView]    Script Date: 04.07.2025 11:23:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprStromVzorProjView] AS 
SELECT ID = vp.ID,
       Rada =vp.Rada,
       Strom = vp.Strom,
       TYP = CASE WHEN vpNad.ID IS NULL THEN 0 ELSE 1 END, 
       Oznaceni = NULL,
       Nazev = vp.Nazev,
       DelkaTrvani = vp.DelkaTrvani,
       IDNadZak = vpNad.ID,
       IDRidZak = vp.IDRidiciVzorProjekt,
       Poradi = vp.Poradi,
       Zodpovida = ISNULL(cz.CisloJmenoTituly, ''),
       Stredisko = ISNULL(s.Nazev, ''),
       KmenoveStredisko = ISNULL(ks.Nazev, '')       
FROM TabGprVzorProjektyEtapy vp
LEFT JOIN TabGprVzorProjektyEtapy vpNad on vpNad.ID = vp.IDVzorNadrizenyProjektEtapa
LEFT JOIN TabCisZam cz on cz.Cislo = vp.Zodpovida
LEFT JOIN TabStrom s on s.Cislo=vp.Stredisko
LEFT JOIN TabStrom ks on ks.Cislo=vp.KmenoveStredisko

UNION ALL

SELECT ID = - TabGprVzorUlohy.ID,
       Rada = NULL,
       Strom = vp.Strom, 
       Typ = 2 + TabGprVzorUlohy.TypUlohy,
       Oznaceni = TabGprVzorUlohy.Oznaceni,
       Nazev = TabGprVzorUlohy.Nazev,
       DelkaTrvani = TabGprVzorUlohy.DelkaTrvani,
       IDNadZak = TabGprVzorUlohy.IDVzorProjektEtapa,
       IDRidZak = vp.IDRidiciVzorProjekt,
       Poradi = TabGprVzorUlohy.Poradi,
       Zodpovida = NULL,
       Stredisko = NULL,
       KmenoveStredisko = ISNULL(ks.Nazev, '')      
FROM TabGprVzorUlohy 
INNER JOIN TabGprVzorProjektyEtapy vp on vp.ID =TabGprVzorUlohy.IDVzorProjektEtapa
LEFT JOIN TabStrom ks on TabGprVzorUlohy.ProvadeciStredisko=ks.Cislo
GO

