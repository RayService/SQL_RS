USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrVPVazby_ASOL_Log]    Script Date: 03.07.2025 8:02:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabPrVPVazby_ASOL_Log] ON [dbo].[TabPrVPVazby]FOR INSERT, UPDATE, DELETEASIF @@ROWCOUNT = 0 RETURNDECLARE @Akce CHARDECLARE @Ins INTDECLARE @Del INTDECLARE @IDZurnal INTDECLARE @Filtr BIT = 0SET NOCOUNT ONIF OBJECT_ID(N'tempdb..#TabPrVPVazby_ASOL_NoLog') IS NOT NULLBEGINIF (SELECT COUNT(*) FROM #TabPrVPVazby_ASOL_NoLog) = 0RETURNELSESET @Filtr = 1ENDELSECREATE TABLE #TabPrVPVazby_ASOL_NoLog(ID INT)SELECT @Ins = COUNT(1) FROM INSERTEDSELECT @Del = COUNT(1) FROM DELETEDIF @Ins > 0 AND @Del = 0 SET @Akce = N'I'IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'IF @Akce IN (N'I', N'D') OR UPDATE(Sklad)BEGINEXEC hp_VratZurnalID @IDZurnal OUT

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabPrVPVazby', ISNULL(D.ID, I.ID), N'Sklad',  @Akce , CONVERT(NVARCHAR(255), D.Sklad), CONVERT(NVARCHAR(255), I.Sklad) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.Sklad <> I.Sklad) OR (D.Sklad IS NULL AND I.Sklad IS NOT NULL ) OR (D.Sklad IS NOT NULL AND I.Sklad IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabPrVPVazby_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabPrVPVazby_ASOL_NoLog))IF @Akce IN (N'D')INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal)SELECT 'TabPrVPVazby', D.ID, 'Sklad', 'D', LEFT('Sklad:' + ISNULL(CONVERT(NVARCHAR(255),  D.Sklad),N'') + '; ',255), NULL, @IDZurnal FROM DELETED DWHERE (@Filtr = 0 OR D.ID IN (SELECT ID FROM #TabPrVPVazby_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabPrVPVazby_ASOL_NoLog') IS NOT NULLDROP TABLE #TabPrVPVazby_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabPrVPVazby] ENABLE TRIGGER [et_TabPrVPVazby_ASOL_Log]
GO

