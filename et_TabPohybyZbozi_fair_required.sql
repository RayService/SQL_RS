USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_fair_required]    Script Date: 02.07.2025 15:54:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPohybyZbozi_fair_required] ON [dbo].[TabPohybyZbozi]
AFTER INSERT ,DELETE,UPDATE
AS 
BEGIN

DECLARE
 @EntryID int
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

	UPDATE tpze SET tpze._DS_RS_fair_pozadovan = t2e._DS_RS_fair_pozadovan
	FROM inserted i
	join TabDokladyZbozi tdz on i.IDDoklad = tdz.ID
	join TabPohybyZbozi_EXT tpze on i.ID=tpze.ID
	join TabPohybyZbozi t2 on i.IDOldPolozka=t2.ID
	left join TabPohybyZbozi_EXT t2e on t2.ID=t2e.ID
	where tdz.DruhPohybuZbo = 0

	insert into TabPohybyZbozi_EXT(ID,_DS_RS_fair_pozadovan)
	select i.ID,t2e._DS_RS_fair_pozadovan
	from inserted i
	join TabDokladyZbozi tdz on i.IDDoklad = tdz.ID
	join TabPohybyZbozi t2 on i.IDOldPolozka=t2.ID
	left join TabPohybyZbozi_EXT t2e on t2.ID=t2e.ID
	where (i.ID not in (select ID from TabPohybyZbozi_EXT) AND tdz.DruhPohybuZbo IN (0,6))
END
END
GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_fair_required]
GO

