USE [RayService]
GO

/****** Object:  View [dbo].[hvw_68E3297364FB435F86B7F44B011888EC]    Script Date: 03.07.2025 11:17:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_68E3297364FB435F86B7F44B011888EC] AS SELECT
				Z.ID,Z.Nazev1, Z.Nazev2, PNV.IDPrikaz

			FROM TabPrNVazby PNV
			LEFT JOIN TabKmenZbozi Z on (PNV.Naradi = Z.ID)
				LEFT JOIN TabKmenZbozi_EXT ZE on (Z.ID = ZE.ID)
				LEFT JOIN B2A_TermETH_ToolUsage_EXT E on (PNV.ID = E.IDTool)

			WHERE
				PNV.IDOdchylkyDo IS NULL AND
				Z.Naradi = 1 AND
				Z.Blokovano = 0 
				AND (E.ToolNewLink IS NULL OR E.ToolNewLink = 0)
GO

