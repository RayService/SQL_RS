USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_uhrada]    Script Date: 03.07.2025 9:59:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*Trigger pro nakopírování počtu dnů splatnosti z předchozího převáděného dokladu*/

CREATE TRIGGER [dbo].[et_TabDokladyZbozi_uhrada] ON [dbo].[TabDokladyZbozi]
AFTER INSERT,DELETE,UPDATE
AS 
BEGIN

DECLARE
@action AS CHAR(1)

SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE NULL -- Skip. It may have been a "failed delete".   
                    END)

IF @action = 'I'
BEGIN
	UPDATE tdz SET Splatnost = (SELECT DATEADD(DAY,tfu.LhutaSplatnosti,i.DatPorizeni) FROM inserted i join TabFormaUhrady tfu ON tfu.FormaUhrady = i.FormaUhrady)
	FROM inserted i
	JOIN TabDokladyZbozi tdz ON i.ID = tdz.ID
	WHERE tdz.ID IN (SELECT i.ID FROM inserted) AND tdz.DruhPohybuZbo = 13

END

IF @action = 'U'
IF UPDATE(CisloOrg)
BEGIN
	UPDATE tdz SET Splatnost = (SELECT DATEADD(DAY,tfu.LhutaSplatnosti,i.DatPorizeni) FROM inserted i join TabFormaUhrady tfu ON tfu.FormaUhrady = i.FormaUhrady)
	FROM inserted i
	JOIN TabDokladyZbozi tdz ON i.ID = tdz.ID
	WHERE tdz.ID IN (SELECT i.ID FROM inserted) AND tdz.DruhPohybuZbo = 13

END
END
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ENABLE TRIGGER [et_TabDokladyZbozi_uhrada]
GO

