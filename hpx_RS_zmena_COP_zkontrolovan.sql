USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_COP_zkontrolovan]    Script Date: 26.06.2025 11:19:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_COP_zkontrolovan]
@_EXT_RS_cop_zkontrolovan BIT,
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT KZE.ID  FROM TabKmenZbozi_EXT as KZE WHERE KZE.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_cop_zkontrolovan)
    VALUES (@ID,@_EXT_RS_cop_zkontrolovan)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _EXT_RS_cop_zkontrolovan = @_EXT_RS_cop_zkontrolovan WHERE ID = @ID
END
GO

