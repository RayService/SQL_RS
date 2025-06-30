USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VPUrgent]    Script Date: 30.06.2025 9:00:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_VPUrgent]
@_EXT_VPUrgent BIT,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPrikaz_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_UrgentKNicemu=@_EXT_VPUrgent WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPrikaz_EXT (ID,_EXT_RS_UrgentKNicemu)
  VALUES (@ID,@_EXT_VPUrgent);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

