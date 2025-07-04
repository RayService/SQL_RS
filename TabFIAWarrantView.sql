USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAWarrantView]    Script Date: 04.07.2025 10:48:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAWarrantView]  --UPDATED 20121130
(TableNr, IdSkupina, LoginName, ReadOnly, Warrant1, ReadOnly2)
AS
SELECT 1, 
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabFIAPreuctovaniReziiSkupinaPrava AS PX WHERE PX.IdPreuctovaniReziiSkupina=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
ISNULL(P.PravoAktualizace,(CASE WHEN EXISTS(SELECT * FROM TabFIAPreuctovaniReziiSkupinaPrava AS PX WHERE PX.IdPreuctovaniReziiSkupina=S.ID)
THEN (CASE WHEN ((SELECT TOP 1 RezimPrav FROM TabHGlob)= 0)
THEN(SELECT MAX(PX.PravoAktualizace)+(CASE MAX(PX.PravoAktualizace)WHEN 2 THEN 0 ELSE 1 END)FROM TabFIAPreuctovaniReziiSkupinaPrava AS PX WHERE PX.IdPreuctovaniReziiSkupina=S.ID)
ELSE 2 END) ELSE 0 END)),
NULL
FROM TabFIAPreuctovaniReziiSkupina AS S
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabFIAPreuctovaniReziiSkupinaPrava AS P
ON S.ID = P.IdPreuctovaniReziiSkupina
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabFIAPreuctovaniReziiSkupinaPrava AS PX WHERE PX.IdPreuctovaniReziiSkupina = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
UNION ALL
SELECT 2,
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabFIAASkupinaVykazuPrava AS PX WHERE PX.IdSkupina=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
ISNULL(P.PravoAktualizace,(CASE WHEN EXISTS(SELECT * FROM TabFIAASkupinaVykazuPrava AS PX WHERE PX.IdSkupina=S.ID)
THEN (CASE WHEN ((SELECT TOP 1 RezimPrav FROM TabHGlob)= 0)
THEN(SELECT MAX(PX.PravoAktualizace)+(CASE MAX(PX.PravoAktualizace)WHEN 2 THEN 0 ELSE 1 END)FROM TabFIAASkupinaVykazuPrava AS PX WHERE PX.IdSkupina=S.ID)
ELSE 2 END) ELSE 0 END)),
ISNULL(P.ReadOnly2,
CASE WHEN EXISTS(SELECT * FROM TabFIAASkupinaVykazuPrava AS PX WHERE PX.IdSkupina=S.ID AND PX.ReadOnly2=0)
THEN 1 ELSE 0 END)
FROM TabFIAAVykazSkupina AS S
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabFIAASkupinaVykazuPrava AS P
ON S.ID = P.IdSkupina
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabFIAASkupinaVykazuPrava AS PX WHERE PX.IdSkupina = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
UNION ALL
SELECT 3,
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabFIABReportPrava AS PX WHERE PX.IdSkupina=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
ISNULL(P.PravoAktualizace,(CASE WHEN EXISTS(SELECT * FROM TabFIABReportPrava AS PX WHERE PX.IdSkupina=S.ID)
THEN (CASE WHEN ((SELECT TOP 1 RezimPrav FROM TabHGlob)= 0)
THEN(SELECT MAX(PX.PravoAktualizace)+(CASE MAX(PX.PravoAktualizace)WHEN 2 THEN 0 ELSE 1 END)FROM TabFIABReportPrava AS PX WHERE PX.IdSkupina=S.ID)
ELSE 2 END) ELSE 0 END)),
NULL
FROM TabFIABReport AS S  
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabFIABReportPrava AS P
ON S.ID = P.IdSkupina
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabFIABReportPrava AS PX WHERE PX.IdSkupina = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
UNION ALL
SELECT 4,
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabSTDLeaSkupinaPrava AS PX WHERE PX.IdSkupina=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
ISNULL(P.PravoAktualizace,(CASE WHEN EXISTS(SELECT * FROM TabSTDLeaSkupinaPrava AS PX WHERE PX.IdSkupina=S.ID)
THEN (CASE WHEN ((SELECT TOP 1 RezimPrav FROM TabHGlob)= 0)
THEN(SELECT MAX(PX.PravoAktualizace)+(CASE MAX(PX.PravoAktualizace)WHEN 2 THEN 0 ELSE 1 END)FROM TabSTDLeaSkupinaPrava AS PX WHERE PX.IdSkupina=S.ID)
ELSE 2 END) ELSE 0 END)),
NULL
FROM TabSTDLeaSkupina AS S
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabSTDLeaSkupinaPrava AS P
ON S.ID = P.IdSkupina
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabSTDLeaSkupinaPrava AS PX WHERE PX.IdSkupina = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
UNION ALL
SELECT 5,
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabFIASestavaPrava AS PX WHERE PX.IdFIASestava=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
ISNULL(P.PravoAktualizace,(CASE WHEN EXISTS(SELECT * FROM TabFIASestavaPrava AS PX WHERE PX.IdFIASestava=S.ID)
THEN (CASE WHEN ((SELECT TOP 1 RezimPrav FROM TabHGlob)= 0)
THEN(SELECT MAX(PX.PravoAktualizace)+(CASE MAX(PX.PravoAktualizace)WHEN 2 THEN 0 ELSE 1 END)FROM TabFIASestavaPrava AS PX WHERE PX.IdFIASestava=S.ID)
ELSE 2 END) ELSE 0 END)),
NULL
FROM TabFIASestava AS S
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabFIASestavaPrava AS P
ON S.ID = P.IdFIASestava
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabFIASestavaPrava AS PX WHERE PX.IdFIASestava = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
UNION ALL
SELECT 6,
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
UNION ALL
SELECT 7,
S.ID,
U.LoginName,
ISNULL(P.ReadOnly,
CASE WHEN EXISTS(SELECT * FROM TabFIADataParamPohledPrava AS PX WHERE PX.IdFIADataParamPohled=S.ID AND PX.ReadOnly=0)
THEN 1 ELSE 0 END),
NULL,
NULL
FROM TabFIADataParamPohled AS S
CROSS JOIN TabUziv AS U
LEFT OUTER JOIN TabFIADataParamPohledPrava AS P
ON S.ID = P.IdFIADataParamPohled
AND (((P.LoginName = U.LoginName) AND (P.IdRole IS NULL))
OR((P.IdRole = U.IdRole) AND (P.IdRole IS NOT NULL)
AND NOT EXISTS(SELECT * FROM TabFIADataParamPohledPrava AS PX WHERE PX.IdFIADataParamPohled = S.ID
AND PX.IdRole IS NULL
AND U.LoginName = PX.LoginName)))
GO

