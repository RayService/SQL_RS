USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmenaDodaciLhuta_tydny]    Script Date: 26.06.2025 11:26:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmenaDodaciLhuta_tydny]
@_EXT_RS_dodaci_lhuta_tydny INT,
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT as tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_dodaci_lhuta_tydny)
    VALUES (@ID,@_EXT_RS_dodaci_lhuta_tydny)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _EXT_RS_dodaci_lhuta_tydny=@_EXT_RS_dodaci_lhuta_tydny WHERE ID = @ID
END
GO

