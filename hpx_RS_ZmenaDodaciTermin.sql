USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaDodaciTermin]    Script Date: 26.06.2025 15:58:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaDodaciTermin]
@kontrola1 BIT,
@_poptLT NUMERIC(19,6),
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_poptLT)
    VALUES (@ID,@_poptLT)
 END
ELSE
UPDATE tpze SET tpze._poptLT = @_poptLT
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID = @ID
END;

IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Provést',16,1);
RETURN;
END;
GO

