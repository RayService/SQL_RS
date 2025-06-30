USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpxRSHZDuvodVojmat]    Script Date: 30.06.2025 8:54:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpxRSHZDuvodVojmat]
@_EXT_RS_DuvodVojmat NVARCHAR(150),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_DuvodVojmat=@_EXT_RS_DuvodVojmat WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_DuvodVojmat)
  VALUES (@ID,@_EXT_RS_DuvodVojmat);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

