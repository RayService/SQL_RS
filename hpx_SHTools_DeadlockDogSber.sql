USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SHTools_DeadlockDogSber]    Script Date: 26.06.2025 15:20:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE       PROCEDURE [dbo].[hpx_SHTools_DeadlockDogSber]
	@DatumOd datetime = NULL
	,@DatumDo datetime = NULL
	,@ExtendedEvent sysname = N'system_health'
	,@HistorieDni smallint = 365
	,@DavkaMazani smallint = 1000
AS
-- =============================================
-- Author: Jiri Dolezal (JiriDolezalSQL@gmail.com)
-- Description: Sber deadlocku ze system_health XE
-- Copyright:	Nasazeni v jinych prostredich? Kontaktujte autora! Plagiatorstvi je zalezitost svedomi.

--MŽ, 3.10.2024 parametr @HistorieDni zvednut na 365


-- =============================================
BEGIN
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @IDSber int
			,@OutputDatabaseName sysname = DB_NAME()
			,@OutputSchemaName sysname = N'dbo'
			,@OutputTableName sysname = N'Tabx_SHTools_BlitzLock';

		SELECT
			@DatumOd = COALESCE(@DatumOd,(SELECT MAX(DatumDo) FROM dbo.Tabx_SHTools_DeadlockDogSber),DATEADD(DAY,-7,GETDATE()))
			,@DatumDo = COALESCE(@DatumDo, GETDATE());

		IF @DatumDo < @DatumOd
			RETURN;

		INSERT INTO dbo.Tabx_SHTools_DeadlockDogSber
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

		/* log pres sp_BlitzLock */

		TRUNCATE TABLE dbo.Tabx_SHTools_BlitzLockFindings;
		TRUNCATE TABLE dbo.Tabx_SHTools_BlitzLock;
		
		EXEC master.dbo.sp_BlitzLock
			@StartDate = @DatumOd
			,@EndDate = @DatumDo
			,@EventSessionName = @ExtendedEvent
			,@OutputDatabaseName = @OutputDatabaseName
			,@OutputSchemaName = @OutputSchemaName
			,@OutputTableName = @OutputTableName;

		/* preneseni a zpracovani dat */
		INSERT INTO dbo.Tabx_SHTools_DeadlockDog
		(
			IDSber
			,Skupina
			,ServerName
			,deadlock_type
			,event_date
			,database_name
			,spid
			,deadlock_group
			,query
			,object_names
			,isolation_level
			,owner_mode
			,waiter_mode
			,lock_mode
			,transaction_count
			,client_option_1
			,client_option_2
			,login_name
			,host_name
			,client_app
			,wait_time
			,wait_resource
			,priority
			,log_used
			,last_tran_started
			,last_batch_started
			,last_batch_completed
			,transaction_name
			,status
			,owner_waiter_type
			,owner_activity
			,owner_waiter_activity
			,owner_merging
			,owner_spilling
			,owner_waiting_to_close
			,waiter_waiter_type
			,waiter_owner_activity
			,waiter_waiter_activity
			,waiter_merging
			,waiter_spilling
			,waiter_waiting_to_close
			,deadlock_graph
		)
		SELECT
			IDSber = @IDSber
			,Skupina = DENSE_RANK() OVER(ORDER BY B.event_date ASC)
			,B.ServerName
			,B.deadlock_type
			,B.event_date
			,B.database_name
			,B.spid
			,B.deadlock_group
			,B.query
			,B.object_names
			,B.isolation_level
			,B.owner_mode
			,B.waiter_mode
			,B.lock_mode
			,B.transaction_count
			,B.client_option_1
			,B.client_option_2
			,B.login_name
			,B.host_name
			,B.client_app
			,B.wait_time
			,B.wait_resource
			,B.priority
			,B.log_used
			,B.last_tran_started
			,B.last_batch_started
			,B.last_batch_completed
			,B.transaction_name
			,B.status
			,B.owner_waiter_type
			,B.owner_activity
			,B.owner_waiter_activity
			,B.owner_merging
			,B.owner_spilling
			,B.owner_waiting_to_close
			,B.waiter_waiter_type
			,B.waiter_owner_activity
			,B.waiter_waiter_activity
			,B.waiter_merging
			,B.waiter_spilling
			,B.waiter_waiting_to_close
			,B.deadlock_graph
		FROM dbo.Tabx_SHTools_BlitzLock B;
		
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
		FROM dbo.Tabx_SHTools_DeadlockDogSber S
		WHERE S.DatumDo < DATEADD(DAY, -@HistorieDni, DATEADD(DAY, 1, CAST(GETDATE() as date)));

		WHILE @@ROWCOUNT > 0
		BEGIN
			DELETE TOP (@DavkaMazani) D
			FROM dbo.Tabx_SHTools_DeadlockDog D
				INNER JOIN #X X
					ON D.IDSber = X.ID
			OPTION(RECOMPILE);
		END;

		DELETE D
		FROM dbo.Tabx_SHTools_DeadlockDogSber D
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
		UPDATE dbo.Tabx_SHTools_DeadlockDogSber SET
			Chyba = @ErrorMessage
		WHERE ID = @IDSber;
			
		THROW;
	END CATCH;
END;
GO

