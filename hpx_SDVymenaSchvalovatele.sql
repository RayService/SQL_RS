USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDVymenaSchvalovatele]    Script Date: 26.06.2025 14:03:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDVymenaSchvalovatele]
@IdPuvodniSchvalovatel INT
, @IdNovySchvalovatel INT
, @VeVychozich BIT
, @VRolich BIT
, @VNezahajenych BIT
, @VZahajenych BIT
AS
SET NOCOUNT ON
IF @VRolich=1
UPDATE Tabx_SDRoleVSchvalovatel SET IdSchvalovatel=@IdNovySchvalovatel
WHERE IdSchvalovatel=@IdPuvodniSchvalovatel
IF @VeVychozich=1
UPDATE Tabx_SDPredpisVRoleVSchvalovatel SET
IdSchvalovatel=@IdNovySchvalovatel
WHERE IdSchvalovatel=@IdPuvodniSchvalovatel
AND IdPredpis IN(SELECT ID FROM Tabx_SDPredpisy WHERE ISNULL(Kopie, 0)=0)
IF @VNezahajenych=1
UPDATE Tabx_SDPredpisVRoleVSchvalovatel SET
IdSchvalovatel=@IdNovySchvalovatel
WHERE IdSchvalovatel=@IdPuvodniSchvalovatel
AND IdPredpis IN(SELECT ID FROM Tabx_SDPredpisy WHERE ISNULL(Kopie, 0)=1 AND StavSchvaleni IS NULL)
IF @VZahajenych=1
UPDATE Tabx_SDPredpisVRoleVSchvalovatel SET
IdSchvalovatel=@IdNovySchvalovatel
WHERE IdSchvalovatel=@IdPuvodniSchvalovatel
AND IdPredpis IN(SELECT ID FROM Tabx_SDPredpisy WHERE ISNULL(Kopie, 0)=1 AND ISNULL(StavSchvaleni, 0)<>9999)
GO

