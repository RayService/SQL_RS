USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_EXT_ASOL_Log]    Script Date: 02.07.2025 15:13:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabKmenZbozi_EXT_ASOL_Log] ON [dbo].[TabKmenZbozi_EXT]
FOR INSERT, UPDATE
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

IF @Akce IN (N'I', N'D') OR UPDATE(_EXT_RS_duvod_lezak) OR UPDATE(_EXT_RS_duvod_lezak_neni) OR UPDATE(_RayService_GenVC_Maska) OR UPDATE(_RayService_GenVC_PosledniCislo) OR UPDATE(_RayService_GenVC_RespPosledni)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi_EXT', ISNULL(D.ID, I.ID), N'_EXT_RS_duvod_lezak',  @Akce , CONVERT(NVARCHAR(255), D._EXT_RS_duvod_lezak), CONVERT(NVARCHAR(255), I._EXT_RS_duvod_lezak) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_RS_duvod_lezak <> I._EXT_RS_duvod_lezak) OR (D._EXT_RS_duvod_lezak IS NULL AND I._EXT_RS_duvod_lezak IS NOT NULL ) OR (D._EXT_RS_duvod_lezak IS NOT NULL AND I._EXT_RS_duvod_lezak IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi_EXT', ISNULL(D.ID, I.ID), N'_EXT_RS_duvod_lezak_neni',  @Akce , CONVERT(NVARCHAR(255), D._EXT_RS_duvod_lezak_neni), CONVERT(NVARCHAR(255), I._EXT_RS_duvod_lezak_neni) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._EXT_RS_duvod_lezak_neni <> I._EXT_RS_duvod_lezak_neni) OR (D._EXT_RS_duvod_lezak_neni IS NULL AND I._EXT_RS_duvod_lezak_neni IS NOT NULL ) OR (D._EXT_RS_duvod_lezak_neni IS NOT NULL AND I._EXT_RS_duvod_lezak_neni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi_EXT', ISNULL(D.ID, I.ID), N'_RayService_GenVC_Maska',  @Akce , CONVERT(NVARCHAR(255), D._RayService_GenVC_Maska), CONVERT(NVARCHAR(255), I._RayService_GenVC_Maska) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._RayService_GenVC_Maska <> I._RayService_GenVC_Maska) OR (D._RayService_GenVC_Maska IS NULL AND I._RayService_GenVC_Maska IS NOT NULL ) OR (D._RayService_GenVC_Maska IS NOT NULL AND I._RayService_GenVC_Maska IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi_EXT', ISNULL(D.ID, I.ID), N'_RayService_GenVC_PosledniCislo',  @Akce , CONVERT(NVARCHAR(255), D._RayService_GenVC_PosledniCislo), CONVERT(NVARCHAR(255), I._RayService_GenVC_PosledniCislo) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._RayService_GenVC_PosledniCislo <> I._RayService_GenVC_PosledniCislo) OR (D._RayService_GenVC_PosledniCislo IS NULL AND I._RayService_GenVC_PosledniCislo IS NOT NULL ) OR (D._RayService_GenVC_PosledniCislo IS NOT NULL AND I._RayService_GenVC_PosledniCislo IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabKmenZbozi_EXT', ISNULL(D.ID, I.ID), N'_RayService_GenVC_RespPosledni',  @Akce , CONVERT(NVARCHAR(255), D._RayService_GenVC_RespPosledni), CONVERT(NVARCHAR(255), I._RayService_GenVC_RespPosledni) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._RayService_GenVC_RespPosledni <> I._RayService_GenVC_RespPosledni) OR (D._RayService_GenVC_RespPosledni IS NULL AND I._RayService_GenVC_RespPosledni IS NOT NULL ) OR (D._RayService_GenVC_RespPosledni IS NOT NULL AND I._RayService_GenVC_RespPosledni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabKmenZbozi_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabKmenZbozi_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabKmenZbozi_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabKmenZbozi_EXT] ENABLE TRIGGER [et_TabKmenZbozi_EXT_ASOL_Log]
GO

