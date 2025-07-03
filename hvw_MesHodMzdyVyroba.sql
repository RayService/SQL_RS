USE [RayService]
GO

/****** Object:  View [dbo].[hvw_MesHodMzdyVyroba]    Script Date: 03.07.2025 15:25:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_MesHodMzdyVyroba] AS SELECT Datum, DATEPART(YEAR, Datum) datum_Y, DATEPART(QUARTER,Datum) datum_Q, DATEPART(MONTH,Datum) datum_M, Orig.Zamestnanec 
, Orig.NormaObsluhy, Orig.SkutCasObsluhy, Orig.OdprHodMzdy, ISNULL(OdpracHod.OdpracHodiny, 0) AS OdpracHodiny 
,ISNULL(Orig.Stredisko, 'Útvar nezadán')   AS Stredisko                --<< Pridano
FROM
(
SELECT 
convert(datetime,CONVERT(VARCHAR(4),datum_Y) +RIGHT('0' + CONVERT(VARCHAR(2),datum_M),2)+'01')  AS Datum
,(DATEPART(QUARTER,convert(datetime,CONVERT(VARCHAR(4),datum_Y) +RIGHT('0' + CONVERT(VARCHAR(2),datum_M),2)+'01'))) AS Datum_Q
,datum_M
,datum_Y
, Zamestnanec, SUM(Nor_cas_Obsluhy_H) AS NormaObsluhy, SUM(Sk_cas_Obsluhy_H) AS SkutCasObsluhy, 
(select HodOdpracovane FROM  TabZamVyp WHERE x_evop.Zamestnanec = TabZamVyp.ZamestnanecId 
                    AND (select IdObdobi FROM TabMzdObd WHERE x_evop.datum_Y = TabMzdObd.Rok and x_evop.datum_M = TabMzdObd.Mesic) = TabZamVyp.IdObdobi 
) AS OdprHodMzdy
--- Pridano odsud ------
,(select ISNULL(TabZamMzd.Stredisko, 'Útvar nezadán!') FROM TabZamVyp 
             JOIN TabZamMzd ON TabZamMzd.ZamestnanecId=TabZamVyp.ZamestnanecId AND TabZamMzd.IdObdobi=TabZamVyp.IdObdobi
             WHERE x_evop.Zamestnanec = TabZamVyp.ZamestnanecId 
                    AND (select IdObdobi FROM TabMzdObd WHERE x_evop.datum_Y = TabMzdObd.Rok and x_evop.datum_M = TabMzdObd.Mesic) = TabZamVyp.IdObdobi 
) AS Stredisko
--- Pridano az sem ------
             FROM TabPrikazMzdyAZmetky as x_evop 
             WHERE x_evop.Zamestnanec IS not null
             GROUP BY x_evop.datum_Y,x_evop.datum_M, x_evop.Zamestnanec
) AS Orig
LEFT JOIN
(
SELECT datum_M, datum_Y, Zamestnanec, 
SUM(CASE WHEN  TypMzdy='0' AND sk_cas_Obsluhy_H=0 THEN nor_cas_Obsluhy_H ELSE  sk_cas_Obsluhy_H END) AS OdpracHodiny
FROM TabPrikazMzdyAZmetky as x_evop 
WHERE Zamestnanec is not null     
--AND (CASE WHEN TypMzdy='0' THEN nor_cas_Obsluhy_H ELSE  sk_cas_Obsluhy_H END) 
--       <> (CASE WHEN  TypMzdy='0' AND sk_cas_Obsluhy_H=0 THEN nor_cas_Obsluhy_H ELSE  sk_cas_Obsluhy_H END)
GROUP BY datum_M, datum_Y, Zamestnanec
) OdpracHod ON Orig.datum_M = OdpracHod.datum_M AND Orig.datum_Y = OdpracHod.datum_Y and Orig.Zamestnanec = OdpracHod.Zamestnanec
GO

