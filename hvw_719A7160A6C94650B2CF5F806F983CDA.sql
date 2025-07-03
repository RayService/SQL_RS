USE [RayService]
GO

/****** Object:  View [dbo].[hvw_719A7160A6C94650B2CF5F806F983CDA]    Script Date: 03.07.2025 11:19:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_719A7160A6C94650B2CF5F806F983CDA] AS SELECT
tuc.ID,tuc.LoginName,tuc.FullName,tr.JmenoRole,tuc.Aktivni
FROM RayService..TabUserCfg tuc WITH(NOLOCK)
LEFT OUTER JOIN TabRole tr WITH(NOLOCK) ON tr.ID=(SELECT TabUziv.IDRole FROM TabUziv WITH(NOLOCK) WHERE TabUziv.LoginName=tuc.LoginName COLLATE database_default)
GO

