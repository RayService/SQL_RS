USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKoopObj_ASOL_Log]    Script Date: 02.07.2025 15:22:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabKoopObj_ASOL_Log] ON [dbo].[TabKoopObj]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabKoopObj_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabKoopObj_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabKoopObj_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(DatRealizace) OR UPDATE(PotvrzTerDod) OR UPDATE(realizovano)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKoopObj', ISNULL(D.ID, I.ID), N'DatRealizace',  @Akce , CONVERT(NVARCHAR(255), D.DatRealizace, 20) , CONVERT(NVARCHAR(255), I.DatRealizace, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatRealizace <> I.DatRealizace) OR (D.DatRealizace IS NULL AND I.DatRealizace IS NOT NULL ) OR (D.DatRealizace IS NOT NULL AND I.DatRealizace IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKoopObj', ISNULL(D.ID, I.ID), N'PotvrzTerDod',  @Akce , CONVERT(NVARCHAR(255), D.PotvrzTerDod, 20) , CONVERT(NVARCHAR(255), I.PotvrzTerDod, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PotvrzTerDod <> I.PotvrzTerDod) OR (D.PotvrzTerDod IS NULL AND I.PotvrzTerDod IS NOT NULL ) OR (D.PotvrzTerDod IS NOT NULL AND I.PotvrzTerDod IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKoopObj', ISNULL(D.ID, I.ID), N'realizovano',  @Akce , CONVERT(NVARCHAR(255), D.realizovano), CONVERT(NVARCHAR(255), I.realizovano) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.realizovano <> I.realizovano) OR (D.realizovano IS NULL AND I.realizovano IS NOT NULL ) OR (D.realizovano IS NOT NULL AND I.realizovano IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabKoopObj', D.ID, 'realizovano', 'D', LEFT('DatRealizace:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatRealizace, 20),N'') + '; ' + 'PotvrzTerDod:' + ISNULL(CONVERT(NVARCHAR(255),  D.PotvrzTerDod, 20),N'') + '; ' + 'realizovano:' + ISNULL(CONVERT(NVARCHAR(255),  D.realizovano),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabKoopObj_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabKoopObj_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabKoopObj_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabKoopObj] ENABLE TRIGGER [et_TabKoopObj_ASOL_Log]
GO

