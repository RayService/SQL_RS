USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_pripojeni_skolici_akce]    Script Date: 26.06.2025 10:49:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_pripojeni_skolici_akce]
@IDakce INT,
@ID INT
AS
BEGIN
IF (SELECT tpmaze.ID  FROM TabPrikazMzdyAZmetky_EXT tpmaze WHERE tpmaze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikazMzdyAZmetky_EXT (ID,_EXT_RS_ID_training) 
    VALUES (@ID,@IDakce)
 END
ELSE
UPDATE TabPrikazMzdyAZmetky_EXT SET _EXT_RS_ID_training=@IDakce WHERE ID=@ID
END
GO

