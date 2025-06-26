USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SHTools_BlokLogSber]    Script Date: 26.06.2025 15:20:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE        PROCEDURE [dbo].[hpx_SHTools_BlokLogSber]
	@DatumOd datetime = NULL
	,@DatumDo datetime = NULL
	,@ExtendedEvent sysname = N'blocked_process_report'
	,@HistorieDni smallint = 365
	,@DavkaMazani smallint = 1000
AS
-- =============================================
-- Author: Jiri Dolezal (JiriDolezalSQL@gmail.com)
-- Description: Sber blocku z XE blocked_process_report
-- Copyright:	Nasazeni v jinych prostredich? Kontaktujte autora! Plagiatorstvi je zalezitost svedomi.

-- MŽ, 3.10.2024 parametr @HistorieDni zvednut na 365

-- =============================================
BEGIN
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @IDSber int;

		SELECT
			@DatumOd = COALESCE(@DatumOd,(SELECT MAX(DatumDo) FROM dbo.Tabx_SHTools_BlokLogSber),DATEADD(DAY,-7,GETDATE()))
			,@DatumDo = COALESCE(@DatumDo, GETDATE());

		IF @DatumDo < @DatumOd
			RETURN;

		INSERT INTO dbo.Tabx_SHTools_BlokLogSber
		(
			DatumOd
			,DatumDo
		)
		VALUES
		(
			@DatumOd
			,@DatumDo
		);

		SELECT @IDSber = SCOPE_IDENTITY();

		/* log pres sp_HumanEventsBlockViewer */

		TRUNCATE TABLE dbo.Tabx_SHTools_BlockedProcessReport;
		
		EXEC master.dbo.sp_HumanEventsBlockViewer
			@session_name = @ExtendedEvent
			,@start_date = @DatumOd
			,@end_date = @DatumDo
			,@OutputToTable = N'Y'

		/* preneseni a zpracovani dat */
		INSERT INTO dbo.Tabx_SHTools_BlokLog
		(
			IDSber
			,event_time
			,database_name
			,currentdbname
			,contentious_object
			,activity
			,blocking_tree
			,spid
			,ecid
			,query_text
			,wait_time_ms
			,status
			,isolation_level
			,lock_mode
			,resource_owner_type
			,transaction_count
			,transaction_name
			,last_transaction_started
			,last_transaction_completed
			,client_option_1
			,client_option_2
			,wait_resource
			,priority
			,log_used
			,client_app
			,host_name
			,login_name
			,transaction_id
			,blocked_process_report
		)
		SELECT
			IDSber = @IDSber
			,B.event_time
			,B.database_name
			,B.currentdbname
			,B.contentious_object
			,B.activity
			,B.blocking_tree
			,B.spid
			,B.ecid
			,B.query_text
			,B.wait_time_ms
			,B.status
			,B.isolation_level
			,B.lock_mode
			,B.resource_owner_type
			,B.transaction_count
			,B.transaction_name
			,B.last_transaction_started
			,B.last_transaction_completed
			,B.client_option_1
			,B.client_option_2
			,B.wait_resource
			,B.priority
			,B.log_used
			,B.client_app
			,B.host_name
			,B.login_name
			,B.transaction_id
			,B.blocked_process_report
		FROM dbo.Tabx_SHTools_BlockedProcessReport B;
		
		/* Vymaz historie */
		DROP TABLE IF EXISTS #X;
		CREATE TABLE #X
		(
			ID int NOT NULL PRIMARY KEY CLUSTERED
		);

		INSERT INTO #X
		(
			ID
		)
		SELECT
			S.ID
		FROM dbo.Tabx_SHTools_BlokLogSber S
		WHERE S.DatumDo < DATEADD(DAY, -@HistorieDni, DATEADD(DAY, 1, CAST(GETDATE() as date)));

		WHILE @@ROWCOUNT > 0
		BEGIN
			DELETE TOP (@DavkaMazani) D
			FROM dbo.Tabx_SHTools_BlokLog D
				INNER JOIN #X X
					ON D.IDSber = X.ID
			OPTION(RECOMPILE);
		END;

		DELETE D
		FROM dbo.Tabx_SHTools_BlokLogSber D
		WHERE EXISTS
			(
				SELECT 1/0
				FROM #X
				WHERE ID = D.ID
			);

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
		UPDATE dbo.Tabx_SHTools_BlokLogSber SET
			Chyba = @ErrorMessage
		WHERE ID = @IDSber;
			
		THROW;
	END CATCH;
END;
GO

