USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_nazev3_4]    Script Date: 26.06.2025 14:01:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_nazev3_4]
@kontrola1 BIT,
@Nazev2 NVARCHAR(100),
@kontrola2 BIT,
@Nazev3 NVARCHAR(100),
@kontrola3 BIT,
@Nazev4 NVARCHAR(100),
@kontrola4 BIT,
@_PopDis NVARCHAR(255),
@kontrola5 BIT,
@_PopDisEN NVARCHAR(255),
@kontrola6 BIT,
@_PopDisDE NVARCHAR(255),
@ID INT
AS
IF @kontrola1=1
BEGIN
UPDATE tkz SET tkz.Nazev2=@Nazev2
FROM TabKmenZbozi tkz
WHERE tkz.ID = @ID
END;
IF @kontrola2=1
BEGIN
UPDATE tkz SET tkz.Nazev3=@Nazev3
FROM TabKmenZbozi tkz
WHERE tkz.ID = @ID
END;
IF @kontrola3=1
BEGIN
UPDATE tkz SET tkz.Nazev4=@Nazev4
FROM TabKmenZbozi tkz
WHERE tkz.ID = @ID
END;
IF @kontrola4=1
BEGIN
UPDATE tkze SET tkze._PopDis=@_PopDis
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @ID
END;
IF @kontrola5=1
BEGIN
UPDATE tkze SET tkze._PopDisEN=@_PopDisEN
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @ID
END;
IF @kontrola6=1
BEGIN
UPDATE tkze SET tkze._PopDisDE=@_PopDisDE
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @ID
END;
IF @kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0 AND @kontrola6=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

