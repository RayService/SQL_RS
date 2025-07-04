USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDRoleVSchvalovatel]    Script Date: 04.07.2025 8:21:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDRoleVSchvalovatel] AS SELECT RS.ID, RS.IdRole, RS.IdSchvalovatel, S.LoginName AS LoginName, S.FullName AS FullName
FROM Tabx_SDRoleVSchvalovatel RS
LEFT OUTER JOIN hvw_SDSchvalovatele S ON S.ID = RS.IdSchvalovatel
GO

