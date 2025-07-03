USE [RayService]
GO

/****** Object:  View [dbo].[hvw_517EFB5DA4444914B635096E910EBA4A]    Script Date: 03.07.2025 11:09:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_517EFB5DA4444914B635096E910EBA4A] AS SELECT
tu.ID AS ID
,tu.IDSklad AS IDSklad
,tu.Kod AS Kod
,tu.Nazev AS Nazev
,tu.Poznamka AS Poznamka
,CAST((SUBSTRING(REPLACE(SUBSTRING(tu.Poznamka,1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) as  NVARCHAR(255)) AS Poznamka_255
,tu.Poznamka as Poznamka_All
,tu.BlokovaniEditoru
,tu.JeNovaVetaEditor
,tu.Blokovano
,tue.ID AS ID_EXT
,ISNULL(tue._VyjmoutZMapySkladu,0) AS _VyjmoutZMapySkladu
,ISNULL(tue._PovolitZaporneMnozNaUmisteni,0) AS _PovolitZaporneMnozNaUmisteni
,tue._IDPolice
,ISNULL(tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,0) AS _EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint
,ISNULL(tue._EXT_RS_generate_stock_taking_subordinate,0) AS _EXT_RS_generate_stock_taking_subordinate
,tue._EXT_RS_PhysicalPlace
,tue._EXT_RS_VypnoutFIFOFEFO
,tue._EXT_RS_VypnoutVzorec
,tpp.Nazev AS PhysicalName
FROM TabUmisteni tu WITH(NOLOCK)
LEFT OUTER JOIN TabUmisteni_EXT tue WITH(NOLOCK) ON tue.ID=tu.ID
LEFT OUTER JOIN Tabx_RS_PhysicalPlaces tpp WITH(NOLOCK) ON tpp.ID=tue._EXT_RS_PhysicalPlace
GO

