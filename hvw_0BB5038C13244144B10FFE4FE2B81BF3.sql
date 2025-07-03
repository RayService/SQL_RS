USE [RayService]
GO

/****** Object:  View [dbo].[hvw_0BB5038C13244144B10FFE4FE2B81BF3]    Script Date: 03.07.2025 10:53:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_0BB5038C13244144B10FFE4FE2B81BF3] AS SELECT
	-- tool
	Predepsano.Nazev1 as Nazev1p,
	Predepsano.Nazev2 as Nazev2p,
	Predepsano.IDPrikaz,

	U.IDCombination as IDCombinationU,
	U.ToolNewLink,

	-- combination
	C.ID as IDCombination,
	C.Title as Contact,
	C.Position,
	C.CrossSection,
	C.Code as WireCode,

	-- usage information (included new)
	U.Nazev1,
	U.IdentificationCode,
	U.ProtocolCode,
	U.SetupParameters,
	U.Color as ColorU,
	U.CrossSection as CrossSectionU,
	U.Position as PositionU,
	U.Created,
	U.NazevPolohovace,
	U.Jmeno,
	U.Prijmeni,
	U.DeletedDate as DatumD,
	U.JmenoD,
	U.PrijmeniD,
	U.JmenoS,
	U.PrijmeniS
FROM
	(
		SELECT
				Z.ID,Z.Nazev1, Z.Nazev2, PNV.IDPrikaz
			FROM
				(SELECT DISTINCT Z.ID, IDPrikaz
				 FROM TabPrNVazby PNV
					 LEFT JOIN TabKmenZbozi Z on (PNV.Naradi = Z.ID)
					 LEFT JOIN B2A_TermETH_ToolUsage_EXT E on (PNV.ID = E.IDTool)
				 WHERE
					 PNV.IDOdchylkyDo IS NULL AND
					 Z.Naradi = 1 AND
					 Z.Blokovano = 0
					 AND Z.SkupZbo IN (N'600',N'605')
					 --AND PNV.IDPrikaz = 117767
				) PNV
			LEFT JOIN TabKmenZbozi Z ON (PNV.ID = Z.ID)

		) AS Predepsano
	-- join combination over PO and Tool
	LEFT JOIN
		(SELECT C.ID, Co.Title, S.Position, S.CrossSection, S.Code, S.IDTool, CPO.IDProductionOrder
		 	FROM dbo.B2A_TDM_Combination_ProductionOrder CPO
			LEFT JOIN dbo.B2A_TDM_Combination C ON (CPO.IDCombination = C.ID)
			LEFT JOIN dbo.B2A_TDM_Setting S ON (S.ID = C.IDSetting)
			LEFT JOIN dbo.B2A_TDM_Contact Co ON (Co.ID = C.IDContact)
			WHERE CPO.ChangeTo IS NULL
			--AND CPO.IDProductionOrder = 117767
			) AS C ON (C.IDTool = Predepsano.ID AND C.IDProductionOrder = Predepsano.IDPrikaz)

	-- join usage over select of PO and Tool or Id Combination
	LEFT JOIN (
				SELECT PNV.Naradi, U.IDCombination, U.IdentificationCode, U.ProtocolCode, U.SetupParameters, U.Color, U.CrossSection, U.Position, U.IDProductionOrder,	U.Created, U.DeletedDate,
					ZP.Nazev1 AS NazevPolohovace,
					ZA.Jmeno, ZA.Prijmeni,
					ZAS.Jmeno AS JmenoS, ZAS.Prijmeni AS PrijmeniS,
					ZAD.Jmeno AS JmenoD, ZAD.Prijmeni AS PrijmeniD,
					Z.Nazev1,
					U.ToolNewLink
					FROM B2A_TermETH_ToolUsage_EXT U
				LEFT JOIN TabPrNVazby PNV ON U.IDTool = PNV.ID
				LEFT JOIN TabKmenZbozi Z on PNV.Naradi = Z.ID
					LEFT JOIN TabKmenZbozi_EXT ZE on Z.ID = ZE.ID
					LEFT JOIN TabCisZam ZA on U.IDEmployee = ZA.ID
					LEFT JOIN TabCisZam ZAS on U.IDEmployeeSuperior = ZAS.ID
					LEFT JOIN TabCisZam ZAD on U.DeletedIDEmployee = ZAD.ID
					LEFT JOIN TabKmenZbozi ZP on U.IDToolPositioner = ZP.ID
		WHERE U.ToolNewLink IS NOT NULL
			--AND U.IDProductionOrder = 117767
		 ) AS U ON (U.IDProductionOrder = Predepsano.IDPrikaz AND U.Naradi = Predepsano.ID AND (U.IDCombination IS NULL OR U.IDCombination = C.ID))
GO

