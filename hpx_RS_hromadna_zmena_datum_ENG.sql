USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_zmena_datum_ENG]    Script Date: 26.06.2025 10:52:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_hromadna_zmena_datum_ENG]
@Datum DATETIME,
@ID INT
AS
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_DatEng) 
    VALUES (@ID,@Datum)
 END
ELSE
UPDATE TabPlan_EXT SET _DatEng=@Datum WHERE ID=@ID
END
GO

