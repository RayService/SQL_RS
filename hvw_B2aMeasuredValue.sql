USE [RayService]
GO

/****** Object:  View [dbo].[hvw_B2aMeasuredValue]    Script Date: 03.07.2025 13:44:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_B2aMeasuredValue] AS SELECT mvd.Name
,mvc.Name AS Category
,mv.Value
,mj.Kod
,mvo.UnitNr
,(case when exists(select * from B2A_MeasuredValue_Configuration where SerialNumberColumn=0)
    then sn.VyrCislo else sn.Popis end) AS SerialNumber
,mvd.Value as DefValue
,mvd.Limit
,mvo.ID
,mvdo.DokladPrPostup AS DocNum
,mvdo.AltPrPostup AS Alt
,mvdo.IDPrikaz AS IDProductionOrder
,mv.ID AS IDValue
,mvd.DefinitionType
,cast(case mvd.DefinitionType
      when 1 then
       case when mv.ValueNum < (mvd.ValueNum + isnull(mvd.ToleranceDown,0))
        or mv.ValueNum > (mvd.ValueNum + isnull(mvd.ToleranceUp,0)) then 0 else 1 end
      when 2 then
       case when mv.ValueStr like mvd.Limit then 1 else 0 end
      when 3 then mv.ValueBit
      else 0 end as bit) as Result
FROM B2A_MeasuredValue_TabPrikazMzdyAZmetky mvo
JOIN B2A_MeasuredValue mv ON mv.ID = mvo.IDMeasuredValue
JOIN B2A_MeasuredValueDefinition mvd ON mvd.ID = mv.IDDefinition
JOIN TabPrikazMzdyAZmetky mvdo ON mvdo.ID = mvo.IDJob
LEFT JOIN TabMJ mj ON mj.ID = mvd.IDUnit
JOIN B2A_MeasuredValueCategory mvc ON mvd.IDCategory = mvc.ID
LEFT JOIN TabVyrCisPrikaz sn ON sn.ID = mv.IDSerialNumber
GO

