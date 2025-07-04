USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDSchvalovatele]    Script Date: 04.07.2025 8:22:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDSchvalovatele] AS SELECT TabUserCfg.ID, TabUserCfg.LoginName, TabUserCfg.FullName, TabUserCfg.Email,
       (SELECT TOP 1 R.Role
        FROM Tabx_SDRoleVSchvalovatel RS
        LEFT OUTER JOIN Tabx_SDRole R ON R.ID = RS.IdRole
        WHERE RS.IdSchvalovatel = TabUserCfg.ID
        ) AS Role,
       TabUserCfg.Aktivni, TabUserCfg.JeLoginNaSQLServeru, TabUserCfg.JeSysAdmin
FROM RayService..TabUserCfg TabUserCfg
GO

