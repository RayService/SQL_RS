USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_TypeMilitaryEquipment]    Script Date: 30.06.2025 8:45:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_TypeMilitaryEquipment]
@Type NVARCHAR(50),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_TypVojMat=@Type WHERE ID = @ID;
IF @@ROWCOUNT = 0 
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_TypVojMat)
  VALUES (@ID,@Type);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

