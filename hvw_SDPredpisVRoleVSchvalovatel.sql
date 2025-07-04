USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDPredpisVRoleVSchvalovatel]    Script Date: 04.07.2025 8:17:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDPredpisVRoleVSchvalovatel] AS SELECT PRS.ID AS ID,
PRS.IdPredpis AS IdPredpis,
PRS.IdSchvalovatel AS IdSchvalovatel,
PRS.IdRole AS IdRole,
PRS.Uroven AS Uroven,
S.LoginName AS LoginName,
S.FullName AS FullName,
R.Role AS Role,
PRS.VracetNaPrvniUroven AS VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel PRS
LEFT OUTER JOIN hvw_SDSchvalovatele S ON S.ID = PRS.IdSchvalovatel
LEFT OUTER JOIN Tabx_SDRole R ON R.ID = PRS.IdRole
GO

