USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_posun_datum_planu]    Script Date: 26.06.2025 11:32:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_posun_datum_planu]
@DatumNew DATETIME,
@ID INT
AS
DECLARE @PocetDnu INT
DECLARE @DatumBase DATETIME
--kontrola, zda je rozpad
IF NOT EXISTS (SELECT tpp.ID FROM TabPlanPrikaz tpp
JOIN TabPlan tp ON tp.ID=tpp.IDPlan
WHERE tpp.IDPlan=@ID)
BEGIN
RAISERROR('Neexistuje plánovaný rozpad, akce neproběhne.',16,1)
RETURN
END
ELSE
--zahájení výpočtu
BEGIN
SET @DatumBase=(SELECT TOP 1 tpp.Plan_zadani
FROM TabPlanPrikaz tpp
JOIN TabPlan tp ON tp.ID=tpp.IDPlan
WHERE tpp.IDPlan=@ID
ORDER BY tpp.Plan_zadani DESC)-13
SET @PocetDnu=(SELECT DATEDIFF(DAY,@DatumBase,@DatumNew))

UPDATE tp SET tp.Datum=tp.Datum+@PocetDnu
FROM TabPlan tp
WHERE tp.ID=@ID

IF OBJECT_ID(N'tempdb..#TabPomSeznamVyrPlanuProVypocetPlanVyroby') IS NOT NULL DROP TABLE #TabPomSeznamVyrPlanuProVypocetPlanVyroby
UPDATE TabPlan SET BlokovaniEditoru = NULL WHERE BlokovaniEditoru IS NOT NULL
IF OBJECT_ID(N'tempdb..#TabPomSeznamVyrPlanuProVypocetPlanVyroby')IS NULL
CREATE TABLE #TabPomSeznamVyrPlanuProVypocetPlanVyroby(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TabPomSeznamVyrPlanuProVypocetPlanVyroby
INSERT #TabPomSeznamVyrPlanuProVypocetPlanVyroby(ID) VALUES (@ID)

DECLARE @ret integer
EXEC @ret=hp_VyrPlan_VypocetPlanovaneVyroby 0
SELECT @ret

END;
GO

