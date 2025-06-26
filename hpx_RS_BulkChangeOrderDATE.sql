USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_BulkChangeOrderDATE]    Script Date: 26.06.2025 13:42:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_BulkChangeOrderDATE] @DatumStart DATETIME, @Prepsat1 BIT, @DatumEnd DATETIME, @Prepsat2 BIT, @ID INT
AS
DECLARE @StavPrikazu INT
SELECT @StavPrikazu=tp.StavPrikazu FROM TabPrikaz tp WHERE tp.ID=@ID
IF @StavPrikazu>40
BEGIN
RAISERROR('Nelze měnit datum na ukončeném nebo uzavřeném příkazu!',16,1)
RETURN
END;

IF @Prepsat1=1
BEGIN
UPDATE tp SET Plan_zadani=@DatumStart
FROM TabPrikaz tp
WHERE tp.ID=@ID
END;

IF @Prepsat2=1
BEGIN
UPDATE tp SET Plan_ukonceni=@DatumEnd
FROM TabPrikaz tp
WHERE tp.ID=@ID
END;

IF @Prepsat1=0 AND @Prepsat2=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN
END;
GO

