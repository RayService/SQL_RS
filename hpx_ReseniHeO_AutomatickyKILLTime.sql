USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_AutomatickyKILLTime]    Script Date: 26.06.2025 9:39:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[hpx_ReseniHeO_AutomatickyKILLTime]
	@NultaDB NVARCHAR(128) = N''	-- systémový název nulté databáze
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		DJ
-- Description:	Automatický KILL neaktivních uživatelů Helios Orange po definovaném čase - pro JOB.
-- =============================================

/* deklarace */

DECLARE @SPID SMALLINT;
DECLARE @ExecSQL NVARCHAR(2000);
DECLARE @CRLF CHAR(2);

SET @CRLF=CHAR(13)+CHAR(10);

/* funkční tělo procedury */

BEGIN TRY

	-- dočasná tabulka pro seznam uživatelů, které odpojovat v definovanem case
	IF OBJECT_ID('tempdb..#ReseniHeO_Kill') IS NOT NULL
		DROP TABLE #ReseniHeO_Kill;
	CREATE TABLE [#ReseniHeO_Kill](
 		[LoginName] [sysname] NOT NULL
		,[KillTime] [smallint] NOT NULL);

	-- kontrola neplatné hodnoty nulté databáze
	IF ISNULL((SELECT DB_ID(@NultaDB)),0) = 0
		BEGIN
			RAISERROR (N'Neplatná hodnota parametru nulté databáze (%s)',16,1,@NultaDB);
			RETURN;
		END;

	-- nevedení seznamu uživatelů pro odpojování
	SET	@ExecSQL = N'INSERT INTO #ReseniHeO_Kill(LoginName, KillTime)' + @CRLF + 
N'SELECT VUserCFG.LoginName, VUserCfgEXT._ReseniHeO_KillTime FROM ' + @NultaDB + N'.dbo.TabUserCfg VUserCfg' + @CRLF +
N'  INNER JOIN ' +  + @NultaDB + N'.dbo.TabUserCfg_EXT VUserCfgEXT ON VUserCfg.ID=VUserCfgEXT.ID' + @CRLF +
N'WHERE VUserCfg.LoginName IS NOT NULL AND VUserCfgEXT._ReseniHeO_KillTime > 0';

	EXEC sp_executesql @ExecSQL;


	-- odpojení
	DECLARE CurOdpojit CURSOR LOCAL FAST_FORWARD FOR
		SELECT spid
		FROM master.dbo.sysprocesses S
			INNER JOIN #ReseniHeO_Kill K ON S.loginame = K.LoginName
		WHERE 
			S.net_library<>N''
			AND DB_NAME(S.[dbid]) = DB_NAME()
			AND S.[program_name] LIKE N'Helios %'
			AND S.open_tran = 0
			AND S.cmd = N'AWAITING COMMAND'
			AND S.[status] = N'sleeping'
			AND DATEDIFF(minute,S.last_batch,GETDATE()) > K.KillTime;
	OPEN CurOdpojit;
	FETCH NEXT FROM CurOdpojit INTO @SPID;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru
			
			INSERT INTO Tabx_KillLog(
				loginame
				,hostname
				,login_time
				,last_batch
				,[program_name]
				,[db_name]
				,[status]
				,cmd
				,open_tran)
			SELECT
				loginame
				,hostname
				,login_time
				,last_batch
				,[program_name]
				,CASE WHEN dbid=0 THEN N'' ELSE DB_NAME([dbid]) END
				,[status]
				,cmd
				,open_tran
			FROM master.dbo.sysprocesses WHERE spid = @SPID;
		
			SET @ExecSQL = N'KILL ' + CAST(@SPID as NVARCHAR);
			EXEC sp_executesql @ExecSQL;
			
			-- konec akce v kurzoru
		FETCH NEXT FROM CurOdpojit INTO @SPID;
		END;
	CLOSE CurOdpojit;
	DEALLOCATE CurOdpojit;
			
END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 --AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	RAISERROR (@ErrorMessage,16,1);
END CATCH;
GO

