USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_dat_dod1]    Script Date: 02.07.2025 15:52:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*Trigger pro kopírování externího pole _dat_dod1 při položkovém převodu z VOB do PŘ */

CREATE TRIGGER [dbo].[et_TabPohybyZbozi_dat_dod1] ON [dbo].[TabPohybyZbozi]
AFTER INSERT ,DELETE,UPDATE
AS 
BEGIN

DECLARE
 @EntryID int
 ,@DefDate date 
 ,@action as char(1)

SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE NULL -- Skip. It may have been a "failed delete".   
                    END)

if @action = 'U'
BEGIN

	UPDATE tpze SET tpze._dat_dod1 = t2e._dat_dod1
	FROM inserted i
	join TabDokladyZbozi tdz on i.IDDoklad = tdz.ID
	join TabPohybyZbozi_EXT tpze on i.ID=tpze.ID
	join TabPohybyZbozi t2 on i.IDOldPolozka=t2.ID
	left join TabPohybyZbozi_EXT t2e on t2.ID=t2e.ID
	where tdz.DruhPohybuZbo IN (0,2)

	insert into TabPohybyZbozi_EXT(ID,_dat_dod1)
	select i.ID,t2e._dat_dod1
	from inserted i
	join TabDokladyZbozi tdz on i.IDDoklad = tdz.ID
	join TabPohybyZbozi t2 on i.IDOldPolozka=t2.ID
	left join TabPohybyZbozi_EXT t2e on t2.ID=t2e.ID
	where (i.ID not in (select ID from TabPohybyZbozi_EXT) AND tdz.DruhPohybuZbo IN (0,2))
END
END
GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_dat_dod1]
GO

