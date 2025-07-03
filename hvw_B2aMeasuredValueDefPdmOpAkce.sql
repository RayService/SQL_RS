USE [RayService]
GO

/****** Object:  View [dbo].[hvw_B2aMeasuredValueDefPdmOpAkce]    Script Date: 03.07.2025 13:46:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_B2aMeasuredValueDefPdmOpAkce] AS SELECT TabDef.Name
,Tab3.Name AS Category
,Kod
,Value
,Limit
,RepeatEvery
,CheckAt
,CheckFirst
,CheckLast
,DefectResolveType
,DefinitionType
,ValueNum
,ValueStr
,ValueBit
,ToleranceDown
,ToleranceUp
,ToleranceDownDefectEntry
,ToleranceUpDefectEntry
,MatchType
,TabDef.ID
,IDPdm
,Operation
,TabDef.IDRoot
,ChangeFrom
,ISNULL(Tab4.Predmet, Tab5.Nazev1) AS ToolName
,ChangeTo
,ID_ToolQMS
,ID_Tool
,TabZmenyOd.datumNastaveni AS ValidFrom
,TabZmenyDo.datumNastaveni AS ValidTo
FROM B2A_MeasuredValueDefinition_PdmOperation Tab1
JOIN B2A_MeasuredValueDefinition TabDef ON Tab1.IDDefinition = TabDef.IDRoot
JOIN B2A_MeasuredValueCategory Tab3 ON TabDef.IDCategory = Tab3.ID
LEFT JOIN TabKontaktJednani Tab4 ON TabDef.ID_ToolQMS = Tab4.ID
LEFT JOIN TabKmenZbozi Tab5 ON TabDef.ID_Tool = Tab4.ID
LEFT JOIN TabCzmeny TabZmenyOd ON TabZmenyOd.ID = TabDef.ErpChangeFrom
LEFT JOIN TabCzmeny TabZmenyDo ON TabZmenyDo.ID = TabDef.ErpChangeTo
LEFT JOIN TabMJ ON TabDef.IDUnit = TabMJ.ID
GO

