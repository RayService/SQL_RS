USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_prenos_do_nakladovosti_zakazek]    Script Date: 26.06.2025 11:27:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_prenos_do_nakladovosti_zakazek] @ID INT
AS

DECLARE @CisloZakazky NVARCHAR(15)
DECLARE @NakladyPlan NUMERIC(19,6)
DECLARE @NakladyReal NUMERIC(19,6)
SET @CisloZakazky=(SELECT CisloZakazky FROM TabZakazka WHERE ID=@ID)
SET @NakladyPlan=(SELECT ISNULL(pr.VzorecPlan,0)
FROM TabZakKalPlanH ph
LEFT OUTER JOIN TabZakKalPlanR pr ON pr.IDHlava=ph.ID
LEFT OUTER JOIN TabZakazka tz ON tz.ID=ph.IDZak
WHERE tz.CisloZakazky= @CisloZakazky AND ph.TypPlanu=0 AND pr.CisloR=5)
SET @NakladyReal=(SELECT SUM(ISNULL(td.Castka,0))
FROM TabDenik td
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=td.CisloZakazky
WHERE (td.CisloUcet IN (N'583310',N'583320',N'583330',N'583340')) AND (td.Strana=0)
AND td.Stav=0
AND td.Zaknihovano<>0
AND td.CisloZakazky=@CisloZakazky)

/*
--začneme kurzorem při hromadném importu
DECLARE Cur CURSOR FAST_FORWARD LOCAL FOR
SELECT
TabZakazka.CisloZakazky
FROM TabZakazka WITH(NOLOCK)
WHERE
--(TabZakazka.DatUzavreni_Y=DATEPART(YEAR,GETDATE()))AND(TabZakazka.DatUzavreni_M=DATEPART(MONTH,GETDATE()))AND
(TabZakazka.CisloZakazky=@CisloZakazky)
;
OPEN Cur
WHILE 1=1
BEGIN
FETCH NEXT FROM Cur INTO @CisloZakazky
IF @@FETCH_STATUS <> 0 BREAK
*/
IF @NakladyPlan<>0 AND @NakladyReal<>0
BEGIN
DELETE FROM Tabx_RS_NakladyZakazky WHERE CisloZakazky=@CisloZakazky

INSERT INTO Tabx_RS_NakladyZakazky (CisloZakazky, NakladyReal, DatUzavreni)
SELECT td.CisloZakazky, SUM(ISNULL(td.Castka,0)), tz.DatUzavreni
FROM TabDenik td
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=td.CisloZakazky
WHERE (td.CisloUcet IN (N'583310',N'583320',N'583330',N'583340')) AND (td.Strana=0)
AND td.Stav=0
AND td.Zaknihovano<>0
AND td.CisloZakazky=@CisloZakazky
GROUP BY td.CisloZakazky, tz.DatUzavreni

UPDATE Tabx_RS_NakladyZakazky SET NakladyPlan=(SELECT ISNULL(pr.VzorecPlan,0)
FROM TabZakKalPlanH ph
LEFT OUTER JOIN TabZakKalPlanR pr ON pr.IDHlava=ph.ID
LEFT OUTER JOIN TabZakazka tz ON tz.ID=ph.IDZak
WHERE tz.CisloZakazky= @CisloZakazky AND ph.TypPlanu=0 AND pr.CisloR=5)
FROM Tabx_RS_NakladyZakazky
WHERE Tabx_RS_NakladyZakazky.CisloZakazky=@CisloZakazky
END
ELSE
RETURN;
/*
END
CLOSE Cur
DEALLOCATE Cur
*/
GO

