USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Mon_HeliosStoji]    Script Date: 26.06.2025 11:07:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_Mon_HeliosStoji]
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Logovani uzivatelem spoustene aktivity pri necinnosti HELIOS
-- =============================================

DECLARE @RunID INT;
DECLARE @destination_table VARCHAR(2000) = DB_NAME() + '.dbo.Tabx_Mon_WhoIsActive';

-- vlozeni zaznamu do tabulky sledovani
INSERT INTO Tabx_Mon_HeliosStoji DEFAULT VALUES;
SELECT @RunID = SCOPE_IDENTITY();

-- logovani
EXEC dbo.sp_WhoIsActive
	@get_task_info = 2
	,@find_block_leaders = 1
	,@get_outer_command = 1
	,@get_transaction_info = 1
	,@get_plans = 1
	,@destination_table = @destination_table;

WAITFOR DELAY '00:00:05';

EXEC dbo.sp_WhoIsActive
	@get_task_info = 2
	,@find_block_leaders = 1
	,@get_outer_command = 1
	,@get_transaction_info = 1
	,@get_plans = 1
	,@destination_table = @destination_table;

-- ukoncovaci cas
UPDATE Tabx_Mon_HeliosStoji SET
	DateStop = GETDATE()
WHERE ID = @RunID;

-- hlaska
IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
	INSERT INTO #TabExtKom(Poznamka)
	VALUES(N'Problém by zalogován a bude předmětem následné analýzy. Děkujeme za spolupráci a pochopení!');
GO

