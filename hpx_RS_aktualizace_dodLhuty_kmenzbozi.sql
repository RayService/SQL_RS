USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_dodLhuty_kmenzbozi]    Script Date: 26.06.2025 10:50:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_dodLhuty_kmenzbozi] @ID INT
AS
DECLARE @lhutaPohyb NUMERIC(19,6);
BEGIN
SET @lhutaPohyb=
(SELECT tpz_EXT._poptLT FROM TabPohybyZbozi tpz WITH(NOLOCK)
LEFT OUTER JOIN TabPohybyZbozi_EXT tpz_EXT WITH(NOLOCK) ON tpz_EXT.ID=tpz.ID
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE
(tpz.ID=@ID))
IF @lhutaPohyb > 0
UPDATE tkz_EXT SET tkz_EXT._EXT_RS_dodaci_lhuta_tydny=tpz_EXT._poptLT
FROM TabPohybyZbozi tpz WITH(NOLOCK)
  LEFT OUTER JOIN TabPohybyZbozi_EXT tpz_EXT WITH(NOLOCK) ON tpz_EXT.ID=tpz.ID
  LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
  LEFT OUTER JOIN TabKmenZbozi_EXT tkz_EXT WITH(NOLOCK) ON tkz_EXT.ID=tkz.ID
WHERE
(tpz.ID=@ID)
END;
GO

