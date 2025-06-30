USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VkladaniDovednostiZamestnancu]    Script Date: 30.06.2025 8:48:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VkladaniDovednostiZamestnancu]
@ZamestnanecId INT,
@UrovenId INT

AS

SET NOCOUNT ON;

--USE HCvicna
--DECLARE @ZamestnanecId INT
--DECLARE @ZnalostId INT
--DECLARE @UrovenId INT

--cvičně si nadefinuju #TabExtKomID
--IF OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL DROP TABLE #TabExtKomID
--CREATE TABLE #TabExtKomID (ID INT NOT NULL)
--INSERT INTO #TabExtKomID (ID)
--VALUES (1511),(1500),(1492),(1366)

IF OBJECT_ID('tempdb..#TabZna') IS NOT NULL DROP TABLE #TabZna
CREATE TABLE #TabZna (ID INT IDENTITY (1,1) NOT NULL, IDZnalost INT NOT NULL, IDZam INT NOT NULL, IDUroven INT NULL)

INSERT INTO #TabZna (IDZnalost, IDZam, IDUroven)
SELECT ptzcis.ID, @ZamestnanecId, @UrovenId
FROM TabPersZnalostiCis ptzcis
WHERE ptzcis.ID IN (SELECT ID FROM #TabExtKomID)
--SELECT *
--FROM #TabZna

MERGE TabCisZamZnalosti AS TARGET
USING #TabZna AS SOURCE
ON TARGET.ZamestnanecId=SOURCE.IDZam AND TARGET.ZnalostId=SOURCE.IDZnalost AND TARGET.UrovenId=SOURCE.IDUroven
WHEN NOT MATCHED BY TARGET THEN
INSERT (ZamestnanecId, ZnalostId, UrovenId)
VALUES (IDZam, IDZnalost, IDUroven)
;
GO

