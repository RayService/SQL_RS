USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDPozastavitSchvalovani]    Script Date: 26.06.2025 9:04:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDPozastavitSchvalovani]
@IdDoklad INT,
@Pozastavit BIT = 0,
@TypDokladu INT = 0,
@Poznamka NVARCHAR(4000),
@ZeSchvalovani BIT = 0,
@ProvadetKontroly BIT = 0
AS
DECLARE @SchvaleniUroven INT, @IdPredpis INT
SET @SchvaleniUroven=dbo.hfx_SD_AktualniUrovenSchvalovani(@IdDoklad, @TypDokladu)
IF @ProvadetKontroly=1
BEGIN
  DECLARE @VysledekVstupniKontroly NVARCHAR(255)
  SET @VysledekVstupniKontroly=dbo.hfx_SD_KontrolaPredSchvalovanim(@IdDoklad, @TypDokladu)
  IF @VysledekVstupniKontroly IS NOT NULL
  BEGIN
    RAISERROR(@VysledekVstupniKontroly, 16, 1)
    RETURN
  END
END
IF @TypDokladu=0
BEGIN
IF NOT EXISTS(SELECT * FROM TabDokladyZbozi_EXT WHERE ID = @IdDoklad)
  INSERT TabDokladyZbozi_EXT(ID) VALUES(@IdDoklad)
UPDATE TabDokladyZbozi_EXT SET
  _SD_SchvalovaniPozastaveno = @Pozastavit
WHERE ID = @IdDoklad
END
IF @TypDokladu=1
BEGIN
IF NOT EXISTS(SELECT * FROM TabPosta_EXT WHERE ID = @IdDoklad)
  INSERT TabPosta_EXT(ID) VALUES(@IdDoklad)
UPDATE TabPosta_EXT SET
  _SD_SchvalovaniPozastaveno = @Pozastavit
WHERE ID = @IdDoklad
END
IF @TypDokladu=2
BEGIN
IF NOT EXISTS(SELECT * FROM TabDosleObjH02_EXT WHERE ID = @IdDoklad)
  INSERT TabDosleObjH02_EXT(ID) VALUES(@IdDoklad)
UPDATE TabDosleObjH02_EXT SET
  _SD_SchvalovaniPozastaveno = @Pozastavit
WHERE ID = @IdDoklad
END
IF @TypDokladu=3
BEGIN
IF NOT EXISTS(SELECT * FROM TabKoopObj_EXT WHERE ID = @IdDoklad)
  INSERT TabKoopObj_EXT(ID) VALUES(@IdDoklad)
UPDATE TabKoopObj_EXT SET
  _SD_SchvalovaniPozastaveno = @Pozastavit
WHERE ID = @IdDoklad
END
IF @TypDokladu=4
BEGIN
IF NOT EXISTS(SELECT * FROM TabPokladna_EXT WHERE ID = @IdDoklad)
  INSERT TabPokladna_EXT(ID) VALUES(@IdDoklad)
UPDATE TabPokladna_EXT SET
  _SD_SchvalovaniPozastaveno = @Pozastavit
WHERE ID = @IdDoklad
END
IF @ZeSchvalovani = 0
INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav, SchvaleniPoznamka, SchvaleniUroven)
VALUES(1, @IdDoklad, @TypDokladu, 6, @Poznamka, @SchvaleniUroven)
IF @ZeSchvalovani = 0
BEGIN
SELECT @IdPredpis=ID
FROM Tabx_SDPredpisy
WHERE Kopie = 1 AND TypDokladu = @TypDokladu AND IdDoklad = @IdDoklad
INSERT Tabx_SDSchvaleneZaznamy(IdPredpis, Akce) VALUES(@IdPredpis, 2)
END
GO

