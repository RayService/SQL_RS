USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAAVazbyRadkuDefiniceVykazuVIEW]    Script Date: 04.07.2025 10:21:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAAVazbyRadkuDefiniceVykazuVIEW]   --UPDATED 20150130
(TableName, IdTable, IdFIAAVykazDefinice, ID)
AS
SELECT N'TabFIAAVykazHodnota', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVykazHodnota 
UNION ALL
SELECT N'TabFIACPlanHodnota', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIACPlanHodnota 
UNION ALL
SELECT N'TabFIACPlanSkutRadek', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIACPlanSkutRadek 
UNION ALL
SELECT N'TabFIAAVCisUctVykazDefinice', ID, IdFIAAVykazDefiniceSouc, IdFIAAVykazDefiniceSouc FROM TabFIAAVCisUctVykazDefinice 
UNION ALL
SELECT N'TabFIAAVNakOkruhVykazParamVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVNakOkruhVykazParamVykazDefinice 
UNION ALL
SELECT N'TabFIAAVUtvarVykazParamVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVUtvarVykazParamVykazDefinice 
UNION ALL
SELECT N'TabFIAAVVozidloVykazParamVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVozidloVykazParamVykazDefinice 
UNION ALL
SELECT N'TabFIAAVVykazDefiniceCisloMzSl', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVykazDefiniceCisloMzSl 
UNION ALL
SELECT N'TabFIAAVVykazDefinicePlan', NULL, IdFIAAVykazDefinicePlan, IdFIAAVykazDefinicePlan FROM TabFIAAVVykazDefinicePlan 
UNION ALL
SELECT N'TabFIAAVVykazDefinicePlan', NULL, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVykazDefinicePlan 
UNION ALL
SELECT N'TabFIAAVVykazDefiniceRadaDokl', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVykazDefiniceRadaDokl 
UNION ALL
SELECT N'TabFIAAVVykazDefiniceRegCis', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVykazDefiniceRegCis 
UNION ALL
SELECT N'TabFIAAVVykazDefiniceSbornik', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVykazDefiniceSbornik 
UNION ALL
SELECT N'TabFIAAVVykazDefiniceSkupZbo', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVVykazDefiniceSkupZbo 
UNION ALL
SELECT N'TabFIACRadkyDefVykazuDoGrafu', NULL, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIACRadkyDefVykazuDoGrafu 
UNION ALL
SELECT N'TabFIAHodnota', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAHodnota 
UNION ALL
SELECT N'TabFIAUkazatel', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAUkazatel 
UNION ALL
SELECT N'TabFIAUkazatelClen', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAUkazatelClen 
UNION ALL
SELECT N'TabFIAAVykazHodnotaMesice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVykazHodnotaMesice 
UNION ALL
SELECT N'TabFIAAVZakazkaVykazParamVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVZakazkaVykazParamVykazDefinice 
UNION ALL
SELECT N'TabFIAAVZamesnanecVykazParamVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVZamesnanecVykazParamVykazDefinice 
UNION ALL
SELECT N'TabFIAADefVykazParamVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAADefVykazParamVykazDefinice 
UNION ALL
SELECT N'TabFIAAVCisUctVykazDefinice', ID, IdFIAAVykazDefinice, IdFIAAVykazDefinice FROM TabFIAAVCisUctVykazDefinice
GO

