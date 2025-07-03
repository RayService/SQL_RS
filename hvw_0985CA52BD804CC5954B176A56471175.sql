USE [RayService]
GO

/****** Object:  View [dbo].[hvw_0985CA52BD804CC5954B176A56471175]    Script Date: 03.07.2025 10:52:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_0985CA52BD804CC5954B176A56471175] AS SELECT TU.SetupParameters, TU.ProtocolCode, TU.ToolNewLink, TU.Created, TU.IDCombination,
	Z.ID AS 'IDZam', Z.Jmeno, Z.Prijmeni,
	Zam2.ID AS 'IDZamS', Zam2.Jmeno as 'JmenoS', Zam2.Prijmeni as 'PrijmeniS',
	P.ID AS 'IDVP', P.Rada, P.Prikaz,
	TPNV.ID AS 'IDPouziti', TPNV.Doklad, TPNV.IDPrikaz, TPNV.IDPracoviste, TPNV.VyrStredisko,
	Z2.ID AS 'IDVyrobku', Z3.ID AS 'IDNaradi', S1.ID AS 'IDSortiment_naradi',

TU.Color as 'Barva', TU.CrossSection as 'Prurez', TU.Position as 'Pozice', TU.IDToolPositioner,
TU.IdentificationCode

-- user deleted
,DeletedIDEmployee, DeletedDate

FROM B2A_TermETH_ToolUsage_EXT TU
LEFT JOIN Gatema_TermETH E on TU.IDEventTermETH = E.ID
LEFT JOIN TabCisZam Z on E.IDZam = Z.ID
LEFT JOIN TabCisZam Zam2 on TU.IDEmployeeSuperior = Zam2.ID
LEFT JOIN TabPrNVazby TPNV on TU.IDTool = TPNV.ID
LEFT JOIN TabPrikaz P ON TPNV.IDPrikaz = P.ID
LEFT JOIN TabKmenZbozi Z2 on TPNV.Dilec = Z2.ID
LEFT JOIN TabKmenZbozi Z3 ON Z3.ID = TPNV.Naradi
LEFT JOIN TabKmenZbozi Z4 ON Z4.ID = TU.IDToolPositioner
LEFT JOIN TabSortiment S1 ON S1.ID = Z3.IdSortiment
GO

