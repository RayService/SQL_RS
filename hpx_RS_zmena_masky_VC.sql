USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_masky_VC]    Script Date: 26.06.2025 12:07:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_zmena_masky_VC]
@_RayService_GenVC_Maska NVARCHAR(100),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _RayService_GenVC_Maska=@_RayService_GenVC_Maska WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_RayService_GenVC_Maska)
  VALUES (@ID,@_RayService_GenVC_Maska);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

