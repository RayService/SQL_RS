USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ChangeContactPerson]    Script Date: 26.06.2025 15:29:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ChangeContactPerson]
@KontOsoba INT,
@Kontrola BIT,
@ID INT
AS

IF @Kontrola=1
BEGIN
UPDATE tdz SET tdz.KontaktOsoba=@KontOsoba
FROM TabDokladyZbozi tdz
WHERE tdz.ID=@ID
END;
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN;
END;
GO

