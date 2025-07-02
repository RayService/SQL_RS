USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikazZdrojVyrPlan_delete_prikaz]    Script Date: 02.07.2025 16:21:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPrikazZdrojVyrPlan_delete_prikaz] ON [dbo].[TabPrikazZdrojVyrPlan]
FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDZurnal INT
DECLARE @Filtr BIT = 0
DECLARE @IDPl INT
SET NOCOUNT ON
SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

BEGIN
IF @Akce IN (N'D')

SET @IDPl=(SELECT IDPlan FROM DELETED)
EXEC hp_VyrPlan_AktualizaceZaplanovanehoMnozstvi @IDPlan=@IDPl

END
/*FOR DELETE
AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON
--tento trigger aktualizuje zaplánované množství při smazání VP
DECLARE @IDVP INT;
DECLARE @IDPl INT;

SET @IDVP=(SELECT ID FROM DELETED) 
--SET @IDPl=(SELECT D.IDPlan FROM DELETED D)
--SET @IDPl=(SELECT CASE WHEN MIN(Z.IDPlan)=MAX(Z.IDPlan) THEN MIN(Z.IDPlan) END FROM TabPrikazZdrojVyrPlan Z WHERE Z.IDPrikaz=@IDVP)

BEGIN
   INSERT INTO dbo.SampleTable_Audit
   (SampleTableID,SampleTableInt, SampleTableChar, SampleTableVarChar, Operation, TriggerTable)    
   SELECT @IDVP,IDPlan/* @IDPl*/, Rada, Prikaz, 'D', 'D'
   FROM deleted;
END;

BEGIN
EXEC hp_VyrPlan_AktualizaceZaplanovanehoMnozstvi @IDPlan=@IDPl
END
*/
GO

ALTER TABLE [dbo].[TabPrikazZdrojVyrPlan] ENABLE TRIGGER [et_TabPrikazZdrojVyrPlan_delete_prikaz]
GO

