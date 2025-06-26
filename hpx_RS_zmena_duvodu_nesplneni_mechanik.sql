USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_duvodu_nesplneni_mechanik]    Script Date: 26.06.2025 12:31:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_zmena_duvodu_nesplneni_mechanik]
@_mistr NVARCHAR(255),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPrikaz_EXT WITH (UPDLOCK, SERIALIZABLE) SET _mistr=@_mistr WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPrikaz_EXT (ID,_mistr)
  VALUES (@ID,@_mistr);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

