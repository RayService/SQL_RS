USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_FAIR_VP]    Script Date: 30.06.2025 8:39:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_FAIR_VP]
@kontrola1 BIT,
@kontrola2 BIT,
@kontrola3 BIT,
@kontrola4 BIT,
@kontrola5 BIT,
@_fair BIT,
@_UvolSer BIT,
@_fair2 BIT,
@_DeltaFair BIT,
@_ManagFAI BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpze.ID  FROM TabPrikaz_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_FAIR)
    VALUES (@ID,@_FAIR)
 END
ELSE
UPDATE tpze SET tpze._FAIR = @_FAIR
FROM TabPrikaz_EXT tpze
WHERE tpze.ID = @ID
END;
IF @kontrola2=1
BEGIN
IF (SELECT tpze.ID  FROM TabPrikaz_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_UvolSer)
    VALUES (@ID,@_UvolSer)
 END
ELSE
UPDATE tpze SET tpze._UvolSer = @_UvolSer
FROM TabPrikaz_EXT tpze
WHERE tpze.ID = @ID
END;

IF @kontrola3=1
BEGIN
IF (SELECT tpze.ID  FROM TabPrikaz_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_fair2)
    VALUES (@ID,@_fair2)
 END
ELSE
UPDATE tpze SET tpze._fair2 = @_fair2
FROM TabPrikaz_EXT tpze
WHERE tpze.ID = @ID
END;

IF @kontrola4=1
BEGIN
IF (SELECT tpze.ID  FROM TabPrikaz_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_DeltaFair)
    VALUES (@ID,@_DeltaFair)
 END
ELSE
UPDATE tpze SET tpze._DeltaFair = @_DeltaFair
FROM TabPrikaz_EXT tpze
WHERE tpze.ID = @ID
END;

IF @kontrola5=1
BEGIN
IF (SELECT tpze.ID  FROM TabPrikaz_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_ManagFAI)
    VALUES (@ID,@_ManagFAI)
 END
ELSE
UPDATE tpze SET tpze._ManagFAI = @_ManagFAI
FROM TabPrikaz_EXT tpze
WHERE tpze.ID = @ID
END;

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

