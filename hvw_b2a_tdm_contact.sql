USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_tdm_contact]    Script Date: 03.07.2025 13:42:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_tdm_contact] AS select t1.ID
       ,t1.Title
       ,t1.NeedCuttingTest
       ,t1.CrossSectionRange
       ,t1.IDMaterial
       ,t1.DeleteDate
       ,case when t2.ID is not null then concat(t2.SkupZbo, '/', t2.RegCis) else null end as MaterialCode
  from B2A_TDM_Contact t1
  left join TabKmenZbozi t2 on t1.IDMaterial = t2.ID
  where t1.DeleteDate is null
GO

