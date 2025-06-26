USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UzaviraniZakazek]    Script Date: 26.06.2025 14:19:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UzaviraniZakazek]
AS

--uzavírání zakázek předěláno z cursoru na MERGE
--hozeno do procedury

IF OBJECT_ID('tempdb..#TempZak') IS NOT NULL DROP TABLE #TempZak
CREATE TABLE #TempZak (ID INT IDENTITY(1,1), CisloZakazky NVARCHAR(15))

INSERT INTO #TempZak (CisloZakazky)
/*
DECLARE @CisloZakazky NVARCHAR(15);
--DECLARE @DatumFAK DATETIME;
--začneme kurzorem při hromadném importu
DECLARE Cur CURSOR FAST_FORWARD LOCAL FOR*/
SELECT tz.CisloZakazky
FROM TabZakazka tz WITH(NOLOCK)
WHERE
tz.CisloZakazky IN ((((((SELECT tdz.CisloZakazky
				FROM TabDokladyZbozi tdz WITH(NOLOCK)
				WHERE((tdz.DruhPohybuZbo=9)AND(tdz.StavRezervace=N'x')AND(tdz.CisloZakazky IS NOT NULL))
				) INTERSECT (SELECT tdz.CisloZakazky
				FROM TabDokladyZbozi tdz WITH(NOLOCK)
				WHERE(tdz.DruhPohybuZbo=13)AND(tdz.StavRezervace<>N'x')AND(tdz.CisloZakazky=tz.CisloZakazky)
				)) EXCEPT (SELECT tdz.CisloZakazky
				FROM TabDokladyZbozi tdz WITH(NOLOCK)
				WHERE((tdz.DruhPohybuZbo=9)AND(tdz.StavRezervace<>N'x')AND(tdz.CisloZakazky IS NOT NULL)
				)) EXCEPT (SELECT tdz.CisloZakazky
				FROM TabDokladyZbozi tdz WITH(NOLOCK)
				WHERE((tdz.DruhPohybuZbo=2)AND(tdz.Realizovano=0)AND(tdz.CisloZakazky IS NOT NULL))
				)) EXCEPT (SELECT tz.CisloZakazky
				FROM TabPrikaz tp WITH(NOLOCK)
				LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tz.ID=tp.IDZakazka
				WHERE tp.StavPrikazu=30)
				)) EXCEPT (SELECT tz.CisloZakazky
				FROM TabPlan WITH(NOLOCK)
				LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tz.ID=TabPlan.IDZakazka
				WHERE
				((TabPlan.zadano=0)AND(TabPlan.uzavreno=0)AND(TabPlan.Rada<>N'pt_burza'))
				GROUP BY tz.CisloZakazky) 
				)
AND tz.Ukonceno=0
ORDER BY tz.CisloZakazky DESC
/*OPEN Cur
WHILE 1=1
BEGIN
FETCH NEXT FROM Cur INTO @CisloZakazky
IF @@FETCH_STATUS <> 0 BREAK
--SET @DatumFAK=(SELECT TOP 1 tdz.DatPorizeni FROM TabDokladyZbozi tdz WITH(NOLOCK) WHERE tdz.CisloZakazky=@CisloZakazky AND tdz.DruhPohybuZbo=13 ORDER BY tdz.ID DESC)
UPDATE Z SET 
Z.Ukonceno=1,
Z.Uzavrel=SUSER_SNAME(),
Z.DatUzavreni=GETDATE()/*@DatumFAK*/
FROM TabZakazka Z
WHERE Z.CisloZakazky=@CisloZakazky
END
CLOSE Cur
DEALLOCATE Cur*/



--SELECT * FROM #TempZak

MERGE TabZakazka AS TARGET
USING #TempZak AS SOURCE
ON TARGET.CisloZakazky=SOURCE.CisloZakazky
WHEN MATCHED THEN UPDATE
SET TARGET.Ukonceno=1, TARGET.Uzavrel=SUSER_SNAME(), TARGET.DatUzavreni=GETDATE()
;

GO

