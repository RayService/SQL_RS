USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_LogisImportKAMING]    Script Date: 30.06.2025 8:30:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_LogisImportKAMING]
AS

SET NOCOUNT ON;

--nový select z PEGGINGu
--USE LADB

IF OBJECT_ID('tempdb..#TabMAGG') IS NOT NULL DROP TABLE #TabMAGG
CREATE TABLE #TabMAGG (ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, DEMAND_ID NVARCHAR(100) NOT NULL, SUPPLY_ID NVARCHAR(4000) NOT NULL, QTY_ALLOCATED NUMERIC(19,6) NULL, AVAILABLE_DATE DATETIME NULL, SUPPLY_TYPE NVARCHAR(100) NULL, CisloZakazky NVARCHAR(15) NULL, IDPohybu INT NULL, SupplyTypeOrig INT NULL, IDPrikaz INT NULL, IDDoklad INT NULL)

INSERT INTO #TabMAGG (DEMAND_ID, SUPPLY_ID, QTY_ALLOCATED, AVAILABLE_DATE, SUPPLY_TYPE, CisloZakazky, IDPohybu, SupplyTypeOrig, IDPrikaz, IDDoklad
)
SELECT peg.DEMAND_ID, peg.SUPPLY_ID, peg.QTY_ALLOCATED, peg.AVAILABLE_DATE, peg.SUPPLY_TYPE, tz.CisloZakazky,tpz.ID, NULL, NULL, tpz.IDDoklad
FROM LADB.dbo.OUT_MFGORDERPEGGING peg
LEFT OUTER JOIN RayService.dbo.TabZakazka tz WITH(NOLOCK) ON tz.CisloZakazky=LEFT(peg.DEMAND_ID, CASE WHEN CHARINDEX('|',(peg.DEMAND_ID))-1 < 0 THEN 0 ELSE CHARINDEX('|',(peg.DEMAND_ID))-1 END) COLLATE DATABASE_DEFAULT AND peg.DEMAND_ID NOT LIKE 'ATO%' AND peg.DEMAND_ID NOT LIKE 'PZ%'
LEFT OUTER JOIN RayService.dbo.TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=RIGHT(peg.DEMAND_ID, CHARINDEX('|',REVERSE(peg.DEMAND_ID))-1) COLLATE DATABASE_DEFAULT AND peg.DEMAND_ID NOT LIKE 'ATO%' AND peg.DEMAND_ID NOT LIKE 'PZ%'
--LEFT OUTER JOIN RayService.dbo.TabPrikaz tp WITH(NOLOCK) ON tp.Rada=LEFT(peg.SUPPLY_ID, CHARINDEX('|',REVERSE(peg.SUPPLY_ID))-1) COLLATE DATABASE_DEFAULT AND tp.Prikaz=RIGHT(peg.SUPPLY_ID, CHARINDEX('|',REVERSE(peg.SUPPLY_ID))-1) COLLATE DATABASE_DEFAULT AND peg.DEMAND_ID NOT LIKE 'ATO%' AND peg.DEMAND_ID NOT LIKE 'PZ%' AND peg.SUPPLY_ID NOT LIKE '%|%|%'
WHERE peg.DEMAND_TYPE = 'DO'
--AND peg.SUPPLY_ID NOT LIKE '%|%|%' AND peg.SUPPLY_ID NOT LIKE 'MFG%'
--AND peg.SUPPLY_ID LIKE '%|%|%'
--ORDER BY peg.DEMAND_ID DESC
AND peg.DEMAND_ID NOT LIKE 'PZ%'
AND peg.DEMAND_ID NOT LIKE 'ATO%'
--AND peg.SUPPLY_TYPE NOT IN ('PO','PP','ALLOC')

--SupplyType: 0=VP, 1=MFG, 2=Sklad
UPDATE #TabMAGG SET SupplyTypeOrig=CASE WHEN SUPPLY_ID LIKE 'MFG%' THEN 1 WHEN SUPPLY_ID LIKE '%|%|%' THEN 2 WHEN SUPPLY_TYPE='PO' THEN 4 WHEN SUPPLY_TYPE='PP' THEN 3 ELSE 0 END

--doplnění ID příkazu
UPDATE m SET m.IDPrikaz=tp.ID
FROM #TabMAGG m
LEFT OUTER JOIN RayService.dbo.TabPrikaz tp WITH(NOLOCK) ON tp.Rada=LEFT(m.SUPPLY_ID, CHARINDEX('|',(m.SUPPLY_ID))-1) COLLATE DATABASE_DEFAULT AND tp.Prikaz=RIGHT(m.SUPPLY_ID, CHARINDEX('|',REVERSE(m.SUPPLY_ID))-1) COLLATE DATABASE_DEFAULT AND m.SupplyTypeOrig=0
WHERE m.SupplyTypeOrig=0

--SELECT *
--FROM #TabMAGG
--WHERE SupplyTypeOrig=0 AND IDPrikaz IS NULL

--SELECT *--m.SUPPLY_ID--, LEFT(m.SUPPLY_ID, CHARINDEX('|',(m.SUPPLY_ID))-1) COLLATE DATABASE_DEFAULT, RIGHT(m.SUPPLY_ID, CHARINDEX('|',REVERSE(m.SUPPLY_ID))-1) 
--FROM #TabMAGG m
--WHERE 
----m.ID=4689 AND
--m.SupplyTypeOrig=0
--ORDER BY SUPPLY_ID ASC

TRUNCATE TABLE RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERKAMING

INSERT INTO RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERKAMING (DEMAND_ID, SUPPLY_ID, QTY_ALLOCATED, AVAILABLE_DATE, SUPPLY_TYPE, CisloZakazky, IDPohybu, SupplyTypeOrig, IDPrikaz, IDDoklad)
SELECT DEMAND_ID, SUPPLY_ID, QTY_ALLOCATED, AVAILABLE_DATE, SUPPLY_TYPE, CisloZakazky, IDPohybu, SupplyTypeOrig, IDPrikaz, IDDoklad
FROM #TabMAGG

GO

