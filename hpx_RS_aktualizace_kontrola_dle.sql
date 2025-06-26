USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_kontrola_dle]    Script Date: 26.06.2025 10:32:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_kontrola_dle]
@_vstupni_kontrola NVARCHAR(50),
@ID INT
AS
IF @_vstupni_kontrola <> ''
BEGIN
UPDATE TabKmenZbozi_EXT
SET _vstupni_kontrola = @_vstupni_kontrola
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
WHERE tpz.ID = @ID
END
GO

