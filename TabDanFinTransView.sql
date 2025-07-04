USE [RayService]
GO

/****** Object:  View [dbo].[TabDanFinTransView]    Script Date: 04.07.2025 9:49:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabDanFinTransView] AS
SELECT ID, Zdroj, IdBankVypisR, IdBankVypisH, DatPorizeni, Suma, Sazba, Vyjimka
, Hodnota, TypCastky, IdFPK
, CAST(CASE WHEN (DanV<=LimitDane) OR (LimitDane=0) THEN ROUND(ABS(DanV)+0.005, 2, 1)
ELSE LimitDane
END AS NUMERIC(19,6)) AS Dan
, CAST(DanHM AS NUMERIC(19,6)) AS ZakladHM
, LimitDane
, DatumKurz, CAST(JednotkaMeny AS INT) AS JednotkaMeny, CAST(Kurz AS NUMERIC(19,6)) AS Kurz
FROM (SELECT 1 AS ID
, CAST(1 AS TINYINT) AS Zdroj
, r.ID AS IdBankVypisR
, r.IDHlava AS IdBankVypisH
, CAST(h.DatumVypisu AS DATE) AS DatPorizeni
, r.Castka AS Suma
, ISNULL(s.Sazba,N'') AS Sazba
, v.Kod AS Vyjimka
, ISNULL(s.Hodnota,0) AS Hodnota
, ISNULL(s.TypCastky,0) AS TypCastky
, NULL AS IDFPK
, CASE WHEN ISNULL(s.TypCastky,0)=0 THEN 0
WHEN s.TypCastky=1 THEN 
CASE WHEN ISNULL(r.Mena, m.Kod)=m.Kod THEN
r.Castka
ELSE
CASE WHEN m.ZpusobKurzu = 0 THEN
r.Castka*ISNULL(DzFTKurz,1)/ISNULL(DzFTPocetJednotek,1)
ELSE
r.Castka*ISNULL(DzFTPocetJednotek,1)/ISNULL(DzFTKurz,1)
END
END * s.Hodnota/100
WHEN s.TypCastky=2 THEN s.Hodnota
END AS DanV
, CASE WHEN ISNULL(s.TypCastky,0)=0 THEN 0
WHEN s.TypCastky=1 THEN 
CASE WHEN ISNULL(r.Mena, m.Kod)=m.Kod THEN
r.Castka
ELSE
CASE WHEN m.ZpusobKurzu = 0 THEN
r.Castka*ISNULL(DzFTKurz,1)/ISNULL(DzFTPocetJednotek,1)
ELSE
r.Castka*ISNULL(DzFTPocetJednotek,1)/ISNULL(DzFTKurz,1)
END
END
WHEN s.TypCastky=2 THEN s.Hodnota
END AS DanHM
, ISNULL(s.LimitSumy,0) AS LimitDane
, DzFTDatumListku AS DatumKurz
, ISNULL(DzFTPocetJednotek,1) AS JednotkaMeny
, ISNULL(DzFTKurz,1.00) AS Kurz
FROM TabBankVypisR r
JOIN TabBankVypisH h ON r.IDHlava=h.ID
LEFT JOIN TabDanFTSazby s ON r.DzFTSazba=s.ID
LEFT JOIN TabDanFTVyjimky v ON r.DzFTVyjimka=v.ID
LEFT JOIN TabKodMen m ON m.HlavniMena=1
WHERE r.DzFT>0
AND h.DatumVypisu BETWEEN ISNULL(s.PlatnostOd,'1900-01-01') AND ISNULL(s.PlatnostDo,'9999-01-01')
AND h.IdObdobi=(SELECT ID FROM TabObdobi WHERE GETDATE() BETWEEN DatumOd AND DatumDo)
UNION
SELECT 2 AS ID
, CAST(2 AS TINYINT) AS Zdroj
, NULL AS IdBankVypisR
, NULL AS IdBankVypisH
, CAST(GETDATE() AS DATE) AS DatPorizeni
, 0 AS Suma
, ISNULL(s.Sazba,N'') AS Sazba
, NULL AS Vyjimka
, ISNULL(s.Hodnota,0) AS Hodnota
, ISNULL(s.TypCastky,0) AS TypCastky
, p.ID AS IdFPK
, CASE WHEN ISNULL(s.TypCastky,0)=0 THEN 0
WHEN s.TypCastky=1 THEN 0*s.Hodnota/100
WHEN s.TypCastky=2 THEN s.Hodnota
END AS DanV
, CASE WHEN ISNULL(s.TypCastky,0)=0 THEN 0
WHEN s.TypCastky=1 THEN 0*s.Hodnota/100
WHEN s.TypCastky=2 THEN s.Hodnota
END AS DanHM
, ISNULL(s.LimitSumy,0) AS LimitDane
, NULL AS DatumKurz
, 1 AS JednotkaMeny
, 1.00 AS Kurz
FROM TabFPKPlatebniKarty p
LEFT JOIN TabDanFTSazby s ON s.ID=4
WHERE p.Stav=1) t
GO

