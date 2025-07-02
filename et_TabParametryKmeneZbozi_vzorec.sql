USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabParametryKmeneZbozi_vzorec]    Script Date: 02.07.2025 15:28:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabParametryKmeneZbozi_vzorec]
   ON  [dbo].[TabParametryKmeneZbozi]
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
declare
 @action as char(1),
 @ErrStr nvarchar(255)

SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE NULL -- Skip. It may have been a "failed delete".   
                    END)

if @action in ('I','U')  
 begin 
	 update TabParametryKmeneZbozi set
	 IDVzorceSpotMat =2
	 from inserted i
	 inner join TabKmenZbozi t on t.ID=i.IDKmenZbozi
	 WHERE TabParametryKmeneZbozi.ID = i.ID AND t.MJEvidence LIKE 'm'-- and t.Material = 1
end
END
GO

ALTER TABLE [dbo].[TabParametryKmeneZbozi] ENABLE TRIGGER [et_TabParametryKmeneZbozi_vzorec]
GO

