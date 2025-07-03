USE [RayService]
GO

/****** Object:  View [dbo].[hvw_nevykryte_expedaky]    Script Date: 03.07.2025 15:27:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_nevykryte_expedaky] AS SELECT tdz.CisloOrg, tdz.RadaDokladu, tdz.DatPorizeni_Y, tss.IDSklad, (tpz.Mnozstvi -  tpz.MnOdebrane)  * tpz.JCbezDaniKCPoS Neodebrano  FROM TabPohybyZbozi tpz 
LEFT OUTER JOIN TabStavSkladu tss ON tpz.IDZboSklad=tss.ID 
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad 
WHERE tpz.DruhPohybuZbo = 9
AND (tpz.Mnozstvi -  tpz.MnOdebrane)  > 0
GO

