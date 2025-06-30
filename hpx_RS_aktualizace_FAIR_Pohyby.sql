USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_FAIR_Pohyby]    Script Date: 30.06.2025 8:11:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_FAIR_Pohyby]
@kontrola1 BIT,
@kontrola2 BIT,
@kontrola3 BIT,
@kontrola4 BIT,
@_FAIR BIT,
@_FAIRint BIT,
@_ManFAIR BIT,
@_EXT_RS_fair_not_required BIT,
@kontrola5 BIT,
@_DeltaFair BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_FAIR)
    VALUES (@ID,@_FAIR)
 END
ELSE
UPDATE tpze SET tpze._FAIR = @_FAIR
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID
END;
IF @kontrola2=1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_FAIRint)
    VALUES (@ID,@_FAIRint)
 END
ELSE
UPDATE tpze SET tpze._FAIRint = @_FAIRint
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID
END;
/*
IF @kontrola3=1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_ManFAIR)
    VALUES (@ID,@_ManFAIR)
 END
ELSE
UPDATE tpze SET tpze._ManFAIR = @_ManFAIR
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID
END;
*/
IF @kontrola4=1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_EXT_RS_fair_not_required)
    VALUES (@ID,@_EXT_RS_fair_not_required)
 END
ELSE
UPDATE tpze SET tpze._EXT_RS_fair_not_required = @_EXT_RS_fair_not_required
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID
END;
IF @kontrola5=1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_DeltaFair)
    VALUES (@ID,@_DeltaFair)
 END
ELSE
UPDATE tpze SET tpze._DeltaFair = @_DeltaFair
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID
END;

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

