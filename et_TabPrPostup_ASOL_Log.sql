USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrPostup_ASOL_Log]    Script Date: 03.07.2025 8:00:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPrPostup_ASOL_Log] ON [dbo].[TabPrPostup]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabPrPostup_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabPrPostup_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabPrPostup_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(nazev) OR UPDATE(Operace) OR UPDATE(Uzavreno) OR UPDATE(ZaevidovaneKusyAll)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrPostup', ISNULL(D.ID, I.ID), N'nazev',  @Akce , CONVERT(NVARCHAR(255), D.nazev), CONVERT(NVARCHAR(255), I.nazev) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.nazev <> I.nazev) OR (D.nazev IS NULL AND I.nazev IS NOT NULL ) OR (D.nazev IS NOT NULL AND I.nazev IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrPostup', ISNULL(D.ID, I.ID), N'Operace',  @Akce , CONVERT(NVARCHAR(255), D.Operace), CONVERT(NVARCHAR(255), I.Operace) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Operace <> I.Operace) OR (D.Operace IS NULL AND I.Operace IS NOT NULL ) OR (D.Operace IS NOT NULL AND I.Operace IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrPostup', ISNULL(D.ID, I.ID), N'Uzavreno',  @Akce , CONVERT(NVARCHAR(255), D.Uzavreno), CONVERT(NVARCHAR(255), I.Uzavreno) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Uzavreno <> I.Uzavreno) OR (D.Uzavreno IS NULL AND I.Uzavreno IS NOT NULL ) OR (D.Uzavreno IS NOT NULL AND I.Uzavreno IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrPostup', ISNULL(D.ID, I.ID), N'ZaevidovaneKusyAll',  @Akce , CONVERT(NVARCHAR(255), D.ZaevidovaneKusyAll), CONVERT(NVARCHAR(255), I.ZaevidovaneKusyAll) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZaevidovaneKusyAll <> I.ZaevidovaneKusyAll) OR (D.ZaevidovaneKusyAll IS NULL AND I.ZaevidovaneKusyAll IS NOT NULL ) OR (D.ZaevidovaneKusyAll IS NOT NULL AND I.ZaevidovaneKusyAll IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrPostup_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPrPostup_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabPrPostup_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPrPostup] ENABLE TRIGGER [et_TabPrPostup_ASOL_Log]
GO

