USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_MzVyuctovaniDaneZPrijmuFO_Pobocky]    Script Date: 26.06.2025 8:50:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpVyuctovaniZalDane.Vyúčtování*/CREATE PROCEDURE [dbo].[hpx_MzVyuctovaniDaneZPrijmuFO_Pobocky]
@Rok INT, @ZrusTempTable BIT, @KodPobocky NVARCHAR(5)
AS
SET NOCOUNT ON
DECLARE @Sloupec_01 DATETIME, @Sloupec_02 NUMERIC(19,2), @Sloupec_03 NUMERIC(19,2)
DECLARE @Sloupec_04 NUMERIC(19,2), @Sloupec_05 NUMERIC(19,2), @Sloupec_05A NUMERIC(19,2)
DECLARE @Sloupec_05B NUMERIC(19,2), @Sloupec_06 NUMERIC(19,2), @Sloupec_07 NUMERIC(19,2)
DECLARE @Sloupec_08 NUMERIC(19,2), @Sloupec_09_Dny DATETIME, @Sloupec_09_Castka NUMERIC(19,2)
SET @Sloupec_01=NULL
SET @Sloupec_02=0
SET @Sloupec_03=0
SET @Sloupec_04=0
SET @Sloupec_05=0
SET @Sloupec_05A=0
SET @Sloupec_05B=0
SET @Sloupec_06=0
SET @Sloupec_07=0
SET @Sloupec_08=0
SET @Sloupec_09_Dny=NULL
SET @Sloupec_09_Castka=0
IF (@ZrusTempTable=0) AND OBJECT_ID(N'tempdb..#VyuctovaniDaneMesPobocky') IS NULL
RETURN
IF OBJECT_ID(N'tempdb..#VyuctovaniDaneMesPobocky') IS NULL
SELECT Mesic AS Mesic,
@Sloupec_01 AS Sloupec_01,
@Sloupec_02 AS Sloupec_02,
@Sloupec_03 AS Sloupec_03,
@Sloupec_04 AS Sloupec_04,
@Sloupec_05 AS Sloupec_05,
@Sloupec_05A AS Sloupec_05A,
@Sloupec_05B AS Sloupec_05B,
@Sloupec_06 AS Sloupec_06,
@Sloupec_07 AS Sloupec_07,
@Sloupec_08 AS Sloupec_08,
@Sloupec_09_Dny AS Sloupec_09_Dny,
@Sloupec_09_Castka AS Sloupec_09_Castka
INTO #VyuctovaniDaneMesPobocky
FROM TabMzdObd
WHERE Rok=@Rok
ORDER BY Mesic ASC
DECLARE @IdObdobi INT, @Mesic INT, @VyplatniDen INT, @VyplRok INT, @VyplMesic INT
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT IdObdobi, Mesic FROM TabMzdObd WHERE Rok=@Rok ORDER BY Mesic ASC
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @IdObdobi, @Mesic
IF @@FETCH_STATUS<>0 BREAK
SET @VyplRok=@Rok
SET @VyplMesic=@Mesic+1
IF @VyplMesic>12
BEGIN
SET @VyplRok=@Rok+1
SET @VyplMesic=1
END
SET @VyplatniDen=NULL
SELECT @VyplatniDen=VyplatniDen FROM TabMzKons WHERE IdObdobi=@IdObdobi
SET @VyplatniDen=ISNULL(@VyplatniDen, 15)
SELECT @Sloupec_01=MAX(Datum)
FROM TabMzKalendarDny d
JOIN TabMzKalendar k ON k.ID=d.IdKalendar
WHERE k.Rok=@VyplRok AND k.Cislo=N'001' AND
MONTH(d.Datum)=@VyplMesic AND DAY(d.Datum)<=@VyplatniDen AND d.TypDne=0 AND d.Svatek=0
IF @Sloupec_01 IS NULL
EXEC dbo.hp_EncodeDate @Sloupec_01 OUT, @Rok, @Mesic, @VyplatniDen
SET @Sloupec_02=0
SET @Sloupec_02=
ISNULL(
(SELECT  SUM(Vyp.DS_DanPoSleve)
FROM TabZamVyp Vyp
LEFT JOIN TabZamMzd Mzd ON Vyp.IdObdobi=Mzd.IdObdobi AND Vyp.ZamestnanecId=Mzd.ZamestnanecId
WHERE (Vyp.IdObdobi=@IdObdobi)
AND (TypDaneHPPaVPP IN (
SELECT 0
UNION
SELECT 1
FROM TabMzKons k1
WHERE k1.IdObdobi = @IdObdobi AND SDS_TypDane1 = 1
UNION
SELECT 2
FROM TabMzKons k1
WHERE k1.IdObdobi = @IdObdobi AND SDS_TypDane2 = 1
UNION
SELECT 3
FROM TabMzKons k1
WHERE k1.IdObdobi = @IdObdobi AND SDS_TypDane3 = 1
UNION
SELECT 4
FROM TabMzKons k1
WHERE k1.IdObdobi = @IdObdobi AND SDS_TypDane4 = 1
UNION
SELECT 5
FROM TabMzKons k1
WHERE k1.IdObdobi = @IdObdobi AND SDS_TypDane5 = 1
))
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
),
0
) +
ISNULL(
(SELECT  SUM(m.Koruny)
FROM TabMzSloz m
JOIN TabCisMzSl c ON c.IdObdobi=m.IdObdobi AND c.CisloMzSl=m.CisloMS
LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
WHERE (m.IdObdobi=@IdObdobi)
AND (CisloMS IN (SELECT CisloMzSl FROM TabCisMzSl WHERE IDObdobi = @IDObdobi AND SkupinaMS = 12
AND 1=(CASE WHEN (Srazky_TypDane = 1) THEN 1
WHEN (Srazky_TypDane = 2) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane1=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 3) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane2=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 4) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane3=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 5) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane4=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 6) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane5=1 AND IdObdobi=@IDObdobi) THEN 1
ELSE 0 END)
))
AND (m.CisloMS>199)
AND (c.Srazky_VztahKDani IN (1)) AND (c.Srazky_VyjmoutZRocZuctovani=0)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
),
0
) -
ISNULL(
(SELECT  SUM(m.Koruny)
FROM TabMzSloz m
JOIN TabCisMzSl c ON c.IdObdobi=m.IdObdobi AND c.CisloMzSl=m.CisloMS
LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
WHERE (m.IdObdobi=@IdObdobi)
AND (CisloMS IN (SELECT CisloMzSl FROM TabCisMzSl WHERE IDObdobi = @IDObdobi AND SkupinaMS = 12
AND 1=(CASE WHEN (Srazky_TypDane = 1) THEN 1
WHEN (Srazky_TypDane = 2) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane1=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 3) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane2=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 4) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane3=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 5) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane4=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 6) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane5=1 AND IdObdobi=@IDObdobi) THEN 1
ELSE 0 END)
))
AND (m.CisloMS>199)
AND (c.Srazky_VztahKDani IN (2,3)) AND (c.Srazky_VyjmoutZRocZuctovani=0)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
),
0
)
SET @Sloupec_03=@Sloupec_02
SET @Sloupec_04=0
SET @Sloupec_04=
ISNULL(
(SELECT SUM(m.Koruny)
FROM TabMzSloz m
JOIN TabCisMzSl c ON c.IdObdobi=m.IdObdobi AND c.CisloMzSl=m.CisloMS
LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
WHERE (m.IdObdobi=@IdObdobi)
AND (CisloMS IN (SELECT CisloMzSl FROM TabCisMzSl WHERE IDObdobi = @IDObdobi AND SkupinaMS = 12
AND 1=(CASE WHEN (Srazky_TypDane = 1) THEN 1
WHEN (Srazky_TypDane = 2) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane1=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 3) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane2=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 4) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane3=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 5) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane4=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 6) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane5=1 AND IdObdobi=@IDObdobi) THEN 1
ELSE 0 END)
))
AND (c.Srazky_VztahKDani=1) AND (c.Srazky_VyjmoutZRocZuctovani=1) AND (m.Koruny>0)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
),
0
)
SELECT
@Sloupec_05=SUM(Preplatek-(CASE WHEN DanBonusRozdil>0 THEN DanBonusRozdil ELSE 0 END))
FROM TabZamDan rzd
WHERE rzd.Rok=@Rok-1 AND rzd.Preplatek>0 AND EXISTS(
SELECT *
FROM TabMzSloz m
LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
WHERE (m.CisloMS=97) AND (m.ZamestnanecId=rzd.ZamestnanecId)
AND (m.IdObdobi=@IdObdobi)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
)
SET @Sloupec_05=ISNULL(@Sloupec_05, 0)
SELECT @Sloupec_05A=SUM(r.DanBonusRozdil)
FROM TabZamDan r
WHERE r.Rok=@Rok-1 AND r.DanBonusRozdil>0 AND EXISTS(
SELECT *
FROM TabMzSloz m
LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
WHERE (m.CisloMS=97) AND (m.ZamestnanecId=r.ZamestnanecId) AND (m.IdObdobi=@IdObdobi)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
)
SET @Sloupec_05A=
ISNULL(@Sloupec_05A,0) +
ISNULL(
(SELECT  SUM(OPM.CastkaUplat)
FROM TabMzdOdpPolMes OPM
LEFT JOIN TabZamMzd Mzd ON OPM.IdObdobi=Mzd.IdObdobi AND OPM.ZamestnanecId=Mzd.ZamestnanecId
WHERE (OPM.IdObdobi=@IdObdobi) AND (OPM.CastkaUplat>0) AND (OPM.VztahKDani IN (3)) AND (OPM.OdpocetBonus=1) AND (OPM.CastkaUplat>0)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
),
0
)
SET @Sloupec_05B=@Sloupec_05A
SET @Sloupec_06=0
SET @Sloupec_06=
ISNULL(
(SELECT -SUM(m.Koruny)
FROM TabMzSloz m
JOIN TabCisMzSl c ON c.IdObdobi=m.IdObdobi AND c.CisloMzSl=m.CisloMS
LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
WHERE (m.IdObdobi=@IdObdobi)
AND (CisloMS IN (SELECT CisloMzSl FROM TabCisMzSl WHERE IDObdobi = @IDObdobi AND SkupinaMS = 12
AND 1=(CASE WHEN (Srazky_TypDane = 1) THEN 1
WHEN (Srazky_TypDane = 2) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane1=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 3) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane2=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 4) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane3=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 5) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane4=1 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 6) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane5=1 AND IdObdobi=@IDObdobi) THEN 1
ELSE 0 END)
))
AND (c.Srazky_VztahKDani=1) AND (c.Srazky_VyjmoutZRocZuctovani=1) AND (m.Koruny<0)
AND (Mzd.Pobocka=@KodPobocky) AND EXISTS(SELECT 1 FROM TabMzKons WHERE (OdvodyNaPobocky=1) AND (IdObdobi=@IdObdobi))  -- zaměstananci dané pobočky a povoleno v konstantách
),
0
)
SET @Sloupec_07=0
IF (@Rok < 2010)
SET @Sloupec_08=@Sloupec_02+@Sloupec_04-@Sloupec_05-@Sloupec_05A-@Sloupec_06+@Sloupec_07
ELSE
SET @Sloupec_08=@Sloupec_02-@Sloupec_05-@Sloupec_05A
IF (@Sloupec_08 < 0) AND  (@Rok < 2010)
SET @Sloupec_08 = 0
SET @Sloupec_09_Castka=NULL
SET @Sloupec_09_Castka=
ISNULL(
(SELECT SUM(PTR.Castka)
FROM TabPlatTuzR PTR
LEFT JOIN TabPlatTuz PTH ON PTR.IDHlavaPP=PTH.ID
LEFT JOIN TabDefPlatPrik DefPP ON DefPP.Kod=PTH.MzdPredpis AND PTH.IdMzdObd=DefPP.IdObdobi
WHERE PTR.IdMzdObd=@IdObdobi AND PTR.TypOdvodu=1 AND DefPP.Pobocka=@KodPobocky
),
0
)
SET @Sloupec_09_Dny=NULL
IF @Sloupec_09_Castka IS NOT NULL AND @Sloupec_09_Castka<>0
BEGIN
SELECT TOP 1 @Sloupec_09_Dny=h.DatumSplatnosti
FROM TabPlatTuz h
JOIN  TabPlatTuzR p ON p.IDHlavaPP=h.ID
LEFT JOIN TabDefPlatPrik DefPP ON h.MzdPredpis=DefPP.Kod AND h.IdMzdObd=DefPP.IdObdobi
WHERE p.IdMzdObd=@IdObdobi AND p.TypOdvodu=1 AND DefPP.Pobocka=@KodPobocky
IF @Sloupec_09_Dny IS NULL
SET @Sloupec_09_Dny=@Sloupec_01
END
ELSE
BEGIN
IF @Rok<2010
SET @Sloupec_09_Castka=@Sloupec_08
ELSE
SET @Sloupec_09_Castka=0
SET @Sloupec_09_Dny=@Sloupec_01
END
UPDATE #VyuctovaniDaneMesPobocky
SET Sloupec_01=@Sloupec_01,
Sloupec_02=@Sloupec_02,
Sloupec_03=@Sloupec_03,
Sloupec_04=@Sloupec_04,
Sloupec_05=@Sloupec_05,
Sloupec_05A=@Sloupec_05A,
Sloupec_05B=@Sloupec_05B,
Sloupec_06=@Sloupec_06,
Sloupec_07=@Sloupec_07,
Sloupec_08=@Sloupec_08,
Sloupec_09_Dny=@Sloupec_09_Dny,
Sloupec_09_Castka=@Sloupec_09_Castka
WHERE Mesic=@Mesic
END
CLOSE c
DEALLOCATE c
INSERT
INTO #VyuctovaniDaneMesPobocky(Mesic, Sloupec_01, Sloupec_02, Sloupec_03, Sloupec_04,
Sloupec_05, Sloupec_05A, Sloupec_05B, Sloupec_06,
Sloupec_07, Sloupec_08, Sloupec_09_Dny, Sloupec_09_Castka)
SELECT 13, NULL, SUM(Sloupec_02), SUM(Sloupec_03), SUM(Sloupec_04),
SUM(Sloupec_05), SUM(Sloupec_05A), SUM(Sloupec_05B), SUM(Sloupec_06),
SUM(Sloupec_07), SUM(Sloupec_08), NULL, SUM(Sloupec_09_Castka)
FROM #VyuctovaniDaneMesPobocky
IF @ZrusTempTable=1
BEGIN
SELECT * FROM #VyuctovaniDaneMesPobocky ORDER BY Mesic ASC
IF OBJECT_ID(N'tempdb..#VyuctovaniDaneMesPobocky') IS NOT NULL
DROP TABLE #VyuctovaniDaneMesPobocky
END
GO

