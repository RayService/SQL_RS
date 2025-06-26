USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_CreateJSONRequestForADD_adr_content]    Script Date: 26.06.2025 14:31:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_CreateJSONRequestForADD_adr_content]
  @IdBalik INT
, @OrderNumber INT
AS
SET NOCOUNT ON
DECLARE @KodDopravce NVARCHAR(20)
SET @KodDopravce=(SELECT Z.KodDopravce FROM Tabx_BalikobotBaliky B JOIN Tabx_BalikobotZasilky Z ON Z.ID=B.IdZasilky WHERE B.ID=@IdBalik)
IF @KodDopravce=N'toptrans'
BEGIN
SELECT ADR_unit_pieces_count AS adr_pieces_count
, ADR_unit_id AS adr_un
, ADR_unit_weight AS adr_weight
, ADR_unit_volume AS adr_volume
FROM Tabx_BalikobotVBalikyADRKody
WHERE IdBalik=@IdBalik
END
IF @KodDopravce=N'fofr'
BEGIN
SELECT TOP 1
ADR_unit_id AS adr_un
FROM Tabx_BalikobotVBalikyADRKody
WHERE IdBalik=@IdBalik
END
IF @KodDopravce=N'raben'
BEGIN
SELECT ADR.ADR_unit_pieces_count AS adr_pieces_count
, ADR.ADR_unit_id AS adr_code
, ADR.ADR_unit_weight AS adr_weight
, ADR.ADR_unit_volume AS adr_volume
, ADR.ADR_manipulation_unit AS adr_manipulation_unit
FROM Tabx_BalikobotVBalikyADRKody ADR
JOIN Tabx_BalikobotBaliky BAL ON BAL.ID=ADR.IdBalik
WHERE BAL.ID=@IdBalik
END
IF @KodDopravce=N'dachser'
BEGIN
SELECT ADR.ADR_unit_pieces_count AS adr_pieces_count
, ADR.ADR_unit_id AS adr_code
, ADR.ADR_unit_weight AS adr_weight
, ADR.ADR_manipulation_unit AS adr_manipulation_unit
FROM Tabx_BalikobotVBalikyADRKody ADR
JOIN Tabx_BalikobotBaliky BAL ON BAL.ID=ADR.IdBalik
WHERE BAL.ID=@IdBalik
END
IF @KodDopravce=N'dsv'
BEGIN
SELECT ADR.ADR_unit_pieces_count AS adr_pieces_count
, ADR.ADR_unit_id AS adr_code
, ADR.ADR_unit_weight AS adr_weight
, ADR.ADR_unit_net_weight AS adr_net_weight
, ADR.ADR_manipulation_unit AS adr_manipulation_unit
FROM Tabx_BalikobotVBalikyADRKody ADR
JOIN Tabx_BalikobotBaliky BAL ON BAL.ID=ADR.IdBalik
WHERE BAL.ID=@IdBalik
END
IF @KodDopravce=N'dbschenker'
BEGIN
SELECT
ADR.adr_eu_waste_code
, ADR.adr_expected_quantities
, ADR.adr_label_type
, ADR.adr_limited_quantity
, ADR.adr_marine_pollutant
, ADR.adr_package_group
, ADR.adr_pieces_count
, ADR.adr_shipping_name
, ADR.adr_special_provision
, ADR.adr_technical_name
, ADR.adr_tunnel_code
, ADR.adr_waste
, ADR.adr_weight_type
, ADR.ADR_manipulation_unit AS adr_manipulation_unit
, ADR.ADR_unit_id AS adr_code
, ADR.ADR_unit_weight AS adr_weight
FROM Tabx_BalikobotVBalikyADRKody ADR
JOIN Tabx_BalikobotBaliky BAL ON BAL.ID=ADR.IdBalik
WHERE BAL.ID=@IdBalik
END
IF @KodDopravce=N'dhl'
BEGIN
SELECT
  ADRUnits.unit_code AS adr_code
, ADR.ADR_unit_weight AS adr_weight
, ADR.ADR_shipping_name AS adr_shipping_name
, ADR.ADR_unit_volume AS adr_volume
FROM Tabx_BalikobotVBalikyADRKody ADR
JOIN Tabx_BalikobotADRJednotky ADRUnits ON ADRUnits.KodDopravce=ADR.KodDopravce AND ADRUnits.unit_id=ADR.ADR_unit_id
WHERE ADR.IdBalik=@IdBalik
END
IF @KodDopravce=N'dhlfreightec'
BEGIN
SELECT
  ADR.ADR_unit_id AS adr_code
, ADR.ADR_unit_weight AS adr_weight
, ADR.adr_pieces_count
, ADR.adr_description
, ADR.adr_quantity
, ADR.adr_package_group
, ADR.adr_limited_quantity
, ADR.adr_exempted_quantity
, ADR.adr_is_empty
, ADR.adr_environmental_indicator
, ADR.ADR_manipulation_unit AS adr_manipulation_unit
FROM Tabx_BalikobotVBalikyADRKody ADR
WHERE ADR.IdBalik=@IdBalik
END
GO

