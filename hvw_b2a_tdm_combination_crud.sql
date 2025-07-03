USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_tdm_combination_crud]    Script Date: 03.07.2025 13:41:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_tdm_combination_crud] AS select t1.ID
      ,t2.Title as Contact
      ,t3.Position
      ,t3.CrossSection
      ,t3.Code as Wire
      ,t7.Nazev as Positioner
      ,t4.Color
      ,t3.IDTool
      ,t5.IDPdm
      ,t6.IDProductionOrder
      ,t1.IDSetting
      ,t3.IDPositioner
      ,t4.IDType as IDPositionerType
      ,t1.IDContact
      ,t1.ChangeTo
      ,t8.Nazev1 AS Tool
      ,cast((case when t5.IDCombination is null then 0 else 1 end) as bit) as IsPdm
      ,cast((case when t6.IDProductionOrder is null then 0 else 1 end) as bit) as IsPo
      ,t1.IsNotSuitable
from B2A_TDM_Combination t1
join B2A_TDM_Contact t2 on t2.ID = t1.IDContact
join B2A_TDM_Setting t3 on t3.ID = t1.IDSetting
left join B2A_TDM_Setting_Positioner t4 on t4.ID = t3.IDPositioner
left join (
  select distinct tt1.IDCombination,min(tt1.IDPdm) as IDPdm
  from B2A_TDM_Combination_Pdm tt1
  left join TabCzmeny tt2 on tt1.ErpChangeTo=tt2.ID
  where isnull(tt2.Platnost,0)=0
  group by tt1.IDCombination
  ) t5 on t5.IDCombination = t1.ID
left join (
  select distinct IDCombination,min(IDProductionOrder) as IDProductionOrder from B2A_TDM_Combination_ProductionOrder where ChangeTo is null group by IDCombination
  ) t6 on t6.IDCombination = t1.ID
left join TabSortiment t7 on t7.ID = t4.IDType
join TabKmenZbozi t8 on t3.IDTool=t8.ID
where t1.ChangeTo is null
GO

