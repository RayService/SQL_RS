USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_ASOL_Log]    Script Date: 02.07.2025 15:39:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPlan_ASOL_Log] ON [dbo].[TabPlan]
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

IF @Akce IN (N'I', N'D') OR UPDATE(Autor) OR UPDATE(datum) OR UPDATE(DatZmeny) OR UPDATE(ID) OR UPDATE(IDTabKmen) OR UPDATE(IDZakazka) OR UPDATE(mnozstvi) OR UPDATE(uzavreno) OR UPDATE(Zmenil)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'Autor',  @Akce , CONVERT(NVARCHAR(255), D.Autor), CONVERT(NVARCHAR(255), I.Autor) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Autor <> I.Autor) OR (D.Autor IS NULL AND I.Autor IS NOT NULL ) OR (D.Autor IS NOT NULL AND I.Autor IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'datum',  @Akce , CONVERT(NVARCHAR(255), D.datum, 20) , CONVERT(NVARCHAR(255), I.datum, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.datum <> I.datum) OR (D.datum IS NULL AND I.datum IS NOT NULL ) OR (D.datum IS NOT NULL AND I.datum IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'DatZmeny',  @Akce , CONVERT(NVARCHAR(255), D.DatZmeny, 20) , CONVERT(NVARCHAR(255), I.DatZmeny, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatZmeny <> I.DatZmeny) OR (D.DatZmeny IS NULL AND I.DatZmeny IS NOT NULL ) OR (D.DatZmeny IS NOT NULL AND I.DatZmeny IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'ID',  @Akce , CONVERT(NVARCHAR(255), D.ID), CONVERT(NVARCHAR(255), I.ID) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ID <> I.ID) OR (D.ID IS NULL AND I.ID IS NOT NULL ) OR (D.ID IS NOT NULL AND I.ID IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'IDTabKmen',  @Akce , CONVERT(NVARCHAR(255), D.IDTabKmen), CONVERT(NVARCHAR(255), I.IDTabKmen) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDTabKmen <> I.IDTabKmen) OR (D.IDTabKmen IS NULL AND I.IDTabKmen IS NOT NULL ) OR (D.IDTabKmen IS NOT NULL AND I.IDTabKmen IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'IDZakazka',  @Akce , CONVERT(NVARCHAR(255), D.IDZakazka), CONVERT(NVARCHAR(255), I.IDZakazka) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDZakazka <> I.IDZakazka) OR (D.IDZakazka IS NULL AND I.IDZakazka IS NOT NULL ) OR (D.IDZakazka IS NOT NULL AND I.IDZakazka IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'mnozstvi',  @Akce , CONVERT(NVARCHAR(255), D.mnozstvi), CONVERT(NVARCHAR(255), I.mnozstvi) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.mnozstvi <> I.mnozstvi) OR (D.mnozstvi IS NULL AND I.mnozstvi IS NOT NULL ) OR (D.mnozstvi IS NOT NULL AND I.mnozstvi IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'uzavreno',  @Akce , CONVERT(NVARCHAR(255), D.uzavreno), CONVERT(NVARCHAR(255), I.uzavreno) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.uzavreno <> I.uzavreno) OR (D.uzavreno IS NULL AND I.uzavreno IS NOT NULL ) OR (D.uzavreno IS NOT NULL AND I.uzavreno IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPlan', ISNULL(D.ID, I.ID), N'Zmenil',  @Akce , CONVERT(NVARCHAR(255), D.Zmenil), CONVERT(NVARCHAR(255), I.Zmenil) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Zmenil <> I.Zmenil) OR (D.Zmenil IS NULL AND I.Zmenil IS NOT NULL ) OR (D.Zmenil IS NOT NULL AND I.Zmenil IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabPlan', D.ID, 'Zmenil', 'D', LEFT('Autor:' + ISNULL(CONVERT(NVARCHAR(255),  D.Autor),N'') + '; ' + 'datum:' + ISNULL(CONVERT(NVARCHAR(255),  D.datum, 20),N'') + '; ' + 'DatZmeny:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatZmeny, 20),N'') + '; ' + 'ID:' + ISNULL(CONVERT(NVARCHAR(255),  D.ID),N'') + '; ' + 'IDTabKmen:' + ISNULL(CONVERT(NVARCHAR(255),  D.IDTabKmen),N'') + '; ' + 'IDZakazka:' + ISNULL(CONVERT(NVARCHAR(255),  D.IDZakazka),N'') + '; ' + 'mnozstvi:' + ISNULL(CONVERT(NVARCHAR(255),  D.mnozstvi),N'') + '; ' + 'Zmenil:' + ISNULL(CONVERT(NVARCHAR(255),  D.Zmenil),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabPlan_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPlan_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabPlan_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPlan] ENABLE TRIGGER [et_TabPlan_ASOL_Log]
GO

