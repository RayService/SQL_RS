USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_ASOL_Log]    Script Date: 03.07.2025 9:55:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabDokladyZbozi_ASOL_Log] ON [dbo].[TabDokladyZbozi]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabDokladyZbozi_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabDokladyZbozi_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabDokladyZbozi_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(CisloOrg) OR UPDATE(CisloZakazky) OR UPDATE(DatPorizeni) OR UPDATE(DatRealizace) OR UPDATE(DatUctovani) OR UPDATE(DruhPohybuZbo) OR UPDATE(IDSklad) OR UPDATE(Kurz) OR UPDATE(NOkruhCislo) OR UPDATE(Obdobi) OR UPDATE(PoradoveCislo) OR UPDATE(RadaDokladu) OR UPDATE(Splneno) OR UPDATE(StredNaklad) OR UPDATE(SumaKc) OR UPDATE(SumaVal)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'CisloOrg',  @Akce , CONVERT(NVARCHAR(255), D.CisloOrg), CONVERT(NVARCHAR(255), I.CisloOrg) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.CisloOrg <> I.CisloOrg) OR (D.CisloOrg IS NULL AND I.CisloOrg IS NOT NULL ) OR (D.CisloOrg IS NOT NULL AND I.CisloOrg IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'CisloZakazky',  @Akce , CONVERT(NVARCHAR(255), D.CisloZakazky), CONVERT(NVARCHAR(255), I.CisloZakazky) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.CisloZakazky <> I.CisloZakazky) OR (D.CisloZakazky IS NULL AND I.CisloZakazky IS NOT NULL ) OR (D.CisloZakazky IS NOT NULL AND I.CisloZakazky IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'DatPorizeni',  @Akce , CONVERT(NVARCHAR(255), D.DatPorizeni, 20) , CONVERT(NVARCHAR(255), I.DatPorizeni, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatPorizeni <> I.DatPorizeni) OR (D.DatPorizeni IS NULL AND I.DatPorizeni IS NOT NULL ) OR (D.DatPorizeni IS NOT NULL AND I.DatPorizeni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'DatRealizace',  @Akce , CONVERT(NVARCHAR(255), D.DatRealizace, 20) , CONVERT(NVARCHAR(255), I.DatRealizace, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatRealizace <> I.DatRealizace) OR (D.DatRealizace IS NULL AND I.DatRealizace IS NOT NULL ) OR (D.DatRealizace IS NOT NULL AND I.DatRealizace IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'DatUctovani',  @Akce , CONVERT(NVARCHAR(255), D.DatUctovani, 20) , CONVERT(NVARCHAR(255), I.DatUctovani, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatUctovani <> I.DatUctovani) OR (D.DatUctovani IS NULL AND I.DatUctovani IS NOT NULL ) OR (D.DatUctovani IS NOT NULL AND I.DatUctovani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'Kurz',  @Akce , CONVERT(NVARCHAR(255), D.Kurz), CONVERT(NVARCHAR(255), I.Kurz) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Kurz <> I.Kurz) OR (D.Kurz IS NULL AND I.Kurz IS NOT NULL ) OR (D.Kurz IS NOT NULL AND I.Kurz IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'NOkruhCislo',  @Akce , CONVERT(NVARCHAR(255), D.NOkruhCislo), CONVERT(NVARCHAR(255), I.NOkruhCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NOkruhCislo <> I.NOkruhCislo) OR (D.NOkruhCislo IS NULL AND I.NOkruhCislo IS NOT NULL ) OR (D.NOkruhCislo IS NOT NULL AND I.NOkruhCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'Splneno',  @Akce , CONVERT(NVARCHAR(255), D.Splneno), CONVERT(NVARCHAR(255), I.Splneno) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Splneno <> I.Splneno) OR (D.Splneno IS NULL AND I.Splneno IS NOT NULL ) OR (D.Splneno IS NOT NULL AND I.Splneno IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'StredNaklad',  @Akce , CONVERT(NVARCHAR(255), D.StredNaklad), CONVERT(NVARCHAR(255), I.StredNaklad) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.StredNaklad <> I.StredNaklad) OR (D.StredNaklad IS NULL AND I.StredNaklad IS NOT NULL ) OR (D.StredNaklad IS NOT NULL AND I.StredNaklad IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'SumaKc',  @Akce , CONVERT(NVARCHAR(255), D.SumaKc), CONVERT(NVARCHAR(255), I.SumaKc) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.SumaKc <> I.SumaKc) OR (D.SumaKc IS NULL AND I.SumaKc IS NOT NULL ) OR (D.SumaKc IS NOT NULL AND I.SumaKc IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabDokladyZbozi', ISNULL(D.ID, I.ID), N'SumaVal',  @Akce , CONVERT(NVARCHAR(255), D.SumaVal), CONVERT(NVARCHAR(255), I.SumaVal) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.SumaVal <> I.SumaVal) OR (D.SumaVal IS NULL AND I.SumaVal IS NOT NULL ) OR (D.SumaVal IS NOT NULL AND I.SumaVal IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabDokladyZbozi', D.ID, 'SumaVal', 'D', LEFT('CisloOrg:' + ISNULL(CONVERT(NVARCHAR(255),  D.CisloOrg),N'') + '; ' + 'CisloZakazky:' + ISNULL(CONVERT(NVARCHAR(255),  D.CisloZakazky),N'') + '; ' + 'DatPorizeni:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatPorizeni, 20),N'') + '; ' + 'DatRealizace:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatRealizace, 20),N'') + '; ' + 'DatUctovani:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatUctovani, 20),N'') + '; ' + 'DruhPohybuZbo:' + ISNULL(CONVERT(NVARCHAR(255),  D.DruhPohybuZbo),N'') + '; ' + 'IDSklad:' + ISNULL(CONVERT(NVARCHAR(255),  D.IDSklad),N'') + '; ' + 'NOkruhCislo:' + ISNULL(CONVERT(NVARCHAR(255),  D.NOkruhCislo),N'') + '; ' + 'Obdobi:' + ISNULL(CONVERT(NVARCHAR(255),  D.Obdobi),N'') + '; ' + 'PoradoveCislo:' + ISNULL(CONVERT(NVARCHAR(255),  D.PoradoveCislo),N'') + '; ' + 'RadaDokladu:' + ISNULL(CONVERT(NVARCHAR(255),  D.RadaDokladu),N'') + '; ' + 'StredNaklad:' + ISNULL(CONVERT(NVARCHAR(255),  D.StredNaklad),N'') + '; ' + 'SumaKc:' + ISNULL(CONVERT(NVARCHAR(255),  D.SumaKc),N'') + '; ' + 'SumaVal:' + ISNULL(CONVERT(NVARCHAR(255),  D.SumaVal),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabDokladyZbozi_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabDokladyZbozi_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabDokladyZbozi_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ENABLE TRIGGER [et_TabDokladyZbozi_ASOL_Log]
GO

