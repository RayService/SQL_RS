USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PrepisPotvrzenehoData]    Script Date: 26.06.2025 15:40:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PrepisPotvrzenehoData]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDPol INT;

SET @IDPol=(SELECT ID FROM #TempDefForm_Validace)

IF EXISTS(SELECT *
			FROM #TempDefForm_Validace v
			LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=v.ID
			WHERE v.ID=tpz.ID AND v.PotvrzDatDod<>tpz.PotvrzDatDod)
BEGIN
  UPDATE Tabx_RS_PohybyPotvrzDat SET Archive=1 WHERE IDPohyb=@IDPol
  UPDATE TabPohybyZbozi_EXT SET _EXT_RS_MovNumber=NULL WHERE ID=@IDPol
END;

--MŽ, 18.6.2025 na přání MM přidána kalkulace cen před slevou
BEGIN
EXEC dbo.hpx_RS_PrepocetSlevNakup @IDPol
END

GO

