USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_editace_cilove_ceny_kalk]    Script Date: 26.06.2025 12:39:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_editace_cilove_ceny_kalk] @Cilova_cena_Kc NUMERIC(19,6), @Cilova_cena_Val NUMERIC(19,6), @kontrola BIT, @ID INT
AS
IF @kontrola=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
IF @kontrola=1
BEGIN
IF (@Cilova_cena_Kc < 0 OR @Cilova_cena_Val < 0)
BEGIN
RAISERROR ('Nelze zadat zápornou hodnotu!',16,1)
RETURN
END
ELSE
BEGIN
UPDATE pozdok SET Cilova_cena_Kc=ISNULL(@Cilova_cena_Kc,0), Cilova_cena_Val=ISNULL(@Cilova_cena_Val,0)
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
END
END;
GO

