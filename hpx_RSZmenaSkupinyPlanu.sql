USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSZmenaSkupinyPlanu]    Script Date: 26.06.2025 15:38:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RSZmenaSkupinyPlanu]
@_EXT_RS_SkupinaPlanu NVARCHAR(10),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPohybyZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_SkupinaPlanu=@_EXT_RS_SkupinaPlanu WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPohybyZbozi_EXT (ID,_EXT_RS_SkupinaPlanu)
  VALUES (@ID,@_EXT_RS_SkupinaPlanu);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

