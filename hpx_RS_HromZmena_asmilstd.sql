USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmena_asmilstd]    Script Date: 26.06.2025 11:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmena_asmilstd]
@_ASMilStan NVARCHAR(30),
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_ASMilStan)
    VALUES (@ID,@_ASMilStan)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _ASMilStan=@_ASMilStan WHERE ID = @ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

