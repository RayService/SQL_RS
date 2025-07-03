USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabCisZam_EXT_ASOL_Log]    Script Date: 03.07.2025 9:53:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabCisZam_EXT_ASOL_Log] ON [dbo].[TabCisZam_EXT]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabCisZam_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabCisZam_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabCisZam_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(_EXT_B2ADIMA_ProductionUnitId) OR UPDATE(_KvalZam)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam_EXT', ISNULL(D.ID, I.ID), N'_EXT_B2ADIMA_ProductionUnitId',  @Akce , CONVERT(NVARCHAR(255), D._EXT_B2ADIMA_ProductionUnitId), CONVERT(NVARCHAR(255), I._EXT_B2ADIMA_ProductionUnitId) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_B2ADIMA_ProductionUnitId <> I._EXT_B2ADIMA_ProductionUnitId) OR (D._EXT_B2ADIMA_ProductionUnitId IS NULL AND I._EXT_B2ADIMA_ProductionUnitId IS NOT NULL ) OR (D._EXT_B2ADIMA_ProductionUnitId IS NOT NULL AND I._EXT_B2ADIMA_ProductionUnitId IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam_EXT', ISNULL(D.ID, I.ID), N'_KvalZam',  @Akce , CONVERT(NVARCHAR(255), D._KvalZam), CONVERT(NVARCHAR(255), I._KvalZam) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._KvalZam <> I._KvalZam) OR (D._KvalZam IS NULL AND I._KvalZam IS NOT NULL ) OR (D._KvalZam IS NOT NULL AND I._KvalZam IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabCisZam_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabCisZam_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabCisZam_EXT] ENABLE TRIGGER [et_TabCisZam_EXT_ASOL_Log]
GO

