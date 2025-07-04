USE [RayService]
GO

/****** Object:  View [dbo].[TabGprStromProjView]    Script Date: 04.07.2025 11:22:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprStromProjView] AS 
SELECT ID = Z.ID,
       Rada = Z.Rada,
       Strom = TabGprProjektyParametry.Strom,
       TYP = CASE WHEN ZNad.ID IS NULL THEN 0 ELSE 1 END,   
       Oznaceni = Z.CisloZakazky,
       Nazev = Z.Nazev,
       ProcentoRealizace =  ((
SELECT ProcentoSplneni=ISNULL(convert(numeric(5,2), vyp.ProcentoSplneni) ,0) 
FROM TabGprProjektyView p
CROSS APPLY ( SELECT datum = convert(date, GetDate())) dnes
LEFT JOIN TabGprProjektyView pn ON pn.CisloZakazky = p.NadrizenaZak
INNER JOIN TabGprProjektyParametry pp on pp.ID = p.ID
OUTER APPLY (
	SELECT ProcentoSplneni = SUM(trvani1.dny * plneni1.procento) / SUM(trvani1.dny)
	FROM TabGprProjektyParametry pp1
	INNER JOIN TabGprUlohy u1 on u1.IDZakazka = pp1.ID
    outer apply (
        select datum = convert(date, ISNULL(u1.PlanZahajeni_X, ISNULL(u1.PlanUkonceni_X, GetDate())))
    ) as PlanZahajeni
    outer apply (
        select datum = convert(date, ISNULL(u1.PlanUkonceni_X, ( CASE WHEN PlanZahajeni.Datum >  GetDate() THEN PlanZahajeni.Datum ELSE GETDATE() END)))
    ) as PlanUkonceni
	outer apply (
		SELECT Dny = 1 + DateDiff(day, PlanZahajeni.datum , PlanUkonceni.datum)
	) trvani1
	outer apply (
		SELECT procento = CASE WHEN (TabGprUlohy.Uzavreno = 1 OR TabGprUlohy.ProcentoRealizace >= 100) THEN 100.0 ELSE
                                 ISNULL(TabGprUlohy.ProcentoRealizace, (
						       	
								    (SELECT AVG(v.p) 
									    FROM (
	SELECT p= convert(NUMERIC(5,2),(	
		SELECT AVG(v1.procento)
		FROM	
			 ( SELECT procento=ISNULL(case when max(convert(int,uz.dokonceno)) = 1 then 100.0 
                                          else  ISNULL(MAX(uz.ProcPlneni), 
                                               (CASE WHEN MAX(uz.Mnozstvi) = 0 THEN 0 ELSE 
                                               (   (CASE WHEN SUM(v.Mnozstvi)>MAX(uz.Mnozstvi) THEN MAX(uz.Mnozstvi) ELSE SUM(v.Mnozstvi) END )
                                               / MAX(uz.Mnozstvi)*100.0)
                                               
                                               END))
                                     end, 0.0)
			  FROM TabGprUlohyPerZdroje uz
			  LEFT JOIN TabGprVykazPracePerZdr v on v.IDGprUlohyPerZdroje=uz.ID
			  WHERE uz.IDGprUlohy=TabGprUlohy.ID 
					AND (uz.Mnozstvi > 0.0 OR uz.ProcPlneni IS NOT NULL)
			  GROUP BY uz.ID
			) v1
	))
										    UNION ALL 
	SELECT p =	convert(NUMERIC(5,2),(	
		SELECT AVG(v1.procento)
		FROM	
			(
			  SELECT procento=ISNULL( case when max(convert(int,uz.dokonceno)) = 1 then 100.0 
                                           else ((CASE WHEN SUM(v.Mnozstvi)>MAX(uz.Mnozstvi) THEN MAX(uz.Mnozstvi) ELSE SUM(v.Mnozstvi) END ) / MAX(uz.Mnozstvi)*100.0) 
                                           end ,0.0)
			  FROM TabGprUlohyNepZdroje uz
			  LEFT JOIN TabGprVykazNakladuNepZdr v on v.IDGprUlohyNepZdroje=uz.ID
			  WHERE uz.IDGprUlohy=TabGprUlohy.ID 
			     	 AND	uz.Mnozstvi > 0.0
			  GROUP BY uz.ID
			  HAVING MAX(uz.Mnozstvi)>0.0
			) v1
	))
										    UNION ALL 
										    SELECT p=TabGprUlohy.SkutProcRealizaceVyrZdr
										    UNION ALL 
	SELECT p =	convert(NUMERIC(5,2),(	
		SELECT AVG(v2.procento)
		FROM	
        (SELECT procento = (CASE WHEN (100.0 - v1.procento) < 0.01 THEN 100.0 ELSE v1.procento END) FROM 
			(
			  SELECT procento=ISNULL(
                                        CASE WHEN MAX(convert(int,uz.Uzavreno)) = 1 THEN 100.0 ELSE   
                                        (( 
                                         CASE 
                                         WHEN SUM(v.Mnozstvi*v.PrepocetMnozstvi)>MAX(uz.Mnozstvi*uz.PrepocetMnozstvi) 
			                             THEN MAX(uz.Mnozstvi*uz.PrepocetMnozstvi) 
                                         ELSE SUM(v.Mnozstvi*v.PrepocetMnozstvi) 
                                         END 
                                        ) / MAX(uz.Mnozstvi*uz.PrepocetMnozstvi)*100.0)
                                        END
                                     ,0.0)
			  FROM TabGprUlohyMatZdroje uz              
			  LEFT JOIN TabGprVykazNakladuMatZdr v on v.IDGprUlohyMatZdroje=uz.ID
			  WHERE uz.IDGprUlohy=TabGprUlohy.ID 
					AND uz.Mnozstvi > 0.0
			  GROUP BY uz.ID
			  HAVING MAX(uz.Mnozstvi*uz.PrepocetMnozstvi)>0.0
			) v1
       ) v2 
	))
                       ) as v ))	
		                            )
                             END       
	   FROM TabGprUlohy WHERE ID=u1.ID 
	) plneni1
	WHERE pp1.IDRidiciZakazka = pp.IDRidiciZakazka AND pp1.Strom like pp.Strom + '%'
	HAVING SUM(trvani1.dny) > 0.0 
) as vyp
WHERE p.ID = TabGprProjektyParametry.ID
)) ,
       DatumStartPlan = Z.DatumStartPlan,
       DatumKonecPlan = Z.DatumKonecPlan,
       SkutZahajeni = (SELECT min(u.SkutZahajeni)
                      FROM TabGprProjektyParametry pp
                      INNER JOIN TabGprUlohy u on u.IDZakazka=pp.ID
                      WHERE pp.IDRidiciZakazka=TabGprProjektyParametry.IDRidiciZakazka AND pp.Strom LIKE TabGprProjektyParametry.Strom+'%'),
       SkutUkonceni = (SELECT max(u.SkutUkonceni)
                          FROM TabGprProjektyParametry pp
                          INNER JOIN TabGprUlohy u on u.IDZakazka=pp.ID
                          OUTER APPLY (
    SELECT splneno = (
    SELECT     
    CONVERT(bit, 
    (CASE WHEN (TabGprUlohy.Uzavreno = 1 OR TabGprUlohy.ProcentoRealizace >= 100 
                OR 
                ( TabGprUlohy.ProcentoRealizace IS NULL AND (                 
                 (convert(numeric(5,2), TabGprUlohy.SkutProcRealizaceVyrZdr) >= 100.0)
                 OR (
                    (
                        EXISTS(SELECT 1 FROM TabGprUlohyPerZdroje upz where upz.IDGprUlohy = TabGprUlohy.ID AND (upz.Dokonceno = 1 OR upz.ProcPlneni = 100.0)) 
                        OR 
                        EXISTS(SELECT 1 FROM TabGprUlohyNepZdroje upz where upz.IDGprUlohy = TabGprUlohy.ID AND upz.Dokonceno = 1) 
                    )
                    AND 
                    NOT EXISTS(SELECT 1 FROM TabGprUlohyPerZdroje upz where upz.IDGprUlohy = TabGprUlohy.ID AND upz.Dokonceno = 0 AND isnull(upz.ProcPlneni,0.0) <> 100.0) 
                    AND 
                    NOT EXISTS(SELECT 1 FROM TabGprUlohyNepZdroje upz where upz.IDGprUlohy = TabGprUlohy.ID AND upz.Dokonceno = 0) 
                   )
                )))
         THEN 1 ELSE 0 END)
         ) 
    FROM TabGprUlohy 
    WHERE TabGprUlohy.Id = u.ID
    )
                          ) as vyp 
                          WHERE pp.IDRidiciZakazka=TabGprProjektyParametry.IDRidiciZakazka AND pp.Strom LIKE TabGprProjektyParametry.Strom+'%'
                          having max(convert(int,vyp.Splneno))=1 AND min(convert(int,vyp.Splneno))=1),
       IDNadZak = ZNad.ID,
       IDRidZak = TabGprProjektyParametry.IDRidiciZakazka,
       Poradi = NULL,
       Zodpovida = ISNULL(cz.CisloJmenoTituly, ''),
       Stredisko = ISNULL(s.Nazev, ''),
       KmenoveStredisko = ISNULL(ks.Nazev, ''),
       Ukonceno = z.Ukonceno,
       Stav = z.Stav,
       ProcentoReal = NULL,
       Identifikator = Z.Identifikator,
       Priorita = Z.Priorita,
       StavFakturace = TabGprProjektyParametry.StavFakturace,
       SmluvenaCastka = TabGprProjektyParametry.SmluvenaCastka,
       SmluvenaCastkaVal = TabGprProjektyParametry.SmluvenaCastkaVal,
       FakturovanaCastka = TabGprProjektyParametry.FakturovanaCastka,
       FakturovanoCelkem = TabGprProjektyParametry.FakturovanoCelkem,
       FakturovanaCastkaVal = TabGprProjektyParametry.FakturovanaCastkaVal,
       FakturacniCenaCelPlan = TabGprProjektyParametry.FakturacniCenaCelPlan,
       NakladovaCenaCelPlan = TabGprProjektyParametry.NakladovaCenaCelPlan,
       FakturacniCenaCelSkut = TabGprProjektyParametry.FakturacniCenaCelSkut,
       NakladovaCenaCelSkut = TabGprProjektyParametry.NakladovaCenaCelSkut,
       Uzavreno = NULL,
       DatUzavreni = NULL,
       OdhadovaneNaklady = TabGprProjektyParametry.OdhadovaneNaklady,
       OdhadovaneVynosy = TabGprProjektyParametry.OdhadovaneVynosy
FROM TabZakazka Z
Inner join TabGprProjektyParametry on TabGprProjektyParametry.ID = Z.id
LEFT JOIN TabCisZam cz on cz.Cislo = z.Zodpovida
LEFT JOIN TabZakazka ZNad on ZNad.CisloZakazky = Z.NadrizenaZak
LEFT JOIN TabStrom s on z.Stredisko=s.Cislo
LEFT JOIN TabStrom ks on TabGprProjektyParametry.KmenoveStredisko=ks.Cislo

UNION ALL

SELECT ID = - TabGprUlohy.ID,
       Rada = NULL,
       Strom = zpp.Strom, 
       Typ = 2 + TabGprUlohy.TypUlohy,
       Oznaceni = TabGprUlohy.Oznaceni,
       Nazev = TabGprUlohy.Nazev,
       ProcentoRealizace = (ISNULL((convert(numeric(5,2), 
CASE WHEN  (TabGprUlohy.Uzavreno = 1 OR TabGprUlohy.ProcentoRealizace >= 100) THEN 100.0 ELSE
ISNULL(TabGprUlohy.ProcentoRealizace,
(SELECT AVG(v.p) FROM ( 
	SELECT p= convert(NUMERIC(5,2),(	
		SELECT AVG(v1.procento)
		FROM	
			(
			  SELECT procento=ISNULL(case when max(convert(int,uz.dokonceno)) = 1 then 100.0 
                                          else  ISNULL(MAX(uz.ProcPlneni), 
                                               (CASE WHEN MAX(uz.Mnozstvi) = 0 THEN 0 ELSE 
                                               (   (CASE WHEN SUM(v.Mnozstvi)>MAX(uz.Mnozstvi) THEN MAX(uz.Mnozstvi) ELSE SUM(v.Mnozstvi) END )
                                               / MAX(uz.Mnozstvi)*100.0)
                                               
                                               END))
                                     end, 0.0)
			  FROM TabGprUlohyPerZdroje uz
			  LEFT JOIN TabGprVykazPracePerZdr v on v.IDGprUlohyPerZdroje=uz.ID
			  WHERE uz.IDGprUlohy=TabGprUlohy.ID 
					AND (uz.Mnozstvi > 0.0 OR uz.ProcPlneni IS NOT NULL)
			  GROUP BY uz.ID
			) v1
	))
										    UNION ALL 
	SELECT p =	convert(NUMERIC(5,2),(	
		SELECT AVG(v1.procento)
		FROM	
			(
			  SELECT procento=ISNULL( case when max(convert(int,uz.dokonceno)) = 1 then 100.0 
                                           else ((CASE WHEN SUM(v.Mnozstvi)>MAX(uz.Mnozstvi) THEN MAX(uz.Mnozstvi) ELSE SUM(v.Mnozstvi) END ) / MAX(uz.Mnozstvi)*100.0) 
                                           end ,0.0)
			  FROM TabGprUlohyNepZdroje uz
			  LEFT JOIN TabGprVykazNakladuNepZdr v on v.IDGprUlohyNepZdroje=uz.ID
			  WHERE uz.IDGprUlohy=TabGprUlohy.ID 
					and uz.Mnozstvi > 0.0
			  GROUP BY uz.ID
			  HAVING MAX(uz.Mnozstvi)>0.0
			) v1
	))
										    UNION ALL 
										    SELECT p=TabGprUlohy.SkutProcRealizaceVyrZdr
										    UNION ALL 
	SELECT p =	convert(NUMERIC(5,2),(	
		SELECT AVG(v2.procento)
		FROM	
        (SELECT procento = (CASE WHEN (100.0 - v1.procento) < 0.01 THEN 100.0 ELSE v1.procento END) FROM 
			(
			  SELECT procento=ISNULL(
                                        CASE WHEN MAX(convert(int,uz.Uzavreno)) = 1 THEN 100.0 ELSE   
                                        (( 
                                         CASE 
                                         WHEN SUM(v.Mnozstvi*v.PrepocetMnozstvi)>MAX(uz.Mnozstvi*uz.PrepocetMnozstvi) 
			                             THEN MAX(uz.Mnozstvi*uz.PrepocetMnozstvi) 
                                         ELSE SUM(v.Mnozstvi*v.PrepocetMnozstvi) 
                                         END 
                                        ) / MAX(uz.Mnozstvi*uz.PrepocetMnozstvi)*100.0)
                                        END
                                     ,0.0)
			  FROM TabGprUlohyMatZdroje uz              
			  LEFT JOIN TabGprVykazNakladuMatZdr v on v.IDGprUlohyMatZdroje=uz.ID
			  WHERE uz.IDGprUlohy=TabGprUlohy.ID 
					and uz.Mnozstvi > 0.0
			  GROUP BY uz.ID
			  HAVING MAX(uz.Mnozstvi*uz.PrepocetMnozstvi)>0.0
			) v1
       ) v2 
	))
) as v )) 
 END) ),0.0)) ,
       DatumStartPlan = TabGprUlohy.PlanZahajeni,
       DatumKonecPlan = TabGprUlohy.PlanUkonceni,
       SkutZahajeni = TabGprUlohy.SkutZahajeni,
       SkutUkonceni = TabGprUlohy.SkutUkonceni,
       IDNadZak = TabGprUlohy.IDZakazka,
       IDRidZak = zpp.IDRidiciZakazka,
       Poradi = TabGprUlohy.Poradi,
       Zodpovida = ISNULL(cz.CisloJmenoTituly, ''),
       Stredisko = NULL,
       KmenoveStredisko = ISNULL(ks.Nazev, ''),
       Ukonceno = NULL,
       Stav = TabGprUlohy.Stav,
       ProcentoReal = TabGprUlohy.ProcentoRealizace,
       Identifikator = '',
       Priorita = '',
       StavFakturace = TabGprUlohy.StavFakturace,
       SmluvenaCastka = TabGprUlohy.SmluvenaCastka,
       SmluvenaCastkaVal = TabGprUlohy.SmluvenaCastkaVal,
       FakturovanaCastka = TabGprUlohy.FakturovanaCastka,
       FakturovanoCelkem = TabGprUlohy.FakturovanoCelkem,
       FakturovanaCastkaVal = TabGprUlohy.FakturovanaCastkaVal,
       FakturacniCenaCelPlan = TabGprUlohy.FakturacniCenaCelPlan,
       NakladovaCenaCelPlan = TabGprUlohy.NakladovaCenaCelPlan,
       FakturacniCenaCelSkut = TabGprUlohy.FakturacniCenaCelSkut,
       NakladovaCenaCelSkut = TabGprUlohy.NakladovaCenaCelSkut,
       Uzavreno = TabGprUlohy.Uzavreno,
       DatUzavreni = TabGprUlohy.DatUzavreni,
       OdhadovaneNaklady = NULL,
       OdhadovaneVynosy = NULL
FROM TabGprUlohy 
INNER JOIN TabZakazka z on z.ID = TabGprUlohy.IDZakazka
LEFT JOIN TabCisZam cz on cz.Cislo = TabGprUlohy.Zodpovida
Inner join TabGprProjektyParametry zpp on zpp.ID = Z.id
LEFT JOIN TabStrom ks on TabGprUlohy.ProvadeciStredisko=ks.Cislo
GO

