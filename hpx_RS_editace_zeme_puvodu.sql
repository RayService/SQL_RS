USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_editace_zeme_puvodu]    Script Date: 26.06.2025 11:28:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_editace_zeme_puvodu]
@Kontrola BIT,
@ZemePuvodu NVARCHAR(2),
@ID INT
AS

-- =============================================
-- Author:		MŽ
-- Create date:            17.7.2020
-- Description:	Hromadná změna země původu na položkách dokladu
-- Change: 10.2.2022 Přidáno zatržítko Přepsat a změněn zdroj na Celní kód
-- =============================================
IF @Kontrola=1
BEGIN
UPDATE TabPohybyZbozi SET
ZemePuvodu= @ZemePuvodu
WHERE ID = @ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

