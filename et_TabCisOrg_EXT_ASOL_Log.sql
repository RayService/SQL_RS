USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabCisOrg_EXT_ASOL_Log]    Script Date: 03.07.2025 9:51:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabCisOrg_EXT_ASOL_Log] ON [dbo].[TabCisOrg_EXT]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
SET NOCOUNT ON
IF OBJECT_ID(N'tempdb..#TabCisOrg_ASOL_NoLog') IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM #TabCisOrg_ASOL_NoLog) = 0
RETURN
ELSE
SET @Filtr = 1
END
ELSE
CREATE TABLE #TabCisOrg_ASOL_NoLog(ID INT)
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I', N'D') OR UPDATE(_odpovednaOsobaOdberatel)
BEGIN
EXEC hp_VratZurnalID @IDZurnal OUT


IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabCisOrg_EXT', ISNULL(D.ID, I.ID), N'_odpovednaOsobaOdberatel',  @Akce , CONVERT(NVARCHAR(255), D._odpovednaOsobaOdberatel), CONVERT(NVARCHAR(255), I._odpovednaOsobaOdberatel) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D._odpovednaOsobaOdberatel <> I._odpovednaOsobaOdberatel) OR (D._odpovednaOsobaOdberatel IS NULL AND I._odpovednaOsobaOdberatel IS NOT NULL ) OR (D._odpovednaOsobaOdberatel IS NOT NULL AND I._odpovednaOsobaOdberatel IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabCisOrg_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabCisOrg_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabCisOrg_ASOL_NoLog') IS NOT NULL
DROP TABLE #TabCisOrg_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabCisOrg_EXT] ENABLE TRIGGER [et_TabCisOrg_EXT_ASOL_Log]
GO

