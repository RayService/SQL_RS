USE [RayService]
GO

/****** Object:  View [dbo].[TabBankSpSchvOsobyView]    Script Date: 04.07.2025 9:44:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabBankSpSchvOsobyView] AS
SELECT ID, LoginName, CAST(FullName AS NVARCHAR(128)) AS FullName, CAST(email AS NVARCHAR(255)) AS Email, CAST(LEFT(LEFT(ListSkupin, Len(ListSkupin)-1),255) AS NVARCHAR(255)) AS Skupiny FROM
(SELECT i.id,i.LoginName,i.FullName,i.email, (SELECT b.JmenoRole + ', ' AS 'data()'
FROM (SELECT r.JmenoRole, u.LoginName FROM TabRole r Join TabRoleUziv u ON r.ID=u.IDRole JOIN TabUziv a ON a.LoginName=u.LoginName collate database_default
UNION
SELECT p.JmenoRole, q.LoginName FROM TabRole p JOIN TabUziv q ON q.IDRole=p.ID) b
WHERE b.LoginName=i.LoginName COLLATE database_default
FOR XML PATH('')) AS ListSkupin FROM
(SELECT u.ID,u.LoginName, N'' AS FullName, N'' AS Email FROM TabUziv u
JOIN TabBankSpSchvOsoby o ON o.Typ=2 AND o.IDUziv=u.ID
UNION
SELECT u.ID,u.LoginName, N'' AS Fullname, N'' AS Email FROM TabUziv u
JOIN TabRoleUziv r ON r.LoginName=u.LoginName collate database_default JOIN TabBankSpSchvOsoby o ON o.Typ=1 AND o.IDRole=u.ID
) i) j
GO

