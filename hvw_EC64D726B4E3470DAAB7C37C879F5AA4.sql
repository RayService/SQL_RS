USE [RayService]
GO

/****** Object:  View [dbo].[hvw_EC64D726B4E3470DAAB7C37C879F5AA4]    Script Date: 03.07.2025 14:42:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_EC64D726B4E3470DAAB7C37C879F5AA4] AS 
SELECT
TabRoleUzivView.LoginName,ucfg.FullName,tr.JmenoRole,(SELECT MAX(Z.DatPorizeni)FROM dbo.TabZurnal AS Z WITH(NOLOCK)WHERE Z.Autor=ucfg.LoginName AND Z.Udalost=0) AS LastLogin
FROM TabRoleUzivView WITH(NOLOCK)
LEFT OUTER JOIN TabUserCfg ucfg WITH(NOLOCK) ON TabRoleUzivView.LoginName=ucfg.LoginName COLLATE database_default
LEFT OUTER JOIN TabRole tr WITH(NOLOCK) ON tr.ID=TabRoleUzivView.IDRole
WHERE (SELECT MAX(Z.DatPorizeni)FROM dbo.TabZurnal AS Z WITH(NOLOCK)WHERE Z.Autor=ucfg.LoginName AND Z.Udalost=0)>='20231101'
GO

