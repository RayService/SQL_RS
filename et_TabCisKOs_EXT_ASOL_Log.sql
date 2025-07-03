USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabCisKOs_EXT_ASOL_Log]    Script Date: 03.07.2025 9:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabCisKOs_EXT_ASOL_Log] ON [dbo].[TabCisKOs_EXT]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabCisKOs_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabCisKOs_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabCisKOs_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(_KontNeakt)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisKOs_EXT', ISNULL(D.ID, I.ID), N'_KontNeakt',  @Akce , CONVERT(NVARCHAR(255), D._KontNeakt), CONVERT(NVARCHAR(255), I._KontNeakt) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._KontNeakt <> I._KontNeakt) OR (D._KontNeakt IS NULL AND I._KontNeakt IS NOT NULL ) OR (D._KontNeakt IS NOT NULL AND I._KontNeakt IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisKOs_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisKOs_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabCisKOs', D.ID, '_KontNeakt', 'D', LEFT('_KontNeakt:' + ISNULL(CONVERT(NVARCHAR(255),  D._KontNeakt),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabCisKOs_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabCisKOs_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabCisKOs_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabCisKOs_EXT] ENABLE TRIGGER [et_TabCisKOs_EXT_ASOL_Log]
GO

