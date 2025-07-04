USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAAWarrantView]    Script Date: 04.07.2025 10:30:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAAWarrantView]  --UPDATED 20141003
(IdSkupina, LoginName, ReadOnly, Warrant1, ReadOnly2)
AS
SELECT
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabFIADataParamPrava AS PX WHERE PX.IdFIADataParam=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
ISNULL(P.PravoAktualizace,(CASE WHEN EXISTS(SELECT * FROM TabFIADataParamPrava AS PX WHERE PX.IdFIADataParam=S.ID)
THEN (CASE WHEN ((SELECT TOP 1 RezimPrav FROM TabHGlob)= 0)
THEN(SELECT MAX(PX.PravoAktualizace)+(CASE MAX(PX.PravoAktualizace)WHEN 2 THEN 0 ELSE 1 END)FROM TabFIADataParamPrava AS PX WHERE PX.IdFIADataParam=S.ID)
ELSE 2 END) ELSE 0 END)),
NULL
FROM TabFIADataParam AS S
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabFIADataParamPrava AS P
ON S.ID = P.IdFIADataParam
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabFIADataParamPrava AS PX WHERE PX.IdFIADataParam = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
GO

