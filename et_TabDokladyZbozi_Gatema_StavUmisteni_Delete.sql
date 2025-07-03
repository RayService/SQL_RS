USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_Gatema_StavUmisteni_Delete]    Script Date: 03.07.2025 9:56:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PluginStavUmisteni.Umisteni*/CREATE TRIGGER [dbo].[et_TabDokladyZbozi_Gatema_StavUmisteni_Delete] ON [dbo].[TabDokladyZbozi] FOR DELETE 
AS 
IF @@ROWCOUNT=0 RETURN 
SET NOCOUNT ON 
DELETE Gatema_PohybManJed WHERE IDDokZbo IN (SELECT ID FROM DELETED) 
IF @@error<>0 
  BEGIN 
    IF @@trancount>0 ROLLBACK TRAN 
    RETURN 
  END
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ENABLE TRIGGER [et_TabDokladyZbozi_Gatema_StavUmisteni_Delete]
GO

