USE [RayService]
GO

/****** Object:  View [dbo].[hvw_856AB8072C964FE7B0B2011028E2F233]    Script Date: 03.07.2025 11:26:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_856AB8072C964FE7B0B2011028E2F233] AS SELECT
tkz.*
      ,tkze.[_E_kody]
      ,tkze.[_RoHs]
      ,tkze.[_RAYJine1]
      ,tkze.[_mzdy]
      ,tkze.[_material]
      ,tkze.[_sklad]
      ,tkze.[_sklad_regal]
      ,tkze.[_sklad_misto]
      ,tkze.[_ramcSmlouva]
      ,tkze.[_RAYJedncas]
      ,tkze.[_RAYJine2]
      ,tkze.[_RAYPocKontaktu]
      ,tkze.[_RAYPocVetvi]
      ,tkze.[_RAYPocVodicu]
      ,tkze.[_RAYPozn1]
      ,tkze.[_RAYPozn2]
      ,tkze.[_RAYPozn3]
      ,tkze.[_RAYPozn4]
      ,tkze.[_RAYSkupMaterialu]
      ,tkze.[_RAYJine3]
      ,tkze.[_balitDle]
      ,tkze.[_lezaky]
      ,tkze.[_datum_generovani]
      ,tkze.[_podm_vyberu]
      ,tkze.[_zpusob_reseni]
      ,tkze.[_skupina_lezaku]
      ,tkze.[_teplota_odizol]
      ,tkze.[_RAY_CofC_JOC]
      ,tkze.[_TechnikTPV100]
FROM RayService6..TabKmenZbozi tkz WITH(NOLOCK)
JOIN RayService6..TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
GO

