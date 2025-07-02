USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKontakty_ASOL_Log]    Script Date: 02.07.2025 15:21:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabKontakty_ASOL_Log] ON [dbo].[TabKontakty]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabKontakty_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabKontakty_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabKontakty_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(Druh) OR UPDATE(Spojeni)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontakty', ISNULL(D.ID, I.ID), N'Druh',  @Akce , CONVERT(NVARCHAR(255), D.Druh), CONVERT(NVARCHAR(255), I.Druh) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Druh <> I.Druh) OR (D.Druh IS NULL AND I.Druh IS NOT NULL ) OR (D.Druh IS NOT NULL AND I.Druh IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontakty_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontakty_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontakty', ISNULL(D.ID, I.ID), N'Spojeni',  @Akce , CONVERT(NVARCHAR(255), D.Spojeni), CONVERT(NVARCHAR(255), I.Spojeni) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Spojeni <> I.Spojeni) OR (D.Spojeni IS NULL AND I.Spojeni IS NOT NULL ) OR (D.Spojeni IS NOT NULL AND I.Spojeni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontakty_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontakty_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabKontakty_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabKontakty_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabKontakty] ENABLE TRIGGER [et_TabKontakty_ASOL_Log]
GO

