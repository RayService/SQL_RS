USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_new_item_pricing_list]    Script Date: 26.06.2025 11:47:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_new_item_pricing_list]
@IDZakazka NVARCHAR(15),
@IDNizsi INT,
@mnf NUMERIC(19,2)
AS

BEGIN
SET @IDZakazka = (SELECT tz.ID FROM TabZakazka tz WHERE tz.CisloZakazky = @IDZakazka)
DECLARE @dilec INT;
DECLARE @material INT;
INSERT INTO TabStrukKusovnik_kalk_cenik (IDZakazka, IDNizsi, mnf, dilec, material, Dat_vypoctu, Autor, Vypocteny_prumer,Cena_2,Cena_dilec,Cena_vypoctena)
SELECT @IDZakazka, @IDNizsi, @mnf, tkz.Dilec, tkz.Material, GETDATE(), SUSER_SNAME(), 0,0,0,0
FROM TabKmenZbozi tkz
WHERE tkz.ID = @IDNizsi
END
GO

