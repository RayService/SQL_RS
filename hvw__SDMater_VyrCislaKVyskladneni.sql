USE [RayService]
GO

/****** Object:  View [dbo].[hvw__SDMater_VyrCislaKVyskladneni]    Script Date: 03.07.2025 10:50:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw__SDMater_VyrCislaKVyskladneni] AS SELECT SkupZbo = KZ.SkupZbo, RegCis = KZ.RegCis, Nazev = KZ.Nazev1, VyrCislo = VC.Nazev1, IDPohybyZbozi = Vyskl.IDPohybyZbozi,
     IDVyrCisla = Vyskl.IDVyrCisla, ID = Vyskl.ID
 FROM Tab_SDMater_VyrCislaKVyskladneni Vyskl
  INNER JOIN TabPohybyZbozi PZ ON PZ.ID = Vyskl.IDPohybyZbozi
  INNER JOIN TabStavSkladu SS ON SS.ID = PZ.IDZboSklad
  INNER JOIN TabKmenZbozi KZ ON KZ.ID = SS.IDKmenZbozi
  INNER JOIN TabVyrCS VC ON VC.ID = Vyskl.IDVyrCisla
GO

