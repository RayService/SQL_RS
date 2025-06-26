USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_technikTK]    Script Date: 26.06.2025 12:40:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_zmena_technikTK]
@_EXT_RS_technikTK INT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_technikTK=@_EXT_RS_technikTK WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_technikTK)
  VALUES (@ID,@_EXT_RS_technikTK);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

