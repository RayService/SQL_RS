USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zobrazeni_technologie_polotovaru]    Script Date: 26.06.2025 10:34:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zobrazeni_technologie_polotovaru] @ID INT
AS

DECLARE @polotovar INT
SET @polotovar = (SELECT nizsi FROM TabPrKVazby WHERE TabPrKVazby.ID = @ID)
SELECT
TabPostup.*
FROM TabPostup WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON TabPostup.ZmenaOd=VPostupCZmenyOd.ID
  LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON TabPostup.ZmenaDo=VPostupCZmenyDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON TabPostup.pracoviste=VPostupCPraco.ID
  LEFT OUTER JOIN TabTarH VPostupTarH WITH(NOLOCK) ON TabPostup.tarif=VPostupTarH.ID
  LEFT OUTER JOIN  TabPostup_EXT WITH(NOLOCK) ON TabPostup_EXT.ID=TabPostup.ID
WHERE
(((TabPostup.dilec=@polotovar))AND((VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()))AND(((VPostupCZmenyDo.platnostTPV=0 OR TabPostup.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) )))
GO

