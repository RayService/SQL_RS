USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_ASOL_Log]    Script Date: 02.07.2025 15:12:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabKmenZbozi_ASOL_Log] ON [dbo].[TabKmenZbozi]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabKmenZbozi_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabKmenZbozi_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabKmenZbozi_ASOL_NoLog(ID INT)
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

IF @Akce IN (N'I', N'D') OR UPDATE(Dilec) OR UPDATE(KJDatDo) OR UPDATE(KJDatOd) OR UPDATE(KmenoveStredisko) OR UPDATE(Material) OR UPDATE(MJEvidence) OR UPDATE(Montaz) OR UPDATE(Naradi) OR UPDATE(Nazev1) OR UPDATE(RegCis) OR UPDATE(RezijniMat) OR UPDATE(SazbaDPHVstup) OR UPDATE(SazbaDPHVystup) OR UPDATE(SkupZbo) OR UPDATE(Vykres)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'Dilec',  @Akce , CONVERT(NVARCHAR(255), D.Dilec), CONVERT(NVARCHAR(255), I.Dilec) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Dilec <> I.Dilec) OR (D.Dilec IS NULL AND I.Dilec IS NOT NULL ) OR (D.Dilec IS NOT NULL AND I.Dilec IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'KJDatDo',  @Akce , CONVERT(NVARCHAR(255), D.KJDatDo, 20) , CONVERT(NVARCHAR(255), I.KJDatDo, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KJDatDo <> I.KJDatDo) OR (D.KJDatDo IS NULL AND I.KJDatDo IS NOT NULL ) OR (D.KJDatDo IS NOT NULL AND I.KJDatDo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'KJDatOd',  @Akce , CONVERT(NVARCHAR(255), D.KJDatOd, 20) , CONVERT(NVARCHAR(255), I.KJDatOd, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KJDatOd <> I.KJDatOd) OR (D.KJDatOd IS NULL AND I.KJDatOd IS NOT NULL ) OR (D.KJDatOd IS NOT NULL AND I.KJDatOd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'KmenoveStredisko',  @Akce , CONVERT(NVARCHAR(255), D.KmenoveStredisko), CONVERT(NVARCHAR(255), I.KmenoveStredisko) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KmenoveStredisko <> I.KmenoveStredisko) OR (D.KmenoveStredisko IS NULL AND I.KmenoveStredisko IS NOT NULL ) OR (D.KmenoveStredisko IS NOT NULL AND I.KmenoveStredisko IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'Material',  @Akce , CONVERT(NVARCHAR(255), D.Material), CONVERT(NVARCHAR(255), I.Material) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Material <> I.Material) OR (D.Material IS NULL AND I.Material IS NOT NULL ) OR (D.Material IS NOT NULL AND I.Material IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'MJEvidence',  @Akce , CONVERT(NVARCHAR(255), D.MJEvidence), CONVERT(NVARCHAR(255), I.MJEvidence) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.MJEvidence <> I.MJEvidence) OR (D.MJEvidence IS NULL AND I.MJEvidence IS NOT NULL ) OR (D.MJEvidence IS NOT NULL AND I.MJEvidence IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'Montaz',  @Akce , CONVERT(NVARCHAR(255), D.Montaz), CONVERT(NVARCHAR(255), I.Montaz) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Montaz <> I.Montaz) OR (D.Montaz IS NULL AND I.Montaz IS NOT NULL ) OR (D.Montaz IS NOT NULL AND I.Montaz IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'Naradi',  @Akce , CONVERT(NVARCHAR(255), D.Naradi), CONVERT(NVARCHAR(255), I.Naradi) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Naradi <> I.Naradi) OR (D.Naradi IS NULL AND I.Naradi IS NOT NULL ) OR (D.Naradi IS NOT NULL AND I.Naradi IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'Nazev1',  @Akce , CONVERT(NVARCHAR(255), D.Nazev1), CONVERT(NVARCHAR(255), I.Nazev1) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Nazev1 <> I.Nazev1) OR (D.Nazev1 IS NULL AND I.Nazev1 IS NOT NULL ) OR (D.Nazev1 IS NOT NULL AND I.Nazev1 IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'RegCis',  @Akce , CONVERT(NVARCHAR(255), D.RegCis), CONVERT(NVARCHAR(255), I.RegCis) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RegCis <> I.RegCis) OR (D.RegCis IS NULL AND I.RegCis IS NOT NULL ) OR (D.RegCis IS NOT NULL AND I.RegCis IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'RezijniMat',  @Akce , CONVERT(NVARCHAR(255), D.RezijniMat), CONVERT(NVARCHAR(255), I.RezijniMat) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RezijniMat <> I.RezijniMat) OR (D.RezijniMat IS NULL AND I.RezijniMat IS NOT NULL ) OR (D.RezijniMat IS NOT NULL AND I.RezijniMat IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'SazbaDPHVstup',  @Akce , CONVERT(NVARCHAR(255), D.SazbaDPHVstup), CONVERT(NVARCHAR(255), I.SazbaDPHVstup) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.SazbaDPHVstup <> I.SazbaDPHVstup) OR (D.SazbaDPHVstup IS NULL AND I.SazbaDPHVstup IS NOT NULL ) OR (D.SazbaDPHVstup IS NOT NULL AND I.SazbaDPHVstup IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'SazbaDPHVystup',  @Akce , CONVERT(NVARCHAR(255), D.SazbaDPHVystup), CONVERT(NVARCHAR(255), I.SazbaDPHVystup) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.SazbaDPHVystup <> I.SazbaDPHVystup) OR (D.SazbaDPHVystup IS NULL AND I.SazbaDPHVystup IS NOT NULL ) OR (D.SazbaDPHVystup IS NOT NULL AND I.SazbaDPHVystup IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'SkupZbo',  @Akce , CONVERT(NVARCHAR(255), D.SkupZbo), CONVERT(NVARCHAR(255), I.SkupZbo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.SkupZbo <> I.SkupZbo) OR (D.SkupZbo IS NULL AND I.SkupZbo IS NOT NULL ) OR (D.SkupZbo IS NOT NULL AND I.SkupZbo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi', ISNULL(D.ID, I.ID), N'Vykres',  @Akce , CONVERT(NVARCHAR(255), D.Vykres), CONVERT(NVARCHAR(255), I.Vykres) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Vykres <> I.Vykres) OR (D.Vykres IS NULL AND I.Vykres IS NOT NULL ) OR (D.Vykres IS NOT NULL AND I.Vykres IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)
SELECT 'TabKmenZbozi', D.ID, 'Vykres', 'D', LEFT('Dilec:' + ISNULL(CONVERT(NVARCHAR(255),  D.Dilec),N'') + '; ' + 'KJDatDo:' + ISNULL(CONVERT(NVARCHAR(255),  D.KJDatDo, 20),N'') + '; ' + 'KJDatOd:' + ISNULL(CONVERT(NVARCHAR(255),  D.KJDatOd, 20),N'') + '; ' + 'Material:' + ISNULL(CONVERT(NVARCHAR(255),  D.Material),N'') + '; ' + 'MJEvidence:' + ISNULL(CONVERT(NVARCHAR(255),  D.MJEvidence),N'') + '; ' + 'Montaz:' + ISNULL(CONVERT(NVARCHAR(255),  D.Montaz),N'') + '; ' + 'Naradi:' + ISNULL(CONVERT(NVARCHAR(255),  D.Naradi),N'') + '; ' + 'Nazev1:' + ISNULL(CONVERT(NVARCHAR(255),  D.Nazev1),N'') + '; ' + 'RegCis:' + ISNULL(CONVERT(NVARCHAR(255),  D.RegCis),N'') + '; ' + 'RezijniMat:' + ISNULL(CONVERT(NVARCHAR(255),  D.RezijniMat),N'') + '; ' + 'SazbaDPHVstup:' + ISNULL(CONVERT(NVARCHAR(255),  D.SazbaDPHVstup),N'') + '; ' + 'SazbaDPHVystup:' + ISNULL(CONVERT(NVARCHAR(255),  D.SazbaDPHVystup),N'') + '; ' + 'SkupZbo:' + ISNULL(CONVERT(NVARCHAR(255),  D.SkupZbo),N'') + '; ' + 'Vykres:' + ISNULL(CONVERT(NVARCHAR(255),  D.Vykres),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabKmenZbozi_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabKmenZbozi_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabKmenZbozi] ENABLE TRIGGER [et_TabKmenZbozi_ASOL_Log]
GO

