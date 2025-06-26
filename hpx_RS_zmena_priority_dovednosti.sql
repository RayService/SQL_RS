USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_priority_dovednosti]    Script Date: 26.06.2025 12:32:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_zmena_priority_dovednosti]
@_EXT_RE_priorita_dovednosti INT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPersZnalostiCis_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RE_priorita_dovednosti=@_EXT_RE_priorita_dovednosti WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPersZnalostiCis_EXT (ID,_EXT_RE_priorita_dovednosti)
  VALUES (@ID,@_EXT_RE_priorita_dovednosti);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

