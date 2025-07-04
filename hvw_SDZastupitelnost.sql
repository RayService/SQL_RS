USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDZastupitelnost]    Script Date: 04.07.2025 8:24:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDZastupitelnost] AS SELECT ID
     , LoginNameSchvalovatel
     , (SELECT TabUserCfg.FullName FROM RayService..TabUserCfg TabUserCfg WHERE TabUserCfg.LoginName=Tabx_SDZastupitelnost.LoginNameSchvalovatel) AS FullNameSchvalovatel
     , LoginNameZastupce
     , (SELECT TabUserCfg.FullName FROM RayService..TabUserCfg TabUserCfg WHERE TabUserCfg.LoginName=Tabx_SDZastupitelnost.LoginNameZastupce) AS FullNameZastupce
     , IdPredpis
     , PlatnostOd
     , PlatnostDo
     , DatPorizeni
     , Autor
     , DatZmeny
     , Zmenil
FROM Tabx_SDZastupitelnost
GO

