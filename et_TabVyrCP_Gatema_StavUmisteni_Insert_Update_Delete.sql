USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabVyrCP_Gatema_StavUmisteni_Insert_Update_Delete]    Script Date: 03.07.2025 8:40:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PluginStavUmisteni.Umisteni*/CREATE TRIGGER [dbo].[et_TabVyrCP_Gatema_StavUmisteni_Insert_Update_Delete] ON [dbo].[TabVyrCP] FOR INSERT, UPDATE, DELETE 
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
    DECLARE @IDStornoDoklad int, @IDDoklad int, @IDZurnal int 
    SET @IDStornoDoklad=NULL 
    SELECT TOP 1 @IDStornoDoklad=PZ.IDDoklad, @IDDoklad=PZ.IDOldDoklad FROM DELETED D INNER JOIN TabPohybyZbozi PZ ON (PZ.ID=D.IDPolozkaDokladu) WHERE PZ.DruhPohybuZbo=3 
    IF @IDStornoDoklad IS NOT NULL AND @IDDoklad IS NOT NULL 
      BEGIN 
        SELECT @IDZurnal=MAX(ID) FROM TabZurnal 
        IF EXISTS(SELECT * FROM TabZurnal Z, TabDokladyZbozi DZ, TabDokladyZbozi SDZ 
                           WHERE Z.ID=@IDZurnal AND DZ.ID=@IDDoklad AND SDZ.ID=@IDStornoDoklad AND Z.Udalost=30 AND 
                                 Z.Akce LIKE N'% '+DZ.RadaDokladu+N' '+CAST(DZ.PoradoveCislo AS NVARCHAR(20))+N'(% '+SDZ.RadaDokladu+N' '+CAST(SDZ.PoradoveCislo AS NVARCHAR(20))+N'(%'  ) 
          BEGIN 
            DELETE Gatema_PohybUmisteni WHERE IDPohZbo IN (SELECT ID FROM TabPohybyZbozi WHERE IDDoklad=@IDDoklad OR IDDoklad=@IDStornoDoklad) 
            IF @@error<>0 
              BEGIN 
                IF @@trancount>0 ROLLBACK TRAN 
                RETURN 
              END 
          END 
      END 
    DELETE PU 
      FROM DELETED D 
        INNER JOIN Gatema_PohybUmisteni PU ON (PU.IDPohZbo=D.IDPolozkaDokladu AND PU.IDVyrCis=D.IDVyrCis) 
    IF @@error<>0 
      BEGIN 
        IF @@trancount>0 ROLLBACK TRAN 
        RETURN 
      END 
  END
GO

ALTER TABLE [dbo].[TabVyrCP] ENABLE TRIGGER [et_TabVyrCP_Gatema_StavUmisteni_Insert_Update_Delete]
GO

