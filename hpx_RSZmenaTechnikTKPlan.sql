USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSZmenaTechnikTKPlan]    Script Date: 26.06.2025 13:54:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RSZmenaTechnikTKPlan]
@_EXT_RS_technikTK INT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
DECLARE @IDTabKmen INT
SET @IDTabKmen=(SELECT IDTabKmen FROM TabPlan WHERE ID=@ID)
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_technikTK=@_EXT_RS_technikTK
WHERE ID = @IDTabKmen;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_technikTK)
  VALUES (@IDTabKmen,@_EXT_RS_technikTK);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

