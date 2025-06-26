USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSZmenaKoefProSK]    Script Date: 26.06.2025 15:10:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RSZmenaKoefProSK]
@_KoefSK NUMERIC(19,6),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _KoefSK=@_KoefSK WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_KoefSK)
  VALUES (@ID,@_KoefSK);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

