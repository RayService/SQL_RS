USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_zmena_mno_pol]    Script Date: 26.06.2025 11:31:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Tato uložená procedura přepočítá ceny všech položky, které k danému dokladu patří.
CREATE PROCEDURE [dbo].[hpx_RS_hromadna_zmena_mno_pol]
@MnozstviNew NUMERIC(19,6),
@kontrola BIT,
@ID INT
AS
IF @kontrola=1
BEGIN
DECLARE @IDDoklad INT, @HmotnostNew NUMERIC (19,6);
SET @IDDoklad=(SELECT tpz.IDDoklad FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID)
SET @HmotnostNew=(SELECT tpz.Hmotnost/tpz.Mnozstvi*@MnozstviNew FROM TabPohybyZbozi tpz WITH(NOLOCK) WHERE tpz.ID=@ID)
UPDATE tpz SET Mnozstvi=@MnozstviNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID
UPDATE tpz SET Hmotnost=@HmotnostNew
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID
EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

