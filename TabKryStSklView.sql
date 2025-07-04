USE [RayService]
GO

/****** Object:  View [dbo].[TabKryStSklView]    Script Date: 04.07.2025 11:29:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabKryStSklView] AS
SELECT r.ID AS IDr,
NULL AS DruhZajDok,
ISNULL(k.IDZboSklad, r.IDZboSklad) AS SkladID,
NULL AS VyrCSID,
CAST(r.Mnozstvi * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
ISNULL(kkm.MJEvidence, rkm.MJEvidence) AS MJ,
CAST((r.Mnozstvi - r.MnozstviVydejky) * r.PrepMnozstvi AS NUMERIC(19,6)) AS Zbyva,
CASE WHEN (ISNULL(zss.MnKryteEvidStavemSkladu, 0) - ISNULL( nv.MnozstviVydejky, 0)) > 0
THEN CAST(zss.MnKryteEvidStavemSkladu - ISNULL( nv.MnozstviVydejky, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaZajistenych,
CASE WHEN (ISNULL(blk.MnozstviBlokovane, 0) - ISNULL( nv.MnozstviVydejky, 0)) > 0
THEN CAST(blk.MnozstviBlokovane - ISNULL( nv.MnozstviVydejky, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaBlokovano,
NULL AS JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
JOIN TabZpusobZajKry02 k ON k.IDZpusob = r.ID AND k.Zpusob = 1
LEFT OUTER JOIN TabStavSkladu ks ON ks.ID = k.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi kkm ON kkm.ID = ks.IDKmenZbozi
LEFT OUTER JOIN (SELECT IDZpusob, IDZbosklad, SUM(MnKryteEvid) AS MnKryteEvidStavemSkladu
FROM TabZpusobZajKry02
GROUP BY IDZpusob, IDZboSklad) zss ON zss.IDZpusob = r.ID AND zss.IDZpusob IS NOT NULL AND zss.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad)
LEFT OUTER JOIN (SELECT IDZpusob, SUM(Mnozstvi) AS MnozstviBlokovane
FROM TabDilciPrijmyDObj02
WHERE IDPohybu IS NULL
GROUP BY IDZpusob) blk ON blk.IDZpusob = k.ID AND blk.IDZpusob IS NOT NULL
LEFT OUTER JOIN (SELECT nd.IDDoslaObjR, p.IDZboSklad, SUM(p.Mnozstvi * p.PrepMnozstvi) AS MnozstviVydejky
FROM TabDosleObjNavazDok02 nd
JOIN TabPohybyZbozi p ON p.ID = nd.IDNavazPol
JOIN TabDokladyZbozi d ON d.ID = p.IDDoklad AND d.DatRealMnoz IS NULL
WHERE p.DruhPohybuZbo IN (2,4)
GROUP BY nd.IDDoslaObjR, p.IDZboSklad ) nv ON nv.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND nv.IDDoslaObjR = r.ID
WHERE r.JeStin = 0 AND r.Splneno = 0
AND (SELECT NZB FROM TabHGlob) = 0
UNION
SELECT r.ID AS IDr,
NULL AS DruhZajDok,
r.IDZboSklad AS SkladID,
NULL AS VyrCSID,
CAST(r.Mnozstvi * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
rkm.MJEvidence AS MJ,
CAST((r.Mnozstvi - r.MnozstviVydejky) * r.PrepMnozstvi AS NUMERIC(19,6)) AS Zbyva,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaZajistenych,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaBlokovano,
NULL AS JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
WHERE r.JeStin = 0 AND r.Splneno = 0
AND NOT EXISTS(SELECT*FROM TabZpusobZajKry02 WHERE IDZpusob = r.ID AND Zpusob = 1)
AND (SELECT NZB FROM TabHGlob) = 0
UNION
SELECT r.ID AS IDr,
NULL AS DruhZajDok,
r.IDZboSklad AS SkladID,
NULL AS VyrCSID,
CAST(r.Mnozstvi * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
rkm.MJEvidence AS MJ,
CAST(0 AS NUMERIC(19,6)) AS Zbyva,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaZajistenych,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaBlokovano,
NULL AS JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
WHERE r.JeStin = 0 AND r.Splneno = 1
AND (SELECT NZB FROM TabHGlob) = 0
UNION
SELECT r.ID AS IDr, ISNULL(z.DruhZajDok, 0) AS DruhZajDok,
ISNULL(k.IDZboSklad, r.IDZboSklad) AS SkladID,
NULL AS VyrCSID,
CAST(r.Mnozstvi * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
ISNULL(kkm.MJEvidence, rkm.MJEvidence) AS MJ,
CAST((r.Mnozstvi - r.MnozstviVydejky) * r.PrepMnozstvi AS NUMERIC(19,6)) AS Zbyva,
CASE WHEN (ISNULL(zss.MnKryteEvidStavemSkladu, 0) - ISNULL( nv.MnozstviVydejky, 0)) > 0
THEN CAST(zss.MnKryteEvidStavemSkladu - ISNULL( nv.MnozstviVydejky, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaZajistenych,
CASE WHEN (ISNULL(blk.MnozstviBlokovane, 0) - ISNULL( nv.MnozstviVydejky, 0)) > 0
THEN CAST(blk.MnozstviBlokovane - ISNULL( nv.MnozstviVydejky, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
JOIN TabZajistX     z ON z.IDDObjR02 = r.ID
JOIN TabZajistKryX  k ON k.IDZajist = z.ID AND k.Zpusob = 1
LEFT OUTER JOIN TabStavSkladu ks ON ks.ID = k.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi kkm ON kkm.ID = ks.IDKmenZbozi
LEFT OUTER JOIN (SELECT zz.IDDObjR02, kk.IDZbosklad, SUM(kk.MnKryteEvid) AS MnKryteEvidStavemSkladu
FROM TabZajistKryX kk
JOIN TabZajistX  zz ON zz.ID = kk.IDZajist
GROUP BY zz.IDDObjR02, kk.IDZboSklad) zss ON zss.IDDObjR02 = r.ID AND zss.IDDObjR02 IS NOT NULL AND zss.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad)
LEFT OUTER JOIN (SELECT IDZajistKry, SUM(Mnozstvi) AS MnozstviBlokovane
FROM TabZajistKryBlokX
GROUP BY IDZajistKry) blk ON blk.IDZajistKry = k.ID AND blk.IDZajistKry IS NOT NULL
LEFT OUTER JOIN (SELECT nd.IDDoslaObjR, p.IDZboSklad, SUM(p.Mnozstvi * p.PrepMnozstvi) AS MnozstviVydejky
FROM TabDosleObjNavazDok02 nd
JOIN TabPohybyZbozi p ON p.ID = nd.IDNavazPol
JOIN TabDokladyZbozi d ON d.ID = p.IDDoklad AND d.DatRealMnoz IS NULL
WHERE p.DruhPohybuZbo IN (2,4)
GROUP BY nd.IDDoslaObjR, p.IDZboSklad ) nv ON nv.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND nv.IDDoslaObjR = r.ID
WHERE r.JeStin = 0 AND r.Splneno = 0
AND (SELECT NZB FROM TabHGlob) = 1
UNION
SELECT r.ID AS IDr, CAST(0 AS TINYINT) AS DruhZajDok, r.IDZboSklad AS SkladID,
NULL AS VyrCSID,
CAST(r.Mnozstvi * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
rkm.MJEvidence AS MJ,
CAST((r.Mnozstvi - r.MnozstviVydejky) * r.PrepMnozstvi AS NUMERIC(19,6)) AS Zbyva,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaZajistenych,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
LEFT OUTER JOIN TabZajistX     z ON z.IDDObjR02 = r.ID
WHERE r.JeStin = 0 AND r.Splneno = 0
AND NOT EXISTS(SELECT*FROM TabZajistKryX kk
JOIN TabZajistX zz ON zz.ID = kk.IDZajist
WHERE zz.IDDObjR02 = r.ID AND kk.Zpusob = 1)
AND (SELECT NZB FROM TabHGlob) = 1
UNION
SELECT r.ID AS IDr, CAST(0 AS TINYINT) AS DruhZajDok, r.IDZboSklad AS SkladID,
NULL AS VyrCSID,
CAST(r.Mnozstvi * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
rkm.MJEvidence AS MJ,
CAST(0 AS NUMERIC(19,6)) AS Zbyva,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaZajistenych,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
LEFT OUTER JOIN TabZajistX     z ON z.IDDObjR02 = r.ID
WHERE r.JeStin = 0 AND r.Splneno = 1
AND (SELECT NZB FROM TabHGlob) = 1
UNION
SELECT r.ID AS IDr, ISNULL(z.DruhZajDok, 0) AS DruhZajDok,
ISNULL(k.IDZboSklad, r.IDZboSklad) AS SkladID,
rvcx.IDVyrCS AS VyrCSID,
CAST(ISNULL(rvc.Mnozstvi, 0 ) * r.PrepMnozstvi AS NUMERIC(19,6)) AS Mnozstvi,
ISNULL(kkm.MJEvidence, rkm.MJEvidence) AS MJ,
CASE WHEN (ISNULL(rvc.Mnozstvi, 0 ) * r.PrepMnozstvi) - ISNULL(nvvcx.MnozstviVydejkyVC,0) > 0
THEN CAST((ISNULL(rvc.Mnozstvi, 0 ) * r.PrepMnozstvi) - ISNULL(nvvcx.MnozstviVydejkyVC,0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS Zbyva,
CASE WHEN (ISNULL(zssvcx.MnKryteEvidStavemSkladuVC, 0) - ISNULL( nvvcx.MnozstviVydejkyVC, 0)) > 0
THEN CAST(zssvcx.MnKryteEvidStavemSkladuVC - ISNULL( nvvcx.MnozstviVydejkyVC, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaZajistenych,
CASE WHEN (ISNULL(blkvcx.MnozstviBlokovaneVC, 0) - ISNULL( nvvcx.MnozstviVydejkyVC, 0)) > 0
THEN CAST(blkvcx.MnozstviBlokovaneVC - ISNULL( nvvcx.MnozstviVydejkyVC, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
JOIN TabZajistX     z ON z.IDDObjR02 = r.ID
JOIN TabZajistKryX  k ON k.IDZajist = z.ID AND k.Zpusob = 1
LEFT OUTER JOIN TabStavSkladu ks ON ks.ID = k.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi kkm ON kkm.ID = ks.IDKmenZbozi
LEFT OUTER JOIN TabDosleObjVyrCis02 rvc ON rvc.IDPolozka =  r.ID
LEFT OUTER JOIN TabZajistKryVyrCX  rvcx ON rvcx.IDZajistKry = k.ID AND rvcx.IDVyrCS = rvc.IDVyrCis
LEFT OUTER JOIN (SELECT nd.IDDoslaObjR, p.IDZboSklad, vcp.IDVyrCis, SUM(vcp.Mnozstvi * p.PrepMnozstvi) AS MnozstviVydejkyVC
FROM TabDosleObjNavazDok02 nd
JOIN TabPohybyZbozi   p ON p.ID = nd.IDNavazPol
JOIN TabDokladyZbozi  d ON d.ID = p.IDDoklad AND d.DatRealMnoz IS NULL
JOIN TabVyrCP       vcp ON vcp.IDPolozkaDokladu = p.ID
WHERE p.DruhPohybuZbo IN (2,4)
GROUP BY nd.IDDoslaObjR, p.IDZboSklad, vcp.IDVyrCis ) nvvcx ON nvvcx.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND nvvcx.IDDoslaObjR = r.ID AND nvvcx.IDVyrCis = rvcx.IDVyrCS
LEFT OUTER JOIN (SELECT zz.IDDObjR02, kk.IDZbosklad, vcx.IDVyrCS, SUM(vcx.MnKryteEv) AS MnKryteEvidStavemSkladuVC
FROM TabZajistKryX kk
JOIN TabZajistX         zz ON zz.ID = kk.IDZajist
JOIN TabZajistKryVyrCX vcx ON vcx.IDZajistKry = kk.ID
GROUP BY zz.IDDObjR02, kk.IDZboSklad, vcx.IDVyrCS) zssvcx ON zssvcx.IDDObjR02 = r.ID AND zssvcx.IDDObjR02 IS NOT NULL AND zssvcx.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND zssvcx.IDVyrCS = rvcx.IDVyrCS
LEFT OUTER JOIN (SELECT zz.IDDObjR02, kk.IDZbosklad, vcx.IDVyrCS, SUM(vcbx.Mnozstvi) AS MnozstviBlokovaneVC
FROM TabZajistKryX kk
JOIN TabZajistX              zz ON zz.ID = kk.IDZajist
JOIN TabZajistKryVyrCX      vcx ON vcx.IDZajistKry = kk.ID
JOIN TabZajistKryVyrCBlokX vcbx ON vcbx.IDZajistKryVyrC = vcx.ID
GROUP BY zz.IDDObjR02, kk.IDZboSklad, vcx.IDVyrCS) blkvcx ON blkvcx.IDDObjR02 = r.ID AND blkvcx.IDDObjR02 IS NOT NULL AND blkvcx.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND blkvcx.IDVyrCS = rvcx.IDVyrCS
WHERE r.JeStin = 0 AND r.Splneno = 0
AND rvcx.IDVyrCS IS NOT NULL
AND (SELECT NZB FROM TabHGlob) = 1
UNION
SELECT r.ID AS IDr, CAST(0 AS TINYINT) AS DruhZajDok, r.IDZboSklad AS SkladID,
rvc.IDVyrCis AS VyrCSID,
CAST(ISNULL((rvc.Mnozstvi * r.PrepMnozstvi), 0 ) AS NUMERIC(19,6)) Mnozstvi,
rkm.MJEvidence AS MJ,
CAST(ISNULL((rvc.Mnozstvi * r.PrepMnozstvi ), 0) - ISNULL(nv.MnozstviVydejky, 0) AS NUMERIC(19,6)) Zbyva,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaZajistenych,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu        rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi        rkm ON rkm.ID = rs.IDKmenZbozi
LEFT OUTER JOIN TabDosleObjVyrCis02 rvc ON rvc.IDPolozka = r.ID
LEFT OUTER JOIN (SELECT nd.IDDoslaObjR, p.IDZboSklad, vcp.IDVyrCis, SUM(vcp.Mnozstvi * p.PrepMnozstvi) AS MnozstviVydejky
FROM TabDosleObjNavazDok02 nd
JOIN TabPohybyZbozi   p ON p.ID = nd.IDNavazPol
JOIN TabDokladyZbozi  d ON d.ID = p.IDDoklad
JOIN TabVyrCP       vcp ON vcp.IDPolozkaDokladu = p.ID
WHERE p.DruhPohybuZbo IN (2,4)
GROUP BY nd.IDDoslaObjR, p.IDZboSklad, vcp.IDVyrCis ) nv ON nv.IDZboSklad = r.IDZboSklad AND nv.IDDoslaObjR = r.ID AND nv.IDVyrCis = rvc.IDVyrCis
LEFT OUTER JOIN TabZajistX            z ON z.IDDObjR02 = r.ID
WHERE r.JeStin = 0 AND r.Splneno = 0
AND rvc.IDVyrCis NOT IN (SELECT vvcx.IDVyrCS
FROM TabZajistKryVyrCX vvcx
JOIN TabZajistKryX kk ON kk.ID = vvcx.IDZajistKry
JOIN TabZajistX zz ON zz.ID = kk.IDZajist
WHERE zz.IDDObjR02 = r.ID AND kk.Zpusob = 1)
AND rvc.IDVyrCis IS NOT NULL
AND (SELECT NZB FROM TabHGlob) = 1
UNION
SELECT r.ID AS IDr, CAST(0 AS TINYINT) AS DruhZajDok, r.IDZboSklad AS SkladID,
rvc.IDVyrCis AS VyrCSID,
CAST(ISNULL(rvc.Mnozstvi * r.PrepMnozstvi, 0) AS NUMERIC(19,6)) AS Mnozstvi,
rkm.MJEvidence AS MJ,
CAST(0 AS NUMERIC(19,6)) AS Zbyva,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaZajistenych,
CAST(0 AS NUMERIC(19,6)) AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu        rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi        rkm ON rkm.ID = rs.IDKmenZbozi
LEFT OUTER JOIN TabDosleObjVyrCis02 rvc ON rvc.IDPolozka = r.ID
LEFT OUTER JOIN TabZajistX            z ON z.IDDObjR02 = r.ID
WHERE r.JeStin = 0 AND r.Splneno = 1
AND rvc.IDVyrCis IS NOT NULL
AND (SELECT NZB FROM TabHGlob) = 1
UNION
SELECT r.ID AS IDr, ISNULL(z.DruhZajDok, 0) AS DruhZajDok,
ISNULL(k.IDZboSklad, r.IDZboSklad) AS SkladID,
rvcx.IDVyrCS AS VyrCSID,
CAST(0 AS NUMERIC(19,6)) AS Mnozstvi,
ISNULL(kkm.MJEvidence, rkm.MJEvidence) AS MJ,
CAST(0 AS NUMERIC(19,6)) AS Zbyva,
CASE WHEN (ISNULL(zssvcx.MnKryteEvidStavemSkladuVC, 0) - ISNULL( nvvcx.MnozstviVydejkyVC, 0)) > 0
THEN CAST(zssvcx.MnKryteEvidStavemSkladuVC - ISNULL( nvvcx.MnozstviVydejkyVC, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaZajistenych,
CASE WHEN (ISNULL(blkvcx.MnozstviBlokovaneVC, 0) - ISNULL( nvvcx.MnozstviVydejkyVC, 0)) > 0
THEN CAST(blkvcx.MnozstviBlokovaneVC - ISNULL( nvvcx.MnozstviVydejkyVC, 0) AS NUMERIC(19,6))
ELSE CAST(0 AS NUMERIC(19,6)) END AS ZbyvaBlokovano,
z.JeVC
FROM TabDosleObjR02 r
LEFT OUTER JOIN TabStavSkladu rs ON rs.ID = r.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi rkm ON rkm.ID = rs.IDKmenZbozi
JOIN TabZajistX     z ON z.IDDObjR02 = r.ID
JOIN TabZajistKryX  k ON k.IDZajist = z.ID AND k.Zpusob = 1
LEFT OUTER JOIN TabStavSkladu ks ON ks.ID = k.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi kkm ON kkm.ID = ks.IDKmenZbozi
LEFT OUTER JOIN TabZajistKryVyrCX  rvcx ON rvcx.IDZajistKry = k.ID
LEFT OUTER JOIN (SELECT nd.IDDoslaObjR, p.IDZboSklad, vcp.IDVyrCis, SUM(vcp.Mnozstvi * p.PrepMnozstvi) AS MnozstviVydejkyVC
FROM TabDosleObjNavazDok02 nd
JOIN TabPohybyZbozi   p ON p.ID = nd.IDNavazPol
JOIN TabDokladyZbozi  d ON d.ID = p.IDDoklad AND d.DatRealMnoz IS NULL
JOIN TabVyrCP       vcp ON vcp.IDPolozkaDokladu = p.ID
WHERE p.DruhPohybuZbo IN (2,4)
GROUP BY nd.IDDoslaObjR, p.IDZboSklad, vcp.IDVyrCis ) nvvcx ON nvvcx.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND nvvcx.IDDoslaObjR = r.ID AND nvvcx.IDVyrCis = rvcx.IDVyrCS
LEFT OUTER JOIN (SELECT zz.IDDObjR02, kk.IDZbosklad, vcx.IDVyrCS, SUM(vcx.MnKryteEv) AS MnKryteEvidStavemSkladuVC
FROM TabZajistKryX kk
JOIN TabZajistX         zz ON zz.ID = kk.IDZajist
JOIN TabZajistKryVyrCX vcx ON vcx.IDZajistKry = kk.ID
GROUP BY zz.IDDObjR02, kk.IDZboSklad, vcx.IDVyrCS) zssvcx ON zssvcx.IDDObjR02 = r.ID AND zssvcx.IDDObjR02 IS NOT NULL AND zssvcx.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND zssvcx.IDVyrCS = rvcx.IDVyrCS
LEFT OUTER JOIN (SELECT zz.IDDObjR02, kk.IDZbosklad, vcx.IDVyrCS, SUM(vcbx.Mnozstvi) AS MnozstviBlokovaneVC
FROM TabZajistKryX kk
JOIN TabZajistX              zz ON zz.ID = kk.IDZajist
JOIN TabZajistKryVyrCX      vcx ON vcx.IDZajistKry = kk.ID
JOIN TabZajistKryVyrCBlokX vcbx ON vcbx.IDZajistKryVyrC = vcx.ID
GROUP BY zz.IDDObjR02, kk.IDZboSklad, vcx.IDVyrCS) blkvcx ON blkvcx.IDDObjR02 = r.ID AND blkvcx.IDDObjR02 IS NOT NULL AND blkvcx.IDZboSklad = ISNULL(k.IDZboSklad, r.IDZboSklad) AND blkvcx.IDVyrCS = rvcx.IDVyrCS
WHERE r.JeStin = 0 AND r.Splneno = 0
AND rvcx.IDVyrCS IS NOT NULL
AND NOT EXISTS(SELECT*FROM TabDosleObjVyrCis02 wrvc WHERE wrvc.IDPolozka = r.ID AND rvcx.IDVyrCS = wrvc.IDVyrCis)
AND (SELECT NZB FROM TabHGlob) = 1
GO

