USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikaz_ASOL_Log]    Script Date: 02.07.2025 16:07:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPrikaz_ASOL_Log] ON [dbo].[TabPrikaz]
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

IF @Ins = 1 AND @Del = 0 AND (SELECT JeNovaVetaEditor FROM INSERTED) = 1
RETURN
IF @Ins = 0 AND @Del = 1 AND (SELECT JeNovaVetaEditor FROM DELETED) = 1
RETURN
IF @Ins = 1 AND (SELECT JeNovaVetaEditor FROM INSERTED) = 0 AND (SELECT JeNovaVetaEditor FROM DELETED) = 1
SET @Akce = 'I'

IF @Akce IN (N'I', N'D') OR UPDATE(DatumTPV) OR UPDATE(ID) OR UPDATE(IDNaklOkruh) OR UPDATE(IDPlan) OR UPDATE(IDTabKmen) OR UPDATE(IDZakazka) OR UPDATE(IndexZmeny1) OR UPDATE(IndexZmeny2) OR UPDATE(KmenoveStredisko) OR UPDATE(kusy_zad) OR UPDATE(NavaznaObjednavka) OR UPDATE(Plan_ukonceni) OR UPDATE(Plan_zadani) OR UPDATE(Prikaz) OR UPDATE(Rada) OR UPDATE(StavPrikazu) OR UPDATE(zadani)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'DatumTPV',  @Akce , CONVERT(NVARCHAR(255), D.DatumTPV, 20) , CONVERT(NVARCHAR(255), I.DatumTPV, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatumTPV <> I.DatumTPV) OR (D.DatumTPV IS NULL AND I.DatumTPV IS NOT NULL ) OR (D.DatumTPV IS NOT NULL AND I.DatumTPV IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'IDNaklOkruh',  @Akce , CONVERT(NVARCHAR(255), D.IDNaklOkruh), CONVERT(NVARCHAR(255), I.IDNaklOkruh) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDNaklOkruh <> I.IDNaklOkruh) OR (D.IDNaklOkruh IS NULL AND I.IDNaklOkruh IS NOT NULL ) OR (D.IDNaklOkruh IS NOT NULL AND I.IDNaklOkruh IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'IDPlan',  @Akce , CONVERT(NVARCHAR(255), D.IDPlan), CONVERT(NVARCHAR(255), I.IDPlan) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDPlan <> I.IDPlan) OR (D.IDPlan IS NULL AND I.IDPlan IS NOT NULL ) OR (D.IDPlan IS NOT NULL AND I.IDPlan IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'IDZakazka',  @Akce , CONVERT(NVARCHAR(255), D.IDZakazka), CONVERT(NVARCHAR(255), I.IDZakazka) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDZakazka <> I.IDZakazka) OR (D.IDZakazka IS NULL AND I.IDZakazka IS NOT NULL ) OR (D.IDZakazka IS NOT NULL AND I.IDZakazka IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'IndexZmeny1',  @Akce , CONVERT(NVARCHAR(255), D.IndexZmeny1), CONVERT(NVARCHAR(255), I.IndexZmeny1) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IndexZmeny1 <> I.IndexZmeny1) OR (D.IndexZmeny1 IS NULL AND I.IndexZmeny1 IS NOT NULL ) OR (D.IndexZmeny1 IS NOT NULL AND I.IndexZmeny1 IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'IndexZmeny2',  @Akce , CONVERT(NVARCHAR(255), D.IndexZmeny2), CONVERT(NVARCHAR(255), I.IndexZmeny2) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IndexZmeny2 <> I.IndexZmeny2) OR (D.IndexZmeny2 IS NULL AND I.IndexZmeny2 IS NOT NULL ) OR (D.IndexZmeny2 IS NOT NULL AND I.IndexZmeny2 IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'KmenoveStredisko',  @Akce , CONVERT(NVARCHAR(255), D.KmenoveStredisko), CONVERT(NVARCHAR(255), I.KmenoveStredisko) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KmenoveStredisko <> I.KmenoveStredisko) OR (D.KmenoveStredisko IS NULL AND I.KmenoveStredisko IS NOT NULL ) OR (D.KmenoveStredisko IS NOT NULL AND I.KmenoveStredisko IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'kusy_zad',  @Akce , CONVERT(NVARCHAR(255), D.kusy_zad), CONVERT(NVARCHAR(255), I.kusy_zad) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.kusy_zad <> I.kusy_zad) OR (D.kusy_zad IS NULL AND I.kusy_zad IS NOT NULL ) OR (D.kusy_zad IS NOT NULL AND I.kusy_zad IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'I',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'NavaznaObjednavka',  @Akce , CONVERT(NVARCHAR(255), D.NavaznaObjednavka), CONVERT(NVARCHAR(255), I.NavaznaObjednavka) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NavaznaObjednavka <> I.NavaznaObjednavka) OR (D.NavaznaObjednavka IS NULL AND I.NavaznaObjednavka IS NOT NULL ) OR (D.NavaznaObjednavka IS NOT NULL AND I.NavaznaObjednavka IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'Plan_ukonceni',  @Akce , CONVERT(NVARCHAR(255), D.Plan_ukonceni, 20) , CONVERT(NVARCHAR(255), I.Plan_ukonceni, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Plan_ukonceni <> I.Plan_ukonceni) OR (D.Plan_ukonceni IS NULL AND I.Plan_ukonceni IS NOT NULL ) OR (D.Plan_ukonceni IS NOT NULL AND I.Plan_ukonceni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'Plan_zadani',  @Akce , CONVERT(NVARCHAR(255), D.Plan_zadani, 20) , CONVERT(NVARCHAR(255), I.Plan_zadani, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Plan_zadani <> I.Plan_zadani) OR (D.Plan_zadani IS NULL AND I.Plan_zadani IS NOT NULL ) OR (D.Plan_zadani IS NOT NULL AND I.Plan_zadani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'Rada',  @Akce , CONVERT(NVARCHAR(255), D.Rada), CONVERT(NVARCHAR(255), I.Rada) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Rada <> I.Rada) OR (D.Rada IS NULL AND I.Rada IS NOT NULL ) OR (D.Rada IS NOT NULL AND I.Rada IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'StavPrikazu',  @Akce , CONVERT(NVARCHAR(255), D.StavPrikazu), CONVERT(NVARCHAR(255), I.StavPrikazu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.StavPrikazu <> I.StavPrikazu) OR (D.StavPrikazu IS NULL AND I.StavPrikazu IS NOT NULL ) OR (D.StavPrikazu IS NOT NULL AND I.StavPrikazu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrikaz', ISNULL(D.ID, I.ID), N'zadani',  @Akce , CONVERT(NVARCHAR(255), D.zadani, 20) , CONVERT(NVARCHAR(255), I.zadani, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.zadani <> I.zadani) OR (D.zadani IS NULL AND I.zadani IS NOT NULL ) OR (D.zadani IS NOT NULL AND I.zadani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabPrikaz', D.ID, 'zadani', 'D', LEFT('ID:' + ISNULL(CONVERT(NVARCHAR(255),  D.ID),N'') + '; ' + 'IDPlan:' + ISNULL(CONVERT(NVARCHAR(255),  D.IDPlan),N'') + '; ' + 'IDTabKmen:' + ISNULL(CONVERT(NVARCHAR(255),  D.IDTabKmen),N'') + '; ' + 'IDZakazka:' + ISNULL(CONVERT(NVARCHAR(255),  D.IDZakazka),N'') + '; ' + 'NavaznaObjednavka:' + ISNULL(CONVERT(NVARCHAR(255),  D.NavaznaObjednavka),N'') + '; ' + 'Prikaz:' + ISNULL(CONVERT(NVARCHAR(255),  D.Prikaz),N'') + '; ' + 'Rada:' + ISNULL(CONVERT(NVARCHAR(255),  D.Rada),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabPrikaz_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPrikaz_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabPrikaz_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPrikaz] ENABLE TRIGGER [et_TabPrikaz_ASOL_Log]
GO

