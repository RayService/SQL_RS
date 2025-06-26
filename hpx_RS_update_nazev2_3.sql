USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_nazev2_3]    Script Date: 26.06.2025 11:38:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_nazev2_3]
@kontrola1 BIT,
@Nazev1 NVARCHAR(100),
@kontrola2 BIT,
@Nazev2 NVARCHAR(100),
@ID INT
AS
IF @kontrola1=1
BEGIN
UPDATE tkz SET tkz.Nazev1=@Nazev1
FROM TabKmenZbozi tkz
WHERE tkz.ID = @ID
END;
IF @kontrola2=1
BEGIN
UPDATE tkz SET tkz.Nazev2=@Nazev2
FROM TabKmenZbozi tkz
WHERE tkz.ID = @ID
END;
IF @kontrola1=0 AND @kontrola2=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

