USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_editace_poznamky]    Script Date: 30.06.2025 8:52:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_editace_poznamky]
@Poznamka NVARCHAR (MAX),
@Pridat BIT,
@Prepsat BIT,
@Potvrdit BIT,
@ID INT
AS

IF @Potvrdit=1
BEGIN
IF @Pridat=0 AND @Prepsat=1
BEGIN
UPDATE TabPohybyZbozi SET Poznamka=@Poznamka WHERE ID = @ID
END;
IF @Pridat=1 AND @Prepsat=0
BEGIN
UPDATE TabPohybyZbozi
SET Poznamka = 
    CAST(
        CASE 
            WHEN ISNULL(CAST(Poznamka AS NVARCHAR(MAX)), '') = '' 
            THEN @Poznamka
            ELSE @Poznamka + CHAR(13) + ISNULL(CAST(Poznamka AS NVARCHAR(MAX)), '')
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

