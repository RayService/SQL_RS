USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_EXT_ASOL_Log]    Script Date: 02.07.2025 15:53:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPohybyZbozi_EXT_ASOL_Log] ON [dbo].[TabPohybyZbozi_EXT]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabPohybyZbozi_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabPohybyZbozi_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabPohybyZbozi_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(_EXT_RS_PromisedStockingDate) OR UPDATE(_EXT_RS_RadaPlanu) OR UPDATE(_EXT_RS_SkupinaPlanu)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPohybyZbozi_EXT', ISNULL(D.ID, I.ID), N'_EXT_RS_PromisedStockingDate',  @Akce , CONVERT(NVARCHAR(255), D._EXT_RS_PromisedStockingDate, 20) , CONVERT(NVARCHAR(255), I._EXT_RS_PromisedStockingDate, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_RS_PromisedStockingDate <> I._EXT_RS_PromisedStockingDate) OR (D._EXT_RS_PromisedStockingDate IS NULL AND I._EXT_RS_PromisedStockingDate IS NOT NULL ) OR (D._EXT_RS_PromisedStockingDate IS NOT NULL AND I._EXT_RS_PromisedStockingDate IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPohybyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPohybyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPohybyZbozi_EXT', ISNULL(D.ID, I.ID), N'_EXT_RS_RadaPlanu',  @Akce , CONVERT(NVARCHAR(255), D._EXT_RS_RadaPlanu), CONVERT(NVARCHAR(255), I._EXT_RS_RadaPlanu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_RS_RadaPlanu <> I._EXT_RS_RadaPlanu) OR (D._EXT_RS_RadaPlanu IS NULL AND I._EXT_RS_RadaPlanu IS NOT NULL ) OR (D._EXT_RS_RadaPlanu IS NOT NULL AND I._EXT_RS_RadaPlanu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPohybyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPohybyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPohybyZbozi_EXT', ISNULL(D.ID, I.ID), N'_EXT_RS_SkupinaPlanu',  @Akce , CONVERT(NVARCHAR(255), D._EXT_RS_SkupinaPlanu), CONVERT(NVARCHAR(255), I._EXT_RS_SkupinaPlanu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_RS_SkupinaPlanu <> I._EXT_RS_SkupinaPlanu) OR (D._EXT_RS_SkupinaPlanu IS NULL AND I._EXT_RS_SkupinaPlanu IS NOT NULL ) OR (D._EXT_RS_SkupinaPlanu IS NOT NULL AND I._EXT_RS_SkupinaPlanu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPohybyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPohybyZbozi_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPohybyZbozi_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabPohybyZbozi_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPohybyZbozi_EXT] ENABLE TRIGGER [et_TabPohybyZbozi_EXT_ASOL_Log]
GO

