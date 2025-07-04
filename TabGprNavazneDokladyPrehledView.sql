USE [RayService]
GO

/****** Object:  View [dbo].[TabGprNavazneDokladyPrehledView]    Script Date: 04.07.2025 11:07:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprNavazneDokladyPrehledView] AS 
SELECT IDZakazka=z1.ID, IDGPRUloha=u1.ID,IDPohybuZbozi=pol.id, TypZdroje=pol.TypZdroje, DruhPohybuZbo=pz1.DruhPohybuZbo
FROM TabZakazka z1 
INNER JOIN TabGprProjektyParametry pp1 on pp1.ID = z1.ID
LEFT JOIN TabGprUlohy u1 on u1.IDZakazka = z1.ID
CROSS APPLY (
    SELECT pz.ID, nd.TypZdroje
    FROM TabGprVykazPracePerZdr v
    inner join TabGprNavazneDoklady nd on nd.IDZdroje=v.ID and nd.TypZdroje=1
    INNER JOIN TabPohybyZbozi pz on pz.ID=nd.IDPolozkyDokladu 
    WHERE  v.IDGprUlohy=u1.id
    UNION ALL
    SELECT pz.ID, nd.TypZdroje
    FROM TabGprVykazNakladuNepZdr v
    inner join TabGprNavazneDoklady nd on nd.IDZdroje=v.ID and nd.TypZdroje=2
    INNER JOIN TabPohybyZbozi pz on pz.ID=nd.IDPolozkyDokladu 
    WHERE  v.IDGprUlohy=u1.ID
    UNION ALL
    SELECT pz.ID, nd.TypZdroje
    FROM TabGprVykazNakladuMatZdr v
    inner join TabGprNavazneDoklady nd on nd.IDZdroje=v.ID and nd.TypZdroje=3
    INNER JOIN TabPohybyZbozi pz on pz.ID=nd.IDPolozkyDokladu 
    WHERE  v.IDGprUlohy=u1.ID
    UNION ALL
    SELECT pz.ID, nd.TypZdroje
    FROM TabGprNavazneDoklady nd 
    INNER JOIN TabPohybyZbozi pz on pz.ID=nd.IDPolozkyDokladu 
    WHERE  nd.IDZdroje=u1.id and nd.TypZdroje=8
    UNION ALL
    SELECT pz.ID, nd.TypZdroje
    FROM TabGprNavazneDoklady nd 
    INNER JOIN TabPohybyZbozi pz on pz.ID=nd.IDPolozkyDokladu 
    WHERE nd.IDZdroje=z1.ID and nd.TypZdroje=9
    UNION ALL
    SELECT pz.ID, nd.TypZdroje
    FROM TabGprUlohyNepZdroje v
    inner join TabGprNavazneDoklady nd on nd.IDZdroje=v.ID and nd.TypZdroje=2
    INNER JOIN TabPohybyZbozi pz on pz.ID=nd.IDPolozkyDokladu 
    WHERE  v.IDGprUlohy=u1.ID
) as pol
INNER JOIN TabPohybyZbozi pz1 on pz1.ID=pol.ID
GO

