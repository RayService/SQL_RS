USE [RayService]
GO

/****** Object:  View [dbo].[hvw_PorVarKusov]    Script Date: 04.07.2025 6:56:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_PorVarKusov] AS SELECT K.ID,K.IdFinal,  K.IdKmenZbozi,KZN.SkupZbo,KZN.Nazev1,  KZN.RegCis,  K.Mnf, K.MJ, KZN1.Nazev1 as Nazev,KZN1.RegCis as RG, KZN1.SkupZbo as SZ   FROM RayPorovVariantK as K
LEFT OUTER JOIN TabKmenZbozi as KZN ON K.IdKmenzbozi=KZN.ID
LEFT OUTER JOIN TabKmenZbozi as KZN1 ON K.IdFinal= KZN1.ID
WHERE Mnf<> 0
GO

