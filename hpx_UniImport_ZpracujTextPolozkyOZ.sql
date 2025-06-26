USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImport_ZpracujTextPolozkyOZ]    Script Date: 26.06.2025 10:15:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImport_ZpracujTextPolozkyOZ]
@VstupniCena INT,
@IDDoklad INT,
@Mnozstvi NUMERIC(19,6),
@Cena NUMERIC(19,6),
@SazbaDPHPol NUMERIC(9,2),
@MJ NVARCHAR(10),
@IDPolozky INT,
@Popis NVARCHAR(100),
@JePDP BIT = 0,
@StredNaklad NVARCHAR(30) = NULL,
@CisloUcet NVARCHAR(30) = NULL,
@Vozidlo NVARCHAR(20) = NULL,
@CisloZakazky NVARCHAR(15) = NULL,
@NOkruh NVARCHAR(15) = NULL,
@CisloZam INT = NULL,
@IdDanovyKlic INT = NULL,
@RucniDPHPovoleno BIT = 0,
@DPHZadanaRucne NUMERIC(19,6) = NULL,
@IdTxtPolozka INT OUT,
@DotahovatSazby BIT = 1,
@TypSlevy TINYINT = 0,
@Sleva NUMERIC(19,6) = 0,
@PomerKoef NUMERIC(19,6) = NULL,
@IDKodPDP INT = NULL
AS
DECLARE @PopisTxtPol NVARCHAR(MAX)
EXEC dbo.hp_InsertTxtPolozkyOZ
  @IDPolozky=@IdTxtPolozka OUT,
  @IDDoklad=@IDDoklad,
  @VstupniCena=@VstupniCena,
  @Cena=@Cena,
  @Popis=@Popis,
  @SazbaDPH=@SazbaDPHPol,
  @ZakazanoDPH = 0,
  @Mnozstvi=@Mnozstvi,
  @MJ = @MJ,
  @TypSlevy = @TypSlevy,
  @Sleva = @Sleva,
  @ZadaneDPH = NULL,
  @JePDP = @JePDP,
  @StredNaklad = @StredNaklad,
  @CisloUcet = @CisloUcet,
  @Vozidlo = @Vozidlo,
  @CisloZakazky = @CisloZakazky,
  @NOkruh = @NOkruh,
  @CisloZam = @CisloZam,
  @DotahovatSazby = @DotahovatSazby,
  @IDKodPDP = @IDKodPDP
IF @IdDanovyKlic IS NOT NULL
  UPDATE TabOZTxtPol SET IdDanovyKlic=@IdDanovyKlic WHERE ID=@IdTxtPolozka
IF (@DPHZadanaRucne IS NOT NULL)AND(@RucniDPHPovoleno=1)
BEGIN
IF @VstupniCena=0 UPDATE TabOZTxtPol SET JCZadaneDPHKc =@DPHZadanaRucne WHERE ID=@IdTxtPolozka
IF @VstupniCena=2 UPDATE TabOZTxtPol SET CCZadaneDPHKc =@DPHZadanaRucne WHERE ID=@IdTxtPolozka
IF @VstupniCena=4 UPDATE TabOZTxtPol SET JCZadaneDPHVal=@DPHZadanaRucne WHERE ID=@IdTxtPolozka
IF @VstupniCena=6 UPDATE TabOZTxtPol SET CCZadaneDPHVal=@DPHZadanaRucne WHERE ID=@IdTxtPolozka
END
UPDATE TabOZTxtPol SET Poznamka=dbo.TabUniImportOZ.PoznamkaPol
FROM TabUniImportOZ
WHERE TabOZTxtPol.ID=@IdTxtPolozka AND TabUniImportOZ.ID=@IDPolozky
SET @PopisTxtPol=(SELECT PopisTxtPol FROM TabUniImportOZ WHERE ID=@IDPolozky)
IF @PopisTxtPol IS NOT NULL
  UPDATE TabOZTxtPol SET Popis=@PopisTxtPol WHERE ID=@IdTxtPolozka
UPDATE TabOZTxtPol SET PomerKoef=@PomerKoef WHERE ID=@IdTxtPolozka
GO

