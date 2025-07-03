USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabCisZam_ASOL_Log]    Script Date: 03.07.2025 9:52:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabCisZam_ASOL_Log] ON [dbo].[TabCisZam]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabCisZam_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabCisZam_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabCisZam_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(AdrPrechMisto) OR UPDATE(AdrPrechOrCislo) OR UPDATE(AdrPrechPopCislo) OR UPDATE(AdrPrechPSC) OR UPDATE(AdrPrechUlice) OR UPDATE(AdrPrechZeme) OR UPDATE(AdrTrvMisto) OR UPDATE(AdrTrvOrCislo) OR UPDATE(AdrTrvPopCislo) OR UPDATE(AdrTrvPSC) OR UPDATE(AdrTrvUlice) OR UPDATE(AdrTrvZeme) OR UPDATE(Cislo) OR UPDATE(Jmeno) OR UPDATE(Prijmeni) OR UPDATE(RodinnyStav) OR UPDATE(RodneCislo) OR UPDATE(RodnePrijmeni) OR UPDATE(StatniPrislus) OR UPDATE(Stredisko) OR UPDATE(TitulPred) OR UPDATE(TitulZa)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrPrechMisto',  @Akce , CONVERT(NVARCHAR(255), D.AdrPrechMisto), CONVERT(NVARCHAR(255), I.AdrPrechMisto) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrPrechMisto <> I.AdrPrechMisto) OR (D.AdrPrechMisto IS NULL AND I.AdrPrechMisto IS NOT NULL ) OR (D.AdrPrechMisto IS NOT NULL AND I.AdrPrechMisto IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrPrechOrCislo',  @Akce , CONVERT(NVARCHAR(255), D.AdrPrechOrCislo), CONVERT(NVARCHAR(255), I.AdrPrechOrCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrPrechOrCislo <> I.AdrPrechOrCislo) OR (D.AdrPrechOrCislo IS NULL AND I.AdrPrechOrCislo IS NOT NULL ) OR (D.AdrPrechOrCislo IS NOT NULL AND I.AdrPrechOrCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrPrechPopCislo',  @Akce , CONVERT(NVARCHAR(255), D.AdrPrechPopCislo), CONVERT(NVARCHAR(255), I.AdrPrechPopCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrPrechPopCislo <> I.AdrPrechPopCislo) OR (D.AdrPrechPopCislo IS NULL AND I.AdrPrechPopCislo IS NOT NULL ) OR (D.AdrPrechPopCislo IS NOT NULL AND I.AdrPrechPopCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrPrechPSC',  @Akce , CONVERT(NVARCHAR(255), D.AdrPrechPSC), CONVERT(NVARCHAR(255), I.AdrPrechPSC) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrPrechPSC <> I.AdrPrechPSC) OR (D.AdrPrechPSC IS NULL AND I.AdrPrechPSC IS NOT NULL ) OR (D.AdrPrechPSC IS NOT NULL AND I.AdrPrechPSC IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrPrechUlice',  @Akce , CONVERT(NVARCHAR(255), D.AdrPrechUlice), CONVERT(NVARCHAR(255), I.AdrPrechUlice) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrPrechUlice <> I.AdrPrechUlice) OR (D.AdrPrechUlice IS NULL AND I.AdrPrechUlice IS NOT NULL ) OR (D.AdrPrechUlice IS NOT NULL AND I.AdrPrechUlice IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrPrechZeme',  @Akce , CONVERT(NVARCHAR(255), D.AdrPrechZeme), CONVERT(NVARCHAR(255), I.AdrPrechZeme) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrPrechZeme <> I.AdrPrechZeme) OR (D.AdrPrechZeme IS NULL AND I.AdrPrechZeme IS NOT NULL ) OR (D.AdrPrechZeme IS NOT NULL AND I.AdrPrechZeme IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrTrvMisto',  @Akce , CONVERT(NVARCHAR(255), D.AdrTrvMisto), CONVERT(NVARCHAR(255), I.AdrTrvMisto) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrTrvMisto <> I.AdrTrvMisto) OR (D.AdrTrvMisto IS NULL AND I.AdrTrvMisto IS NOT NULL ) OR (D.AdrTrvMisto IS NOT NULL AND I.AdrTrvMisto IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrTrvOrCislo',  @Akce , CONVERT(NVARCHAR(255), D.AdrTrvOrCislo), CONVERT(NVARCHAR(255), I.AdrTrvOrCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrTrvOrCislo <> I.AdrTrvOrCislo) OR (D.AdrTrvOrCislo IS NULL AND I.AdrTrvOrCislo IS NOT NULL ) OR (D.AdrTrvOrCislo IS NOT NULL AND I.AdrTrvOrCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrTrvPopCislo',  @Akce , CONVERT(NVARCHAR(255), D.AdrTrvPopCislo), CONVERT(NVARCHAR(255), I.AdrTrvPopCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrTrvPopCislo <> I.AdrTrvPopCislo) OR (D.AdrTrvPopCislo IS NULL AND I.AdrTrvPopCislo IS NOT NULL ) OR (D.AdrTrvPopCislo IS NOT NULL AND I.AdrTrvPopCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrTrvPSC',  @Akce , CONVERT(NVARCHAR(255), D.AdrTrvPSC), CONVERT(NVARCHAR(255), I.AdrTrvPSC) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrTrvPSC <> I.AdrTrvPSC) OR (D.AdrTrvPSC IS NULL AND I.AdrTrvPSC IS NOT NULL ) OR (D.AdrTrvPSC IS NOT NULL AND I.AdrTrvPSC IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrTrvUlice',  @Akce , CONVERT(NVARCHAR(255), D.AdrTrvUlice), CONVERT(NVARCHAR(255), I.AdrTrvUlice) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrTrvUlice <> I.AdrTrvUlice) OR (D.AdrTrvUlice IS NULL AND I.AdrTrvUlice IS NOT NULL ) OR (D.AdrTrvUlice IS NOT NULL AND I.AdrTrvUlice IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'AdrTrvZeme',  @Akce , CONVERT(NVARCHAR(255), D.AdrTrvZeme), CONVERT(NVARCHAR(255), I.AdrTrvZeme) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AdrTrvZeme <> I.AdrTrvZeme) OR (D.AdrTrvZeme IS NULL AND I.AdrTrvZeme IS NOT NULL ) OR (D.AdrTrvZeme IS NOT NULL AND I.AdrTrvZeme IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'Jmeno',  @Akce , CONVERT(NVARCHAR(255), D.Jmeno), CONVERT(NVARCHAR(255), I.Jmeno) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Jmeno <> I.Jmeno) OR (D.Jmeno IS NULL AND I.Jmeno IS NOT NULL ) OR (D.Jmeno IS NOT NULL AND I.Jmeno IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'Prijmeni',  @Akce , CONVERT(NVARCHAR(255), D.Prijmeni), CONVERT(NVARCHAR(255), I.Prijmeni) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Prijmeni <> I.Prijmeni) OR (D.Prijmeni IS NULL AND I.Prijmeni IS NOT NULL ) OR (D.Prijmeni IS NOT NULL AND I.Prijmeni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'RodinnyStav',  @Akce , CONVERT(NVARCHAR(255), D.RodinnyStav), CONVERT(NVARCHAR(255), I.RodinnyStav) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RodinnyStav <> I.RodinnyStav) OR (D.RodinnyStav IS NULL AND I.RodinnyStav IS NOT NULL ) OR (D.RodinnyStav IS NOT NULL AND I.RodinnyStav IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'RodneCislo',  @Akce , CONVERT(NVARCHAR(255), D.RodneCislo), CONVERT(NVARCHAR(255), I.RodneCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RodneCislo <> I.RodneCislo) OR (D.RodneCislo IS NULL AND I.RodneCislo IS NOT NULL ) OR (D.RodneCislo IS NOT NULL AND I.RodneCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'RodnePrijmeni',  @Akce , CONVERT(NVARCHAR(255), D.RodnePrijmeni), CONVERT(NVARCHAR(255), I.RodnePrijmeni) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RodnePrijmeni <> I.RodnePrijmeni) OR (D.RodnePrijmeni IS NULL AND I.RodnePrijmeni IS NOT NULL ) OR (D.RodnePrijmeni IS NOT NULL AND I.RodnePrijmeni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'StatniPrislus',  @Akce , CONVERT(NVARCHAR(255), D.StatniPrislus), CONVERT(NVARCHAR(255), I.StatniPrislus) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.StatniPrislus <> I.StatniPrislus) OR (D.StatniPrislus IS NULL AND I.StatniPrislus IS NOT NULL ) OR (D.StatniPrislus IS NOT NULL AND I.StatniPrislus IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'Stredisko',  @Akce , CONVERT(NVARCHAR(255), D.Stredisko), CONVERT(NVARCHAR(255), I.Stredisko) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Stredisko <> I.Stredisko) OR (D.Stredisko IS NULL AND I.Stredisko IS NOT NULL ) OR (D.Stredisko IS NOT NULL AND I.Stredisko IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'TitulPred',  @Akce , CONVERT(NVARCHAR(255), D.TitulPred), CONVERT(NVARCHAR(255), I.TitulPred) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.TitulPred <> I.TitulPred) OR (D.TitulPred IS NULL AND I.TitulPred IS NOT NULL ) OR (D.TitulPred IS NOT NULL AND I.TitulPred IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisZam', ISNULL(D.ID, I.ID), N'TitulZa',  @Akce , CONVERT(NVARCHAR(255), D.TitulZa), CONVERT(NVARCHAR(255), I.TitulZa) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.TitulZa <> I.TitulZa) OR (D.TitulZa IS NULL AND I.TitulZa IS NOT NULL ) OR (D.TitulZa IS NOT NULL AND I.TitulZa IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabCisZam', D.ID, 'TitulZa', 'D', LEFT('Cislo:' + ISNULL(CONVERT(NVARCHAR(255),  D.Cislo),N'') + '; ' + 'Jmeno:' + ISNULL(CONVERT(NVARCHAR(255),  D.Jmeno),N'') + '; ' + 'Prijmeni:' + ISNULL(CONVERT(NVARCHAR(255),  D.Prijmeni),N'') + '; ' + 'RodneCislo:' + ISNULL(CONVERT(NVARCHAR(255),  D.RodneCislo),N'') + '; ' + 'TitulPred:' + ISNULL(CONVERT(NVARCHAR(255),  D.TitulPred),N'') + '; ' + 'TitulZa:' + ISNULL(CONVERT(NVARCHAR(255),  D.TitulZa),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabCisZam_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabCisZam_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabCisZam_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabCisZam] ENABLE TRIGGER [et_TabCisZam_ASOL_Log]
GO

