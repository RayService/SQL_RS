USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SHTools_RetezecBlokovaniKill]    Script Date: 26.06.2025 15:22:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[hpx_SHTools_RetezecBlokovaniKill]
	@IDRetezecBlokovani INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		Jiri Dolezal (JiriDolezalSQL@gmail.com)
-- Description:	Znazorneni retezce blkovani
-- Copyright:	Nasazeni v jinych prostredich? Kontaktujte autora! Plagiatorstvi je zalezitost svedomi.
-- =============================================

DECLARE @SPID smallint = (SELECT SPID FROM dbo.Tabx_SHTools_RetezecBlokovani WHERE ID = @IDRetezecBlokovani)
	,@ExecSQL nvarchar(MAX)
	,@Oznacenych smallint = (SELECT Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM')
	,@Aktualni smallint = (SELECT Cislo FROM #TabExtKomPar WHERE Popis = 'PRECHOD');

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
	
IF @SPID IS NOT NULL
	AND EXISTS
	(
		SELECT 1/0
		FROM sys.sysprocesses 
		WHERE spid = @SPID
	)
BEGIN
	SET @ExecSQL = N'KILL ' + CAST(@SPID as NVARCHAR);
	EXEC (@ExecSQL);
	EXEC dbo.hpx_SHTools_RetezecBlokovani
		@InfoOut = 0;
END;
GO

