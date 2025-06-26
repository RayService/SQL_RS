USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SHTools_RetezecBlokovani]    Script Date: 26.06.2025 15:21:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[hpx_SHTools_RetezecBlokovani]
	@InfoOut BIT = 1
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		Jiri Dolezal (JiriDolezalSQL@gmail.com)
-- Description:	Znazorneni retezce blkovani
-- Copyright:	Nasazeni v jinych prostredich? Kontaktujte autora! Plagiatorstvi je zalezitost svedomi.
-- =============================================

DECLARE @results TABLE 
(
	id INT IDENTITY(1,1)
    ,BlockingSPID INT NULL
    ,SPID INT NOT NULL
    ,ecid SMALLINT NULL
    ,RowNo INT NOT NULL
    ,LevelRow INT NULL
);

SELECT
    spid
    ,ecid
    ,blocked as BlockingSPID
    ,waittime
    ,CAST(0 as BIT) as deadlock
INTO #Processes
FROM sys.sysprocesses s /* deprecated - predelat na	sys.dm_exec_connections, sys.dm_exec_sessions, sys.dm_exec_requests */
WHERE spid > 50;

-- smazeme duplicity, paralelni plany
WITH Dupl AS 
(
	SELECT
		SPID
		,BlockingSPID
		,ROW_NUMBER() OVER(PARTITION BY SPID ORDER BY waittime DESC) as Poradi
	FROM #Processes
)
DELETE FROM Dupl
WHERE Poradi > 1;

-- osetreni pripadnych deadlocku (nesmysl, aby tam byla, ale holt sou - pri paralelnim zprac.)

WITH DL AS 
(
	SELECT
		SPID
		,BlockingSPID
		,waittime
		,DL = CASE 
			WHEN BlockingSPID > 0 AND EXISTS(SELECT * FROM #Processes WHERE SPID = P.BlockingSPID AND BlockingSPID = P.SPID) THEN 1 
		END
	FROM #Processes P
	WHERE P.BlockingSPID > 0
)
,TDL as 
(
	SELECT DISTINCT
		T.spid
		,T.BlockingSPID
	FROM DL
		-- s nejvyssim casem blokovani, necht je navrhu
		CROSS APPLY 
		(
			SELECT TOP (1) 
				spid
				,BlockingSPID 
			FROM DL D 
			WHERE D.DL = 1 
				AND 
				(
					(D.spid = DL.spid AND D.BlockingSPID = DL.BlockingSPID) 
					OR (D.spid = DL.BlockingSPID AND D.BlockingSPID = DL.spid)
				) 
			ORDER BY D.waittime DESC
		) as T
	WHERE DL.DL = 1
)
UPDATE C SET
	C.BlockingSPID = 0
	,C.deadlock = 1
FROM #Processes C
	INNER JOIN TDL ON C.spid = TDL.spid AND C.BlockingSPID = TDL.BlockingSPID;

-- konstrukce retezce
WITH Blocking AS
(
	SELECT
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
INSERT INTO @results 
(
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
GROUP BY BlockingSPID
	,SPID
	,ecid
	,LevelRow
ORDER BY MIN(RowNo)
	,LevelRow;
 
TRUNCATE TABLE dbo.Tabx_SHTools_RetezecBlokovani;

IF NOT EXISTS
(
	SELECT 1/0
	FROM @results
)
BEGIN
	IF @InfoOut = 1
	BEGIN
		INSERT INTO #TabExtKom(Poznamka)
		VALUES(N'Aktuálně neexistují žádné blokující se procesy!');
	END;
	RETURN;
END;
ELSE
BEGIN
	INSERT INTO dbo.Tabx_SHTools_RetezecBlokovani
	(
		Retezec
		,SPID
		,ECID
		,LoginName
		,HostName
		,ProgramName
		,DbName
		,ObjectId
		,Query
		,ParentQuery
		,Deadlock
	)
	SELECT
		Retezec = CASE 
			WHEN R.BlockingSPID = 0 
				THEN CAST(R.SPID AS NVARCHAR(50)) + CASE WHEN ISNULL(R.ecid,0) > 0 THEN N'(' + CAST(R.ecid as NVARCHAR) + N')' ELSE N'' END 
			ELSE
				SPACE(R.LevelRow * 5) + CAST(R.SPID AS NVARCHAR(50)) + CASE WHEN ISNULL(R.ecid,0) > 0 THEN N'(' + CAST(R.ecid as NVARCHAR) + N')' ELSE N'' END 
			END
		,R.SPID
		,R.ecid
		,S.loginame
		,S.hostname
		,ProgramName = S.[program_name]
		,DbName = DB_NAME(S.dbid)
		,ObjectId = OBJECT_NAME(Q.objectid, s.dbid)
		,Query = SUBSTRING(Q.[text],(s.stmt_start/2) + 1, 
			(CASE
				WHEN s.stmt_end = -1 OR s.stmt_end = 0
					THEN DATALENGTH(Q.[text])
				ELSE s.stmt_end
			END - s.stmt_start)/2 + 1)
		,ParentQuery = REPLACE(REPLACE(Q.[text], CHAR(10),' '), CHAR(13), '')
		,P.deadlock
	FROM @results R
		INNER JOIN sys.sysprocesses S 
			ON R.SPID = S.spid
		CROSS APPLY sys.dm_exec_sql_text (S.[sql_handle]) as Q
		LEFT OUTER JOIN #Processes P 
			ON R.SPID = P.spid AND R.ecid = P.ecid
	ORDER BY R.id ASC;
END;
GO

