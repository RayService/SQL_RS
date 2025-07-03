USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_tdm_tensile_test]    Script Date: 03.07.2025 13:42:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_tdm_tensile_test] AS select t1.ID
      ,t1.Protocol
      ,t1.ExpirationDate
      ,t1.ExecutionDate
      ,convert(int, t1.Success) as Success
      ,t2.Nazev1 as ToolName
      ,t8._KL_RS as ToolCode
      ,t5.Title as Contact
      ,t4.Position
      ,t4.CrossSection
      ,t4.Code as Wire
      ,t7.Nazev as PositionerType
      ,t6.Color as PositionerColor
      ,t1.IDTool
      ,t1.IDCombination
      ,t1.Note
      ,t1.CreateUser
      ,t1.CreateEmployeeID
from B2A_TDM_TensileTest t1
join TabKmenZbozi t2 on t1.IDTool=t2.ID
join B2A_TDM_Combination t3 on t1.IDCombination=t3.ID
join B2A_TDM_Setting t4 on t3.IDSetting=t4.ID
join B2A_TDM_Contact t5 on t3.IDContact=t5.ID
left join B2A_TDM_Setting_Positioner t6 on t4.IDPositioner=t6.ID
left join TabSortiment t7 on t6.IDType=t7.ID
left join TabKmenZbozi_EXT t8 on t2.ID=t8.ID
where t1.ChangeTo is null
GO

