USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ConstainsContraParts]    Script Date: 26.06.2025 13:59:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ConstainsContraParts] @ID INT
AS

BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_DilecObsahujeProtikusy=1 WHERE ID = (SELECT Dilec FROM TabNvazby WHERE ID=@ID);
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_DilecObsahujeProtikusy)
  SELECT Dilec,1
  FROM TabNvazby WHERE ID=@ID;
END
COMMIT TRANSACTION;
END;
GO

