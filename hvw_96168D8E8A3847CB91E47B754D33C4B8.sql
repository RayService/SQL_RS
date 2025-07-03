USE [RayService]
GO

/****** Object:  View [dbo].[hvw_96168D8E8A3847CB91E47B754D33C4B8]    Script Date: 03.07.2025 12:44:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_96168D8E8A3847CB91E47B754D33C4B8] AS SELECT
tkv.ID AS ID,
tkv.vyssi AS vyssi,
tkv.nizsi AS nizsi,
tkv.ZmenaOd AS ZmenaOd,
tkv.ZmenaDo AS ZmenaDo,
tkv.pozice AS pozice,
tkv.Operace AS Operace,
tkv.IDVzorceSpotMat AS IDVzorceSpotMat,
tkv.mnozstvi AS mnozstvi,
tkv.mnozstviSeZtratou AS mnozstviSeZtratou,
tkv.FixniMnozstvi AS FixniMnozstvi,
tkv.Globalni AS Globalni,
tkv.Prirez AS Prirez,
tkv.ProcZtrat AS ProcZtrat,
tkv.SpotRozmer AS SpotRozmer,
tkv.VychoziSklad AS VychoziSklad,
tkv.RezijniMat AS RezijniMat,
tkv.VyraditZKalkulace AS VyraditZKalkulace,
tkv.DatPorizeni AS DatPorizeni,
tkv.Autor AS Autor,
tkv.Zmenil AS Zmenil,
tkv.DatZmeny AS DatZmeny
FROM TabKvazby tkv
LEFT OUTER JOIN TabCzmeny tczOd WITH(NOLOCK) ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo WITH(NOLOCK) ON tkv.ZmenaDo=tczDo.ID
WHERE
(tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE())AND
((tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) )

/*
FROM TabPohybyZbozi tpz WITH(NOLOCK)
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.ID=tpz.IDZboSklad
LEFT OUTER JOIN TabKvazby tkv WITH(NOLOCK) ON tkv.vyssi=tss.IDKmenZbozi
LEFT OUTER JOIN TabCzmeny tczOd WITH(NOLOCK) ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo WITH(NOLOCK) ON tkv.ZmenaDo=tczDo.ID
WHERE
--(tpz.ID=7714963)AND
(tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE())AND
((tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) )
*/
GO

