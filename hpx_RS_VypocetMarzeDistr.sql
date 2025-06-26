USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VypocetMarzeDistr]    Script Date: 26.06.2025 13:47:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VypocetMarzeDistr] @Year INT, @ID INT
AS

IF OBJECT_ID('tempdb..#VypocetMarzeDistr') IS NOT NULL DROP TABLE #VypocetMarzeDistr
CREATE TABLE #VypocetMarzeDistr (
ID INT IDENTITY(1,1),
Year INT NULL,
Month INT NULL,
CisloOrg INT NULL,
VazenyPrumer NUMERIC (19,6) NULL,
CenaCelkem NUMERIC (19,6)
)
/*
DECLARE @Year INT
DECLARE @Month INT

SET @CisloOrg=9067
SET @Year=2023
*/

DECLARE @CisloOrg INT
SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ID=@ID)

;WITH Vypocet AS (
SELECT
tdz.ID AS IDDoklad,tpz.ID AS IDPohyb,tpz.IDZboSklad AS IDZboSklad,tdz.DatPorizeni_Y AS DatPorizeni_Y,tdz.DatPorizeni_M AS DatPorizeni_M,tdz.CisloOrg AS CisloOrg,tpz.Mnozstvi
--,CAST((CASE WHEN tpz.DruhPohybuZbo=13 THEN tpz.JCbezDaniKC-tpz.JCevidSN ELSE 0.00 END) AS NUMERIC(19,2)) AS MarzePolozky
,CAST((CASE WHEN (tpz.DruhPohybuZbo=13) AND (tpz.JCbezDaniKcPoS)<>0 THEN (tpz.CCbezDaniKcPoS-tpz.CCevidSN)/tpz.CCbezDaniKcPoS*100 
ELSE 0.00 END) AS NUMERIC(19,2)) AS ProcMarze
,(tpz.Mnozstvi*CAST((CASE WHEN (tpz.DruhPohybuZbo=13) AND (tpz.JCbezDaniKcPoS)<>0 THEN (tpz.CCbezDaniKcPoS-tpz.CCevidSN)/tpz.CCbezDaniKcPoS*100 
ELSE 0.00 END) AS NUMERIC(19,2))) AS ProcMarzeZaklad
,tpz.CCbezDaniKcPoS AS CenaCelkBezDPHPos
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStrom ts ON tdz.strednaklad=ts.cislo  
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE
((tdz.DatPorizeni_Y=@Year)AND
(tdz.IDSklad IS NULL)AND(tdz.DruhPohybuZbo BETWEEN 13 AND 14)AND(tdz.PoradoveCislo>=0))
AND(((tdz.RadaDokladu=N'200')OR(tdz.RadaDokladu=N'210')OR(tdz.RadaDokladu=N'220')OR(tdz.RadaDokladu=N'225')OR(tdz.RadaDokladu=N'240'))
AND(ts.NakladoveStredisko like N'100%'))
AND((tdz.StredNaklad like N'100%')AND(tpz.SkupZbo<N'799'))
AND(tco.CisloOrg=@CisloOrg)
)
INSERT INTO #VypocetMarzeDistr (Year, Month, CisloOrg, VazenyPrumer, CenaCelkem)
SELECT v.DatPorizeni_Y AS DatPorizeni_Y, v.DatPorizeni_M AS DatPorizeni_M, v.CisloOrg AS CisloOrg,SUM(v.ProcMarzeZaklad)/SUM(v.Mnozstvi) AS VazenyPrumer, SUM(v.CenaCelkBezDPHPos)
FROM Vypocet v
GROUP BY v.DatPorizeni_Y ,v.DatPorizeni_M , v.CisloOrg
ORDER BY v.DatPorizeni_Y DESC,v.DatPorizeni_M DESC, v.CisloOrg ASC

SELECT *
FROM #VypocetMarzeDistr

DELETE FROM Tabx_RS_MarginsByOrganisations WHERE Year=@Year AND CisloOrg=@CisloOrg AND SalesType=1

INSERT INTO Tabx_RS_MarginsByOrganisations (Year, SalesType, CisloOrg)
VALUES (@Year, 1, @CisloOrg)


--leden
UPDATE tmo SET tmo.Leden=vm.VazenyPrumer,tmo.LedenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=1 AND tmo.SalesType=1
--únor
UPDATE tmo SET tmo.Unor=vm.VazenyPrumer,tmo.UnorCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=2 AND tmo.SalesType=1
--březen
UPDATE tmo SET tmo.Brezen=vm.VazenyPrumer,tmo.BrezenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=3 AND tmo.SalesType=1
--duben
UPDATE tmo SET tmo.Duben=vm.VazenyPrumer,tmo.DubenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=4 AND tmo.SalesType=1
--květen
UPDATE tmo SET tmo.Kveten=vm.VazenyPrumer,tmo.KvetenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=5 AND tmo.SalesType=1
--červen
UPDATE tmo SET tmo.Cerven=vm.VazenyPrumer,tmo.CervenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=6 AND tmo.SalesType=1
--červenec
UPDATE tmo SET tmo.Cervenec=vm.VazenyPrumer,tmo.CervenecCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=7 AND tmo.SalesType=1
--srpen
UPDATE tmo SET tmo.Srpen=vm.VazenyPrumer,tmo.SrpenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=8 AND tmo.SalesType=1
--září
UPDATE tmo SET tmo.Zari=vm.VazenyPrumer,tmo.ZariCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=9 AND tmo.SalesType=1
--říjen
UPDATE tmo SET tmo.Rijen=vm.VazenyPrumer,tmo.RijenCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=10 AND tmo.SalesType=1
--listopad
UPDATE tmo SET tmo.Listopad=vm.VazenyPrumer,tmo.ListopadCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=11 AND tmo.SalesType=1
--prosinec
UPDATE tmo SET tmo.Prosinec=vm.VazenyPrumer,tmo.ProsinecCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistr vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Month=12 AND tmo.SalesType=1

--kvartály
IF OBJECT_ID('tempdb..#VypocetMarzeDistrQ') IS NOT NULL DROP TABLE #VypocetMarzeDistrQ
CREATE TABLE #VypocetMarzeDistrQ (
ID INT IDENTITY(1,1),
Year INT NULL,
Quarter INT NULL,
CisloOrg INT NULL,
VazenyPrumer NUMERIC (19,6) NULL,
CenaCelkem NUMERIC (19,6)
)

;WITH Vypocet AS (
SELECT
tdz.ID AS IDDoklad,tpz.ID AS IDPohyb,tpz.IDZboSklad AS IDZboSklad,tdz.DatPorizeni_Y AS DatPorizeni_Y,tdz.DatPorizeni_Q AS DatPorizeni_Q,tdz.CisloOrg AS CisloOrg,tpz.Mnozstvi
--,CAST((CASE WHEN tpz.DruhPohybuZbo=13 THEN tpz.JCbezDaniKC-tpz.JCevidSN ELSE 0.00 END) AS NUMERIC(19,2)) AS MarzePolozky
,CAST((CASE WHEN (tpz.DruhPohybuZbo=13) AND (tpz.JCbezDaniKcPoS)<>0 THEN (tpz.CCbezDaniKcPoS-tpz.CCevidSN)/tpz.CCbezDaniKcPoS*100 
ELSE 0.00 END) AS NUMERIC(19,2)) AS ProcMarze
,(tpz.Mnozstvi*CAST((CASE WHEN (tpz.DruhPohybuZbo=13) AND (tpz.JCbezDaniKcPoS)<>0 THEN (tpz.CCbezDaniKcPoS-tpz.CCevidSN)/tpz.CCbezDaniKcPoS*100 
ELSE 0.00 END) AS NUMERIC(19,2))) AS ProcMarzeZaklad
,tpz.CCbezDaniKcPoS AS CenaCelkBezDPHPos
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStrom ts ON tdz.strednaklad=ts.cislo  
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE
((tdz.DatPorizeni_Y=@Year)AND
(tdz.IDSklad IS NULL)AND(tdz.DruhPohybuZbo BETWEEN 13 AND 14)AND(tdz.PoradoveCislo>=0))
AND(((tdz.RadaDokladu=N'200')OR(tdz.RadaDokladu=N'210')OR(tdz.RadaDokladu=N'220')OR(tdz.RadaDokladu=N'225')OR(tdz.RadaDokladu=N'240'))
AND(ts.NakladoveStredisko like N'100%'))
AND((tdz.StredNaklad like N'100%')AND(tpz.SkupZbo<N'799'))
AND(tco.CisloOrg=@CisloOrg)
)
INSERT INTO #VypocetMarzeDistrQ (Year, Quarter, CisloOrg, VazenyPrumer, CenaCelkem)
SELECT v.DatPorizeni_Y AS DatPorizeni_Y, v.DatPorizeni_Q AS DatPorizeni_Q, v.CisloOrg AS CisloOrg,SUM(v.ProcMarzeZaklad)/SUM(v.Mnozstvi) AS VazenyPrumer, SUM(v.CenaCelkBezDPHPos)
FROM Vypocet v
GROUP BY v.DatPorizeni_Y ,v.DatPorizeni_Q , v.CisloOrg
ORDER BY v.DatPorizeni_Y DESC,v.DatPorizeni_Q DESC, v.CisloOrg ASC

SELECT *
FROM #VypocetMarzeDistrQ

--Q1
UPDATE tmo SET tmo.Q1=vm.VazenyPrumer,tmo.Q1Cena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistrQ vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Quarter=1 AND tmo.SalesType=1
--Q2
UPDATE tmo SET tmo.Q2=vm.VazenyPrumer,tmo.Q2Cena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistrQ vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Quarter=2 AND tmo.SalesType=1
--Q3
UPDATE tmo SET tmo.Q3=vm.VazenyPrumer,tmo.Q3Cena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistrQ vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Quarter=3 AND tmo.SalesType=1
--Q4
UPDATE tmo SET tmo.Q4=vm.VazenyPrumer,tmo.Q4Cena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistrQ vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND vm.Quarter=4 AND tmo.SalesType=1

--roky
IF OBJECT_ID('tempdb..#VypocetMarzeDistrY') IS NOT NULL DROP TABLE #VypocetMarzeDistrY
CREATE TABLE #VypocetMarzeDistrY (
ID INT IDENTITY(1,1),
Year INT NULL,
CisloOrg INT NULL,
VazenyPrumer NUMERIC (19,6) NULL,
CenaCelkem NUMERIC (19,6)
)

;WITH Vypocet AS (
SELECT
tdz.ID AS IDDoklad,tpz.ID AS IDPohyb,tpz.IDZboSklad AS IDZboSklad,tdz.DatPorizeni_Y AS DatPorizeni_Y, tdz.CisloOrg AS CisloOrg,tpz.Mnozstvi
--,CAST((CASE WHEN tpz.DruhPohybuZbo=13 THEN tpz.JCbezDaniKC-tpz.JCevidSN ELSE 0.00 END) AS NUMERIC(19,2)) AS MarzePolozky
,CAST((CASE WHEN (tpz.DruhPohybuZbo=13) AND (tpz.JCbezDaniKcPoS)<>0 THEN (tpz.CCbezDaniKcPoS-tpz.CCevidSN)/tpz.CCbezDaniKcPoS*100 
ELSE 0.00 END) AS NUMERIC(19,2)) AS ProcMarze
,(tpz.Mnozstvi*CAST((CASE WHEN (tpz.DruhPohybuZbo=13) AND (tpz.JCbezDaniKcPoS)<>0 THEN (tpz.CCbezDaniKcPoS-tpz.CCevidSN)/tpz.CCbezDaniKcPoS*100 
ELSE 0.00 END) AS NUMERIC(19,2))) AS ProcMarzeZaklad
,tpz.CCbezDaniKcPoS AS CenaCelkBezDPHPos
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStrom ts ON tdz.strednaklad=ts.cislo  
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE
((tdz.DatPorizeni_Y=@Year)AND
(tdz.IDSklad IS NULL)AND(tdz.DruhPohybuZbo BETWEEN 13 AND 14)AND(tdz.PoradoveCislo>=0))
AND(((tdz.RadaDokladu=N'200')OR(tdz.RadaDokladu=N'210')OR(tdz.RadaDokladu=N'220')OR(tdz.RadaDokladu=N'225')OR(tdz.RadaDokladu=N'240'))
AND(ts.NakladoveStredisko like N'100%'))
AND((tdz.StredNaklad like N'100%')AND(tpz.SkupZbo<N'799'))
AND(tco.CisloOrg=@CisloOrg)
)
INSERT INTO #VypocetMarzeDistrY (Year, CisloOrg, VazenyPrumer, CenaCelkem)
SELECT v.DatPorizeni_Y AS DatPorizeni_Y, v.CisloOrg AS CisloOrg,SUM(v.ProcMarzeZaklad)/SUM(v.Mnozstvi) AS VazenyPrumer, SUM(v.CenaCelkBezDPHPos)
FROM Vypocet v
GROUP BY v.DatPorizeni_Y , v.CisloOrg
ORDER BY v.DatPorizeni_Y DESC, v.CisloOrg ASC

SELECT *
FROM #VypocetMarzeDistrY

UPDATE tmo SET tmo.YearSum=vm.VazenyPrumer,tmo.YearSumCena=vm.CenaCelkem
FROM Tabx_RS_MarginsByOrganisations tmo
LEFT OUTER JOIN #VypocetMarzeDistrY vm ON vm.Year=tmo.Year AND vm.CisloOrg=tmo.CisloOrg
WHERE tmo.CisloOrg=@CisloOrg AND tmo.Year=@Year AND vm.Year=@Year AND tmo.SalesType=1
GO

