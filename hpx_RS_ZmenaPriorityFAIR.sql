USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaPriorityFAIR]    Script Date: 26.06.2025 16:12:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaPriorityFAIR]
@kontrola1 BIT,
@_EXT_RS_PrioritaFAI BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tple.ID  FROM TabPrikaz_EXT tple WHERE tple.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_EXT_RS_PrioritaFAI)
    VALUES (@ID,@_EXT_RS_PrioritaFAI)
 END
ELSE
UPDATE tpe SET tpe._EXT_RS_PrioritaFAI=@_EXT_RS_PrioritaFAI
FROM TabPrikaz_EXT tpe
WHERE tpe.ID = @ID
END;

IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

