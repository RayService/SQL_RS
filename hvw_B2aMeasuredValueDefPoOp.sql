USE [RayService]
GO

/****** Object:  View [dbo].[hvw_B2aMeasuredValueDefPoOp]    Script Date: 03.07.2025 13:46:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_B2aMeasuredValueDefPoOp] AS SELECT Tab2.Name
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
,ToleranceUp
,ToleranceDown
,ToleranceUpDefectEntry
,ToleranceDownDefectEntry
,MatchType
,Tab2.ID
,DocNum
,Alt
,IDProductionOrder
,IDRoot
,ChangeFrom
,ChangeTo
,ID_ToolQMS
,ID_Tool
,ISNULL(Tab4.Predmet, Tab5.Nazev1) AS ToolName
FROM B2A_MeasuredValueDefinition_ProductionOrderOperation Tab1
JOIN B2A_MeasuredValueDefinition Tab2 ON Tab1.IDDefinition = Tab2.IDRoot AND Tab2.ChangeTo IS NULL
JOIN B2A_MeasuredValueCategory Tab3 ON Tab2.IDCategory = Tab3.ID
LEFT JOIN TabKontaktJednani Tab4 ON Tab2.ID_ToolQMS = Tab4.ID
LEFT JOIN TabKmenZbozi Tab5 ON Tab2.ID_Tool = Tab4.ID
LEFT JOIN TabMJ ON Tab2.IDUnit = TabMJ.ID
GO

