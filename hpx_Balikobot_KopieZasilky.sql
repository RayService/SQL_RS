USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_KopieZasilky]    Script Date: 26.06.2025 14:36:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_KopieZasilky]
@IdZasilky INT
AS
SET NOCOUNT ON
DECLARE @IdZasilkaKopie INT, @WhereSysSourceTab NVARCHAR(100), @PoradoveCisloNEW NVARCHAR(100), @IdBalik INT, @IdZasilkaKopieNVCHR NVARCHAR(100)
SET @WhereSysSourceTab=N'ID=' + CAST(@IdZasilky AS NVARCHAR)
SET @PoradoveCisloNEW=CAST((SELECT MAX(PoradoveCislo)+1 FROM Tabx_BalikobotZasilky) AS NVARCHAR)
IF @PoradoveCisloNEW IS NULL
SET @PoradoveCisloNEW=N'1'
EXEC dbo.hpx_Balikobot_CopyRecord
@TabName='Tabx_BalikobotZasilky'
, @WhereSysSourceTab=@WhereSysSourceTab
, @IgnoreAtrList=N'Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru,IdDokladyZbozi,IdDOBJ,StitekVytisknut,labels_url,handover_url,file_url,DatumTiskuArchu,order_id,'
, @ReplaceAtr1=N'[PoradoveCislo]'
, @ReplaceValue1=@PoradoveCisloNEW
, @IDTargetRecord=@IdZasilkaKopie OUTPUT
IF @IdZasilkaKopie IS NULL
RETURN
SET @IdZasilkaKopieNVCHR=CAST(@IdZasilkaKopie AS NVARCHAR)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID FROM Tabx_BalikobotBaliky WHERE IdZasilky=@IdZasilky ORDER BY OrderNumber ASC
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @IdBalik
IF @@fetch_status<>0 BREAK
SET @WhereSysSourceTab=N'ID=' + CAST(@IdBalik AS NVARCHAR)
EXEC dbo.hpx_Balikobot_CopyRecord
@TabName='Tabx_BalikobotBaliky'
, @WhereSysSourceTab=@WhereSysSourceTab
, @IgnoreAtrList=N'GUID,Stav,carrier_id,package_id,Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru,label_url,file_url,carrier_id_final,track_url_final,StitekVytisknut,TrackStatusCode,TrackStatusText,TrackLink,DatumPredaniDat,DatumTiskuStitku,'
, @ReplaceAtr1=N'[IdZasilky]'
, @ReplaceValue1=@IdZasilkaKopieNVCHR
END
DEALLOCATE c
DECLARE @PrvniBalikKopie INT
SET @PrvniBalikKopie=(SELECT ID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilkaKopie)
SET @IdBalik=(SELECT ID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)
INSERT Tabx_BalikobotVBalikyADRKody(IdBalik, ADR_unit_id, ADR_unit_pieces_count, ADR_unit_weight, ADR_unit_volume, ADR_manipulation_unit, ADR_unit_net_weight,
                                    adr_eu_waste_code, adr_expected_quantities, adr_label_type, adr_limited_quantity, adr_marine_pollutant,
                                    adr_package_group, adr_pieces_count, adr_shipping_name, adr_special_provision, adr_technical_name,
                                    adr_tunnel_code, adr_waste, adr_weight_type,
                                    adr_description, adr_quantity, adr_exempted_quantity, adr_is_empty, adr_environmental_indicator)
SELECT @PrvniBalikKopie, ADR_unit_id, ADR_unit_pieces_count, ADR_unit_weight, ADR_unit_volume, ADR_manipulation_unit, ADR_unit_net_weight,
       adr_eu_waste_code, adr_expected_quantities, adr_label_type, adr_limited_quantity, adr_marine_pollutant,
       adr_package_group, adr_pieces_count, adr_shipping_name, adr_special_provision, adr_technical_name,
       adr_tunnel_code, adr_waste, adr_weight_type,
       adr_description, adr_quantity, adr_exempted_quantity, adr_is_empty, adr_environmental_indicator
FROM Tabx_BalikobotVBalikyADRKody
WHERE IdBalik=@IdBalik
SELECT @IdZasilkaKopie
GO

