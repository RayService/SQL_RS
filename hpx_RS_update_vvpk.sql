USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_vvpk]    Script Date: 26.06.2025 11:07:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_vvpk]
@kontrola1 BIT,
@_VVPKVysl NVARCHAR(10),
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpe.ID  FROM TabPlan_EXT tpe WHERE tpe.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_VVPKVysl)
    VALUES (@ID,@_VVPKVysl)
 END
ELSE
UPDATE tpe SET tpe._VVPKVysl = @_VVPKVysl
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

