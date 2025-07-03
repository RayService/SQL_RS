USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabSchvalRizeni_ASOL_Log]    Script Date: 03.07.2025 8:05:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabSchvalRizeni_ASOL_Log] ON [dbo].[TabSchvalRizeni]FOR INSERT, UPDATEASIF @@ROWCOUNT = 0 RETURNDECLARE @Akce CHARDECLARE @Ins INTDECLARE @Del INTDECLARE @IDZurnal INTDECLARE @Filtr BIT = 0SET NOCOUNT ONIF OBJECT_ID(N'tempdb..#TabSchvalRizeni_ASOL_NoLog') IS NOT NULLBEGINIF (SELECT COUNT(*) FROM #TabSchvalRizeni_ASOL_NoLog) = 0RETURNELSESET @Filtr = 1ENDELSECREATE TABLE #TabSchvalRizeni_ASOL_NoLog(ID INT)SELECT @Ins = COUNT(1) FROM INSERTEDSELECT @Del = COUNT(1) FROM DELETEDIF @Ins > 0 AND @Del = 0 SET @Akce = N'I'IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'IF @Akce IN (N'I', N'D') OR UPDATE(IDZam) OR UPDATE(PlanTermin) OR UPDATE(Stav)BEGINEXEC hp_VratZurnalID @IDZurnal OUT

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabSchvalRizeni', ISNULL(D.ID, I.ID), N'IDZam',  @Akce , CONVERT(NVARCHAR(255), D.IDZam), CONVERT(NVARCHAR(255), I.IDZam) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDZam <> I.IDZam) OR (D.IDZam IS NULL AND I.IDZam IS NOT NULL ) OR (D.IDZam IS NOT NULL AND I.IDZam IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabSchvalRizeni_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabSchvalRizeni_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabSchvalRizeni', ISNULL(D.ID, I.ID), N'PlanTermin',  @Akce , CONVERT(NVARCHAR(255), D.PlanTermin, 20) , CONVERT(NVARCHAR(255), I.PlanTermin, 20) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PlanTermin <> I.PlanTermin) OR (D.PlanTermin IS NULL AND I.PlanTermin IS NOT NULL ) OR (D.PlanTermin IS NOT NULL AND I.PlanTermin IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabSchvalRizeni_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabSchvalRizeni_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabSchvalRizeni', ISNULL(D.ID, I.ID), N'Stav',  @Akce , CONVERT(NVARCHAR(255), D.Stav), CONVERT(NVARCHAR(255), I.Stav) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Stav <> I.Stav) OR (D.Stav IS NULL AND I.Stav IS NOT NULL ) OR (D.Stav IS NOT NULL AND I.Stav IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabSchvalRizeni_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabSchvalRizeni_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabSchvalRizeni_ASOL_NoLog') IS NOT NULLDROP TABLE #TabSchvalRizeni_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabSchvalRizeni] ENABLE TRIGGER [et_TabSchvalRizeni_ASOL_Log]
GO

