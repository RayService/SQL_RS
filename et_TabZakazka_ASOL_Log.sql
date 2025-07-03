USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabZakazka_ASOL_Log]    Script Date: 03.07.2025 8:42:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabZakazka_ASOL_Log] ON [dbo].[TabZakazka]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabZakazka_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabZakazka_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabZakazka_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(CisloNabidky) OR UPDATE(CisloObjednavky) OR UPDATE(CisloZakazky) OR UPDATE(NadrizenaZak) OR UPDATE(NavaznaZak) OR UPDATE(Nazev)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabZakazka', ISNULL(D.ID, I.ID), N'CisloNabidky',  @Akce , CONVERT(NVARCHAR(255), D.CisloNabidky), CONVERT(NVARCHAR(255), I.CisloNabidky) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.CisloNabidky <> I.CisloNabidky) OR (D.CisloNabidky IS NULL AND I.CisloNabidky IS NOT NULL ) OR (D.CisloNabidky IS NOT NULL AND I.CisloNabidky IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabZakazka', ISNULL(D.ID, I.ID), N'CisloObjednavky',  @Akce , CONVERT(NVARCHAR(255), D.CisloObjednavky), CONVERT(NVARCHAR(255), I.CisloObjednavky) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.CisloObjednavky <> I.CisloObjednavky) OR (D.CisloObjednavky IS NULL AND I.CisloObjednavky IS NOT NULL ) OR (D.CisloObjednavky IS NOT NULL AND I.CisloObjednavky IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabZakazka', ISNULL(D.ID, I.ID), N'CisloZakazky',  @Akce , CONVERT(NVARCHAR(255), D.CisloZakazky), CONVERT(NVARCHAR(255), I.CisloZakazky) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.CisloZakazky <> I.CisloZakazky) OR (D.CisloZakazky IS NULL AND I.CisloZakazky IS NOT NULL ) OR (D.CisloZakazky IS NOT NULL AND I.CisloZakazky IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabZakazka', ISNULL(D.ID, I.ID), N'NadrizenaZak',  @Akce , CONVERT(NVARCHAR(255), D.NadrizenaZak), CONVERT(NVARCHAR(255), I.NadrizenaZak) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NadrizenaZak <> I.NadrizenaZak) OR (D.NadrizenaZak IS NULL AND I.NadrizenaZak IS NOT NULL ) OR (D.NadrizenaZak IS NOT NULL AND I.NadrizenaZak IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabZakazka', ISNULL(D.ID, I.ID), N'NavaznaZak',  @Akce , CONVERT(NVARCHAR(255), D.NavaznaZak), CONVERT(NVARCHAR(255), I.NavaznaZak) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NavaznaZak <> I.NavaznaZak) OR (D.NavaznaZak IS NULL AND I.NavaznaZak IS NOT NULL ) OR (D.NavaznaZak IS NOT NULL AND I.NavaznaZak IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabZakazka', ISNULL(D.ID, I.ID), N'Nazev',  @Akce , CONVERT(NVARCHAR(255), D.Nazev), CONVERT(NVARCHAR(255), I.Nazev) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Nazev <> I.Nazev) OR (D.Nazev IS NULL AND I.Nazev IS NOT NULL ) OR (D.Nazev IS NOT NULL AND I.Nazev IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabZakazka', D.ID, 'Nazev', 'D', LEFT('CisloObjednavky:' + ISNULL(CONVERT(NVARCHAR(255),  D.CisloObjednavky),N'') + '; ' + 'NadrizenaZak:' + ISNULL(CONVERT(NVARCHAR(255),  D.NadrizenaZak),N'') + '; ' + 'NavaznaZak:' + ISNULL(CONVERT(NVARCHAR(255),  D.NavaznaZak),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabZakazka_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabZakazka_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabZakazka_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabZakazka] ENABLE TRIGGER [et_TabZakazka_ASOL_Log]
GO

