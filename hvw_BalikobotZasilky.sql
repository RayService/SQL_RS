USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BalikobotZasilky]    Script Date: 03.07.2025 14:09:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BalikobotZasilky] AS WITH
TrackStatus
AS
(
SELECT
BALIK.IdZasilky,
COUNT(IIF(BALIKSTATUS.status_id=1, 1, 0)) AS PocetDoruceno,
COUNT(IIF(BALIKSTATUS.status_id<>1, 1, 0)) AS PocetNedoruceno
FROM Tabx_BalikobotTrackStatus BALIKSTATUS
INNER JOIN Tabx_BalikobotBaliky BALIK ON BALIKSTATUS.IdBalik = BALIK.ID
WHERE BALIKSTATUS.Poradi = 0
GROUP BY BALIK.IdZasilky
),
SumaceBaliku
AS
(
SELECT
IdZasilky,
COUNT(*) AS PocetBaliku,
COUNT(DISTINCT Stav) AS PocetStavu,
MIN(Stav) AS MinStav,
SUM(IIF(ISNULL(Tabx_BalikobotBaliky.TrackStatusCode, -999)<>1, 0, 1)) AS Doruceno
FROM Tabx_BalikobotBaliky
GROUP BY IdZasilky
)
SELECT Tabx_BalikobotZasilky.*
, IIF(SB.PocetStavu>1, 100, SB.MinStav) AS Stav
, SB.PocetBaliku AS PocetBaliku
, CAST(IIF(SB.PocetBaliku=SB.Doruceno, 1, 0) AS BIT) AS Doruceno
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.DatumPredaniDat  AS DatumPredaniDat
, DATEPART(DAY, B.DatumPredaniDat) AS DatumPredaniDat_D
, DATEPART(MONTH, B.DatumPredaniDat) AS DatumPredaniDat_M
, DATEPART(YEAR, B.DatumPredaniDat) AS DatumPredaniDat_Y
, DATEPART(QUARTER, B.DatumPredaniDat) AS DatumPredaniDat_Q
, DATEPART(WEEK, B.DatumPredaniDat) AS DatumPredaniDat_W
, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,B.DatumPredaniDat))) AS DatumPredaniDat_X
, DATEPART(ISO_WEEK, B.DatumPredaniDat) AS DatumPredaniDat_V
, ((DATEPART(dw, B.DatumPredaniDat)+@@DATEFIRST-2)%7+1) AS DatumPredaniDat_O
, B.DatumTiskuStitku AS DatumTiskuStitku
, CAST(IIF(ISNULL(TS.PocetNedoruceno, 0) <> ISNULL(TS.PocetDoruceno, 0), 1, 0) AS BIT) AS NekonzistTrackStatus
, ISNULL(TS.PocetDoruceno, 0) AS PocetDoruceno
, ISNULL(TS.PocetNedoruceno, 0) AS PocetNedoruceno
, B.DatumPredani AS DatumPredani
, DATEPART(DAY, B.DatumPredani) AS DatumPredani_D
, DATEPART(MONTH, B.DatumPredani) AS DatumPredani_M
, DATEPART(YEAR, B.DatumPredani) AS DatumPredani_Y
, DATEPART(QUARTER, B.DatumPredani) AS DatumPredani_Q
, DATEPART(WEEK, B.DatumPredani) AS DatumPredani_W
, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,B.DatumPredani))) AS DatumPredani_X
, DATEPART(ISO_WEEK, B.DatumPredani) AS DatumPredani_V
, ((DATEPART(dw, B.DatumPredani)+@@DATEFIRST-2)%7+1) AS DatumPredani_O
, B.ID AS IdPrvniBalik
, TSB.ID AS IdStatus
FROM Tabx_BalikobotZasilky
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Tabx_BalikobotZasilky.ID AND B.OrderNumber=1
LEFT OUTER JOIN TrackStatus TS ON Tabx_BalikobotZasilky.ID=TS.IdZasilky
LEFT OUTER JOIN SumaceBaliku SB ON Tabx_BalikobotZasilky.ID = SB.IdZasilky
LEFT OUTER JOIN Tabx_BalikobotTrackStatus TSB ON TSB.IdBalik=B.ID AND TSB.Poradi=0
GO

