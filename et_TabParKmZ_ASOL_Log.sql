USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabParKmZ_ASOL_Log]    Script Date: 02.07.2025 15:30:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabParKmZ_ASOL_Log] ON [dbo].[TabParKmZ]FOR INSERT, UPDATEASIF @@ROWCOUNT = 0 RETURNDECLARE @Akce CHARDECLARE @Ins INTDECLARE @Del INTDECLARE @IDZurnal INTDECLARE @Filtr BIT = 0SET NOCOUNT ONIF OBJECT_ID(N'tempdb..#TabParKmZ_ASOL_NoLog') IS NOT NULLBEGINIF (SELECT COUNT(*) FROM #TabParKmZ_ASOL_NoLog) = 0RETURNELSESET @Filtr = 1ENDELSECREATE TABLE #TabParKmZ_ASOL_NoLog(ID INT)SELECT @Ins = COUNT(1) FROM INSERTEDSELECT @Del = COUNT(1) FROM DELETEDIF @Ins > 0 AND @Del = 0 SET @Akce = N'I'IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'IF @Akce IN (N'I', N'D') OR UPDATE(RadaVyrPrikazu) OR UPDATE(VychoziSklad) OR UPDATE(VyraditZGenerPodrizPrikazu)BEGINEXEC hp_VratZurnalID @IDZurnal OUT

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabParKmZ', ISNULL(D.ID, I.ID), N'RadaVyrPrikazu',  @Akce , CONVERT(NVARCHAR(255), D.RadaVyrPrikazu), CONVERT(NVARCHAR(255), I.RadaVyrPrikazu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RadaVyrPrikazu <> I.RadaVyrPrikazu) OR (D.RadaVyrPrikazu IS NULL AND I.RadaVyrPrikazu IS NOT NULL ) OR (D.RadaVyrPrikazu IS NOT NULL AND I.RadaVyrPrikazu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabParKmZ_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabParKmZ_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabParKmZ', ISNULL(D.ID, I.ID), N'VychoziSklad',  @Akce , CONVERT(NVARCHAR(255), D.VychoziSklad), CONVERT(NVARCHAR(255), I.VychoziSklad) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.VychoziSklad <> I.VychoziSklad) OR (D.VychoziSklad IS NULL AND I.VychoziSklad IS NOT NULL ) OR (D.VychoziSklad IS NOT NULL AND I.VychoziSklad IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabParKmZ_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabParKmZ_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabParKmZ', ISNULL(D.ID, I.ID), N'VyraditZGenerPodrizPrikazu',  @Akce , CONVERT(NVARCHAR(255), D.VyraditZGenerPodrizPrikazu), CONVERT(NVARCHAR(255), I.VyraditZGenerPodrizPrikazu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.VyraditZGenerPodrizPrikazu <> I.VyraditZGenerPodrizPrikazu) OR (D.VyraditZGenerPodrizPrikazu IS NULL AND I.VyraditZGenerPodrizPrikazu IS NOT NULL ) OR (D.VyraditZGenerPodrizPrikazu IS NOT NULL AND I.VyraditZGenerPodrizPrikazu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabParKmZ_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabParKmZ_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabParKmZ_ASOL_NoLog') IS NOT NULLDROP TABLE #TabParKmZ_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabParKmZ] ENABLE TRIGGER [et_TabParKmZ_ASOL_Log]
GO

