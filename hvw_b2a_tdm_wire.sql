USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_tdm_wire]    Script Date: 03.07.2025 13:43:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_tdm_wire] AS select t1.ID
       ,t1.Title
       ,t1.CrossSection
       ,t1.DeleteDate
       ,t1.IDMaterial
       ,case when t2.ID is not null then concat(t2.SkupZbo, '/', t2.RegCis) else null end as MaterialCode
  from B2A_TDM_Wire t1
  left join TabKmenZbozi t2 on t1.IDMaterial = t2.ID
  where t1.DeleteDate is null
GO

