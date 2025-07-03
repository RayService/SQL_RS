USE [RayService]
GO

/****** Object:  View [dbo].[hvw_D548EE922B724D3693BB4ACBD675BC23]    Script Date: 03.07.2025 14:31:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_D548EE922B724D3693BB4ACBD675BC23] AS SELECT
TabPohybyZbozi.ID,TabPohybyZbozi.IDZboSklad,tkz.Obrazek
FROM TabPohybyZbozi WITH(NOLOCK)
  LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WITH(NOLOCK) WHERE TabStavSkladu.ID=TabPohybyZbozi.IDZboSklad)
WHERE tkz.Obrazek IS NOT NULL
GO

