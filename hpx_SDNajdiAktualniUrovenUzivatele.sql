USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDNajdiAktualniUrovenUzivatele]    Script Date: 30.06.2025 8:19:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDNajdiAktualniUrovenUzivatele]
@IdPredpis INT,
@AktualniUroven INT OUT,
@VracetNaPrvniUroven BIT OUT
AS
DECLARE @Rezim INT, @StavSchvaleni INT
SELECT @Rezim=Rezim, @StavSchvaleni=ISNULL(StavSchvaleni,0) FROM Tabx_SDPredpisy WHERE ID=@IdPredpis
IF @Rezim=0
BEGIN
SELECT TOP 1 @AktualniUroven = Uroven, @VracetNaPrvniUroven = VracetNaPrvniUroven
FROM
(
SELECT SCH.LoginName, PS.Uroven, ISNULL(PS.VracetNaPrvniUroven, 0) AS VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel PS
LEFT OUTER JOIN hvw_SDSchvalovatele SCH ON SCH.ID = PS.IdSchvalovatel
WHERE PS.IdPredpis = @IdPredpis
AND PS.IdSchvalovatel IS NOT NULL
AND PS.Uroven >= (SELECT TOP 1 ISNULL(StavSchvaleni, 0) FROM Tabx_SDPredpisy WHERE ID=@IdPredpis ORDER BY ID DESC)
AND ((SCH.LoginName = SUSER_SNAME())OR(SCH.LoginName IN(SELECT LoginName FROM dbo.hfx_SD_KohoZastupujePrihlasenyUzivatel(@IdPredpis))))
UNION
SELECT SCH.LoginName, PS.Uroven, ISNULL(PS.VracetNaPrvniUroven, 0) AS VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel PS
LEFT OUTER JOIN Tabx_SDRoleVSchvalovatel ROL ON ROL.IdRole = PS.IdRole
LEFT OUTER JOIN hvw_SDSchvalovatele SCH ON SCH.ID = ROL.IdSchvalovatel
WHERE PS.IdPredpis = @IdPredpis
AND PS.IdRole IS NOT NULL
AND PS.Uroven >= (SELECT TOP 1 ISNULL(StavSchvaleni, 0) FROM Tabx_SDPredpisy WHERE ID=@IdPredpis ORDER BY ID DESC)
AND ((SCH.LoginName = SUSER_SNAME())OR(SCH.LoginName IN(SELECT LoginName FROM dbo.hfx_SD_KohoZastupujePrihlasenyUzivatel(@IdPredpis))))
) X
ORDER BY Uroven DESC
END
IF @Rezim=1
BEGIN
SELECT TOP 1 @AktualniUroven = Uroven, @VracetNaPrvniUroven = VracetNaPrvniUroven
FROM
(
SELECT SCH.LoginName, PS.Uroven, ISNULL(PS.VracetNaPrvniUroven, 0) AS VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel PS
LEFT OUTER JOIN hvw_SDSchvalovatele SCH ON SCH.ID = PS.IdSchvalovatel
WHERE PS.IdPredpis = @IdPredpis
AND PS.IdSchvalovatel IS NOT NULL
AND PS.Uroven >= (SELECT TOP 1 ISNULL(StavSchvaleni, 0) FROM Tabx_SDPredpisy WHERE ID=@IdPredpis ORDER BY ID DESC)
AND ((SCH.LoginName = SUSER_SNAME())OR(SCH.LoginName IN(SELECT LoginName FROM dbo.hfx_SD_KohoZastupujePrihlasenyUzivatel(@IdPredpis))))
UNION
SELECT SCH.LoginName, PS.Uroven, ISNULL(PS.VracetNaPrvniUroven, 0) AS VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel PS
LEFT OUTER JOIN Tabx_SDRoleVSchvalovatel ROL ON ROL.IdRole = PS.IdRole
LEFT OUTER JOIN hvw_SDSchvalovatele SCH ON SCH.ID = ROL.IdSchvalovatel
WHERE PS.IdPredpis = @IdPredpis
AND PS.IdRole IS NOT NULL
AND PS.Uroven >= (SELECT TOP 1 ISNULL(StavSchvaleni, 0) FROM Tabx_SDPredpisy WHERE ID=@IdPredpis ORDER BY ID DESC)
AND ((SCH.LoginName = SUSER_SNAME())OR(SCH.LoginName IN(SELECT LoginName FROM dbo.hfx_SD_KohoZastupujePrihlasenyUzivatel(@IdPredpis))))
) X
WHERE Uroven>=ABS(@StavSchvaleni)
ORDER BY Uroven ASC
END
GO

