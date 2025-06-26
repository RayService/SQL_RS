USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_profession]    Script Date: 26.06.2025 10:11:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_profession]
@ID INT
AS
-- =====================================================================
-- Author:		MŽ
-- Create date:            10.4.2019
-- Description:	Hromadný import profese z externího pole na materiálu do profese na operacích
-- =====================================================================

DECLARE @IDHlavicka INT
SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'

--dohledání ID změny
DECLARE @IDZmena INT
SELECT @IDZmena = (SELECT
TabCzmeny.ID
FROM TabCzmeny
WHERE
((TabCZmeny.Platnost = 0 AND TabCZmeny.ID IN  (SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDHlavicka UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDHlavicka UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabNVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabNVazby WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDHlavicka UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDHlavicka ))))

BEGIN
IF NOT EXISTS (SELECT tpvp.IDVyrProfese
FROM TabPostupVyrProfese tpvp
LEFT OUTER JOIN TabPostup tp ON tp.ID = tpvp.IDPostup
LEFT OUTER JOIN TabPostup_EXT tpe ON tpe.ID = tp.ID
LEFT OUTER JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec AND tkv.Operace = tp.Operace
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi-- AND tkv.ZmenaOd = @IDZmena
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
WHERE tkv.ID = @ID AND tpvp.IDVyrProfese = tkze._EXT_RS_material_profession)

INSERT INTO TabPostupVyrProfese (IDPostup, IDVyrProfese, Mnozstvi,ParKP_PocetSoucaneObsluhStroju)
SELECT tp.ID, tkze._EXT_RS_material_profession, 1, 1
FROM TabKVazby tkv
LEFT OUTER JOIN TabKvazby_EXT tkve ON tkve.ID = tkv.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi-- AND tkv.ZmenaOd = @IDZmena
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
LEFT OUTER JOIN TabPostup tp ON tp.dilec = tkv.vyssi AND tp.Operace = tkv.Operace-- AND tkv.ZmenaOd = @IDZmena
LEFT OUTER JOIN TabPostup_EXT tpe ON tpe.ID = tp.ID
WHERE tkv.ID = @ID
END
GO

