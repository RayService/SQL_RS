USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_fixace_plan_vyroby]    Script Date: 26.06.2025 12:09:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_zmena_fixace_plan_vyroby]
@_FixVyrKT INT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPrikaz_EXT WITH (UPDLOCK, SERIALIZABLE) SET _FixVyrKT=@_FixVyrKT WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPrikaz_EXT (ID,_FixVyrKT)
  VALUES (@ID,@_FixVyrKT);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

