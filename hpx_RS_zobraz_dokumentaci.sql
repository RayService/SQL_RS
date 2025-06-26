USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zobraz_dokumentaci]    Script Date: 26.06.2025 10:33:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zobraz_dokumentaci] @ID INT
AS
SELECT tvd.*
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = (SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID = tpz.IDZboSklad)
LEFT OUTER JOIN TabVazbyVyrDokum tvvd ON tvvd.RecID = tkz.ID
LEFT OUTER JOIN TabVyrDokum tvd ON tvd.ID1 = tvvd.ID1VyrDokum
LEFT OUTER JOIN TabCzmeny tczOd ON tvd.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo ON tvd.ZmenaDo=tczDo.ID
WHERE (((tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()))
AND(((tczDo.platnostTPV=0 OR tvd.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) ))
AND((tvd.Archiv=0 )) AND tpz.ID = @ID)
GO

