USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_vypocet_nakladu_interni_neshody]    Script Date: 26.06.2025 12:00:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_vypocet_nakladu_interni_neshody]
AS
SET NOCOUNT ON

--1.náklady na materiál
DECLARE @Material NUMERIC(19,6), @Mesic INT, @Rok INT, @Stredisko NVARCHAR(30)

IF OBJECT_ID(N'tempdb..#TabMaterial') IS NOT NULL DROP TABLE #TabMaterial
CREATE TABLE #TabMaterial 
(
ID INT IDENTITY(1,1),
Material NUMERIC(19,6),
Mesic INT,
Rok INT,
Stredisko NVARCHAR(30)
)

INSERT INTO #TabMaterial (Rok,Mesic,Material,Stredisko)
(SELECT tdz.DatPorizeni_Y AS Rok, tdz.DatPorizeni_M AS Mesic,SUM(EcCelkemDoklUctoDruhovy)*(-1) AS Material,tp.KmenoveStredisko AS Stredisko
FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tdz.IDPrikaz=tp.ID
WHERE
((tdz.PoradoveCislo>=0)AND((tdz.DruhPohybuZbo < 5 OR  tdz.DruhPohybuZbo BETWEEN 24 AND 27)))
AND((tdz.Realizovano=1)AND(tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(((((tdz.RadaDokladu=N'698')OR(tdz.RadaDokladu=N'699'))
AND((tp.RadaPrikaz not like N'909%')AND(tp.RadaPrikaz not like N'450%')))
AND(tdz.Poznamka NOT LIKE '%920%' OR tdz.Poznamka IS NULL)AND(tp.KmenoveStredisko IS NOT NULL))
OR(tdz.RadaDokladu=N'579')))GROUP BY tdz.DatPorizeni_Y,tdz.DatPorizeni_M,tp.KmenoveStredisko)
UNION ALL
(SELECT tdz.DatPorizeni_Y AS Rok,tdz.DatPorizeni_M AS Mesic,SUM(EcCelkemDoklUctoDruhovy)*(-1) AS Material,tp.KmenoveStredisko AS Stredisko
FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tdz.IDPrikaz=tp.ID
WHERE
((tdz.PoradoveCislo>=0)AND((tdz.DruhPohybuZbo < 5 OR  tdz.DruhPohybuZbo BETWEEN 24 AND 27)))
AND((tdz.Realizovano=1)
AND(tdz.DatPorizeni_X>=DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-1,0) AND tdz.DatPorizeni_X<=DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1))
AND(((((tdz.RadaDokladu=N'698')OR(tdz.RadaDokladu=N'699'))
AND((tp.RadaPrikaz not like N'909%')AND(tp.RadaPrikaz not like N'450%')))
AND(tdz.Poznamka NOT LIKE '%920%' OR tdz.Poznamka IS NULL)AND(tp.KmenoveStredisko IS NOT NULL))
OR(tdz.RadaDokladu=N'579')))
GROUP BY tdz.DatPorizeni_Y,tdz.DatPorizeni_M,tp.KmenoveStredisko)

DECLARE CurMaterial CURSOR LOCAL FAST_FORWARD FOR
SELECT Material, Rok, Mesic, Stredisko
FROM #TabMaterial
WHERE Material <> 0

OPEN CurMaterial;
	FETCH NEXT FROM CurMaterial INTO @Material, @Rok, @Mesic, @Stredisko;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	
	UPDATE nin SET nin.Material=@Material
	FROM Tabx_RS_NakladyInterniNeshody nin
	WHERE nin.Mesic=@Mesic AND nin.Rok=@Rok AND (nin.Stredisko=@Stredisko OR (nin.Stredisko IS NULL AND @Stredisko IS NULL))

	FETCH NEXT FROM CurMaterial INTO @Material, @Rok, @Mesic, @Stredisko;
	END;
CLOSE CurMaterial;
DEALLOCATE CurMaterial;

--2. náklady na vícepráce
DECLARE @Viceprace NUMERIC(19,6)--, @Mesic INT, @Stredisko NVARCHAR(30)

IF OBJECT_ID(N'tempdb..#TabViceprace') IS NOT NULL DROP TABLE #TabViceprace
CREATE TABLE #TabViceprace 
(
ID INT IDENTITY(1,1),
Viceprace NUMERIC(19,6),
Mesic INT,
Rok INT,
Stredisko NVARCHAR(30)
)

INSERT INTO #TabViceprace (Rok, Mesic,Viceprace,Stredisko)
(SELECT T.datum_Y AS Rok, T.datum_M AS Mesic,SUM(T.Mzda) AS Viceprace,T.KmenoveStredisko AS Stredisko
FROM (SELECT tpmz.datum_Y,tpmz.datum_M,tpmz.Mzda,tp.KmenoveStredisko
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz
LEFT OUTER JOIN TabCisZam tcz ON tpmz.Zamestnanec=tcz.ID
WHERE
(tpmz.TypMzdy<>2)AND((tpmz.datum_M=DATEPART(MONTH,GETDATE()))AND(tpmz.datum_Y=DATEPART(YEAR,GETDATE()))AND(tp.Rada<N'800')
AND((CONVERT(bit, CASE WHEN EXISTS(SELECT * FROM TabPrikazNaOpravu PNO8 WHERE PNO8.IDPrikaz=tp.ID) THEN 1 ELSE 0 END))=1)
AND(tcz.Stredisko<>N'20000260')AND((CONVERT(nvarchar(50), (SELECT P.RadaPrikaz FROM TabPrikaz P WHERE P.ID=tp.IDPrikazRidici)))<>N'200 - 25406'))
UNION ALL
SELECT tpmz.datum_Y,tpmz.datum_M,tpmz.Mzda,tp.KmenoveStredisko
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrPostup tpp ON tpmz.IDPrikaz=tpp.IDPrikaz AND tpmz.DokladPrPostup=tpp.Doklad AND tpmz.AltPrPostup=tpp.Alt AND tpp.IDOdchylkyDo IS NULL
LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz
LEFT OUTER JOIN TabKmenZbozi tkz ON tpmz.IDTabKmen=tkz.ID
LEFT OUTER JOIN TabCisZam tcz ON tpmz.Zamestnanec=tcz.ID
WHERE
(tpmz.TypMzdy<>2)AND((tpmz.datum_M=DATEPART(MONTH,GETDATE()))AND(tpmz.datum_Y=DATEPART(YEAR,GETDATE()))AND((tpp.nazev LIKE N'%oprava%')AND(tpp.nazev LIKE N'%neshody%')OR(tpp.nazev LIKE N'%vícepráce%'))AND((tpp.nazev NOT LIKE N'%stroje%'))
AND(tp.Rada<N'800')AND(tkz.Nazev1<>N'IR detector - oprava')AND(tp.KmenoveStredisko<>N'90000970')AND(tpp.nazev NOT LIKE N'%Oprava neshody pracovníkem TPV%'))
) AS T
GROUP BY T.datum_Y,T.datum_M,T.KmenoveStredisko)
UNION ALL
(SELECT T.datum_Y AS Rok,T.datum_M AS Mesic,SUM(T.Mzda) AS Viceprace,T.KmenoveStredisko AS Stredisko
FROM (SELECT tpmz.datum_Y,tpmz.datum_M,tpmz.Mzda,tp.KmenoveStredisko
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz
LEFT OUTER JOIN TabCisZam tcz ON tpmz.Zamestnanec=tcz.ID
WHERE
(tpmz.TypMzdy<>2)
AND((  tpmz.DatPorizeni_X>=DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-1,0) AND tpmz.DatPorizeni_X<=DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)   )
AND(tp.Rada<N'800')
AND((CONVERT(bit, CASE WHEN EXISTS(SELECT * FROM TabPrikazNaOpravu PNO8 WHERE PNO8.IDPrikaz=tp.ID) THEN 1 ELSE 0 END))=1)
AND(tcz.Stredisko<>N'20000260')AND((CONVERT(nvarchar(50), (SELECT P.RadaPrikaz FROM TabPrikaz P WHERE P.ID=tp.IDPrikazRidici)))<>N'200 - 25406'))
UNION ALL
SELECT tpmz.datum_Y,tpmz.datum_M,tpmz.Mzda,tp.KmenoveStredisko
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrPostup tpp ON tpmz.IDPrikaz=tpp.IDPrikaz AND tpmz.DokladPrPostup=tpp.Doklad AND tpmz.AltPrPostup=tpp.Alt AND tpp.IDOdchylkyDo IS NULL
LEFT OUTER JOIN TabPrikaz tp ON tp.ID=tpmz.IDPrikaz
LEFT OUTER JOIN TabKmenZbozi tkz ON tpmz.IDTabKmen=tkz.ID
LEFT OUTER JOIN TabCisZam tcz ON tpmz.Zamestnanec=tcz.ID
WHERE
(tpmz.TypMzdy<>2)
AND((  tpmz.DatPorizeni_X>=DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-1,0) AND tpmz.DatPorizeni_X<=DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)   )
AND((tpp.nazev LIKE N'%oprava%')AND(tpp.nazev LIKE N'%neshody%')OR(tpp.nazev LIKE N'%vícepráce%'))AND((tpp.nazev NOT LIKE N'%stroje%'))
AND(tp.Rada<N'800')AND(tkz.Nazev1<>N'IR detector - oprava')AND(tp.KmenoveStredisko<>N'90000970')AND(tpp.nazev NOT LIKE N'%Oprava neshody pracovníkem TPV%'))
) AS T
GROUP BY T.datum_Y,T.datum_M,T.KmenoveStredisko)

DECLARE CurViceprace CURSOR LOCAL FAST_FORWARD FOR
SELECT Viceprace, Rok, Mesic, Stredisko
FROM #TabViceprace
WHERE Viceprace <> 0

OPEN CurViceprace;
	FETCH NEXT FROM CurViceprace INTO @Viceprace, @Rok, @Mesic, @Stredisko;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	
	UPDATE nin SET nin.Viceprace=@Viceprace
	FROM Tabx_RS_NakladyInterniNeshody nin
	WHERE nin.Mesic=@Mesic AND nin.Rok=@Rok AND nin.Stredisko=@Stredisko

	FETCH NEXT FROM CurViceprace INTO @Viceprace, @Rok, @Mesic, @Stredisko;
	END;
CLOSE CurViceprace;
DEALLOCATE CurViceprace;

--3. přijato na sklad
DECLARE @Prijato NUMERIC(19,6)--, @Mesic INT, @Stredisko NVARCHAR(30)

IF OBJECT_ID(N'tempdb..#TabPrijato') IS NOT NULL DROP TABLE #TabPrijato
CREATE TABLE #TabPrijato 
(
ID INT IDENTITY(1,1),
Prijato NUMERIC(19,6),
Mesic INT,
Rok INT,
Stredisko NVARCHAR(30)
)

INSERT INTO #TabPrijato (Prijato,Rok,Mesic,Stredisko)
(SELECT SUM(tdz.EcSNCelkemDokl) AS Prijato,tdz.DatPorizeni_Y AS Rok,tdz.DatPorizeni_M AS Mesic,tp.KmenoveStredisko AS Stredisko
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabPrikaz tp ON tdz.IDPrikaz=tp.ID
WHERE
(((tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))AND(tdz.IDSklad='200')AND(tdz.DruhPohybuZbo<=1))
AND((tdz.RadaDokladu LIKE N'%550%')OR(tdz.RadaDokladu LIKE N'%540%'))--AND(tp.KmenoveStredisko IS NOT NULL)
)
GROUP BY tdz.DatPorizeni_Y,tdz.DatPorizeni_M,tp.KmenoveStredisko
)
UNION ALL
(SELECT SUM(tdz.EcSNCelkemDokl) AS Prijato,tdz.DatPorizeni_Y AS Rok,tdz.DatPorizeni_M AS Mesic,tp.KmenoveStredisko AS Stredisko
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabPrikaz tp ON tdz.IDPrikaz=tp.ID
WHERE
((
(tdz.DatPorizeni_X>=DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-1,0) AND tdz.DatPorizeni_X<=DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1))
AND(tdz.IDSklad='200')AND(tdz.DruhPohybuZbo<=1))
AND((tdz.RadaDokladu LIKE N'%550%')OR(tdz.RadaDokladu LIKE N'%540%'))--AND(tp.KmenoveStredisko IS NOT NULL)
)
GROUP BY tdz.DatPorizeni_Y,tdz.DatPorizeni_M,tp.KmenoveStredisko)

DECLARE CurPrijato CURSOR LOCAL FAST_FORWARD FOR
SELECT Prijato, Rok, Mesic, Stredisko
FROM #TabPrijato
WHERE Prijato <> 0

OPEN CurPrijato;
	FETCH NEXT FROM CurPrijato INTO @Prijato, @Rok, @Mesic, @Stredisko;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	
	UPDATE nin SET nin.Prijato=@Prijato
	FROM Tabx_RS_NakladyInterniNeshody nin
	WHERE nin.Mesic=@Mesic AND nin.Rok=@Rok AND nin.Stredisko=@Stredisko

	FETCH NEXT FROM CurPrijato INTO @Prijato, @Rok, @Mesic, @Stredisko;
	END;
CLOSE CurPrijato;
DEALLOCATE CurPrijato;

--4. výpočet měsíčního koeficientu

UPDATE nakl SET nakl.Koef_mesic = (SELECT (SUM(nin.Material)+SUM(nin.Viceprace))/ ISNULL(NULLIF(SUM(nin.Prijato),0),-1)*100
									FROM Tabx_RS_NakladyInterniNeshody nin
									WHERE nin.Mesic=nakl.Mesic AND nin.Rok=nakl.Rok
									GROUP BY nin.Rok,nin.Mesic)
FROM Tabx_RS_NakladyInterniNeshody nakl

UPDATE nakl SET DatZmeny = GETDATE()
FROM Tabx_RS_NakladyInterniNeshody nakl
WHERE Mesic = DATEPART(MONTH,GETDATE()) AND Rok = DATEPART(YEAR,GETDATE())

UPDATE nakl SET DatZmeny = GETDATE()
FROM Tabx_RS_NakladyInterniNeshody nakl
WHERE Mesic = DATEPART(MONTH,DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-1,0)) AND Rok = DATEPART(YEAR,GETDATE())
GO

