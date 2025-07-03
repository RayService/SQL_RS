USE [RayService]
GO

/****** Object:  View [dbo].[hvw_2D4D2729D5124F3FBE42CE92B5700798]    Script Date: 03.07.2025 11:03:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_2D4D2729D5124F3FBE42CE92B5700798] AS SELECT
tkv.ID AS ID,
tkv.vyssi AS vyssi,
tkv.IDVarianta AS IDVarianta,
tkv.nizsi AS nizsi,
tkv.ZmenaOd AS ZmenaOd,
tkv.ZmenaDo AS ZmenaDo,
tkv.pozice AS Pozice,
tkzV.Nazev1 AS Nazev1Vyssi,
tkzV.RegCis AS RegCisVyssi,
tkzN.Nazev1 AS Nazev1nizsi,
tkzV.Nazev3 AS Nazev3Vyssi,
tkzV.Nazev4 AS Nazev4Vyssi,
tkv.mnozstvi AS mnozstvi,
tkzN.MJEvidence AS MJEvidence,
tcv.Varianta AS Varianta,
tkzv.Poznamka AS Poznamka,
(CAST(tkzV.Poznamka AS NVARCHAR(MAX))) AS Poznamka_All
FROM TabKvazby tkv WITH(NOLOCK)
LEFT OUTER JOIN TabCzmeny tczOd WITH(NOLOCK) ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo WITH(NOLOCK) ON tkv.ZmenaDo=tczDo.ID
LEFT OUTER JOIN TabKmenZbozi tkzV WITH(NOLOCK) ON tkv.vyssi=tkzV.ID
LEFT OUTER JOIN TabKmenZbozi tkzN WITH(NOLOCK) ON tkv.nizsi=tkzN.ID
LEFT OUTER JOIN TabCVariant tcv WITH(NOLOCK) ON tcv.ID=tkv.IDVarianta
WHERE
(((tkv.IDZakazModif IS NOT NULL OR tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()/*:__DATUMTPV*/ AND (tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE()/*:__DATUMTPV*/)) )))AND((tkzV.SkupZbo=N'899')AND(tkzN.MJEvidence<>N'm')AND(tkzN.Nazev1<>N'0903 132 6921')AND(tkzN.Nazev1<>N'173 002 KSG 173')AND(tkzN.Nazev1<>N'0903 164 6922')AND(tkzN.Nazev1<>N'600-052 (6,1x362,1)mm /BE-02/')AND(tkzN.Nazev1<>N'600-057 (3,0x206,4)mm /BE-04/')AND(tkzV.Nazev1 not like N'M2 0%')AND(tkzV.Nazev1 not like N'M4 0%')AND((tkzN.SkupZbo like N'5%')OR(tkzN.SkupZbo like N'6%')))
/*(((tkv.IDZakazModif IS NOT NULL OR tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()/*:__DATUMTPV*/ AND (tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE()/*:__DATUMTPV*/)) )))AND((tkzV.SkupZbo=N'899')AND(tkzN.MJEvidence<>N'm')AND(tkzN.Nazev1<>N'0903 132 6921')AND(tkzN.Nazev1<>N'173 002 KSG 173')AND(tkzN.Nazev1<>N'0903 164 6922')AND(tkv.pozice NOT LIKE N'%A%')AND(tkv.pozice NOT LIKE N'%B%')AND(tkv.pozice NOT LIKE N'%C%')AND(tkv.pozice NOT LIKE N'%D%')AND(tkv.pozice NOT LIKE N'%E%')AND(tkv.pozice NOT LIKE N'%F%')AND(tkv.pozice NOT LIKE N'%G%')AND(tkv.pozice NOT LIKE N'%H%')AND(tkv.pozice NOT LIKE N'%I%')AND(tkv.pozice NOT LIKE N'%J%')AND(tkv.pozice NOT LIKE N'%K%')AND(tkv.pozice NOT LIKE N'%L%')AND(tkv.pozice NOT LIKE N'%M%')AND(tkv.pozice NOT LIKE N'%N%')AND(tkv.pozice NOT LIKE N'%O%')AND(tkv.pozice NOT LIKE N'%P%')AND(tkv.pozice NOT LIKE N'%Q%')AND(tkv.pozice NOT LIKE N'%R%')AND(tkv.pozice NOT LIKE N'%S%')AND(tkv.pozice NOT LIKE N'%T%')AND(tkv.pozice NOT LIKE N'%U%')AND(tkv.pozice NOT LIKE N'%V%')AND(tkv.pozice NOT LIKE N'%W%')AND(tkv.pozice NOT LIKE N'%X%')AND(tkv.pozice NOT LIKE N'%Y%')AND(tkv.pozice NOT LIKE N'%Z%')AND(tkzV.Nazev1 not like N'M2 0%')AND(tkzV.Nazev1 not like N'M4 0%'))*/
GO

