USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_dodLhuty_kmenzbozi_cenik]    Script Date: 26.06.2025 12:30:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_dodLhuty_kmenzbozi_cenik] @ID INT
AS
DECLARE @lhutaPohyb NUMERIC(19,6);
BEGIN
SET @lhutaPohyb=
(SELECT tkkc.Dokl_poptLT
FROM TabStrukKusovnik_kalk_cenik tkkc
WHERE
(tkkc.ID=@ID))
IF @lhutaPohyb > 0
UPDATE tkz_EXT SET tkz_EXT._EXT_RS_dodaci_lhuta_tydny=tkkc.Dokl_poptLT
FROM TabStrukKusovnik_kalk_cenik tkkc WITH(NOLOCK)
  LEFT OUTER JOIN TabKmenZbozi tkz ON tkkc.IDNizsi=tkz.ID
  LEFT OUTER JOIN TabKmenZbozi_EXT tkz_EXT WITH(NOLOCK) ON tkz_EXT.ID=tkz.ID
WHERE (tkkc.ID=@ID)
END;
GO

