USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_posun_PozadDatDod]    Script Date: 26.06.2025 10:33:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_posun_PozadDatDod]
@Weekcount INT,
@Weekday INT,
@ID int
AS
DECLARE @DateOrig DATETIME -- původní Požadované datum dodání na pohybu
DECLARE @YearOrig INT -- rok z původního Požadovaného data dodání
DECLARE @WeekNr INT -- počet týdnů v daném roce původního Požadovaného data dodání
DECLARE @DateNew DATETIME -- nové datum
SET @DateOrig = (SELECT tpz.PozadDatDod
				FROM TabPohybyZbozi tpz
				WHERE tpz.ID = @ID)
SELECT DATEADD(wk, @Weekcount, DATEADD(DAY, 1-DATEPART(WEEKDAY, @DateOrig), DATEDIFF(dd, 0, @DateOrig)))+1 --first day required week
SELECT DATEADD(wk, @Weekcount, DATEADD(DAY, 1-DATEPART(WEEKDAY, @DateOrig), DATEDIFF(dd, 0, @DateOrig)))+@Weekday AS 'Datum kam posunout'
SET @DateNew = (SELECT DATEADD(wk, @Weekcount, DATEADD(DAY, 1-DATEPART(WEEKDAY, @DateOrig), DATEDIFF(dd, 0, @DateOrig)))+@Weekday);
IF @DateNew > GETDATE()
BEGIN
UPDATE TabPohybyZbozi SET PozadDatDod = (SELECT DATEADD(wk, @Weekcount, DATEADD(DAY, 1-DATEPART(WEEKDAY, @DateOrig), DATEDIFF(dd, 0, @DateOrig)))+@Weekday) WHERE ID = @ID
END
IF @DateNew <= GETDATE()
BEGIN
IF (DATEPART(WEEKDAY, @DateNew)) > (DATEPART(WEEKDAY, GETDATE()))
BEGIN 
DECLARE @DayDiff INT;
SET @DayDiff = ((DATEPART(WEEKDAY, @DateNew)) - (DATEPART(WEEKDAY, GETDATE())))
UPDATE TabPohybyZbozi SET PozadDatDod = GETDATE()+@DayDiff WHERE ID = @ID
END
IF (DATEPART(WEEKDAY, @DateNew)) <= (DATEPART(WEEKDAY, GETDATE()))
BEGIN
SET @DateNew = (SELECT DATEADD(wk, 1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE())))+@Weekday);
UPDATE TabPohybyZbozi SET PozadDatDod = @DateNew WHERE ID = @ID
END
END
;
GO

