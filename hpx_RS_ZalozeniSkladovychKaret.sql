USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZalozeniSkladovychKaret]    Script Date: 26.06.2025 15:43:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZalozeniSkladovychKaret]
AS

SET NOCOUNT ON;

DECLARE @IDSkladOdv NVARCHAR(30)
DECLARE @IDSkladVyd NVARCHAR(30)
DECLARE @IDKmen INT
DECLARE @IDStart INT, @IDEnd INT

IF OBJECT_ID('tempdb..#SkladyOdv') IS NOT NULL DROP TABLE #SkladyOdv
CREATE TABLE #SkladyOdv (ID INT IDENTITY(1,1) NOT NULL, IDKmen INT NOT NULL, IDSklad NVARCHAR(30) NOT NULL)
IF OBJECT_ID('tempdb..#SkladyVyd') IS NOT NULL DROP TABLE #SkladyVyd
CREATE TABLE #SkladyVyd (ID INT IDENTITY(1,1) NOT NULL, IDKmen INT NOT NULL, IDSklad NVARCHAR(30) NOT NULL)

--generování skladové karty na výchozím skladu pro odvádění
INSERT INTO #SkladyOdv (IDKmen, IDSklad)
SELECT tkz.ID, kmz.VychoziSklad
FROM TabKmenZbozi tkz
LEFT OUTER JOIN TabParKmZ kmz ON kmz.IDKmenZbozi=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=kmz.VychoziSklad
WHERE kmz.VychoziSklad IS NOT NULL AND tss.ID IS NULL

SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #SkladyOdv
IF @IDStart IS NULL
BEGIN
--cyklus
WHILE @IDStart<=@IDEnd
BEGIN 
	SET @IDKmen=(SELECT IDKmen FROM #SkladyOdv WHERE ID=@IDStart)
	SET @IDSkladOdv=(SELECT IDKmen FROM #SkladyOdv WHERE ID=@IDStart)
	EXEC hp_InsertStavSkladu @IDKmen=@IDKmen, @IDSklad=@IDSkladOdv
	SET @IDStart=@IDStart+1
END;
END;

--generování skladové karty na výchozím skladu pro výdej do výroby
SET @IDStart=NULL
SET @IDEnd=NULL
INSERT INTO #SkladyVyd (IDKmen, IDSklad)
SELECT tkz.ID, kmz.VychoziSklad
FROM TabKmenZbozi tkz
LEFT OUTER JOIN TabParametryKmeneZbozi kmz ON kmz.IDKmenZbozi=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=kmz.VychoziSklad
WHERE kmz.VychoziSklad IS NOT NULL AND tss.ID IS NULL

SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #SkladyVyd
IF @IDStart IS NULL
BEGIN
--cyklus
WHILE @IDStart<=@IDEnd
BEGIN 
	SET @IDKmen=(SELECT IDKmen FROM #SkladyVyd WHERE ID=@IDStart)
	SET @IDSkladVyd=(SELECT IDKmen FROM #SkladyVyd WHERE ID=@IDStart)
	EXEC hp_InsertStavSkladu @IDKmen=@IDKmen, @IDSklad=@IDSkladVyd
	SET @IDStart=@IDStart+1
END;
END;
GO

