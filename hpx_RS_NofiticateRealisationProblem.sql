USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NofiticateRealisationProblem]    Script Date: 26.06.2025 12:56:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_NofiticateRealisationProblem]
@ID INT
AS
--DECLARE @ID INT;
DECLARE @loginname NVARCHAR(128);
DECLARE @IdZaznamu INT;
DECLARE @IdObdobi INT = (SELECT TabObdobi.ID FROM TabObdobi WHERE (TabObdobi.Nazev LIKE (SELECT DATEPART(YEAR,GETDATE()))));
DECLARE @Sklad NVARCHAR(30);
DECLARE @SystemovePromenne NVARCHAR(MAX);
DECLARE @doc NVARCHAR(30);
DECLARE @TextFull NVARCHAR(255);
IF OBJECT_ID('tempdb..#Notifikace') IS NOT NULL DROP TABLE #Notifikace
CREATE TABLE #Notifikace (ID INT IDENTITY(1,1),IDDoklad INT,IDSklad INT,RadaDokladu NVARCHAR(3),PoradoveCislo NVARCHAR(10),LoginId NVARCHAR(128))
INSERT INTO #Notifikace (IDDoklad,IDSklad,RadaDokladu,PoradoveCislo,LoginId)
SELECT tdz.ID,tdz.IDSklad,tdz.RadaDokladu,tdz.PoradoveCislo,CASE tdz.RadaDokladu WHEN '540' THEN 'abrahamova' WHEN '550' THEN 'kralikova' END--MŽ, 5.12.2022 změna z 'kralikova', 8.12.2022 změna dle řady příjemky
FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tdz.CisloZakazky=tz.CisloZakazky
WHERE tdz.ID=@ID

BEGIN
SET @loginname=(SELECT LoginID FROM #Notifikace WHERE IDDoklad=@ID);
SET @IdZaznamu=(SELECT IDDoklad FROM #Notifikace WHERE IDDoklad=@ID);
SET @Sklad=(SELECT IDSklad FROM #Notifikace WHERE IDDoklad=@ID);
SET @doc=(SELECT RadaDokladu+PoradoveCislo FROM #Notifikace WHERE IDDoklad=@ID);
SET @TextFull=(SELECT 'Nelze zrealizovat příjemku č. '+@doc+' na skladu '+@Sklad +', protože není splněna některá kooperační operace na VP, z něhož je příjemka generována.');
--nadefinujeme systémové proměnné
EXEC dbo.hp_Notifikace_FormatujSystemovePromenne
@IdObdobi = @IdObdobi
,@Sklad = @Sklad
,@Vystup = @SystemovePromenne OUT;
--pošleme notifikaci
EXEC dbo.hp_Notifikace_Zalozeni
@IdNotif = NULL
,@Typ = 0
,@GUIDNotifikator = N'4DBDCAD4-DBDD-408C-8CA3-2A2635F7859E'
,@TextShort = N'Nelze zrealizovat příjemku.'
,@TextFull = @TextFull
,@LoginName = @loginname/*N'zufan'*/
,@NazevTabulkySys = N'TabDokladyZbozi'
,@BrowseID_DPSN = 16
,@SystemovePromenne = @SystemovePromenne
,@IdZaznamu = @IdZaznamu;

END;

GO

