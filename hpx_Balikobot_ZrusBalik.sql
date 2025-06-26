USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_ZrusBalik]    Script Date: 26.06.2025 15:08:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_ZrusBalik]
@IdBaliku INT
AS
SET NOCOUNT ON
DECLARE @IdZasilky INT
UPDATE Tabx_BalikobotBaliky SET
GUID=CONVERT(uniqueidentifier, NEWID()),
Stav=0,
package_id=NULL,
carrier_id=NULL,
label_url=NULL
WHERE ID=@IdBaliku
SET @IdZasilky=(SELECT IdZasilky FROM Tabx_BalikobotBaliky WHERE ID=@IdBaliku)
IF (SELECT KodDopravce FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky) IN('dhl', 'sps', 'japo')
UPDATE Tabx_BalikobotBaliky SET
GUID=(SELECT GUID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky),
Stav=0,
package_id=NULL,
carrier_id=NULL,
label_url=NULL
WHERE IdZasilky=@IdZasilky AND OrderNumber>1
ELSE
UPDATE Tabx_BalikobotBaliky SET
GUID=(SELECT GUID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)
WHERE IdZasilky=@IdZasilky AND OrderNumber>1
GO

