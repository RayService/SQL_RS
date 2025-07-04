USE [RayService]
GO

/****** Object:  View [dbo].[TabRoleUzivView]    Script Date: 04.07.2025 12:50:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabRoleUzivView] AS
SELECT LoginName, IDRole, CAST(1 AS BIT) AS HlavniRole FROM dbo.TabUziv
WHERE IDRole IS NOT NULL
UNION
SELECT LoginName, IDRole, CAST(0 AS BIT) AS HlavniRole
FROM dbo.TabRoleUziv ru
WHERE NOT EXISTS(SELECT*FROM TabUziv WHERE LoginName = ru.LoginName AND IDRole = ru.IDRole)
GO

