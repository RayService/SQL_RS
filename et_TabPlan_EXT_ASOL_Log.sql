USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_EXT_ASOL_Log]    Script Date: 02.07.2025 15:42:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPlan_EXT_ASOL_Log] ON [dbo].[TabPlan_EXT]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabPlan_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabPlan_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabPlan_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(_DatEng) OR UPDATE(_DatumZaplanovani) OR UPDATE(_EngPrip) OR UPDATE(_EXT_datumEX)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan_EXT', ISNULL(D.ID, I.ID), N'_DatEng',  @Akce , CONVERT(NVARCHAR(255), D._DatEng, 20) , CONVERT(NVARCHAR(255), I._DatEng, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._DatEng <> I._DatEng) OR (D._DatEng IS NULL AND I._DatEng IS NOT NULL ) OR (D._DatEng IS NOT NULL AND I._DatEng IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan_EXT', ISNULL(D.ID, I.ID), N'_DatumZaplanovani',  @Akce , CONVERT(NVARCHAR(255), D._DatumZaplanovani, 20) , CONVERT(NVARCHAR(255), I._DatumZaplanovani, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._DatumZaplanovani <> I._DatumZaplanovani) OR (D._DatumZaplanovani IS NULL AND I._DatumZaplanovani IS NOT NULL ) OR (D._DatumZaplanovani IS NOT NULL AND I._DatumZaplanovani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan_EXT', ISNULL(D.ID, I.ID), N'_EngPrip',  @Akce , CONVERT(NVARCHAR(255), D._EngPrip), CONVERT(NVARCHAR(255), I._EngPrip) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EngPrip <> I._EngPrip) OR (D._EngPrip IS NULL AND I._EngPrip IS NOT NULL ) OR (D._EngPrip IS NOT NULL AND I._EngPrip IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan_EXT', ISNULL(D.ID, I.ID), N'_EXT_datumEX',  @Akce , CONVERT(NVARCHAR(255), D._EXT_datumEX, 20) , CONVERT(NVARCHAR(255), I._EXT_datumEX, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_datumEX <> I._EXT_datumEX) OR (D._EXT_datumEX IS NULL AND I._EXT_datumEX IS NOT NULL ) OR (D._EXT_datumEX IS NOT NULL AND I._EXT_datumEX IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabPlan', D.ID, '_EXT_datumEX', 'D', LEFT('_DatEng:' + ISNULL(CONVERT(NVARCHAR(255),  D._DatEng, 20),N'') + '; ' + '_DatumZaplanovani:' + ISNULL(CONVERT(NVARCHAR(255),  D._DatumZaplanovani, 20),N'') + '; ' + '_EXT_datumEX:' + ISNULL(CONVERT(NVARCHAR(255),  D._EXT_datumEX, 20),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPlan_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabPlan_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPlan_EXT] ENABLE TRIGGER [et_TabPlan_EXT_ASOL_Log]
GO

