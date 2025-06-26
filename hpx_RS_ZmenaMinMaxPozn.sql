USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaMinMaxPozn]    Script Date: 26.06.2025 15:15:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaMinMaxPozn]
@_MinMaxPozn NVARCHAR (150),
@Pridat BIT,
@Prepsat BIT,
@Potvrdit BIT,
@ID INT
AS

IF @Potvrdit=1
BEGIN
IF @Pridat=0 AND @Prepsat=1
BEGIN
UPDATE TabKmenZbozi_EXT  SET _MinMaxPozn=@_MinMaxPozn WHERE ID = @ID
END;
IF @Pridat=1 AND @Prepsat=0
BEGIN
UPDATE TabKmenZbozi_EXT SET _MinMaxPozn=CAST((ISNULL(CAST(_MinMaxPozn AS NVARCHAR(150)),'') +' '+ @_MinMaxPozn) AS NVARCHAR(150)) WHERE ID=@ID
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

