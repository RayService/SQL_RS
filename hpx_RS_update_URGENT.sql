USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_URGENT]    Script Date: 26.06.2025 14:04:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_URGENT]
@kontrola1 BIT,
@_InfoProVK NVARCHAR(20),
@ID INT
AS
--DECLARE @_InfoProVK NVARCHAR(20)
--SET @_InfoProVK='URGENT-ručně';
IF @kontrola1=1
BEGIN
IF (SELECT tdze.ID  FROM TabDokladyZbozi_EXT tdze WHERE tdze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabDokladyZbozi_EXT (ID,_InfoProVK)
    VALUES (@ID,@_InfoProVK)
 END
ELSE
UPDATE tpe SET tpe._InfoProVK = @_InfoProVK
FROM TabDokladyZbozi_EXT tpe
WHERE tpe.ID = @ID
END;
IF (@kontrola1=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

