USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_NaplnCisBrowse]    Script Date: 26.06.2025 10:08:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_ReseniHeO_NaplnCisBrowse]
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		DJ
-- Description:	Naplnění tabulky - Tabx_ReseniHeO_CisBrowse
-- =============================================
IF OBJECT_ID('tempdb..#TabPravaPrehledTemp') IS NULL
	BEGIN
		RAISERROR(N'Dočasná tabulka #TabPravaPrehledTemp neexistuje!',16,1);
		RETURN;
	END;
	
TRUNCATE TABLE Tabx_ReseniHeO_CisBrowse;
INSERT INTO Tabx_ReseniHeO_CisBrowse(
	BID
	,BrowseName
	,TableName
	,SysTableName
	,Soudecek)
SELECT DISTINCT
	BID
	,BrowseName
	,TableName
	,SysTableName
	,Soudecek
FROM #TabPravaPrehledTemp
UNION ALL
SELECT
	(100000 + Cislo)
	,Nazev
	,Nazev
	,NazevSys
	,N'Definované přehledy'
FROM TabObecnyPrehled;
GO

