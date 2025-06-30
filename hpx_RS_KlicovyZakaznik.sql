USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KlicovyZakaznik]    Script Date: 30.06.2025 8:37:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_KlicovyZakaznik]
@_EXT_KlicovyZakaznik BIT,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabCisOrg_EXT WITH (UPDLOCK, SERIALIZABLE) SET _shop=@_EXT_KlicovyZakaznik WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabCisOrg_EXT (ID,_shop)
  VALUES (@ID,@_EXT_KlicovyZakaznik);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

