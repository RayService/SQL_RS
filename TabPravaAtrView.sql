USE [RayService]
GO

/****** Object:  View [dbo].[TabPravaAtrView]    Script Date: 04.07.2025 12:37:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPravaAtrView] AS
WITH RoleUziv_CTE(LoginName, IDRole, HlavniRole)
AS
(
SELECT LoginName, IDRole, CAST(1 AS BIT) AS HlavniRole FROM dbo.TabUziv
WHERE IDRole IS NOT NULL
UNION
SELECT LoginName, IDRole, CAST(0 AS BIT) AS HlavniRole
FROM dbo.TabRoleUziv ru
WHERE NOT EXISTS(SELECT*FROM TabUziv WHERE LoginName = ru.LoginName AND IDRole = ru.IDRole)
)
SELECT T.NazevTabulkySys, T.NazevAtrSys
FROM TabPravaAtr T
WHERE T.LoginName = SUSER_SNAME()
UNION
SELECT T.NazevTabulkySys, T.NazevAtrSys
FROM TabPravaAtr T
JOIN RoleUziv_CTE r ON r.IDRole = T.IDRole
WHERE r.LoginName = SUSER_SNAME()
GROUP BY T.NazevTabulkySys, T.NazevAtrSys
HAVING COUNT(*) = (SELECT COUNT(*) FROM (SELECT DISTINCT IDRole FROM RoleUziv_CTE WHERE LoginName = SUSER_SNAME()) x)
GO

