USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_BlockingChain_Kill]    Script Date: 26.06.2025 10:07:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_ReseniHeO_BlockingChain_Kill]
	@ID INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Kill uživatele
-- =============================================

DECLARE @SPID SMALLINT;
DECLARE @ExecSQL NVARCHAR(800);
DECLARE @Oznacenych SMALLINT;
DECLARE @Aktualni SMALLINT;

SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM';
SELECT @Aktualni = Cislo FROM #TabExtKomPar WHERE Popis = 'PRECHOD';
IF @Aktualni IS NOT NULL OR @Oznacenych IS NOT NULL
	BEGIN
		RAISERROR ('Akci lze spustit pouze nad jedním označeným řádkem!',16,1);
		RETURN;
	END;

IF IS_SRVROLEMEMBER('sysadmin',SUSER_SNAME()) <> 1
	BEGIN
		RAISERROR (N'Akci může provést pouze uživatel v roli sysadmin!',16,1);
		RETURN;
	END;
	
SELECT @SPID = SPID FROM Tabx_ReseniHeO_BlockingChain WHERE ID = @ID;
IF @SPID IS NOT NULL
	AND EXISTS(SELECT * FROM sys.sysprocesses WHERE spid = @SPID)
	BEGIN
		SET @ExecSQL = N'KILL ' + CAST(@SPID as NVARCHAR);
		EXEC (@ExecSQL);
		EXEC dbo.hpx_ReseniHeO_BlockingChain
			@InfoOut = 0;
	END;
GO

