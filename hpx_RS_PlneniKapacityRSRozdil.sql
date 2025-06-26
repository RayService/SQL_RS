USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlneniKapacityRSRozdil]    Script Date: 26.06.2025 16:07:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlneniKapacityRSRozdil]
AS
SET NOCOUNT ON;
--začneme smazáním stávajících řádků pro Rozdíl
DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRS WHERE TypKapacity=3

IF OBJECT_ID('tempdb..#Rozdil') IS NOT NULL DROP TABLE #Rozdil
CREATE TABLE #Rozdil (ID INT IDENTITY(1,1) NOT NULL, Leden NUMERIC(19,6), Unor NUMERIC(19,6), Brezen NUMERIC(19,6), Duben NUMERIC(19,6), Kveten NUMERIC(19,6), Cerven NUMERIC(19,6), Cervenec NUMERIC(19,6), Srpen NUMERIC(19,6)
, Zari NUMERIC(19,6), Rijen NUMERIC(19,6), Listopad NUMERIC(19,6), Prosinec NUMERIC(19,6), IDPracoviste INT, SkupinaPracoviste NVARCHAR(100))

;WITH Diff AS (
SELECT SkupinaPracoviste, IDPracoviste, Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec
FROM RayService.dbo.Tabx_RS_PrehledKapacitRS
WHERE TypKapacity=1
)
INSERT INTO #Rozdil (SkupinaPracoviste, IDPracoviste, Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec)
SELECT Diff.SkupinaPracoviste, Diff.IDPracoviste, Diff.Leden-Zak.Leden AS Leden, Diff.Unor-Zak.Unor AS Unor, Diff.Brezen-Zak.Brezen AS Brezen, Diff.Duben-Zak.Duben AS Duben, Diff.Kveten-Zak.Kveten AS Kveten, Diff.Cerven-Zak.Cerven AS Cerven, Diff.Cervenec-Zak.Cervenec AS Cervenec
, Diff.Srpen-Zak.Srpen AS Srpen, Diff.Zari-Zak.Zari AS Zari, Diff.Rijen-Zak.Rijen AS Rijen, Diff.Listopad-Zak.Listopad AS Listopad, Diff.Prosinec-Zak.Prosinec AS Prosinec
FROM Diff
LEFT OUTER JOIN RayService.dbo.Tabx_RS_PrehledKapacitRS Zak ON Zak.IDPracoviste=Diff.IDPracoviste

DELETE FROM #Rozdil WHERE Leden=0 OR Unor=0 OR Brezen=0 OR Duben=0 OR Kveten=0 OR Cerven=0 OR Cervenec=0 OR Srpen=0 OR Zari=0 OR Rijen=0 OR Listopad=0 OR Prosinec=0

UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Leden=0 WHERE Leden IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Unor=0 WHERE Unor IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Brezen=0 WHERE Brezen IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Duben=0 WHERE Duben IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Kveten=0 WHERE Kveten IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Cerven=0 WHERE Cerven IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Cervenec=0 WHERE Cervenec IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Srpen=0 WHERE Srpen IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Zari=0 WHERE Zari IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Rijen=0 WHERE Rijen IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Listopad=0 WHERE Listopad IS NULL
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRS SET Prosinec=0 WHERE Prosinec IS NULL

--SELECT *
--FROM  #Rozdil
--ORDER BY IDPracoviste

DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRS WHERE TypKapacity=3

INSERT INTO RayService.dbo.Tabx_RS_PrehledKapacitRS (SkupinaPracoviste, IDPracoviste, TypKapacity, Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec)
SELECT SkupinaPracoviste, IDPracoviste, 3, ISNULL(Leden,0), ISNULL(Unor,0), ISNULL(Brezen,0), ISNULL(Duben,0), ISNULL(Kveten,0), ISNULL(Cerven,0), ISNULL(Cervenec,0), ISNULL(Srpen,0), ISNULL(Zari,0), ISNULL(Rijen,0), ISNULL(Listopad,0), ISNULL(Prosinec,0)
FROM #Rozdil





GO

