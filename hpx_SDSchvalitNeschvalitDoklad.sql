USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDSchvalitNeschvalitDoklad]    Script Date: 26.06.2025 9:05:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDSchvalitNeschvalitDoklad]
@Schvalit BIT = 1,
@TypDokladu INT = 0,
@IdDoklad INT,
@Poznamka NVARCHAR(4000),
@ProvadetKontroly BIT = 0
AS
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
DECLARE @IdPredpis INT, @AktualniUroven INT, @CilovaUroven INT, @VracetNaPrvniUroven BIT, @DruhPohybuZboOZ INT=-1
DECLARE @TypHlasky TINYINT, @Hlaska NVARCHAR(MAX), @FinalneSchvaleno BIT
IF @TypDokladu=0
  SET @DruhPohybuZboOZ=(SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID=@IdDoklad)
IF OBJECT_ID('dbo.epx_SDSchvalitNeschvalitDoklad01', 'P') IS NOT NULL
  EXEC dbo.epx_SDSchvalitNeschvalitDoklad01
    @Schvalit=@Schvalit,
    @TypDokladu=@TypDokladu,
    @IdDoklad=@IdDoklad,
    @Poznamka=@Poznamka
IF @@ERROR<>0
  RETURN
IF OBJECT_ID('dbo.epx_SDSchvalitNeschvalitDoklad04', 'P') IS NOT NULL
BEGIN
  EXEC dbo.epx_SDSchvalitNeschvalitDoklad04
    @Schvalit=@Schvalit,
    @TypDokladu=@TypDokladu,
    @IdDoklad=@IdDoklad,
    @Poznamka=@Poznamka,
    @TypHlasky=@TypHlasky OUT,
    @Hlaska=@Hlaska OUT
  IF (@TypHlasky IS NOT NULL)AND(@Hlaska IS NOT NULL)
    INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), @TypHlasky, @Hlaska)
END
IF ISNULL(@TypHlasky, 0)=1
  RETURN
SET @AktualniUroven = NULL
SET @CilovaUroven = NULL
SET @VracetNaPrvniUroven = 0
SELECT @IdPredpis=ID
FROM Tabx_SDPredpisy
WHERE Kopie = 1 AND TypDokladu = @TypDokladu AND IdDoklad = @IdDoklad
EXEC dbo.hpx_SDNajdiAktualniUrovenUzivatele
@IdPredpis=@IdPredpis,
@AktualniUroven=@AktualniUroven OUT,
@VracetNaPrvniUroven=@VracetNaPrvniUroven OUT
IF @AktualniUroven IS NULL
BEGIN
  RAISERROR('Nebyla dohledána aktuální úroveň dle loginu - zřejmě se jedná o nestandardní pokus schválit doklad někým, kdo na to nemá právo.', 16, 1)
  RETURN
END
IF @Schvalit = 1
BEGIN
SET @CilovaUroven = (SELECT TOP 1 Uroven
FROM Tabx_SDPredpisVRoleVSchvalovatel
WHERE IdPredpis = @IdPredpis
AND Uroven > @AktualniUroven
ORDER BY Uroven ASC
)
IF @CilovaUroven IS NULL
SET @CilovaUroven = 9999
END
ELSE
BEGIN
SET @CilovaUroven = (SELECT TOP 1 Uroven
FROM Tabx_SDPredpisVRoleVSchvalovatel
WHERE IdPredpis = @IdPredpis
AND Uroven < @AktualniUroven
ORDER BY Uroven DESC
)
IF @CilovaUroven IS NULL
SET @CilovaUroven = 1
IF @VracetNaPrvniUroven = 1
SET @CilovaUroven = 1
SET @CilovaUroven = -1*@CilovaUroven
END
UPDATE Tabx_SDPredpisy SET
StavSchvaleni = @CilovaUroven
WHERE Kopie = 1 AND TypDokladu = @TypDokladu AND IdDoklad = @IdDoklad
IF @TypDokladu=0
BEGIN
DECLARE @PriznakSchvalenoVOBJ BIT, @NeprovadetOdemceniVOBJ BIT
DECLARE @PriznakSchvalenoEP BIT, @NeprovadetOdemceniEP BIT
SELECT @PriznakSchvalenoVOBJ=PriznakSchvalenoVOBJ, @NeprovadetOdemceniVOBJ=NeprovadetOdemceniVOBJ,
       @PriznakSchvalenoEP=PriznakSchvalenoEP, @NeprovadetOdemceniEP=NeprovadetOdemceniEP
FROM Tabx_SDKonfigurace
IF ((@DruhPohybuZboOZ=6)AND(@PriznakSchvalenoVOBJ=1))
OR ((@DruhPohybuZboOZ=9)AND(@PriznakSchvalenoEP=1))
BEGIN
IF NOT EXISTS(SELECT 0 FROM TabDokZboDodatek WHERE IDHlavicky = @IdDoklad AND DatumSchvaleni IS NOT NULL)
  UPDATE TabDokZboDodatek SET
    DatumSchvaleni = GETDATE(),
    Schvalil = SUSER_SNAME()
  WHERE IDHlavicky = @IdDoklad
IF ((@DruhPohybuZboOZ=6)AND(@NeprovadetOdemceniVOBJ=0))
OR ((@DruhPohybuZboOZ=9)AND(@NeprovadetOdemceniEP=0))
BEGIN
IF (@TypDokladu = 0)
AND
(ABS(@CilovaUroven) = 1)
AND
((SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID = @IdDoklad) = @DruhPohybuZboOZ)
UPDATE TabDokZboDodatek SET
  DatumSchvaleni = NULL,
  Schvalil = NULL
WHERE IDHlavicky = @IdDoklad
END
END
END
EXEC dbo.hpx_SDPozastavitSchvalovani
@IdDoklad = @IdDoklad,
@Pozastavit = 0,
@TypDokladu = @TypDokladu,
@Poznamka = @Poznamka,
@ZeSchvalovani = 1
INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav, SchvaleniPoznamka, SchvaleniUroven)
VALUES(1, @IdDoklad, @TypDokladu, @Schvalit, @Poznamka, @AktualniUroven)
IF @Schvalit = 1
  INSERT Tabx_SDSchvaleneZaznamy(IdPredpis, Akce) VALUES(@IdPredpis, 1)
ELSE
  INSERT Tabx_SDSchvaleneZaznamy(IdPredpis, Akce) VALUES(@IdPredpis, 0)
IF @CilovaUroven = 9999
  IF OBJECT_ID('dbo.epx_SDSchvalitNeschvalitDoklad02', 'P') IS NOT NULL
    EXEC dbo.epx_SDSchvalitNeschvalitDoklad02
      @TypDokladu=@TypDokladu,
      @IdDoklad=@IdDoklad
IF OBJECT_ID('dbo.epx_SDSchvalitNeschvalitDoklad03', 'P') IS NOT NULL
  EXEC dbo.epx_SDSchvalitNeschvalitDoklad03
    @TypDokladu=@TypDokladu,
    @IdDoklad=@IdDoklad,
    @Schvalit=@Schvalit
IF @CilovaUroven = 9999
  SET @FinalneSchvaleno=1
ELSE
  SET @FinalneSchvaleno=0
IF OBJECT_ID('dbo.epx_SDSchvalitNeschvalitDoklad05', 'P') IS NOT NULL
BEGIN
  EXEC dbo.epx_SDSchvalitNeschvalitDoklad05
    @Schvalit=@Schvalit,
    @TypDokladu=@TypDokladu,
    @IdDoklad=@IdDoklad,
    @Poznamka=@Poznamka,
    @FinalneSchvaleno=@FinalneSchvaleno,
    @TypHlasky=@TypHlasky OUT,
    @Hlaska=@Hlaska OUT
  IF (@TypHlasky IS NOT NULL)AND(@Hlaska IS NOT NULL)
    INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), @TypHlasky, @Hlaska)
END
GO

