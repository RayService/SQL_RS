USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UzavreniOperaciSkladu]    Script Date: 26.06.2025 15:43:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UzavreniOperaciSkladu]
AS 
SET NOCOUNT ON;

--při zatržení Připraveno do výroby/ do kooperace (_Popisstavu) - uzavřít operace, které mají v názvu "příprava materiálu" a jsou na pracovišti sklad = 1

IF OBJECT_ID('tempdb..#Operace') IS NOT NULL DROP TABLE #Operace
CREATE TABLE #Operace (ID INT IDENTITY(1,1) NOT NULL, IDPrikaz INT NOT NULL, Doklad INT NOT NULL)

;WITH tp AS (
SELECT tp.ID, tp.Rada, tp.Prikaz
FROM TabPrikaz tp
LEFT OUTER JOIN TabPrikaz_EXT tpe ON tpe.ID=tp.ID
WHERE tp.StavPrikazu IN (20,30,40) AND ((ISNULL(tpe._Popisstavu,0)=1 AND tp.Rada<>N'803')OR(tp.Rada='803')))
INSERT INTO #Operace (IDPrikaz, Doklad)
SELECT tp.ID, prp.Doklad
--SELECT tp.ID AS IDPrikaz, prp.ID AS IDOperace, prp.Doklad, prp.Uzavreno, prp.Splneno, tp.Rada, tp.Prikaz, cpo.IDTabStrom, cpo.Pracoviste, ISNULL(cpoe._EXT_RS_workplaceWH,0) AS _EXT_RS_workplaceWH
FROM tp
LEFT OUTER JOIN TabPrPostup prp ON prp.IDPrikaz=tp.ID
LEFT OUTER JOIN TabCPraco cpo ON prp.Pracoviste=cpo.ID
LEFT OUTER JOIN TabCPraco_EXT cpoe ON cpoe.ID=cpo.ID
WHERE
((prp.IDOdchylkyDo IS NULL)AND(prp.Splneno=0)AND(ISNULL(cpoe._EXT_RS_workplaceWH,0)=1)AND(prp.nazev LIKE '%příprava materiálu%'))
ORDER BY tp.ID ASC

--SELECT *
--FROM #Operace

DECLARE @IDStart INT, @IDEnd INT, @IDPrikaz INT, @Doklad INT
SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #Operace

WHILE @IDStart<=@IDEnd
	BEGIN
	SET @IDPrikaz=(SELECT IDPrikaz FROM #Operace WHERE ID=@IDStart)
	SET @Doklad=(SELECT Doklad FROM #Operace WHERE ID=@IDStart)
	EXEC hp_VyrOperace_ZmenaStavuUzavreno @IDPrikaz, @Doklad, N'A', 1
	SET @IDStart=@IDStart+1
	END;

GO

