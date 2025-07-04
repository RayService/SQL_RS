USE [RayService]
GO

/****** Object:  View [dbo].[TabFPKUzivatelePKView]    Script Date: 04.07.2025 11:05:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFPKUzivatelePKView] AS
SELECT DISTINCT t.TypUziv,t.ID,t.Cislo,t.Prijmeni,t.Jmeno,t.PrijmeniJmeno,
t.PrijmeniJmenoTituly FROM
(SELECT
0 AS TypUziv,
cz.ID,
cz.Cislo,
cz.Prijmeni,
cz.Jmeno,
cz.PrijmeniJmeno,
cz.PrijmeniJmenoTituly
FROM TabFPKPlatebniKarty AS pk
JOIN TabCisZam AS cz ON cz.Cislo=pk.UzivatelZamestnanec
UNION ALL
SELECT
1 AS TypUziv,
-cko.ID,
-cko.Cislo,
cko.Prijmeni,
cko.Jmeno,
cko.PrijmeniJmeno,
cko.PrijmeniJmenoTituly
FROM TabFPKPlatebniKarty AS pk
JOIN TabCisKOs AS cko ON cko.Cislo=pk.UzivatelKontaktniOsoba) t
GO

