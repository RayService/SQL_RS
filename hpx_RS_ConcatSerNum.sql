USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ConcatSerNum]    Script Date: 26.06.2025 13:26:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ConcatSerNum]
AS
DECLARE @IDPrikaz INT,
@mnozOd NUMERIC(19,6), 
@mnozDo NUMERIC(19,6), 
@SK NVARCHAR(3),
@RC NVARCHAR(30), 
@Rada NVARCHAR(10),
@Prikaz NVARCHAR(10),
@vyrCislo NVARCHAR(100),
@PopisVC NVARCHAR(100), 
@PoradoveCisloNew NVARCHAR(4),
@PocetVP INT

--cvičná deklarace, jinak řešeno v HEO
/*
IF OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL DROP TABLE #TabExtKomID
CREATE TABLE #TabExtKomID (ID INT)
INSERT INTO #TabExtKomID(ID)
SELECT ID
FROM TabVyrCisPrikaz
WHERE IDPrikaz IN (171931,171930)
--konec cvičné deklarace
*/

;WITH Poradi AS (
SELECT vcp.IDPrikaz AS IDPrikaz, ROW_NUMBER() OVER (ORDER BY vcp.IDPrikaz) AS rn
FROM #TabExtKomID
LEFT OUTER JOIN TabVyrCisPrikaz vcp WITH(NOLOCK) ON vcp.ID=#TabExtKomID.ID
GROUP BY vcp.IDPrikaz)
SELECT @PocetVP=rn
FROM Poradi


IF @PocetVP>1
BEGIN
RAISERROR('Jsou označena výrobní čísla z více příkazů, nelze spustit.',16,1)
RETURN
END;

IF @PocetVP=0
BEGIN
RAISERROR('Neexistují VČ, nelze spustit.',16,1)
RETURN
END;


SELECT @IDPrikaz=IDPrikaz, @SK=tkz.SkupZbo, @RC=tkz.RegCis, @Rada=RTRIM(tp.Rada), @Prikaz=CONVERT(NVARCHAR(10),tp.Prikaz)
FROM TabVyrCisPrikaz vcp
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcp.IDPrikaz
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tp.IDTabKmen
WHERE vcp.ID IN (SELECT ID FROM #TabExtKomID)

IF (SELECT StavPrikazu FROM TabPrikaz WHERE ID=@IDPrikaz)>=50
BEGIN
RAISERROR('VP je ukončen nebo uzavřen, nelze spustit.',16,1)
RETURN
END;


IF OBJECT_ID('tempdb..#TabIDVC') IS NOT NULL DROP TABLE #TabIDVC
CREATE TABLE #TabIDVC (ID INT, Popis NVARCHAR(100), VyrCislo NVARCHAR(100), Mnozstvi NUMERIC(19,6))
INSERT INTO #TabIDVC(ID)
SELECT ID
FROM #TabExtKomID

MERGE #TabIDVC AS TARGET
USING TabVyrCisPrikaz AS SOURCE
ON TARGET.ID=SOURCE.ID
WHEN MATCHED THEN
UPDATE SET TARGET.Popis=SOURCE.Popis,TARGET.VyrCislo=SOURCE.VyrCislo,TARGET.Mnozstvi=SOURCE.MnozstviZive
;
--SELECT * FROM #TabIDVC

DELETE FROM #TabIDVC WHERE Mnozstvi=0

DECLARE @VyrCislo_all VARCHAR(8000), @MnozstviZive_All NUMERIC(19,6)
SELECT @VyrCislo_all=STRING_AGG(VyrCislo,', '), @MnozstviZive_All=SUM(Mnozstvi)
FROM #TabIDVC

--SELECT @VyrCislo_all, @MnozstviZive_All

SET @PoradoveCisloNew =(SELECT TOP 1 RIGHT('0000'+CAST((RIGHT(VyrCislo,4)+1) AS VARCHAR(4)),4)
FROM TabVyrCisPrikaz
WHERE IDPrikaz=@IDPrikaz
ORDER BY VyrCislo DESC)

SET @vyrCislo=CONCAT(@SK, @RC, @Rada, @Prikaz, @PoradoveCisloNew)
SET @PopisVC=@Rada+'-'+@Prikaz

--SELECT @vyrCislo, @PopisVC

INSERT INTO TabVyrCisPrikaz (VyrCislo, Popis, Mnozstvi, IDPrikaz, DatExpirace, Poznamka) VALUES(@vyrCislo, @PopisVC, @MnozstviZive_All, @IDPrikaz, NULL, @VyrCislo_all)

--vynulování stávajících VČ
MERGE TabVyrCisPrikaz AS TARGET
USING #TabIDVC AS SOURCE
ON TARGET.ID=SOURCE.ID
WHEN MATCHED THEN
UPDATE SET TARGET.Mnozstvi=0
;
GO

