USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikaz_upd_zadani]    Script Date: 02.07.2025 16:14:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--========================================================
-- Author:		MŽ
-- Description:	Nemožnost posunout datum plánovaného zadání na VP jinému uživateli, než autoru "uzamčení", sa a nově (4.7.2019) panu Veleckému.
-- Date: 20.3.2018
--========================================================
CREATE TRIGGER [dbo].[et_TabPrikaz_upd_zadani] ON [dbo].[TabPrikaz]
FOR UPDATE
AS
BEGIN
  IF UPDATE(Plan_zadani)
    if exists(
		SELECT * 
		FROM inserted a 
		INNER JOIN TabPrikaz_EXT b on a.ID = b.ID
		WHERE (SUSER_SNAME() NOT IN (b._EXT_locking_user,'sa','minks')) AND b._EXT_locked = 1
--		WHERE ((SUSER_SNAME() <> b._EXT_locking_user OR SUSER_SNAME() <> 'sa')  AND b._EXT_locked = 1)
	) BEGIN
        ROLLBACK
        RAISERROR('Změna data zahájení není povolena', 16, 1);
  	
      END
END
GO

ALTER TABLE [dbo].[TabPrikaz] ENABLE TRIGGER [et_TabPrikaz_upd_zadani]
GO

