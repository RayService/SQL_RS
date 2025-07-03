USE [RayService]
GO

/****** Object:  View [dbo].[hvw_D6FBF06182174D9682FBEA7E6EE758A2]    Script Date: 03.07.2025 14:33:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_D6FBF06182174D9682FBEA7E6EE758A2] AS WITH Doc AS (
SELECT
TD.ID,TD.Popis,tkj.Kategorie,TD.OznaceniDokumentace,TD.CisloVerze,TD.DatPlatnostOd,TD.DatPlatnostDo,TD.DatSchvaleno,TD.DatSchvalenoQMS
FROM TabDokumenty TD WITH(NOLOCK)
LEFT OUTER JOIN TabKontaktJednani tkj WITH(NOLOCK) ON EXISTS(SELECT*
												FROM TabDokumVazba V WITH(NOLOCK)
												JOIN TabKontaktJednani KJ WITH(NOLOCK) ON KJ.ID=V.IDTab AND KJ.ID=tkj.ID
												JOIN TabKategKontJed KK WITH(NOLOCK) ON KK.Cislo=KJ.Kategorie
												WHERE V.IDDok=TD.ID AND V.IdentVazby=1 AND KK.QMSAgenda=8)
WHERE
((
EXISTS(SELECT * 
		FROM TabKontaktJednani KJ WITH(NOLOCK) 
		JOIN TabDokumVazba V WITH(NOLOCK) ON V.IDDok=TD.ID AND V.IdentVazby=1 AND V.IDTab=KJ.ID 
		JOIN TabKategKontJed KTG WITH(NOLOCK) ON KJ.Kategorie=KTG.Cislo 
		JOIN TabKJUcastZam KJUZ WITH(NOLOCK) ON KJUZ.IDKJ=KJ.ID
		WHERE KTG.QMSAgenda=8 AND KJ.Ukonceni IS NULL AND ((TD.DatPlatnostOd<=GETDATE()) 
		AND (TD.DatPlatnostDo IS NULL OR TD.DatPlatnostDo>=GETDATE())))
))
)
SELECT Doc.ID AS IDDocument
,Doc.Popis AS Popis
,Doc.Kategorie AS Kategorie
,Doc.OznaceniDokumentace AS OznaceniDokumentace
,Doc.CisloVerze AS CisloVerze
,Doc.DatPlatnostOd AS PlatnostOd
,Doc.DatPlatnostDo AS PlatnostDo
,Doc.DatSchvaleno AS Schvaleno
,Doc.DatSchvalenoQMS AS SchvalenoQMS
,tprd.ID AS IDPrava
,tprd.LoginName AS LoginName
,(SELECT U.FullName FROM RayService.dbo.TabUserCfg AS U WHERE U.LoginName=tprd.LoginName COLLATE DATABASE_DEFAULT) AS FullName
,tr.JmenoRole AS RoleName
FROM Doc WITH(NOLOCK)
LEFT OUTER JOIN TabPravaDokum tprd WITH(NOLOCK) ON tprd.IDDokum=Doc.ID
LEFT OUTER JOIN TabRole tr WITH(NOLOCK) ON tr.ID=tprd.IDRole
/*
SELECT
tprd.ID,tprd.BlokovaniEditoru,tprd.LoginName,(SELECT U.FullName FROM RayService.dbo.TabUserCfg AS U WHERE U.LoginName=tprd.LoginName COLLATE DATABASE_DEFAULT) AS FullName,tr.JmenoRole
FROM TabPravaDokum tprd
  LEFT OUTER JOIN TabRole tr ON tr.ID=tprd.IDRole
WHERE
(tprd.IDDokum=669680)

*/
GO

