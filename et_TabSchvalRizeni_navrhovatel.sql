USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabSchvalRizeni_navrhovatel]    Script Date: 03.07.2025 8:05:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--=============================================================================
-- Author:		MŽ
-- Description:	Nemožnost založit schvalovací řízení stejné osobě jako je navrhovatel změny
-- Date: 19.7.2019
--=============================================================================
CREATE TRIGGER [dbo].[et_TabSchvalRizeni_navrhovatel] ON [dbo].[TabSchvalRizeni]
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

if @action = 'I'
BEGIN
    if exists(
		SELECT * 
		FROM inserted a 
		INNER JOIN TabCzmeny b on a.IDVazby = b.ID
		INNER JOIN TabCisZam c ON c.ID = a.IDZam
		WHERE b.Autor = c.LoginId
	) BEGIN
        ROLLBACK
        RAISERROR('Schvalovací řízení nelze založit - stejná osoba navrhovatele změny a schvalovatele', 16, 1);
  	
      END
  
END
END
GO

ALTER TABLE [dbo].[TabSchvalRizeni] ENABLE TRIGGER [et_TabSchvalRizeni_navrhovatel]
GO

