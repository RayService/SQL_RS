USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CalcFairPpapPrice]    Script Date: 26.06.2025 13:04:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_CalcFairPpapPrice] @ID INT
AS
SET NOCOUNT ON

DECLARE @IDPol INT;
DECLARE @CountPol INT, @PriceFAIR INT, @PricePPAP INT;

SET @IDPol=(SELECT pozdok.IDKmenZbozi
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID)
SET @CountPol=(SELECT COUNT(tkv.ID)
FROM TabKvazby tkv
LEFT OUTER JOIN TabCzmeny tczOd ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo ON tkv.ZmenaDo=tczDo.ID
WHERE
((tkv.vyssi=@IDPol)AND((tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()))AND(((tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) ))))

SELECT @PriceFAIR = CASE WHEN (@CountPol < 10) THEN 100 WHEN (@CountPol >= 10 AND @CountPol < 50) THEN 300 WHEN (@CountPol >= 50) THEN 500 ELSE 0 END
SELECT @PricePPAP = CASE WHEN (@CountPol < 10) THEN 200 WHEN (@CountPol >= 10 AND @CountPol < 50) THEN 600 WHEN (@CountPol >= 50) THEN 1000 ELSE 0 END

SELECT @IDPol, @CountPol, @PriceFAIR, @PricePPAP

UPDATE pozdok SET pozdok.FAIR=@PriceFAIR, pozdok.PPAP=@PricePPAP, pozdok.VypocetFairPpap=1
FROM TabPozaZDok_kalk pozdok
WHERE pozdok.ID=@ID
GO

