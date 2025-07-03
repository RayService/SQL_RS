USE [RayService]
GO

/****** Object:  View [dbo].[hvw_B284D4EA38B241AEBB8F90F1DB27C2F4]    Script Date: 03.07.2025 13:38:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_B284D4EA38B241AEBB8F90F1DB27C2F4] AS SELECT
tp.ID AS ID,
tp.dilec AS dilec,
tp.Odvadeci AS Odvadeci,
tp.typ AS typ,
tp.ZmenaOd AS ZmenaOd,
tp.ZmenaDo AS ZmenaDo,
tp.Operace AS Operace,
tp.pracoviste AS pracoviste,
tp.IDStroje AS IDStroje,
tp.IDTypuNaklPrac AS IDTypuNaklPrac,
tp.IDkooperace AS IDkooperace,
tp.tarif AS tarif,
tp.JeTypova AS JeTypova,
tp.IDObrazek AS IODobrazek,
tp.nazev AS nazev,
tp.TBC_N AS TBC_N,
tp.TAC_N AS TAC_N,
tp.TAC_Obsluhy_N AS TAC_Obsluhy_N,
tp.TEC_N AS TEC_N,
tp.DatPorizeni AS DatPorizeni,
tp.Autor AS Autor,
tp.Zmenil AS Zmenil,
tp.DatZmeny AS DatZmeny
FROM TabPostup tp
LEFT OUTER JOIN TabCzmeny tczOd WITH(NOLOCK) ON tp.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo WITH(NOLOCK) ON tp.ZmenaDo=tczDo.ID
WHERE
(tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE())AND
((tczDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) )
GO

