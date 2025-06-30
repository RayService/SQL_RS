USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpxRSHZKlasECCN]    Script Date: 30.06.2025 8:54:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpxRSHZKlasECCN]
@_EXT_RS_ClassificationECCN NVARCHAR(15),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_ClassificationECCN=@_EXT_RS_ClassificationECCN WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_ClassificationECCN)
  VALUES (@ID,@_EXT_RS_ClassificationECCN);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

