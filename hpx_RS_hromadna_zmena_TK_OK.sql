USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_zmena_TK_OK]    Script Date: 26.06.2025 10:58:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_hromadna_zmena_TK_OK]
@_TKok BIT,
@ID INT
AS
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_TKok) 
    VALUES (@ID,@_TKok)
 END
ELSE
UPDATE TabPlan_EXT SET _TKok=@_TKok WHERE ID=@ID
END
GO

