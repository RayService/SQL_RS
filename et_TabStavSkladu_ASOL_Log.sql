USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabStavSkladu_ASOL_Log]    Script Date: 03.07.2025 8:07:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabStavSkladu_ASOL_Log] ON [dbo].[TabStavSkladu]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabStavSkladu_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabStavSkladu_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabStavSkladu_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Ins = 1 AND @Del = 0 AND (SELECT JeNovaVetaEditor FROM INSERTED) = 1
RETURN
IF @Ins = 0 AND @Del = 1 AND (SELECT JeNovaVetaEditor FROM DELETED) = 1
RETURN
IF @Ins = 1 AND (SELECT JeNovaVetaEditor FROM INSERTED) = 0 AND (SELECT JeNovaVetaEditor FROM DELETED) = 1
SET @Akce = 'I'

IF @Akce IN (N'I', N'D') OR UPDATE(Maximum) OR UPDATE(Minimum)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabStavSkladu', ISNULL(D.ID, I.ID), N'Maximum',  @Akce , CONVERT(NVARCHAR(255), D.Maximum), CONVERT(NVARCHAR(255), I.Maximum) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Maximum <> I.Maximum) OR (D.Maximum IS NULL AND I.Maximum IS NOT NULL ) OR (D.Maximum IS NOT NULL AND I.Maximum IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabStavSkladu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabStavSkladu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabStavSkladu', ISNULL(D.ID, I.ID), N'Minimum',  @Akce , CONVERT(NVARCHAR(255), D.Minimum), CONVERT(NVARCHAR(255), I.Minimum) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Minimum <> I.Minimum) OR (D.Minimum IS NULL AND I.Minimum IS NOT NULL ) OR (D.Minimum IS NOT NULL AND I.Minimum IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabStavSkladu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabStavSkladu_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabStavSkladu_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabStavSkladu_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabStavSkladu] ENABLE TRIGGER [et_TabStavSkladu_ASOL_Log]
GO

