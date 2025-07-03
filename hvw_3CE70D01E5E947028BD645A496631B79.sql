USE [RayService]
GO

/****** Object:  View [dbo].[hvw_3CE70D01E5E947028BD645A496631B79]    Script Date: 03.07.2025 11:07:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_3CE70D01E5E947028BD645A496631B79] AS SELECT 
     mv.ID
     , po.ID as po_ID
      ,op.Operace
      ,op.nazev as op_name
      ,mvd.Name as definition_name /* Název definice */
      ,iif(workDoneExtEmployee.ID is null, workDoneEmployee.PrijmeniJmeno, workDoneExtEmployee.PrijmeniJmeno) as Author /* Autor */
      ,mvc.Name as category_name /* Kategorie */
      ,case
        when mvd.DefinitionType = 1 then replace(mv.ValueNum,'','')
        when mvd.DefinitionType = 2 then mv.ValueStr
        when mvd.DefinitionType = 3 then case when mv.ValueBit = 1 then 'ANO' else 'NE' end
        end as MeasuredValue /* Nam. hodnota */
      ,mj.Nazev as unit_name /* Jednotka */
      ,mvo.UnitNr /* Měřený kus */
      ,(case when exists(select * from B2A_MeasuredValue_Configuration where SerialNumberColumn=0)
        then sn.VyrCislo else sn.Popis end) AS SerialNumber  /* Sériové číslo */
      ,case
        when mvd.DefinitionType = 1 then replace(mvd.ValueNum,'','')
        when mvd.DefinitionType = 2 then mvd.ValueStr
        when mvd.DefinitionType = 3 then case when mvd.ValueBit = 1 then 'ANO' else 'NE' end
        end as DefinitionTypeValue /* Def. hodnota */
      ,mvd.Limit /* Rozsah hodnot */
,mv.DatPorizeni
FROM TabPrikaz po
JOIN TabPrPostup op ON op.IDPrikaz = po.ID and op.IDOdchylkyDo is NULL
JOIN TabPrikazMzdyAZmetky workDone ON workDone.IDPrikaz = po.ID and workDone.DokladPrPostup = op.Doklad and workDone.AltPrPostup = op.Alt
JOIN B2A_MeasuredValue_TabPrikazMzdyAZmetky mvo ON workDone.ID = mvo.IDJob
JOIN B2A_MeasuredValue mv ON mv.ID = mvo.IDMeasuredValue
JOIN B2A_MeasuredValueDefinition mvd ON mvd.ID = mv.IDDefinition
JOIN B2A_MeasuredValueCategory mvc ON mvc.ID = mvd.IDCategory
LEFT JOIN TabMJ mj ON mj.ID = mvd.IDUnit
INNER JOIN TabPrikazMzdyAZmetky_EXT as workDone_ext on workDone.ID = workDone_ext.ID
INNER JOIN TabCisZam as workDoneEmployee on workDone.Zamestnanec = workDoneEmployee.ID
LEFT JOIN TabCisZam workDoneExtEmployee on workDone_ext._EXT_B2ADIMA_WorkDoneSupervisorPersonalNr = workDoneExtEmployee.Cislo
LEFT JOIN TabVyrCisPrikaz sn ON sn.ID = mv.IDSerialNumber
GO

