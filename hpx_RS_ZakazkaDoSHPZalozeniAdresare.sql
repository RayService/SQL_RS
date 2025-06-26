USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZakazkaDoSHPZalozeniAdresare]    Script Date: 26.06.2025 14:26:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_ZakazkaDoSHPZalozeniAdresare]
 @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS


SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
EXECUTE AS USER='zufan';
-- ===============================================================================================
-- Author:		MŽ
-- Create date:            21.10.2024
-- Description:	Generování powershellu při založení zakázky, založení adresáře pro zakázku na filesharu
-- ===============================================================================================
--cvičně
--DECLARE @ID INT=104630
--ostře
DECLARE @ID INT
SET @ID=(SELECT ID FROM #TempDefForm_Validace)
DECLARE @CisloZakazky NVARCHAR(15), @PrijemceZakazky NVARCHAR(255), @CisloObjednavky NVARCHAR(50), @UzivatelskyStav NVARCHAR(15)
DECLARE @Path NVARCHAR(255);
SET @CisloZakazky=(SELECT CisloZakazky FROM TabZakazka WHERE ID=@ID)
SET @Path = 'H:\RS\'+@CisloZakazky
SET @CisloObjednavky=(SELECT ISNULL(NULLIF(CisloObjednavky,''),'X') FROM TabZakazka WHERE ID=@ID)
SET @PrijemceZakazky=(SELECT ISNULL(tco.Nazev,'X') FROM TabCisOrg tco LEFT OUTER JOIN TabZakazka tz ON tz.Prijemce=tco.CisloOrg WHERE tz.ID=@ID)
SET @UzivatelskyStav=(SELECT ISNULL(NULLIF(Stav,''),'X') FROM TabZakazka WHERE ID=@ID)

IF @PrijemceZakazky IS NULL
BEGIN
SET @PrijemceZakazky='X'
END;
--SELECT @Path, @CisloZakazky, @CisloObjednavky, @UzivatelskyStav, @PrijemceZakazky
/*
--DECLARE @Net VARCHAR(8000)
--SET @Net='net use H: /delete'
EXEC xp_cmdshell 'net use H: /delete', NO_OUTPUT;
--EXEC xp_cmdshell 'net use H: \\Rayserverfs\helios baRS+245 /USER:michal.zufan /PERSISTENT:yes'
EXEC xp_cmdshell 'net use H: \\Rayserverfs\helios ProductSQL42- /USER:operatorsql /PERSISTENT:yes', NO_OUTPUT;


	--vytvoříme adresář
	EXEC xp_create_subdir @Path;
	--SELECT @Path;
	--EXEC xp_fileexist @Path, NO_OUTPUT;
*/
	--tag číslo zakázky
	DECLARE @sql1 VARCHAR(8000)
	SET @sql1='powershell.exe -File "C:\Tools\PowerShell\Set-TagKlient.ps1" -Path "'+@Path+'" -Tag "CZ" -Value "'+@CisloZakazky+'" -LogFile "C:\Tools\PowerShell\Set-TagKlient.exe.ErrorLog.txt" -LogVerbosity Error'
	--SELECT @sql1
	EXEC xp_cmdshell @sql1, NO_OUTPUT;
	
	--tag příjemce zakázky
	DECLARE @sql2 VARCHAR(8000)
	SET @sql2='powershell.exe -File "C:\Tools\PowerShell\Set-TagKlient.ps1" -Path "'+@Path+'" -Tag "PZ" -Value "'+@PrijemceZakazky+'" -LogFile "C:\Tools\PowerShell\Set-TagKlient.exe.ErrorLog.txt" -LogVerbosity Error'
	--SELECT @sql2
	EXEC xp_cmdshell @sql2, NO_OUTPUT;
	
	--tag číslo objednávky
	DECLARE @sql3 VARCHAR(8000)
	SET @sql3='powershell.exe -File "C:\Tools\PowerShell\Set-TagKlient.ps1" -Path "'+@Path+'" -Tag "CO" -Value "'+@CisloObjednavky+'" -LogFile "C:\Tools\PowerShell\Set-TagKlient.exe.ErrorLog.txt" -LogVerbosity Error'
	--SELECT @sql3
	EXEC xp_cmdshell @sql3, NO_OUTPUT;
	
	--tag uživatelský stav
	DECLARE @sql4 VARCHAR(8000)
	SET @sql4='powershell.exe -File "C:\Tools\PowerShell\Set-TagKlient.ps1" -Path "'+@Path+'" -Tag "US" -Value "'+@UzivatelskyStav+'" -LogFile "C:\Tools\PowerShell\Set-TagKlient.exe.ErrorLog.txt" -LogVerbosity Error'
	--SELECT @sql4
	EXEC xp_cmdshell @sql4, NO_OUTPUT;
	
	

	
GO

