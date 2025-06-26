USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_technicianTPV]    Script Date: 26.06.2025 11:05:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_technicianTPV]
@kontrola1 BIT,
@_TechnikTPV100 NVARCHAR(50),
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tkze.ID  FROM TabPlan tp LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tp.IDTabKmen WHERE tp.ID=@ID) IS NULL
 BEGIN
    INSERT INTO TabKmenZbozi_EXT (ID,_TechnikTPV100)
    SELECT tkz.ID,@_TechnikTPV100
	FROM TabKmenZbozi tkz
	LEFT OUTER JOIN TabPlan tp ON tp.IDTabKmen=tkz.ID
	WHERE tp.ID=@ID
 END
ELSE
UPDATE tkze SET tkze._TechnikTPV100 = @_TechnikTPV100
FROM TabPlan tp
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tp.IDTabKmen
WHERE tp.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

