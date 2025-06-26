USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_FAIR]    Script Date: 26.06.2025 13:21:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_FAIR]
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
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_FAIR)
    VALUES (@ID,@_FAIR)
 END
ELSE
UPDATE tpe SET tpe._FAIR = @_FAIR
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola2=1
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_FAIRint)
    VALUES (@ID,@_FAIRint)
 END
ELSE
UPDATE tpe SET tpe._FAIRint = @_FAIRint
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola3=1
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_ManFAIR)
    VALUES (@ID,@_ManFAIR)
 END
ELSE
UPDATE tpe SET tpe._ManFAIR = @_ManFAIR
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola4=1
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_EXT_RS_fair_not_required)
    VALUES (@ID,@_EXT_RS_fair_not_required)
 END
ELSE
UPDATE tpe SET tpe._EXT_RS_fair_not_required = @_EXT_RS_fair_not_required
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola5=1
BEGIN
IF (SELECT tple.ID  FROM TabPlan_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_DeltaFair)
    VALUES (@ID,@_DeltaFair)
 END
ELSE
UPDATE tpe SET tpe._DeltaFair = @_DeltaFair
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

