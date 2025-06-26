USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_RS_PlneniUkolu_Novy]    Script Date: 26.06.2025 15:15:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_RS_PlneniUkolu_Novy]
@CisloZam INT,
@DatumProvedeni DATETIME,
@DobaProvedeni NUMERIC(19,6),
@Poznamka NVARCHAR(250),
@ID INT
AS
BEGIN
DECLARE @Cislo INT
SET @Cislo = (SELECT ISNULL(MAX(Cislo),0)+1 FROM TabDosleObjH20 WHERE Cislo BETWEEN 1 AND 999999 AND IDUkol = @ID)

/*INSERT INTO TabDosleObjH20 (IDUkol,CisloZam, DatumProvedeni, DobaProvedeni, Poznamka)
VALUES
(@ID,@CisloZam, @DatumProvedeni, @DobaProvedeni, @Poznamka)
*/

INSERT INTO RayService..TabDosleObjH20
(IDUkol, Cislo, CisloZam, PolPoziceZaokrDPH, PolHraniceZaokrDPH, ZaokrDPHvaluty, ZaokrDPHMalaCisla, KoeficientDPH, Fakturace, VMeneHonorare,DatumProvedeni, DobaProvedeni, Poznamka)
VALUES
(@ID,@Cislo,@CisloZam,2,2,0,0,1,0,0, @DatumProvedeni, @DobaProvedeni, @Poznamka)
END;

--zápis data zahájení
DECLARE @DatumZahajeni DATETIME
SET @DatumZahajeni=(SELECT DatumZahajeni FROM RayService..TabUkoly WHERE ID=@ID)
IF @DatumZahajeni IS NULL
BEGIN
UPDATE RayService..TabUkoly SET DatumZahajeni=GETDATE() WHERE ID=@ID
END;
GO

