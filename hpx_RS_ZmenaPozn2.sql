USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaPozn2]    Script Date: 30.06.2025 8:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaPozn2]
@_PoznamkaPol2 NVARCHAR (MAX),
@Pridat BIT,
@Prepsat BIT,
@Potvrdit BIT,
@ID INT
AS

IF @Potvrdit=1
BEGIN
IF @Pridat=0 AND @Prepsat=1
BEGIN
UPDATE TabPohybyZbozi_EXT  SET _DS_RS_PoznamkaPol2=@_PoznamkaPol2 WHERE ID = @ID
END;
IF @Pridat=1 AND @Prepsat=0
BEGIN
UPDATE TabPohybyZbozi_EXT 
SET _DS_RS_PoznamkaPol2 = 
    CAST(
        CASE 
            WHEN ISNULL(CAST(_DS_RS_PoznamkaPol2 AS NVARCHAR(MAX)), '') = '' 
            THEN @_PoznamkaPol2 
            ELSE @_PoznamkaPol2 + CHAR(13) + ISNULL(CAST(_DS_RS_PoznamkaPol2 AS NVARCHAR(MAX)), '')
        END 
    AS NVARCHAR(MAX)) 
WHERE ID = @ID
END
IF @Pridat=1 AND @Prepsat=1
BEGIN
RAISERROR('Nic neproběhne, je zatržena nepovolená kombinace.',16,1)
RETURN
END;
END
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Potvrdit.',16,1)
RETURN
END;
GO

