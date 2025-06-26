USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_VSDVyuct_ZalozPolozky]    Script Date: 26.06.2025 8:39:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpVyuctovaniZalDane.Vyúčtování*/CREATE PROC [dbo].[hpx_VSDVyuct_ZalozPolozky] @ID INT, @Posun BIT
AS
DECLARE @Rok INT, @IdVSDVyuct INT
DECLARE @RokPosun INT, @MesicPosun INT, @DatPosun DATETIME
SET @IdVSDVyuct=@ID
SET @Rok=(SELECT rok FROM dbo.Tabx_VSDVyuct WHERE ID=@ID)
IF OBJECT_ID(N'tempdb..#VyuctovaniDaneSeznam') IS NOT NULL
DROP TABLE #VyuctovaniDaneSeznam
DECLARE @IDObdobi INT, @i INT
CREATE TABLE #VyuctovaniDaneSeznam(Mesic INT, VypocetDan NUMERIC(19, 6), PlatakOdvedeno NUMERIC(19, 6))
SET @i = 0
WHILE @i < 12
BEGIN
SET @i = @i + 1
IF @Posun=0  -- posun období
BEGIN
SELECT @IDObdobi = IDObdobi FROM TabMzdObd WHERE Rok = @Rok AND Mesic = @i
END
ELSE BEGIN
SET @DatPosun = DATEADD(MONTH, -1, CAST(CAST(@Rok AS NVARCHAR(4)) + RIGHT(N'00'+CAST(@i AS NVARCHAR(2)),2) + N'01' AS DATETIME))
SET @RokPosun = YEAR(@DatPosun)
SET @MesicPosun = MONTH(@DatPosun)
SELECT @IDObdobi = IDObdobi FROM TabMzdObd WHERE Rok = @RokPosun AND Mesic = @MesicPosun
END
INSERT INTO #VyuctovaniDaneSeznam(Mesic, VypocetDan, PlatakOdvedeno)
SELECT
@I,
ISNULL((SELECT SUM(Koruny)
FROM TabMzSloz
WHERE IDObdobi = @IDObdobi
AND (CisloMS IN (SELECT CisloMzSl FROM TabCisMzSl WHERE IDObdobi = @IDObdobi AND VstupniFormular IN (0,4) AND SkupinaMS = 12
AND 1=(CASE WHEN (Srazky_TypDane = 2) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane1=0 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 3) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane2=0 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 4) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane3=0 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 5) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane4=0 AND IdObdobi=@IDObdobi) THEN 1
WHEN (Srazky_TypDane = 6) AND EXISTS(SELECT 1 FROM TabMzKons WHERE SDS_TypDane5=0 AND IdObdobi=@IDObdobi) THEN 1
ELSE 0 END)
)))
,0),
ISNULL((SELECT SUM(Castka)
FROM TabPlatTuzR
WHERE IdMzdObd=@IdObdobi AND TypOdvodu=2), 0)
END
INSERT Tabx_VSDMesVypocet(IdVSDVyuct, mesic, kc_dpsi10_vyp, kc_dpsi01_vyp, kc_dpsi02_vyp)
SELECT
@IdVSDVyuct,
Mesic,
PlatakOdvedeno,
VypocetDan,
VypocetDan
FROM #VyuctovaniDaneSeznam
IF OBJECT_ID(N'tempdb..#VyuctovaniDaneSeznam') IS NOT NULL
DROP TABLE #VyuctovaniDaneSeznam
GO

