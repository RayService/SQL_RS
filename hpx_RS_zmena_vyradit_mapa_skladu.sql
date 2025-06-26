USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_vyradit_mapa_skladu]    Script Date: 26.06.2025 11:05:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_vyradit_mapa_skladu]
@_VyjmoutZMapySkladu BIT,
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT tue.ID  FROM TabUmisteni_EXT as tue WHERE tue.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabUmisteni_EXT (ID,_VyjmoutZMapySkladu) 
    VALUES (@ID,@_VyjmoutZMapySkladu)
 END
ELSE
UPDATE TabUmisteni_EXT SET _VyjmoutZMapySkladu = @_VyjmoutZMapySkladu WHERE ID = @ID
END
GO

