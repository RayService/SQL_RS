USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDKopiePredpis]    Script Date: 26.06.2025 10:10:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDKopiePredpis]
@IdZdroj INT
AS
SET NOCOUNT ON
DECLARE @IdKopie INT
IF (SELECT Kopie FROM Tabx_SDPredpisy WHERE ID=@IdZdroj)=1
RETURN
INSERT INTO Tabx_SDPredpisy(Kopie, TypDokladu, Nazev, Popis, StavSchvaleni, Skupina, Rezim)
SELECT Kopie, TypDokladu, N'K_' + Nazev, Popis, StavSchvaleni, Skupina, Rezim
FROM Tabx_SDPredpisy
WHERE ID=@IdZdroj
SET @IdKopie=SCOPE_IDENTITY()
INSERT INTO Tabx_SDPredpisVRoleVSchvalovatel(IdPredpis, IdSchvalovatel, IdRole, Uroven, VracetNaPrvniUroven)
SELECT @IdKopie, IdSchvalovatel, IdRole, Uroven, VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel
WHERE IdPredpis=@IdZdroj
SELECT @IdKopie
GO

