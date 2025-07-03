USE [RayService]
GO

/****** Object:  View [dbo].[hvw_A0A9062252D140A3BBF8E844B6BAD039]    Script Date: 03.07.2025 12:48:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_A0A9062252D140A3BBF8E844B6BAD039] AS SELECT mvd.ID /* primary key */
      ,p.Dilec
      ,p.Operace /* Číslo operace */
      ,p.nazev as name_op /* Název operace */
      ,mvd.Name as name_definition /* Název definice */
      ,mvc.Name as name_category /* Kategorie */
      ,mj.Nazev as name_unit /* Jednotka */
      ,case
        when mvd.DefinitionType = 1 then replace(mvd.ValueNum,'','')
        when mvd.DefinitionType = 2 then mvd.ValueStr
        when mvd.DefinitionType = 3 then case when mvd.ValueBit = 1 then 'ANO' else 'NE' end
        end as DefinitionTypeValue /* Definovaná hodnota */
      ,mvd.Limit /* Limit */
      ,mvd.RepeatEvery /* Opakování */
      ,mvd.CheckAt /* Kontrola */
      ,mvd.CheckFirst /* První */
      ,mvd.CheckLast /* Poslední */
      ,case
        when mvd.DefectResolveType = 1 then 'Opravitelné zmetky'
        when mvd.DefectResolveType = 2 then 'Zmetky IO'
        else 'Neopravitelné zmetky'
        end as ResolveType /* Způsob řešení */
      ,kj.Predmet as Tool /* Nářadí */
FROM B2A_MeasuredValueDefinition mvd
JOIN B2A_MeasuredValueCategory mvc ON mvd.IDCategory = mvc.ID
JOIN B2A_MeasuredValueDefinition_PdmOperation mvop ON mvop.IDDefinition = mvd.IDRoot
JOIN TabPostup p ON p.dilec = mvop.IDPdm AND p.Operace = mvop.Operation
LEFT JOIN TabKontaktJednani kj ON kj.ID = mvd.ID_ToolQMS
LEFT JOIN TabMJ mj ON mj.ID = mvd.IDUnit
JOIN TabCzmeny op_from ON p.ZmenaOd = op_from.ID and op_from.Platnost = 1
LEFT JOIN TabCzmeny op_to ON p.ZmenaDo = op_to.ID
JOIN TabCzmeny ch_from ON mvd.ErpChangeFrom = ch_from.ID and ch_from.Platnost = 1
LEFT JOIN TabCzmeny ch_to ON mvd.ErpChangeTo = ch_to.ID
WHERE isnull(ch_to.Platnost,0)=0 and isnull(op_to.Platnost,0)=0
GO

