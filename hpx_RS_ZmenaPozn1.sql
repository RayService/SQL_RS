USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaPozn1]    Script Date: 30.06.2025 9:02:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaPozn1]
@_Poznamka1 NVARCHAR (MAX),
@Pridat BIT,
@Prepsat BIT,
@Potvrdit BIT,
@ID INT
AS

IF @Potvrdit=1
BEGIN
IF @Pridat=0 AND @Prepsat=1
BEGIN
UPDATE TabDokladyZbozi  SET Poznamka=@_Poznamka1 WHERE ID = @ID
END;
IF @Pridat=1 AND @Prepsat=0
BEGIN
UPDATE TabDokladyZbozi 
SET Poznamka = 
    CAST(
        CASE 
            WHEN ISNULL(CAST(Poznamka AS NVARCHAR(MAX)), '') = '' 
            THEN @_Poznamka1 
            ELSE @_Poznamka1 + CHAR(13) + ISNULL(CAST(Poznamka AS NVARCHAR(MAX)), '')
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

