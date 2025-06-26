USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_zmena_PNodberatel]    Script Date: 26.06.2025 11:53:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_zmena_PNodberatel]
@_RAY_Part_number NVARCHAR(50),
@ID INT
AS
IF  (SELECT KZE.ID  FROM TabNC_EXT as KZE WHERE KZE.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabNC_EXT (ID,_RAY_Part_number) 
    VALUES (@ID,@_RAY_Part_number)
 END
ELSE
IF @_RAY_Part_number <> ''
UPDATE TabNC_EXT  SET _RAY_Part_number = @_RAY_Part_number WHERE ID = @ID
GO

