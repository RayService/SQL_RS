USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_NevykrPolExpSumOrg]    Script Date: 04.07.2025 7:03:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_NevykrPolExpSumOrg] AS SELECT CO.CisloOrg, CO.Nazev,SUM( ( PZ.Mnozstvi -  PZ.MnOdebrane)  * PZ.JCbezDaniKCPoS) CenaBezDPH
FROM TabPohybyZbozi as PZ
LEFT JOIN TabStavSkladu as SS ON PZ.IDZboSklad=SS.ID 
LEFT JOIN TabDokladyZbozi as DZ ON DZ.ID=PZ.IDDoklad  
LEFT JOIN TabKmenZbozi as KZ ON KZ.ID=SS.IDKmenZbozi
LEFT JOIN TabCisOrg as CO ON CO.CisloOrg=DZ.CisloOrg
WHERE PZ.DruhPohybuZbo = 9 AND (PZ.Mnozstvi -  PZ.MnOdebrane)  > 0
GROUP BY CO.CisloOrg, CO.Nazev
GO

