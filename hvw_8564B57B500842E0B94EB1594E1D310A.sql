USE [RayService]
GO

/****** Object:  View [dbo].[hvw_8564B57B500842E0B94EB1594E1D310A]    Script Date: 03.07.2025 11:26:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_8564B57B500842E0B94EB1594E1D310A] AS SELECT
tpvp.*,
tvp.ID AS tvp_ID,
tkz.ID AS tkz_ID,
tp.ID AS tp_ID
FROM TabPostupVyrProfese tpvp WITH(NOLOCK)
  LEFT OUTER JOIN TabVyrProfese tvp WITH(NOLOCK) ON tvp.ID=tpvp.IDVyrProfese
  LEFT OUTER JOIN TabPostup tp WITH(NOLOCK) ON tp.ID = tpvp.IDPostup
  LEFT OUTER JOIN TabCzmeny tzcod WITH(NOLOCK) ON tp.ZmenaOd=tzcod.ID
  LEFT OUTER JOIN TabCzmeny tzcdo WITH(NOLOCK) ON tp.ZmenaDo=tzcdo.ID
  LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID = tp.dilec
WHERE ((tzcod.platnostTPV=1 AND tzcod.datum<=/*:__DATUMTPV*/GETDATE()))AND(tzcdo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tzcdo.platnostTPV=1 AND tzcdo.datum>/*:__DATUMTPV*/GETDATE()))
GO

