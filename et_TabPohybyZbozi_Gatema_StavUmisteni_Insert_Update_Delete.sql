USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_Gatema_StavUmisteni_Insert_Update_Delete]    Script Date: 02.07.2025 15:55:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PluginStavUmisteni.Umisteni*/CREATE TRIGGER [dbo].[et_TabPohybyZbozi_Gatema_StavUmisteni_Insert_Update_Delete] ON [dbo].[TabPohybyZbozi] FOR INSERT, UPDATE, DELETE 
AS 
IF @@ROWCOUNT=0 RETURN 
SET NOCOUNT ON 
DECLARE @ErrMsg nvarchar(500)=NULL 
IF EXISTS(SELECT * FROM INSERTED) 
  BEGIN 
    IF (SELECT ZakazStandPohybuUmisOZ FROM Gatema_KonfiguraceUmisteni)=1 
      IF EXISTS(SELECT * FROM INSERTED WHERE IdUmisteni IS NOT NULL) 
        BEGIN 
          IF @@trancount>0 ROLLBACK TRAN 
          RAISERROR(N'Použití standardního umístění oběhu zboží máte zakázáno. Změnu nastavení lze provést v konfiguraci pluginu PluginStavUmisteni.', 16, 1) 
          RETURN 
        END 
    IF UPDATE(SkutecneDatReal) 
      BEGIN 
        SELECT TOP 1 @ErrMsg=N'Umístění není korektně vyplněno.'+NCHAR(13)+N' Zboží: '+KZ.SkupZbo+N' '+KZ.RegCis+ISNULL(NCHAR(13)+N' Výr. číslo: '+CS.Nazev1,'') 
          FROM INSERTED I 
            INNER JOIN TabStavSkladu SS ON (SS.ID=I.IDZboSklad) 
            INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND KZ.Sluzba=0) 
            LEFT OUTER JOIN TabStavSkladu_Ext SS_E ON (SS_E.ID=I.IDZboSklad) 
            INNER JOIN TabStrom S ON (S.Cislo=SS.IDSklad) 
            LEFT OUTER JOIN TabStrom_Ext S_E ON (S_E.ID=S.ID) 
            LEFT OUTER JOIN TabInvHead IH_P ON (IH_P.IDPrijem=I.IDDoklad) 
            LEFT OUTER JOIN TabInvHead IH_V ON (IH_V.IDVydej=I.IDDoklad) 
            LEFT OUTER JOIN TabVyrCP CP ON (CP.IDPolozkaDokladu=I.ID) 
            LEFT OUTER JOIN TabVyrCS CS ON (CS.ID=CP.IDVyrCis) 
            OUTER APPLY (SELECT Mnozstvi=ISNULL(ABS(SUM(PU.Mnozstvi)),0.0) FROM hvw_Gatema_PohybUmisteniAll PU WHERE PU.IDPohZbo=I.ID AND ISNULL(PU.IDVyrCis,0)=ISNULL(CP.IDVyrCis,0)) Um 
          WHERE I.SkutecneDatReal IS NOT NULL AND I.DruhPohybuZbo IN (0,1,2,3,4) AND ISNULL(SS_E._SU_EvidenceUmisteni, S_E._SU_EvidenceUmisteni)=3 AND IH_P.ID IS NULL AND IH_V.ID IS NULL AND 
                ABS(ISNULL(CP.Mnozstvi,I.Mnozstvi)*I.PrepMnozstvi - Um.Mnozstvi)>=0.0001 
        IF @ErrMsg IS NOT NULL 
          BEGIN 
            IF @@trancount>0 ROLLBACK TRAN 
            RAISERROR(@ErrMsg, 16, 1) 
            RETURN 
          END 
      END 
  END ELSE 
  BEGIN 
    DECLARE @IDStornoDoklad int, @IDDoklad int, @IDZurnal int 
    SET @IDStornoDoklad=NULL 
    SELECT TOP 1 @IDStornoDoklad=IDDoklad, @IDDoklad=IDOldDoklad FROM DELETED WHERE DruhPohybuZbo IN (1,3) 
    IF @IDStornoDoklad IS NOT NULL AND @IDDoklad IS NOT NULL 
      BEGIN 
        SELECT @IDZurnal=MAX(ID) FROM TabZurnal 
        IF EXISTS(SELECT * FROM TabZurnal Z, TabDokladyZbozi DZ, TabDokladyZbozi SDZ 
                           WHERE Z.ID=@IDZurnal AND DZ.ID=@IDDoklad AND SDZ.ID=@IDStornoDoklad AND Z.Udalost=30 AND 
                                 Z.Akce LIKE N'% '+DZ.RadaDokladu+N' '+CAST(DZ.PoradoveCislo AS NVARCHAR(20))+N'(% '+SDZ.RadaDokladu+N' '+CAST(SDZ.PoradoveCislo AS NVARCHAR(20))+N'(%'  ) 
          BEGIN 
            DELETE Gatema_PohybUmisteni WHERE IDPohZbo IN (SELECT ID FROM TabPohybyZbozi WHERE IDDoklad=@IDDoklad OR IDDoklad=@IDStornoDoklad UNION 
                                                           SELECT ID FROM DELETED WHERE IDDoklad=@IDDoklad OR IDDoklad=@IDStornoDoklad) 
            IF @@error<>0 
              BEGIN 
                IF @@trancount>0 ROLLBACK TRAN 
                RETURN 
              END 
            UPDATE Gatema_PohybManJed SET IDDokZbo=NULL WHERE IDDokZbo=@IDStornoDoklad 
            UPDATE Gatema_PohybManJed SET IDDokZbo=NULL WHERE IDDokZbo=@IDDoklad 
          END 
      END 
    DELETE Gatema_PohybUmisteni WHERE IDPohZbo IN (SELECT ID FROM DELETED) 
    IF @@error<>0 
      BEGIN 
        IF @@trancount>0 ROLLBACK TRAN 
        RETURN 
      END 
  END
GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_Gatema_StavUmisteni_Insert_Update_Delete]
GO

