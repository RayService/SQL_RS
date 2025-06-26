USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_BlockingChain]    Script Date: 26.06.2025 10:07:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_ReseniHeO_BlockingChain]
	@InfoOut BIT = 1
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Znároznění řetezce blokování
-- =============================================

DECLARE @results TABLE (
	id INT IDENTITY(1,1)
    ,BlockingSPID INT NULL
    ,SPID INT NOT NULL
    ,ecid SMALLINT NULL
    ,RowNo INT NOT NULL
    ,LevelRow INT NULL);

IF OBJECT_ID('tempdb..#Processes') IS NOT NULL
    DROP TABLE #Processes;
 
SELECT
    spid
    ,ecid
    ,blocked as BlockingSPID
    ,waittime
    ,CAST(0 as BIT) as deadlock
INTO #Processes
FROM sys.sysprocesses s
WHERE spid > 50;

-- smažeme duplicity - paralelní plány
WITH Dupl AS (
	SELECT
		SPID
		,BlockingSPID
		,ROW_NUMBER() OVER(PARTITION BY SPID ORDER BY waittime DESC) as Poradi
	FROM #Processes)
DELETE FROM Dupl
WHERE Poradi > 1;

-- ošetření případných deadlocků (nesmysl, aby tam byla, ale holt sou - pri paralelním zprac.)

WITH DL AS (
	SELECT
	SPID
	,BlockingSPID
	,waittime
	,CASE WHEN BlockingSPID > 0 
		AND EXISTS(SELECT * FROM #Processes WHERE SPID = P.BlockingSPID AND BlockingSPID = P.SPID) THEN 1 END as DL
	FROM #Processes P
		WHERE P.BlockingSPID > 0)

	,TDL as (
	SELECT DISTINCT
		T.spid
		,T.BlockingSPID
	FROM DL
		-- s nejvyssim casem blokovani, necht je navrhu
		CROSS APPLY (SELECT TOP (1) spid, BlockingSPID FROM DL D WHERE D.DL = 1 AND ((D.spid = DL.spid AND D.BlockingSPID = DL.BlockingSPID) OR (D.spid = DL.BlockingSPID AND D.BlockingSPID = DL.spid)) ORDER BY D.waittime DESC) as T
	WHERE DL.DL = 1
	)
UPDATE C SET
	C.BlockingSPID = 0
	,C.deadlock = 1
FROM #Processes C
	INNER JOIN TDL ON C.spid = TDL.spid AND C.BlockingSPID = TDL.BlockingSPID;

-- konstrukce retezce
WITH Blocking AS
	(SELECT
		s.SPID
		,s.ecid
		,s.BlockingSPID
		,ROW_NUMBER() OVER(ORDER BY s.SPID) AS RowNo
		,0 AS LevelRow
	FROM #Processes s
		INNER JOIN #Processes s1 ON s.SPID = s1.BlockingSPID
	WHERE s.BlockingSPID = 0
		UNION ALL
	SELECT
		r.SPID
		,r.ecid
		,r.BlockingSPID
		,d.RowNo
		,d.LevelRow + 1
	FROM #Processes r
		INNER JOIN Blocking d ON r.BlockingSPID = d.SPID
	WHERE r.BlockingSPID > 0 AND r.BlockingSPID <> r.SPID)
INSERT INTO @results (
    BlockingSPID
    ,SPID
    ,ecid
    ,RowNo
    ,LevelRow) 
SELECT
    BlockingSPID
    ,SPID
    ,ecid
    ,MIN(RowNo)
    ,LevelRow 
FROM Blocking
GROUP BY BlockingSPID, SPID, ecid, LevelRow
ORDER BY MIN(RowNo), LevelRow;
 
TRUNCATE TABLE Tabx_ReseniHeo_BlockingChain;

IF NOT EXISTS (SELECT * FROM @results)
	BEGIN
		IF @InfoOut = 1
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(N'Aktuálně neexistují žádné blokující se procesy!');
		RETURN;
	END;
ELSE
	BEGIN
		INSERT INTO Tabx_ReseniHeO_BlockingChain(
			BlockingChain
			,SPID
			,ECID
			,LoginName
			,HostName
			,ProgramName
			,DbName
			,ObjectId
			,Query
			,ParentQuery
			,Deadlock)
		SELECT
			CASE WHEN R.BlockingSPID = 0 
					THEN CAST(R.SPID AS NVARCHAR(50)) + CASE WHEN ISNULL(R.ecid,0) > 0 THEN N'(' + CAST(R.ecid as NVARCHAR) + N')' ELSE N'' END 
				ELSE
					SPACE(R.LevelRow * 5) + CAST(R.SPID AS NVARCHAR(50)) + CASE WHEN ISNULL(R.ecid,0) > 0 THEN N'(' + CAST(R.ecid as NVARCHAR) + N')' ELSE N'' END 
				END as BlockingChain
			,R.SPID
			,R.ecid
			,S.loginame as LoginName
			,S.hostname as HostName
			,S.[program_name] as ProgramName
			,DB_NAME(S.dbid) as DbName
			,OBJECT_NAME(Q.objectid, s.dbid) as ObjectId
			,SUBSTRING(Q.[text],(s.stmt_start/2) + 1, 
			  (CASE
				 WHEN s.stmt_end = -1 OR s.stmt_end = 0
				   THEN DATALENGTH(Q.[text])
				 ELSE s.stmt_end
			   END - s.stmt_start)/2 + 1) as Query
			,REPLACE(REPLACE(Q.[text], CHAR(10),' '), CHAR(13), '') as ParentQuery
			,P.deadlock
		FROM @results R
			INNER JOIN sys.sysprocesses S ON R.SPID = S.spid
			CROSS APPLY sys.dm_exec_sql_text (S.[sql_handle]) as Q
			LEFT OUTER JOIN #Processes P ON R.SPID = P.spid AND R.ecid = P.ecid
		ORDER BY R.id ASC;
		
		-- GetSysInfo
		--EXEC dbo.hpx_GetSysInfo
		--	@EventType = 1; -- Blokování
		
	END;
GO

