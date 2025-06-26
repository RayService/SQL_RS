USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VypocetVykonSkladu]    Script Date: 26.06.2025 15:27:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VypocetVykonSkladu]
AS
SET NOCOUNT ON

BEGIN
--DELETE FROM Tabx_RS_VykonSkladu
;WITH PolScan AS (
SELECT
tcz.ID AS IDZam,
CONVERT(DATE,sddoc.DatPorizeni) AS DatPorizeni,
ROUND(sdpol.mnozstvi*(-1),3) AS Mnozstvi,
ROUND(DATEDIFF(SECOND, sddoc.DatPorizeni, ISNULL(sddoc.DatGenerovani,sddoc.DatGenerInv))/60.0,2)/COUNT(sdpol.ID) OVER(PARTITION BY sddoc.ID) AS DobaVyskladneniPol,
1/*sdpol.ID*/ AS PocPol
--COUNT(sdpol.ID) OVER(PARTITION BY CONVERT(DATE,sddoc.DatPorizeni)) AS PocPol
FROM Gatema_SDScanData sdpol
LEFT OUTER JOIN Gatema_SDDoklady sddoc ON sddoc.ID=sdpol.IDDokladSD
LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=(SELECT tcz.ID  FROM TabCisZam tcz WITH(NOLOCK)  LEFT OUTER JOIN SDServer_Users U ON U.OsCislo=tcz.Cislo WHERE sdpol.Autor=U.Login)
WHERE
sddoc.DatGenerovani IS NOT NULL AND sddoc.TypDokladu<>700
AND(sdpol.DatPorizeni>GETDATE()-365)
AND(sddoc.Autor IS NOT NULL)
AND(ROUND((sdpol.mnozstvi*(-1)),3)>0.0)
AND(sddoc.TypDokladu IN (533,1100))
AND(ROUND(DATEDIFF(SECOND, sddoc.DatPorizeni, ISNULL(sddoc.DatGenerovani,sddoc.DatGenerInv))/60.0,2))<300
)
INSERT INTO Tabx_RS_VykonSkladu (IDZam,DatPorizeniPolozky,Mnozstvi,DS_RS_DobaVyskladneniPol,PocPol,DS_RS_AVGDobaVyskladneniPol)
SELECT IDzam, DatPorizeni, SUM(Mnozstvi), SUM(DobaVyskladneniPol),SUM(PocPol),AVG(DobaVyskladneniPol)
FROM PolScan
WHERE DatPorizeni=CONVERT(DATE,GETDATE()-1)
GROUP BY DatPorizeni, IDZam
END;
GO

