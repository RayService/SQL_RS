USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabVyrCisPrikaz_ASOL_Log]    Script Date: 03.07.2025 8:38:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabVyrCisPrikaz_ASOL_Log] ON [dbo].[TabVyrCisPrikaz]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabVyrCisPrikaz_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabVyrCisPrikaz_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabVyrCisPrikaz_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(DatExpirace) OR UPDATE(ID) OR UPDATE(Mnozstvi) OR UPDATE(Popis) OR UPDATE(VyrCislo)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabVyrCisPrikaz', ISNULL(D.ID, I.ID), N'DatExpirace',  @Akce , CONVERT(NVARCHAR(255), D.DatExpirace, 20) , CONVERT(NVARCHAR(255), I.DatExpirace, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatExpirace <> I.DatExpirace) OR (D.DatExpirace IS NULL AND I.DatExpirace IS NOT NULL ) OR (D.DatExpirace IS NOT NULL AND I.DatExpirace IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabVyrCisPrikaz', ISNULL(D.ID, I.ID), N'ID',  @Akce , CONVERT(NVARCHAR(255), D.ID), CONVERT(NVARCHAR(255), I.ID) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ID <> I.ID) OR (D.ID IS NULL AND I.ID IS NOT NULL ) OR (D.ID IS NOT NULL AND I.ID IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabVyrCisPrikaz', ISNULL(D.ID, I.ID), N'Mnozstvi',  @Akce , CONVERT(NVARCHAR(255), D.Mnozstvi), CONVERT(NVARCHAR(255), I.Mnozstvi) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Mnozstvi <> I.Mnozstvi) OR (D.Mnozstvi IS NULL AND I.Mnozstvi IS NOT NULL ) OR (D.Mnozstvi IS NOT NULL AND I.Mnozstvi IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabVyrCisPrikaz', ISNULL(D.ID, I.ID), N'Popis',  @Akce , CONVERT(NVARCHAR(255), D.Popis), CONVERT(NVARCHAR(255), I.Popis) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Popis <> I.Popis) OR (D.Popis IS NULL AND I.Popis IS NOT NULL ) OR (D.Popis IS NOT NULL AND I.Popis IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabVyrCisPrikaz', ISNULL(D.ID, I.ID), N'VyrCislo',  @Akce , CONVERT(NVARCHAR(255), D.VyrCislo), CONVERT(NVARCHAR(255), I.VyrCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.VyrCislo <> I.VyrCislo) OR (D.VyrCislo IS NULL AND I.VyrCislo IS NOT NULL ) OR (D.VyrCislo IS NOT NULL AND I.VyrCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabVyrCisPrikaz', D.ID, 'VyrCislo', 'D', LEFT('Popis:' + ISNULL(CONVERT(NVARCHAR(255),  D.Popis),N'') + '; ' + 'VyrCislo:' + ISNULL(CONVERT(NVARCHAR(255),  D.VyrCislo),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabVyrCisPrikaz_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabVyrCisPrikaz_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabVyrCisPrikaz_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabVyrCisPrikaz] ENABLE TRIGGER [et_TabVyrCisPrikaz_ASOL_Log]
GO

