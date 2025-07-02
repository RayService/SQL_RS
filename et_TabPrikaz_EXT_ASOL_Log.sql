USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikaz_EXT_ASOL_Log]    Script Date: 02.07.2025 16:11:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPrikaz_EXT_ASOL_Log] ON [dbo].[TabPrikaz_EXT]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabPrikaz_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabPrikaz_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabPrikaz_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(_pocet_opraveno) OR UPDATE(_popistavu5_zad)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz_EXT', ISNULL(D.ID, I.ID), N'_pocet_opraveno',  @Akce , CONVERT(NVARCHAR(255), D._pocet_opraveno, 20) , CONVERT(NVARCHAR(255), I._pocet_opraveno, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._pocet_opraveno <> I._pocet_opraveno) OR (D._pocet_opraveno IS NULL AND I._pocet_opraveno IS NOT NULL ) OR (D._pocet_opraveno IS NOT NULL AND I._pocet_opraveno IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz_EXT', ISNULL(D.ID, I.ID), N'_popistavu5_zad',  @Akce , CONVERT(NVARCHAR(255), D._popistavu5_zad), CONVERT(NVARCHAR(255), I._popistavu5_zad) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._popistavu5_zad <> I._popistavu5_zad) OR (D._popistavu5_zad IS NULL AND I._popistavu5_zad IS NOT NULL ) OR (D._popistavu5_zad IS NOT NULL AND I._popistavu5_zad IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabPrikaz', D.ID, '_popistavu5_zad', 'D', LEFT('_pocet_opraveno:' + ISNULL(CONVERT(NVARCHAR(255),  D._pocet_opraveno, 20),N'') + '; ' + '_popistavu5_zad:' + ISNULL(CONVERT(NVARCHAR(255),  D._popistavu5_zad),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPrikaz_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabPrikaz_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPrikaz_EXT] ENABLE TRIGGER [et_TabPrikaz_EXT_ASOL_Log]
GO

