USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ValidaceLTMOQDneKusovnik]    Script Date: 30.06.2025 8:46:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ValidaceLTMOQDneKusovnik]
@_EXT_RS_ValidateLTMOQDne DATETIME,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
DECLARE @IDKmen INT
SET @IDKmen=(SELECT tkz.ID FROM TabKmenZbozi tkz LEFT OUTER JOIN hvw_49230AD4A78D4639B265A02071A119B1 kus ON kus.IDNizsi=tkz.ID WHERE kus.ID=@ID)
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_ValidateLTMOQDne=@_EXT_RS_ValidateLTMOQDne WHERE ID=@IDKmen;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_ValidateLTMOQDne)
  VALUES (@IDKmen,@_EXT_RS_ValidateLTMOQDne);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

