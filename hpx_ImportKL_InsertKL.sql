USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ImportKL_InsertKL]    Script Date: 26.06.2025 8:42:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpImportKL.ImportKL*/CREATE PROC [dbo].[hpx_ImportKL_InsertKL]
@Cislo INT,
@Mena NVARCHAR(3),
@Kurz NUMERIC(19,6),
@JednotkaMeny INT,
@Datum DATETIME,
@ZpusobVzniku TINYINT
AS
BEGIN
BEGIN TRAN
BEGIN TRY
IF EXISTS (SELECT 0 FROM TabKodMen WHERE Kod = @Mena)
BEGIN
IF @ZpusobVzniku = 1 -- Kobler
BEGIN
UPDATE TabKurzList SET
CelniKurz = @Kurz,
Popis = 'Dotažen i celní kurz'
WHERE Mena = @Mena AND YEAR(Datum) = YEAR(@Datum) AND MONTH(Datum) = MONTH(@Datum) AND ISNULL(Popis, '') = '' AND ZpusobVzniku = 2 -- ČNB
END
ELSE
BEGIN
IF NOT EXISTS (SELECT 0 FROM TabKurzList WHERE Mena = @Mena AND Datum = @Datum AND ZpusobVzniku = @ZpusobVzniku)
INSERT INTO TabKurzList (Mena, Kurz, CelniKurz, Datum, Cislo, JednotkaMeny, ZpusobVzniku)
VALUES (@Mena, @Kurz, @Kurz, @Datum, @Cislo, @JednotkaMeny, @ZpusobVzniku)
ELSE
BEGIN
UPDATE TabKurzList SET
Kurz = @Kurz,
JednotkaMeny = @JednotkaMeny
WHERE Mena = @Mena AND Datum = @Datum AND ZpusobVzniku = @ZpusobVzniku
UPDATE TabKurzList SET
CelniKurz = @Kurz
WHERE Mena = @Mena AND Datum = @Datum AND ZpusobVzniku = @ZpusobVzniku AND ISNULL(Popis, '') = ''
END
END
END
END TRY
BEGIN CATCH
DECLARE @Err NVARCHAR(400)
SET @Err = (SELECT ERROR_MESSAGE())
IF @@TRANCOUNT > 0
BEGIN
ROLLBACK TRAN
RAISERROR(@Err, 16, 1)
END
END CATCH
IF @@TRANCOUNT > 0
BEGIN
COMMIT TRAN
END
END
GO

