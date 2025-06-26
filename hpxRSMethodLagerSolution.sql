USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpxRSMethodLagerSolution]    Script Date: 26.06.2025 15:09:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpxRSMethodLagerSolution]
@_EXT_RS_PraceSLezaky NVARCHAR(50),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PraceSLezaky=@_EXT_RS_PraceSLezaky WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_PraceSLezaky)
  VALUES (@ID,@_EXT_RS_PraceSLezaky);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

