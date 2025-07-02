USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabInvItem_Gatema_StavUmisteni_Insert_Update_Delete]    Script Date: 02.07.2025 15:10:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PluginStavUmisteni.Umisteni*/CREATE TRIGGER [dbo].[et_TabInvItem_Gatema_StavUmisteni_Insert_Update_Delete] ON [dbo].[TabInvItem] FOR INSERT, UPDATE, DELETE 
AS 
IF @@ROWCOUNT=0 RETURN 
SET NOCOUNT ON 
IF EXISTS(SELECT * FROM INSERTED) 
  BEGIN 
    IF (SELECT ZakazStandPohybuUmisOZ FROM Gatema_KonfiguraceUmisteni)=1 
      IF EXISTS(SELECT * FROM INSERTED WHERE IdUmisteni IS NOT NULL) 
        BEGIN 
          IF @@trancount>0 ROLLBACK TRAN 
          RAISERROR(N'Použití standardního umístění oběhu zboží máte zakázáno. Změnu nastavení lze provést v konfiguraci pluginu PluginStavUmisteni.', 16, 1) 
          RETURN 
        END 
  END ELSE 
  BEGIN 
    IF EXISTS(SELECT * FROM Gatema_InvItemUmisteni WHERE IDInvItem IN (SELECT ID FROM DELETED) AND Narovnano=1) 
      BEGIN 
        IF @@trancount>0 ROLLBACK TRAN 
        RAISERROR(N'Stav umístění již byl narovnán.', 16, 1) 
        RETURN 
      END 
    DELETE Gatema_InvItemUmisteni WHERE IDInvItem IN (SELECT ID FROM DELETED) 
    IF @@error<>0 
      BEGIN 
        IF @@trancount>0 ROLLBACK TRAN 
        RETURN 
      END 
  END
GO

ALTER TABLE [dbo].[TabInvItem] ENABLE TRIGGER [et_TabInvItem_Gatema_StavUmisteni_Insert_Update_Delete]
GO

