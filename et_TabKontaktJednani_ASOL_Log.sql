USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKontaktJednani_ASOL_Log]    Script Date: 02.07.2025 15:19:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabKontaktJednani_ASOL_Log] ON [dbo].[TabKontaktJednani]FOR INSERT, UPDATE, DELETEASIF @@ROWCOUNT = 0 RETURNDECLARE @Akce CHARDECLARE @Ins INTDECLARE @Del INTDECLARE @IDZurnal INTDECLARE @Filtr BIT = 0SET NOCOUNT ONIF OBJECT_ID(N'tempdb..#TabKontaktJednani_ASOL_NoLog') IS NOT NULLBEGINIF (SELECT COUNT(*) FROM #TabKontaktJednani_ASOL_NoLog) = 0RETURNELSESET @Filtr = 1ENDELSECREATE TABLE #TabKontaktJednani_ASOL_NoLog(ID INT)SELECT @Ins = COUNT(1) FROM INSERTEDSELECT @Del = COUNT(1) FROM DELETEDIF @Ins > 0 AND @Del = 0 SET @Akce = N'I'IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'IF @Ins = 1 AND @Del = 0 AND (SELECT JeNovaVetaEditor FROM INSERTED) = 1RETURNIF @Ins = 0 AND @Del = 1 AND (SELECT JeNovaVetaEditor FROM DELETED) = 1RETURNIF @Ins = 1 AND (SELECT JeNovaVetaEditor FROM INSERTED) = 0 AND (SELECT JeNovaVetaEditor FROM DELETED) = 1SET @Akce = 'I'IF @Akce IN (N'I', N'D') OR UPDATE(CisloOrg) OR UPDATE(DatumJednaniDo) OR UPDATE(DatumJednaniOd) OR UPDATE(DruhVystupu) OR UPDATE(MistoKonani) OR UPDATE(Predmet) OR UPDATE(PredpokladCena) OR UPDATE(PredpokladUspech) OR UPDATE(Stav) OR UPDATE(Typ) OR UPDATE(Ukonceni)BEGINEXEC hp_VratZurnalID @IDZurnal OUT

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'DatumJednaniDo',  @Akce , CONVERT(NVARCHAR(255), D.DatumJednaniDo, 20) , CONVERT(NVARCHAR(255), I.DatumJednaniDo, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatumJednaniDo <> I.DatumJednaniDo) OR (D.DatumJednaniDo IS NULL AND I.DatumJednaniDo IS NOT NULL ) OR (D.DatumJednaniDo IS NOT NULL AND I.DatumJednaniDo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'DatumJednaniOd',  @Akce , CONVERT(NVARCHAR(255), D.DatumJednaniOd, 20) , CONVERT(NVARCHAR(255), I.DatumJednaniOd, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DatumJednaniOd <> I.DatumJednaniOd) OR (D.DatumJednaniOd IS NULL AND I.DatumJednaniOd IS NOT NULL ) OR (D.DatumJednaniOd IS NOT NULL AND I.DatumJednaniOd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'DruhVystupu',  @Akce , CONVERT(NVARCHAR(255), D.DruhVystupu), CONVERT(NVARCHAR(255), I.DruhVystupu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.DruhVystupu <> I.DruhVystupu) OR (D.DruhVystupu IS NULL AND I.DruhVystupu IS NOT NULL ) OR (D.DruhVystupu IS NOT NULL AND I.DruhVystupu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'MistoKonani',  @Akce , CONVERT(NVARCHAR(255), D.MistoKonani), CONVERT(NVARCHAR(255), I.MistoKonani) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.MistoKonani <> I.MistoKonani) OR (D.MistoKonani IS NULL AND I.MistoKonani IS NOT NULL ) OR (D.MistoKonani IS NOT NULL AND I.MistoKonani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'PredpokladCena',  @Akce , CONVERT(NVARCHAR(255), D.PredpokladCena), CONVERT(NVARCHAR(255), I.PredpokladCena) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PredpokladCena <> I.PredpokladCena) OR (D.PredpokladCena IS NULL AND I.PredpokladCena IS NOT NULL ) OR (D.PredpokladCena IS NOT NULL AND I.PredpokladCena IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'PredpokladUspech',  @Akce , CONVERT(NVARCHAR(255), D.PredpokladUspech), CONVERT(NVARCHAR(255), I.PredpokladUspech) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PredpokladUspech <> I.PredpokladUspech) OR (D.PredpokladUspech IS NULL AND I.PredpokladUspech IS NOT NULL ) OR (D.PredpokladUspech IS NOT NULL AND I.PredpokladUspech IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'Stav',  @Akce , CONVERT(NVARCHAR(255), D.Stav), CONVERT(NVARCHAR(255), I.Stav) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Stav <> I.Stav) OR (D.Stav IS NULL AND I.Stav IS NOT NULL ) OR (D.Stav IS NOT NULL AND I.Stav IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'Typ',  @Akce , CONVERT(NVARCHAR(255), D.Typ), CONVERT(NVARCHAR(255), I.Typ) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Typ <> I.Typ) OR (D.Typ IS NULL AND I.Typ IS NOT NULL ) OR (D.Typ IS NOT NULL AND I.Typ IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKontaktJednani', ISNULL(D.ID, I.ID), N'Ukonceni',  @Akce , CONVERT(NVARCHAR(255), D.Ukonceni, 20) , CONVERT(NVARCHAR(255), I.Ukonceni, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Ukonceni <> I.Ukonceni) OR (D.Ukonceni IS NULL AND I.Ukonceni IS NOT NULL ) OR (D.Ukonceni IS NOT NULL AND I.Ukonceni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)SELECT 'TabKontaktJednani', D.ID, 'Ukonceni', 'D', LEFT('CisloOrg:' + ISNULL(CONVERT(NVARCHAR(255),  D.CisloOrg),N'') + '; ' + 'DatumJednaniDo:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatumJednaniDo, 20),N'') + '; ' + 'DatumJednaniOd:' + ISNULL(CONVERT(NVARCHAR(255),  D.DatumJednaniOd, 20),N'') + '; ' + 'DruhVystupu:' + ISNULL(CONVERT(NVARCHAR(255),  D.DruhVystupu),N'') + '; ' + 'MistoKonani:' + ISNULL(CONVERT(NVARCHAR(255),  D.MistoKonani),N'') + '; ' + 'Predmet:' + ISNULL(CONVERT(NVARCHAR(255),  D.Predmet),N'') + '; ' + 'PredpokladCena:' + ISNULL(CONVERT(NVARCHAR(255),  D.PredpokladCena),N'') + '; ' + 'PredpokladUspech:' + ISNULL(CONVERT(NVARCHAR(255),  D.PredpokladUspech),N'') + '; ' + 'Stav:' + ISNULL(CONVERT(NVARCHAR(255),  D.Stav),N'') + '; ' + 'Typ:' + ISNULL(CONVERT(NVARCHAR(255),  D.Typ),N'') + '; ' + 'Ukonceni:' + ISNULL(CONVERT(NVARCHAR(255),  D.Ukonceni, 20),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabKontaktJednani_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabKontaktJednani_ASOL_NoLog') IS NOT NULLDROP TABLE #TabKontaktJednani_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabKontaktJednani] ENABLE TRIGGER [et_TabKontaktJednani_ASOL_Log]
GO

