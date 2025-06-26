USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_zmena_minmaxnastavil]    Script Date: 26.06.2025 15:16:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_zmena_minmaxnastavil]
@_MinMaxZam NVARCHAR(50),
@ID INT
AS
IF  (SELECT KZE.ID  FROM TabKmenZbozi_EXT as KZE WHERE   KZE.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_MinMaxZam) 
    VALUES (@ID,@_MinMaxZam)
 END
ELSE
IF @_MinMaxZam <> ''
UPDATE TabKmenZbozi_EXT  SET _MinMaxZam = @_MinMaxZam WHERE ID = @ID
GO

