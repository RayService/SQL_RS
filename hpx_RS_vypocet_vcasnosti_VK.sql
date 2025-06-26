USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_vypocet_vcasnosti_VK]    Script Date: 26.06.2025 11:41:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RS_vypocet_vcasnosti_VK] @ID INT
AS

DECLARE @datum DATETIME
DECLARE @CisloZam INT

SET @datum = (SELECT GETDATE())
SET @CisloZam=(SELECT tcz.Cislo FROM TabCisZam tcz WHERE tcz.LoginId=SUSER_SNAME())
SELECT @datum,@CisloZam

UPDATE tpze SET tpze._jakost='A', tpze._uplnost='A'
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID

UPDATE tpz SET CisloZam=@CisloZam
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID

BEGIN TRANSACTION;
UPDATE dbo.TabPohybyZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _SkutDatKon=GETDATE() WHERE ID=@ID
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPohybyZbozi_EXT(ID, _SkutDatKon) VALUES(@ID, GETDATE());
END
COMMIT TRANSACTION;

GO

