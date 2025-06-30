USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AktualizaceMaticeRoliProcesu]    Script Date: 30.06.2025 8:56:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_AktualizaceMaticeRoliProcesu]
AS
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#TabUsers') IS NOT NULL DROP TABLE #TabUsers
CREATE TABLE #TabUsers (ID INT IDENTITY(1,1) NOT NULL, LoginName NVARCHAR(128) NOT NULL, FullName NVARCHAR(255) NULL, JmenoRole NVARCHAR(255) NULL, IDZam INT NULL, Pristup BIT NULL)

IF OBJECT_ID(N'tempdb..#TabDBUzivSys','U') IS NULL
SELECT DISTINCT X.LoginName,
CAST(CASE WHEN IS_SRVROLEMEMBER(N'sysadmin', X.LoginName)=1 THEN 1
ELSE 0 END AS BIT) AS RoleMember,
DATEADD(hh, 1, GETDATE()) AS Platnost
INTO #TabDBUzivSys
FROM [RayService]..TabUserCfg X LEFT JOIN sysusers ON X.LoginName=SUSER_SNAME(sysusers.sid)

IF OBJECT_ID(N'tempdb..#TabDBUzivatele','U') IS NOT NULL DROP TABLE #TabDBUzivatele
DECLARE @IDowner INT, @IDdatareader INT
SET @IDowner=(SELECT principal_id FROM sys.database_principals WHERE name=N'db_owner')
SET @IDdatareader=(SELECT principal_id FROM sys.database_principals WHERE name=N'db_datareader')
SELECT X.LoginName,
CAST(CASE WHEN S.RoleMember=1 THEN 1
WHEN SUSER_SID(X.LoginName) IS NOT NULL AND EXISTS(SELECT * FROM sys.database_role_members AS m WHERE USER_NAME(m.member_principal_id)=(SELECT name FROM dbo.sysusers WHERE sid=SUSER_SID(X.LoginName)) AND m.role_principal_id IN (@IDowner,@IDdatareader))THEN 1
ELSE 0 END AS BIT)AS Pristup,
CAST(CASE WHEN EXISTS(SELECT*FROM sys.database_principals WHERE name COLLATE database_default = X.LoginName COLLATE database_default) THEN 1 ELSE 0 END AS BIT) AS JeLoginVDatabazi,
CAST(CASE WHEN SUSER_SID(X.LoginName) IS NOT NULL AND EXISTS(SELECT * FROM dbo.sysusers WHERE name=N'dbo' AND sid=SUSER_SID(X.LoginName)) THEN 1 ELSE 0 END AS BIT) AS UserDbo
INTO #TabDBUzivatele
FROM [RayService]..TabUserCfg AS X
LEFT JOIN #TabDBUzivSys AS S ON S.LoginName COLLATE database_default = X.LoginName COLLATE database_default

INSERT INTO #TabUsers (LoginName, FullName, JmenoRole, IDZam, Pristup)
SELECT
uv.LoginName,ucfg.FullName,tr.JmenoRole,tcz.ID, tu.Pristup
--,(SELECT MAX(Z.DatPorizeni)FROM dbo.TabZurnal AS Z WITH(NOLOCK)WHERE Z.Autor=ucfg.LoginName AND Z.Udalost=0) AS LastLogin
FROM TabRoleUzivView uv
LEFT OUTER JOIN TabUserCfg ucfg ON uv.LoginName=ucfg.LoginName COLLATE database_default
LEFT OUTER JOIN TabRole tr ON tr.ID=uv.IDRole
LEFT OUTER JOIN TabCisZam tcz ON tcz.LoginId=uv.LoginName
LEFT OUTER JOIN #TabDBUzivatele tu ON tu.LoginName=uv.LoginName
WHERE (SELECT MAX(Z.DatPorizeni)FROM dbo.TabZurnal AS Z WITH(NOLOCK)WHERE Z.Autor=ucfg.LoginName AND Z.Udalost=0)>='20231101'
ORDER BY tr.JmenoRole ASC, uv.LoginName ASC

SELECT *
FROM #TabUsers
WHERE IDZam IS NOT NULL
ORDER BY LoginName ASC

MERGE Tabx_RS_MaticeRoleProcesy AS TARGET
USING #TabUsers AS SOURCE
ON TARGET.LoginName=SOURCE.LoginName AND SOURCE.IDZam IS NOT NULL
WHEN MATCHED THEN UPDATE
SET TARGET.Role=SOURCE.JmenoRole, TARGET.Active=SOURCe.Pristup, TARGET.Zmenil=SUSER_SNAME(), TARGET.DatZmeny=GETDATE()
WHEN NOT MATCHED BY TARGET THEN
INSERT (LoginName, FullName, Role, IDZam, Active)
VALUES (LoginName, FUllName, JmenoRole, IDZam, 1)
;

DELETE FROM Tabx_RS_MaticeRoleProcesy WHERE IDZam IS NULL
GO

