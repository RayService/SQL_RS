USE [RayService]
GO

/****** Object:  View [dbo].[hvw_HistVarKus]    Script Date: 03.07.2025 15:16:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_HistVarKus] AS SELECT K.*,KZ.RegCis, KZ.SkupZbo, KZ.Nazev1,Z.CisloZakazky  FROM RayHistVariantK as K
LEFT OUTER JOIN TabKmenZbozi KZ ON K.IDKmenZbozi=KZ.ID
LEFT OUTER JOIN TabZakazka Z ON K.IDZakazka=Z.ID
GO

