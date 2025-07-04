USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SynchroTyp]    Script Date: 04.07.2025 8:38:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SynchroTyp] AS SELECT
TypSynchro
,Nazev
,DBZdroj
,DBCil
,IDSkladCil
,RadaDokladuCil
,TypSynchroKmen
,TypSynchroOrg
FROM Tabx_SynchroTyp
GO

