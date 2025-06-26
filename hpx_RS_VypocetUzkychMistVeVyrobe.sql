USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VypocetUzkychMistVeVyrobe]    Script Date: 26.06.2025 14:00:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VypocetUzkychMistVeVyrobe]
AS
--nejprve vymažeme data pro dnešní den
DELETE FROM Tabx_RS_UzkaMistaVyroby WHERE (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatumVypoctu))))=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
--1. K zadání do přípravy výroby
--vložíme veškerá data s dnešním datem
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F0 Týdenní check_čeká na zadání do skladu_elektrom
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,1 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')
AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=0)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=0)))

--F0 Týdenní check_čeká na zadání do skladu_kabeláže
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,1 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')
AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=0)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=0)))
)
--2. V přípravě výroby 
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F1 Týdenní check_ve skladu_elektrom.
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,2 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')
AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=1)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=0)))

--F1 Týdenní check_ve skladu_kabeláže
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,2 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')
AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=1)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=0)))
) 
--3. Čeká do výroby
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F2 Týdenní check_připraveno do výroby_elektrom.
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,3 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')
AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=1)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=1)AND((CONVERT(BIT,Case when exists(select * 
								from Gatema_TermETH T WITH(NOLOCK) inner join TabPrPostup P WITH(NOLOCK) ON 
									  T.Akce>0 AND 
									  P.IDPrikaz=T.IDPrikaz AND 
									  P.Doklad=T.Doklad AND 
									  P.Alt=T.Alt AND 
									  P.IDOdchylkyDo IS NULL
								where P.IDPrikaz=TabPrikaz.ID) then 1 else 0 end))=0)))

--F2 Týdenní check_připraveno do výroby_kabeláže
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,3 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')
AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=1)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=1)AND((CONVERT(BIT,Case when exists(select * 
								from Gatema_TermETH T WITH(NOLOCK) inner join TabPrPostup P WITH(NOLOCK) ON 
									  T.Akce>0 AND 
									  P.IDPrikaz=T.IDPrikaz AND 
									  P.Doklad=T.Doklad AND 
									  P.Alt=T.Alt AND 
									  P.IDOdchylkyDo IS NULL
								where P.IDPrikaz=TabPrikaz.ID) then 1 else 0 end))=0)))
)
--4. Ve výrobě 
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F3 Týdenní check_ve výrobě_elektrom.
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,4 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabPohybyZbozi VPrikazRezervace ON VPrikazRezervace.ID=TabPrikaz.IDRezervace
  LEFT OUTER JOIN TabPohybyZbozi_EXT VPrikazRezervace_EXT ON VPrikazRezervace_EXT.ID=VPrikazRezervace.ID
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')AND(TabPrikaz.Rada<>N'400')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND(((CONVERT(BIT,Case when exists(select * 
								from Gatema_TermETH T WITH(NOLOCK) inner join TabPrPostup P WITH(NOLOCK) ON 
									  T.Akce>0 AND 
									  P.IDPrikaz=T.IDPrikaz AND 
									  P.Doklad=T.Doklad AND 
									  P.Alt=T.Alt AND 
									  P.IDOdchylkyDo IS NULL
								where P.IDPrikaz=TabPrikaz.ID) then 1 else 0 end))=1)AND((((ISNULL(TabPrikaz_EXT._PredMK,0)=0)AND(ISNULL(TabPrikaz_EXT._PoMK,0)=0))OR((ISNULL(TabPrikaz_EXT._PredMK,0)=1)AND(ISNULL(TabPrikaz_EXT._PoMK,0)=1)))AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=0))))

--F3 Týdenní check_ve výrobě_kabeláže
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,4 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabPohybyZbozi VPrikazRezervace ON VPrikazRezervace.ID=TabPrikaz.IDRezervace
  LEFT OUTER JOIN TabPohybyZbozi_EXT VPrikazRezervace_EXT ON VPrikazRezervace_EXT.ID=VPrikazRezervace.ID
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')AND(TabPrikaz.Rada<>N'400')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=40)OR(TabPrikaz.StavPrikazu=20))AND(((CONVERT(BIT,Case when exists(select * 
								from Gatema_TermETH T WITH(NOLOCK) inner join TabPrPostup P WITH(NOLOCK) ON 
									  T.Akce>0 AND 
									  P.IDPrikaz=T.IDPrikaz AND 
									  P.Doklad=T.Doklad AND 
									  P.Alt=T.Alt AND 
									  P.IDOdchylkyDo IS NULL
								where P.IDPrikaz=TabPrikaz.ID) then 1 else 0 end))=1)AND((((ISNULL(TabPrikaz_EXT._PredMK,0)=0)AND(ISNULL(TabPrikaz_EXT._PoMK,0)=0))OR(ISNULL(TabPrikaz_EXT._PredMK,0)=1)AND(ISNULL(TabPrikaz_EXT._PredMK,0)=1))AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=0))))
)
--5. Na MK 
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F3.5 Týdenní check_na MK_elektrom._new
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,5 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabPohybyZbozi VPrikazRezervace ON VPrikazRezervace.ID=TabPrikaz.IDRezervace
  LEFT OUTER JOIN TabPohybyZbozi_EXT VPrikazRezervace_EXT ON VPrikazRezervace_EXT.ID=VPrikazRezervace.ID
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND((ISNULL(TabPrikaz_EXT._PredMK,0)=1)AND(ISNULL(TabPrikaz_EXT._PoMK,0)=0)))

--F3.5 Týdenní check_na MK_kabeláže_new
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,5 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabPohybyZbozi VPrikazRezervace ON VPrikazRezervace.ID=TabPrikaz.IDRezervace
  LEFT OUTER JOIN TabPohybyZbozi_EXT VPrikazRezervace_EXT ON VPrikazRezervace_EXT.ID=VPrikazRezervace.ID
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND((ISNULL(TabPrikaz_EXT._PredMK,0)=1)AND(ISNULL(TabPrikaz_EXT._PoMK,0)=0)))
)
--6. Na TK - už rozděleno minulý týden
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
(
SELECT
TabPrikaz.ID AS IDPrikaz,
 (
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = tpl.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,6 AS DruhMista
,GETDATE()
FROM TabPrikaz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=TabPrikaz.IDTabKmen
LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
LEFT OUTER JOIN TabPlan tpl ON tpl.ID=TabPrikaz.IDPlan
WHERE
(((tkz.SkupZbo<>N'800')AND(tkz.SkupZbo<>N'899')AND(tkz.SkupZbo<>N'850'))AND(TabPrikaz.DatPorizeni_X>='1.1.2022')AND(TabPrikaz.KmenoveStredisko like N'2%')AND(TabPrikaz.Rada<=N'900')AND(TabPrikaz.StavPrikazu=30)AND(ISNULL(TabPrikaz_EXT._Zapujcka,0)=0)AND((((ISNULL(TabPrikaz_EXT._UvolSer,0)=1)OR(ISNULL(TabPrikaz_EXT._fair,0)=1))AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND(ISNULL(TabPrikaz_EXT._PripFAI,0)=0)AND(ISNULL(TabPrikaz_EXT._EXT_RS_after_validation_ready_fair,0)=0)AND((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=0))OR((ISNULL(TabPrikaz_EXT._fair,0)=0)AND(ISNULL(TabPrikaz_EXT._UvolSer,0)=0)AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=0))))
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,
 (
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = tpl.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,6 AS DruhMista
,GETDATE()
FROM TabPrikaz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=TabPrikaz.IDTabKmen
LEFT OUTER JOIN TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
LEFT OUTER JOIN TabPlan tpl ON tpl.ID=TabPrikaz.IDPlan
WHERE
(((tkz.SkupZbo=N'800')OR(tkz.SkupZbo=N'899')OR(tkz.SkupZbo=N'850'))AND(TabPrikaz.DatPorizeni_X>='1.1.2022')AND(TabPrikaz.KmenoveStredisko like N'2%')AND(TabPrikaz.Rada<=N'900')AND(TabPrikaz.StavPrikazu=30)AND(ISNULL(TabPrikaz_EXT._Zapujcka,0)=0)AND((((ISNULL(TabPrikaz_EXT._UvolSer,0)=1)OR(ISNULL(TabPrikaz_EXT._fair,0)=1))AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND(ISNULL(TabPrikaz_EXT._PripFAI,0)=0)AND(ISNULL(TabPrikaz_EXT._EXT_RS_after_validation_ready_fair,0)=0)AND((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=0))OR((ISNULL(TabPrikaz_EXT._fair,0)=0)AND(ISNULL(TabPrikaz_EXT._UvolSer,0)=0)AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=0))))
)

--7. K validaci 
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F5 Týdenní check_k validaci_elektrom._new
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,7 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabKmenZbozi_EXT VPrikazKmenZbozi_EXT ON VPrikazKmenZbozi_EXT.ID=VPrikazKmenZbozi.ID
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=1)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=1)AND((CONVERT(BIT,Case when exists(select * 
								from Gatema_TermETH T WITH(NOLOCK) inner join TabPrPostup P WITH(NOLOCK) ON 
									  T.Akce>0 AND 
									  P.IDPrikaz=T.IDPrikaz AND 
									  P.Doklad=T.Doklad AND 
									  P.Alt=T.Alt AND 
									  P.IDOdchylkyDo IS NULL
								where P.IDPrikaz=TabPrikaz.ID) then 1 else 0 end))=1)AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND(ISNULL(TabPrikaz_EXT._PripFAI,0)=1)AND(ISNULL(TabPrikaz_EXT._EXT_RS_after_validation_ready_fair,0)=0)
								AND((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),
								(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=0)))

--F5 Týdenní check_k validaci_kabeláže_new
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,7 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabKmenZbozi_EXT VPrikazKmenZbozi_EXT ON VPrikazKmenZbozi_EXT.ID=VPrikazKmenZbozi.ID
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND((ISNULL(TabPrikaz_EXT._vPriprave,0)=1)AND(ISNULL(TabPrikaz_EXT._Popisstavu,0)=1)AND((CONVERT(BIT,Case when exists(select * 
								from Gatema_TermETH T WITH(NOLOCK) inner join TabPrPostup P WITH(NOLOCK) ON 
									  T.Akce>0 AND 
									  P.IDPrikaz=T.IDPrikaz AND 
									  P.Doklad=T.Doklad AND 
									  P.Alt=T.Alt AND 
									  P.IDOdchylkyDo IS NULL
								where P.IDPrikaz=TabPrikaz.ID) then 1 else 0 end))=1)AND(ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND(ISNULL(TabPrikaz_EXT._PripFAI,0)=1)AND(ISNULL(TabPrikaz_EXT._EXT_RS_after_validation_ready_fair,0)=0)
								AND((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),
								(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=0)))
) 
--8. K FAIR
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F6 Týdenní check_k FAIR_elektrom._new
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,8 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabKmenZbozi_EXT VPrikazKmenZbozi_EXT ON VPrikazKmenZbozi_EXT.ID=VPrikazKmenZbozi.ID
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND((ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND(ISNULL(TabPrikaz_EXT._PripFAI,0)=1)AND(ISNULL(TabPrikaz_EXT._EXT_RS_after_validation_ready_fair,0)=1)AND(ISNULL(TabPrikaz_EXT._fair_proveden,0)=0)))

--F6 Týdenní check_k FAIR_kabeláže_new
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,8 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabKmenZbozi_EXT VPrikazKmenZbozi_EXT ON VPrikazKmenZbozi_EXT.ID=VPrikazKmenZbozi.ID
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND((ISNULL(TabPrikaz_EXT._popistatvu4,0)=1)AND(ISNULL(TabPrikaz_EXT._PripFAI,0)=1)AND(ISNULL(TabPrikaz_EXT._EXT_RS_after_validation_ready_fair,0)=1)AND(ISNULL(TabPrikaz_EXT._fair_proveden,0)=0)))
) 
--9. K zaskladnění
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--F7 Týdenní check_po TK k zaskladnění_elektrom._new
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,9 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN hvw_ZAKPRIJ Vudv2D02BEE015E34D3F8FF8A2CCB1C835F1 ON TabPrikaz.IDZakazka = Vudv2D02BEE015E34D3F8FF8A2CCB1C835F1.ID
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))
AND(((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),
(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=1)AND(TabPrikaz.kusy_zive>0)))

--F7 Týdenní check_po TK k zaskladnění_kabeláže_new
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,9 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabParKmZ VPrikazParKmZ ON TabPrikaz.IDTabKmen=VPrikazParKmZ.IDKmenZbozi
  LEFT OUTER JOIN hvw_ZAKPRIJ Vudv2D02BEE015E34D3F8FF8A2CCB1C835F1 ON TabPrikaz.IDZakazka = Vudv2D02BEE015E34D3F8FF8A2CCB1C835F1.ID
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN  TabPrikaz_EXT ON TabPrikaz_EXT.ID=TabPrikaz.ID
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')AND((TabPrikaz.StavPrikazu=30)OR(TabPrikaz.StavPrikazu=20))AND(((CAST(COALESCE((SELECT NULLIF(_popistavu5_zad,0) FROM TabPrikaz_EXT WITH(NOLOCK) WHERE ID = TabPrikaz.ID),(CASE WHEN EXISTS(SELECT * FROM TabPrPostup WITH(NOLOCK) WHERE IDOdchylkyDo IS NULL AND IDPrikaz = TabPrikaz.ID AND prednastaveno=1 AND Odvadeci = 1 AND Kusy_zive = 0.) THEN 1 ELSE 0 END)) as BIT))=1)AND(TabPrikaz.kusy_zive>0)))
)
--10. Realizováno sklad
INSERT INTO Tabx_RS_UzkaMistaVyroby (IDPrikaz, ObratPolozky, Typ, DruhMista, DatumVypoctu)
--V. RoH_obrat _všechny řady_ISO_týden_konec_elektro
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'E' AS Typ
,10 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabKmenZbozi_EXT VPrikazKmenZbozi_EXT ON VPrikazKmenZbozi_EXT.ID=VPrikazKmenZbozi.ID
WHERE
((VPrikazKmenZbozi.SkupZbo<>N'800')AND(VPrikazKmenZbozi.SkupZbo<>N'880')AND(VPrikazKmenZbozi.SkupZbo<>N'850')AND(VPrikazKmenZbozi.SkupZbo<>N'899')AND(TabPrikaz.Rada<=N'900')
AND(((DATEPART(ISO_WEEK,TabPrikaz.ukonceni)))=DATEPART(ISO_WEEK,GETDATE()))AND(TabPrikaz.ukonceni_Y=DATEPART(YEAR,GETDATE())))

--V. RoH_obrat _všechny řady_ISO_týden_konec_kabeláž
)
UNION
(
SELECT
TabPrikaz.ID AS IDPrikaz,(
SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ WITH(NOLOCK) ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = VPrikazPlan.ID
GROUP BY TP.ID, TP.mnozstvi
) AS ObratPolozky,
'K' AS Typ
,10 AS DruhMista
,GETDATE()
FROM TabPrikaz
  LEFT OUTER JOIN TabKmenZbozi VPrikazKmenZbozi ON VPrikazKmenZbozi.ID=TabPrikaz.IDTabKmen
  LEFT OUTER JOIN TabPlan VPrikazPlan ON VPrikazPlan.ID=TabPrikaz.IDPlan
  LEFT OUTER JOIN TabZakazka VPrikazZakazka ON VPrikazZakazka.ID=TabPrikaz.IDZakazka
  LEFT OUTER JOIN TabKmenZbozi_EXT VPrikazKmenZbozi_EXT ON VPrikazKmenZbozi_EXT.ID=VPrikazKmenZbozi.ID
WHERE
(((VPrikazKmenZbozi.SkupZbo=N'880')OR(VPrikazKmenZbozi.SkupZbo=N'800')OR(VPrikazKmenZbozi.SkupZbo=N'850')OR(VPrikazKmenZbozi.SkupZbo=N'899'))AND(TabPrikaz.Rada<=N'900')
AND(((DATEPART(ISO_WEEK,TabPrikaz.ukonceni)))=DATEPART(ISO_WEEK,GETDATE()))AND(TabPrikaz.ukonceni_Y=DATEPART(YEAR,GETDATE())))
)




GO

