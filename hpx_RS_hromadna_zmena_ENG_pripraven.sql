USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_zmena_ENG_pripraven]    Script Date: 26.06.2025 10:54:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_hromadna_zmena_ENG_pripraven]
@_EngPrip BIT,
@ID INT
AS
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_EngPrip) 
    VALUES (@ID,@_EngPrip)
 END
ELSE
UPDATE TabPlan_EXT SET _EngPrip=@_EngPrip WHERE ID=@ID
END
GO

