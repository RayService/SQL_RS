USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_rada_VP]    Script Date: 26.06.2025 11:10:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_rada_VP]
@kontrola1 BIT,
@RadaVyrPrikazu NVARCHAR(10),
@ID INT
AS
IF @kontrola1=1
BEGIN
UPDATE tpkz SET tpkz.RadaVyrPrikazu = @RadaVyrPrikazu
FROM TabPlan tp
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tp.IDTabKmen
LEFT OUTER JOIN TabParKmZ tpkz ON tpkz.IDKmenZbozi=tkz.ID
WHERE tp.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

