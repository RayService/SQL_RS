USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikaz_B2A_ProductionOrderExt_RecentSuspendedToInProgressTransition]    Script Date: 02.07.2025 16:10:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPrikaz_B2A_ProductionOrderExt_RecentSuspendedToInProgressTransition]
	ON [dbo].[TabPrikaz]
	FOR UPDATE
	AS
BEGIN
	BEGIN
		UPDATE ext
		SET ext._EXT_RSDIMA_RecentSuspendedToInProgressTransition = 1
		FROM TabPrikaz_EXT ext
				 JOIN Inserted i on ext.ID = i.ID
				 JOIN Deleted d on ext.ID = d.ID
		WHERE i.StavPrikazu = 30
		  AND d.StavPrikazu = 40
	END
	BEGIN
		UPDATE ext
		SET ext._EXT_RSDIMA_RecentSuspendedToInProgressTransition = 0
		FROM TabPrikaz_EXT ext
				 JOIN Inserted i on ext.ID = i.ID
				 JOIN Deleted d on ext.ID = d.ID
		WHERE i.StavPrikazu = 40
		  AND d.StavPrikazu = 30
	END
END
GO

ALTER TABLE [dbo].[TabPrikaz] DISABLE TRIGGER [et_TabPrikaz_B2A_ProductionOrderExt_RecentSuspendedToInProgressTransition]
GO

