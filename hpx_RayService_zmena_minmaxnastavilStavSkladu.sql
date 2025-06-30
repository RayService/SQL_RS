USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_zmena_minmaxnastavilStavSkladu]    Script Date: 30.06.2025 9:00:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_zmena_minmaxnastavilStavSkladu]
@_MinMaxZam NVARCHAR(50),
@ID INT
AS
IF  (SELECT sse.ID  FROM TabStavSkladu_EXT as sse WHERE sse.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabStavSkladu_EXT (ID,_MinMaxZam) 
    VALUES (@ID,@_MinMaxZam)
 END
ELSE
IF @_MinMaxZam <> ''
UPDATE TabStavSkladu_EXT  SET _MinMaxZam = @_MinMaxZam WHERE ID = @ID
GO

