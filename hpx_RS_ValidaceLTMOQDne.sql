USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ValidaceLTMOQDne]    Script Date: 26.06.2025 15:49:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ValidaceLTMOQDne]
@_EXT_RS_ValidateLTMOQDne DATETIME,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_ValidateLTMOQDne=@_EXT_RS_ValidateLTMOQDne WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_ValidateLTMOQDne)
  VALUES (@ID,@_EXT_RS_ValidateLTMOQDne);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

