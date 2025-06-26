USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_editace_operace]    Script Date: 26.06.2025 13:23:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_editace_operace]
@Plan_ukonceni DATETIME,
@_OdpOsOp NVARCHAR(20),
@_EXT_B2ADIMARS_IdAssignedEmployee INT,
@ID INT
AS
BEGIN
IF @Plan_ukonceni <> ''
UPDATE TabPrPostup SET Plan_ukonceni = @Plan_ukonceni WHERE ID = @ID
END
BEGIN
IF @_OdpOsOp <> ''
UPDATE TabPrPostup_EXT SET _OdpOsOp = @_OdpOsOp WHERE ID = @ID
END
BEGIN
IF @_EXT_B2ADIMARS_IdAssignedEmployee <> ''
UPDATE TabPrPostup_EXT SET _EXT_B2ADIMARS_IdAssignedEmployee = @_EXT_B2ADIMARS_IdAssignedEmployee WHERE ID = @ID
END
GO

