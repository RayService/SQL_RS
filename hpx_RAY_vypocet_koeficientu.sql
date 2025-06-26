USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_vypocet_koeficientu]    Script Date: 26.06.2025 10:05:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_vypocet_koeficientu] @ID INT

AS

DECLARE @Result_koef_uziv NUMERIC(20,6)
DECLARE @ID_Param INT
DECLARE @Vyhodnoceni TINYINT
DECLARE @Vyhodnoceni24 TINYINT
DECLARE @Vyporadani_premioveho_koef NUMERIC(19,6)
DECLARE @Premiovy_koef_od NUMERIC(19,6)
DECLARE @Premiovy_koef_do NUMERIC(19,6)
DECLARE @Koef_1_od NUMERIC(19,6)
DECLARE @Koef_1_do NUMERIC(19,6)
DECLARE @Koef_08_od NUMERIC(19,6)
DECLARE @Koef_08_do NUMERIC(19,6)
DECLARE @Koef_06_od NUMERIC(19,6)
DECLARE @Koef_06_do NUMERIC(19,6)
DECLARE @Koef_0_od NUMERIC(19,6)
DECLARE @Koef_0_do NUMERIC(19,6)
DECLARE @Mesic_value numeric(19, 6)
DECLARE @Kumulativ_value numeric(19, 6)
DECLARE @Result_koef_calc NUMERIC(19,6)

SELECT @ID_Param = ID_Param FROM RAY_Parametry_Values WHERE ID = @ID
SELECT @Vyhodnoceni = Vyhodnoceni FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param 
SELECT @Vyporadani_premioveho_koef = Vyporadani_premioveho_koef FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Premiovy_koef_od = Premiovy_koef_od FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Premiovy_koef_do = Premiovy_koef_do FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_1_od = Koef_1_od FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_1_do = Koef_1_do FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_08_od = Koef_08_od FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_08_do = Koef_08_do FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_06_od = Koef_06_od FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_06_do = Koef_06_do FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_0_od = Koef_0_od FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Koef_0_do = Koef_0_do FROM RAY_Parametry_Definice WHERE RAY_Parametry_Definice.ID = @ID_Param
SELECT @Mesic_value = Mesic_value FROM RAY_Parametry_Values WHERE ID = @ID
SELECT @Kumulativ_value = Kumulativ_value FROM RAY_Parametry_Values WHERE ID = @ID

--měsíční hodnota--
--prémiový koef--
IF @Vyhodnoceni = 0 AND @Mesic_value BETWEEN @Premiovy_koef_od AND @Premiovy_koef_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = @Vyporadani_premioveho_koef, Result_koef_calc = @Vyporadani_premioveho_koef
WHERE ID = @ID
END
--koef 1--
IF @Vyhodnoceni = 0 AND @Mesic_value BETWEEN @Koef_1_od AND @Koef_1_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 1, Result_koef_calc = 1
WHERE ID = @ID
END
--koef 0,8--
IF @Vyhodnoceni = 0 AND @Mesic_value BETWEEN @Koef_08_od AND @Koef_08_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.8, Result_koef_calc = 0.8
WHERE ID = @ID
END
--koef 0,6--
IF @Vyhodnoceni = 0 AND @Mesic_value BETWEEN @Koef_06_od AND @Koef_06_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.6, Result_koef_calc = 0.6
WHERE ID = @ID
END
--koef 0--
IF @Vyhodnoceni = 0 AND @Mesic_value BETWEEN @Koef_0_od AND @Koef_0_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0, Result_koef_calc = 0
WHERE ID = @ID
END

--kumulativní hodnota--
--prémiový koef--
IF @Vyhodnoceni = 1 AND @Kumulativ_value BETWEEN @Premiovy_koef_od AND @Premiovy_koef_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = @Vyporadani_premioveho_koef, Result_koef_calc = @Vyporadani_premioveho_koef
WHERE ID = @ID
END
--koef 1--
IF @Vyhodnoceni = 1 AND @Kumulativ_value BETWEEN @Koef_1_od AND @Koef_1_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 1, Result_koef_calc = 1
WHERE ID = @ID
END
--koef 0,8--
IF @Vyhodnoceni = 1 AND @Kumulativ_value BETWEEN @Koef_08_od AND @Koef_08_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.8, Result_koef_calc = 0.8
WHERE ID = @ID
END
--koef 0,6--
IF @Vyhodnoceni = 1 AND @Kumulativ_value BETWEEN @Koef_06_od AND @Koef_06_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.6, Result_koef_calc = 0.6
WHERE ID = @ID
END
--koef 0--
IF @Vyhodnoceni = 1 AND @Kumulativ_value BETWEEN @Koef_0_od AND @Koef_0_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0, Result_koef_calc = 0
WHERE ID = @ID
END

--parametr 24,135,136,137,138 překryv rozsahu--
--měsíční hodnota--
--prémiový koef--
IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value  BETWEEN @Premiovy_koef_od AND @Premiovy_koef_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = @Vyporadani_premioveho_koef, Result_koef_calc = @Vyporadani_premioveho_koef
WHERE ID = @ID
END
--koef 1--
IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value BETWEEN @Koef_1_od AND @Premiovy_koef_od
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 1, Result_koef_calc = 1
WHERE ID = @ID
END

IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value BETWEEN @Premiovy_koef_do AND @Koef_1_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 1, Result_koef_calc = 1
WHERE ID = @ID
END
--koef 0,8--
IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value BETWEEN @Koef_08_od AND @Koef_1_od
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.8, Result_koef_calc = 0.8
WHERE ID = @ID
END

IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value BETWEEN @Koef_1_do AND @Koef_08_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.8, Result_koef_calc = 0.8
WHERE ID = @ID
END

--koef 0,6--
IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value BETWEEN @Koef_06_od AND @Koef_08_od
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.6, Result_koef_calc = 0.6
WHERE ID = @ID
END

IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value BETWEEN @Koef_08_do AND @Koef_06_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0.6, Result_koef_calc = 0.6
WHERE ID = @ID
END

--koef 0--
IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value > @Koef_0_od
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0, Result_koef_calc = 0
WHERE ID = @ID
END

IF @ID_Param IN (24,135,136,137,138) AND @Mesic_value < @Koef_0_do
BEGIN
UPDATE RAY_Parametry_Values SET Result_koef_uziv = 0, Result_koef_calc = 0
WHERE ID = @ID
END
GO

