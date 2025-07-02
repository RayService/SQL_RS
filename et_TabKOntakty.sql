USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKOntakty]    Script Date: 02.07.2025 15:20:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabKOntakty] ON [dbo].[TabKontakty] FOR DELETE AS
SET NOCOUNT ON
DECLARE @Popis varchar(50),@Spojeni varchar(50),@Spojeni2 varchar(50),@Druh smallint,@Kam smallint
DECLARE @PocetDeleted INT,@PocetInserted INT
SET @PocetDeleted=(SELECT COUNT(*)FROM deleted)
SET @PocetInserted=(SELECT COUNT(*)FROM inserted)
IF @PocetInserted=0 AND @PocetDeleted>0 
BEGIN
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT
    Popis,Spojeni,Spojeni2,Druh,Kam    
    FROM DELETED
    OPEN c
    WHILE 1=1
    BEGIN
      FETCH NEXT FROM c INTO
      @Popis,@Spojeni,@Spojeni2,@Druh,@Kam    
      IF @@FETCH_STATUS<>0 BREAK
      INSERT INTO xTabKontaktyDeleteLog
      (Popis,Spojeni,Spojeni2,Druh,Kam,Pachatel,Datum)
      VALUES
      (@Popis,@Spojeni,@Spojeni2,@Druh,@Kam,SUSER_NAME(),GETDATE())

    END
    CLOSE c
    DEALLOCATE c
END


 
GO

ALTER TABLE [dbo].[TabKontakty] ENABLE TRIGGER [et_TabKOntakty]
GO

