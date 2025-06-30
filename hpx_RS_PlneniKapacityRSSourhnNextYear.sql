USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlneniKapacityRSSourhnNextYear]    Script Date: 30.06.2025 8:44:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlneniKapacityRSSourhnNextYear]
AS
SET NOCOUNT ON;

----začneme smazáním všech řádků
DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity IN (0,1,2,3,4,5)
--pro insert do Tabx_RS_PrehledKapacitRSSouhrnNextYear je TypKapacity: 0=Disponibilní kapacita RS, 1=Expediční příkazy, 2=BD, 3=Volná kapacita, 4=FC, 5=RO
--Disponibilní kapacita RS
INSERT INTO Tabx_RS_PrehledKapacitRSSouhrnNextYear (Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec, TypKapacity, Konstanta, Prodano, TotalKapacityPercentage, KonstantaDisponibility)
SELECT SUM(Leden) AS Leden, SUM(Unor) AS Unor, SUM(Brezen) AS Brezen, SUM(Duben) AS Duben, SUM(Kveten) AS Kveten, SUM(Cerven) AS Cervern, SUM(Cervenec) AS Cervenec, SUM(Srpen) AS Srpen, SUM(Zari) AS Zari, SUM(Rijen) AS Rijen, SUM(Listopad) AS Listopad, SUM(Prosinec) AS Prosinec, 0, 0, 0, 100, 530000
FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear
WHERE SkupinaPracoviste IS NOT NULL AND TypKapacity=1
GROUP BY TypKapacity
--Expediční příkazy
INSERT INTO Tabx_RS_PrehledKapacitRSSouhrnNextYear (Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec, TypKapacity, Konstanta, Prodano, TotalKapacityPercentage,KonstantaDisponibility)
SELECT SUM(Leden) AS Leden, SUM(Unor) AS Unor, SUM(Brezen) AS Brezen, SUM(Duben) AS Duben, SUM(Kveten) AS Kveten, SUM(Cerven) AS Cervern, SUM(Cervenec) AS Cervenec, SUM(Srpen) AS Srpen, SUM(Zari) AS Zari, SUM(Rijen) AS Rijen, SUM(Listopad) AS Listopad, SUM(Prosinec) AS Prosinec, 1, 0, 0, 0, 0
FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear
WHERE SkupinaPracoviste IS NOT NULL AND TypKapacity=2 AND EP=1
GROUP BY TypKapacity
--BD
INSERT INTO Tabx_RS_PrehledKapacitRSSouhrnNextYear (Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec, TypKapacity, Konstanta, Prodano, TotalKapacityPercentage, KonstantaDisponibility)
SELECT SUM(Leden) AS Leden, SUM(Unor) AS Unor, SUM(Brezen) AS Brezen, SUM(Duben) AS Duben, SUM(Kveten) AS Kveten, SUM(Cerven) AS Cervern, SUM(Cervenec) AS Cervenec, SUM(Srpen) AS Srpen, SUM(Zari) AS Zari, SUM(Rijen) AS Rijen, SUM(Listopad) AS Listopad, SUM(Prosinec) AS Prosinec, 2, 0, 0, 0, 0
FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear
WHERE IDPracoviste=343 AND TypKapacity=2
GROUP BY TypKapacity
--FC
INSERT INTO Tabx_RS_PrehledKapacitRSSouhrnNextYear (Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec, TypKapacity, Konstanta, Prodano, TotalKapacityPercentage, KonstantaDisponibility)
SELECT SUM(Leden) AS Leden, SUM(Unor) AS Unor, SUM(Brezen) AS Brezen, SUM(Duben) AS Duben, SUM(Kveten) AS Kveten, SUM(Cerven) AS Cervern, SUM(Cervenec) AS Cervenec, SUM(Srpen) AS Srpen, SUM(Zari) AS Zari, SUM(Rijen) AS Rijen, SUM(Listopad) AS Listopad, SUM(Prosinec) AS Prosinec, 4, 0, 0, 0, 0
FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear
WHERE IDPracoviste=344 AND TypKapacity=2
GROUP BY TypKapacity
--Rámcové objednávky
INSERT INTO Tabx_RS_PrehledKapacitRSSouhrnNextYear (Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec, TypKapacity, Konstanta, Prodano, TotalKapacityPercentage,KonstantaDisponibility)
SELECT SUM(Leden) AS Leden, SUM(Unor) AS Unor, SUM(Brezen) AS Brezen, SUM(Duben) AS Duben, SUM(Kveten) AS Kveten, SUM(Cerven) AS Cervern, SUM(Cervenec) AS Cervenec, SUM(Srpen) AS Srpen, SUM(Zari) AS Zari, SUM(Rijen) AS Rijen, SUM(Listopad) AS Listopad, SUM(Prosinec) AS Prosinec, 5, 0, 0, 0, 0
FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear
WHERE SkupinaPracoviste IS NOT NULL AND TypKapacity=2 AND EP=0
GROUP BY TypKapacity
--volná kapacita před výpočtem
INSERT INTO Tabx_RS_PrehledKapacitRSSouhrnNextYear (Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec, TypKapacity, Konstanta, Prodano, TotalKapacityPercentage, KonstantaDisponibility)
SELECT 0,0,0,0,0,0,0,0,0,0,0,0, 3, 0, 0, 0, 0
--výpočet TotalKapacity
--pro insert do Tabx_RS_PrehledKapacitRSSouhrnNextYear je TypKapacity: 0=Disponibilní kapacita RS, 1=Expediční příkazy + P_RO, 2=BD, 3=Volná kapacita, 4=FC
UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacity=Leden+Unor+Brezen+Duben+Kveten+Cerven+Cervenec+Srpen+Zari+Rijen+Listopad+Prosinec+TypKapacity+Konstanta+Prodano WHERE TypKapacity IN (0,1,2,4,5)

DECLARE @TotalKapacityDispo NUMERIC(19,6),
@TotalKapacityBD NUMERIC(19,6),
@TotalKapacityFC NUMERIC(19,6),
@TotalKapacityEP NUMERIC(19,6),
@TotalKapacityRO NUMERIC(19,6),
@TotalKapacityDispoPerc NUMERIC(19,6),
@TotalKapacityBDPerc NUMERIC(19,6),
@TotalKapacityFCPerc NUMERIC(19,6),
@TotalKapacityEPPerc NUMERIC(19,6),
@TotalKapacityROPerc NUMERIC(19,6)
SET @TotalKapacityDispo=(SELECT TotalKapacity FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)
SET @TotalKapacityBD=(SELECT TotalKapacity FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)
SET @TotalKapacityFC=(SELECT TotalKapacity FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)
SET @TotalKapacityEP=(SELECT TotalKapacity FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)
SET @TotalKapacityRO=(SELECT TotalKapacity FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)

UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacity=@TotalKapacityDispo-(@TotalKapacityBD+@TotalKapacityFC) WHERE TypKapacity=3

SET @TotalKapacityDispoPerc=(SELECT TotalKapacityPercentage FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)
SET @TotalKapacityEPPerc=@TotalKapacityEP/@TotalKapacityDispo*100
SET @TotalKapacityROPerc=@TotalKapacityRO/@TotalKapacityDispo*100
SET @TotalKapacityBDPerc=@TotalKapacityBD/@TotalKapacityDispo*100
SET @TotalKapacityFCPerc=@TotalKapacityFC/@TotalKapacityDispo*100

UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacityPercentage=@TotalKapacityEPPerc WHERE TypKapacity=1
UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacityPercentage=@TotalKapacityBDPerc WHERE TypKapacity=2
UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacityPercentage=@TotalKapacityROPerc WHERE TypKapacity=5
UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacityPercentage=@TotalKapacityFCPerc WHERE TypKapacity=4
UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET TotalKapacityPercentage=@TotalKapacityDispoPerc-(@TotalKapacityBDPerc+@TotalKapacityFCPerc) WHERE TypKapacity=3

DECLARE @VolKapLeden NUMERIC(19,6),@VolKapUnor NUMERIC(19,6),@VolKapBrezen NUMERIC(19,6),@VolKapDuben NUMERIC(19,6),@VolKapKveten NUMERIC(19,6),@VolKapCerven NUMERIC(19,6),@VolKapCervenec NUMERIC(19,6),@VolKapSrpen NUMERIC(19,6),@VolKapZari NUMERIC(19,6),@VolKapRijen NUMERIC(19,6),@VolKapListopad NUMERIC(19,6),@VolKapProsinec NUMERIC(19,6)

SET @VolKapLeden=(SELECT Leden FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Leden FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Leden FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Leden FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Leden FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapUnor=(SELECT Unor FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Unor FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Unor FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Unor FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Unor FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapBrezen=(SELECT Brezen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Brezen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Brezen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Brezen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Brezen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapDuben=(SELECT Duben FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Duben FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Duben FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Duben FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Duben FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapKveten=(SELECT Kveten FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Kveten FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Kveten FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Kveten FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Kveten FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapCerven=(SELECT Cerven FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Cerven FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Cerven FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Cerven FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Cerven FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapCervenec=(SELECT Cervenec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Cervenec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Cervenec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Cervenec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Cervenec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapSrpen=(SELECT Srpen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Srpen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Srpen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Srpen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Srpen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapZari=(SELECT Zari FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Zari FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Zari FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Zari FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Zari FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapRijen=(SELECT Rijen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Rijen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Rijen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Rijen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Rijen FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapListopad=(SELECT Listopad FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Listopad FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Listopad FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Listopad FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Listopad FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)
SET @VolKapProsinec=(SELECT Prosinec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=0)-(SELECT Prosinec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=1)-(SELECT Prosinec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=2)-(SELECT Prosinec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=4)-(SELECT Prosinec FROM Tabx_RS_PrehledKapacitRSSouhrnNextYear WHERE TypKapacity=5)

UPDATE Tabx_RS_PrehledKapacitRSSouhrnNextYear SET Leden=@VolKapLeden, Unor=@VolKapUnor, Brezen=@VolKapBrezen, Duben=@VolKapDuben, Kveten=@VolKapKveten, Cerven=@VolKapCerven, Cervenec=@VolKapCervenec, Srpen=@VolKapSrpen, Zari=@VolKapZari, Rijen=@VolKapRijen, Listopad=@VolKapListopad, Prosinec=@VolKapProsinec WHERE TypKapacity=3



GO

