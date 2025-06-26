USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_workplace_capacity_calc]    Script Date: 26.06.2025 13:10:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_workplace_capacity_calc]
AS

BEGIN
DELETE FROM Tabx_RS_workplace_capacity

--výčetka vše
INSERT INTO Tabx_RS_workplace_capacity(IDWorkplace,Datum,WorkerAmount)
SELECT tcze._EXT_RS_workplace_IDWorkplace, dpich.picDatum, COUNT(tcz.ID)
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPichacka dpich WITH(NOLOCK)
LEFT OUTER JOIN RayService..TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=dpich.picIDOsoby
LEFT OUTER JOIN RayService..TabCisZam_EXT tczezam WITH(NOLOCK) ON tczezam.ID=tcz.ID
LEFT OUTER JOIN RayService..TabCisZam_EXT tcze WITH(NOLOCK) ON tczezam._EXT_RS_workplace_IDForeman = tcze.ID
WHERE DATEPART(YEAR,dpich.picDatum)>=2022/*DATEPART(YEAR,GETDATE())*/ AND DATEPART(YEAR,dpich.picCasPrichodu)>=2022/*DATEPART(YEAR,GETDATE())*/ AND dpich.picDatum<CONVERT(DATE,GETDATE())
--AND tcz.Cislo='5'
AND tcze._EXT_RS_workplace_IDWorkplace IS NOT NULL
GROUP BY tcze._EXT_RS_workplace_IDWorkplace, dpich.picDatum
ORDER BY tcze._EXT_RS_workplace_IDWorkplace, dpich.picDatum


--docházka - přítomnost
INSERT INTO Tabx_RS_workplace_capacity(IDWorkplace,Datum,WorkerAmount)
SELECT tcze._EXT_RS_workplace_IDWorkplace, DATEADD(DAY,0,DATEDIFF(DAY,0,GETDATE())), COUNT(tcz.ID)
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPritomnost dpr WITH(NOLOCK)
LEFT OUTER JOIN DOCHAZKASQL.IdentitaNET.dbo.OsobyPersonalniData opd WITH(NOLOCK) ON opd.opdIDOsoby=dpr.priIDOsoby
LEFT OUTER JOIN RayService..TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=dpr.priIDOsoby
LEFT OUTER JOIN RayService..TabCisZam_EXT tczezam WITH(NOLOCK) ON tczezam.ID=tcz.ID
LEFT OUTER JOIN RayService..TabCisZam_EXT tcze WITH(NOLOCK) ON tczezam._EXT_RS_workplace_IDForeman = tcze.ID
WHERE ISNULL(opd.opdDenUkonceni,opd.opdDatumVyrazeniDo) IS NULL
--AND tcz.Cislo = '5'
AND tcze._EXT_RS_workplace_IDWorkplace IS NOT NULL
GROUP BY tcze._EXT_RS_workplace_IDWorkplace
ORDER BY tcze._EXT_RS_workplace_IDWorkplace

--budoucnost
INSERT INTO Tabx_RS_workplace_capacity(IDWorkplace,Datum)
SELECT wc.IDWorkplace, vw.Plan_ukonceni_X
FROM hvw_B1E35595F5B2424AAC7695CCCB8F6EE2 vw, Tabx_RS_workplace_capacity wc
WHERE vw.Plan_ukonceni_X > (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
GROUP BY vw.Plan_ukonceni_X, wc.IDWorkplace
ORDER BY vw.Plan_ukonceni_X
--update počtu lidí
UPDATE wc SET wc.WorkerAmount=(SELECT COUNT(tczemistr.ID)
FROM TabCPraco tcpo
LEFT OUTER JOIN TabCisZam_EXT tcze ON tcze._EXT_RS_workplace_IDWorkplace=tcpo.ID
JOIN TabCisZam tcz ON tcz.ID=tcze.ID
LEFT OUTER JOIN TabCisZam_EXT tczemistr ON tczemistr._EXT_RS_workplace_IDForeman=tcz.ID
WHERE tcpo.ID=wc.IDWorkplace)
FROM Tabx_RS_workplace_capacity wc
WHERE wc.Datum > (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))



MERGE Tabx_RS_workplace_capacity AS TARGET
USING TabCPraco AS SOURCE
ON TARGET.IDWorkplace=SOURCE.ID
WHEN MATCHED THEN
UPDATE SET TARGET.Capacity=(
SELECT (convert(Numeric(19,6),(TabCPraco.smennost * 0.01 * TabCPraco.plneni * TARGET.WorkerAmount)))
FROM TabCPraco
WHERE TabCPraco.ID=SOURCE.ID);

END;

GO

