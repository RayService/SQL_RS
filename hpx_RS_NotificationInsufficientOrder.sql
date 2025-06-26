USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NotificationInsufficientOrder]    Script Date: 26.06.2025 13:14:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_NotificationInsufficientOrder]
AS

DECLARE @loginname NVARCHAR(255);
DECLARE @IdZaznamu INT;
DECLARE @IdObdobi INT = (SELECT TabObdobi.ID FROM TabObdobi WHERE (TabObdobi.Nazev LIKE (SELECT DATEPART(YEAR,GETDATE()))));
DECLARE @Sklad NVARCHAR(30);
DECLARE @SystemovePromenne NVARCHAR(MAX);
DECLARE @doc NVARCHAR(30);
DECLARE @TextFull NVARCHAR(255);

BEGIN

IF OBJECT_ID('tempdb..#Notifikace') IS NOT NULL
DROP TABLE #Notifikace
CREATE TABLE #Notifikace (ID INT IDENTITY(1,1),IDDoklad INT,IDSklad INT,RadaDokladu NVARCHAR(3),PoradoveCislo NVARCHAR(10),Autor NVARCHAR(128),LoginId NVARCHAR(128))
INSERT INTO #Notifikace (IDDoklad,IDSklad,RadaDokladu,PoradoveCislo,Autor,LoginId)
SELECT
tdz.ID,tdz.IDSklad,tdz.RadaDokladu,tdz.PoradoveCislo,tdz.Autor,ISNULL(NULLIF(tcz.LoginId,''),'pochyly')
FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabCisZam tcz WITH(NOLOCK) ON tcz.ID=tco.OdpOs
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabNotifikaceSeznamID tnsid WITH(NOLOCK) ON tnsid.IDDoklad=tdz.ID
WHERE
((tdz.Obdobi=@IdObdobi)AND(tdz.DruhPohybuZbo=9)AND(tdz.RadaDokladu IN (N'400',N'410',N'411'))AND(tdz.IDSklad IN (N'100',N'10000115'))AND(tdz.PoradoveCislo>=0)
AND(tdz.SumaKcBezDPH<3000)AND(tcoe._EXT_RS_segmentace NOT LIKE N'%klíčový%')
AND(tnsid.IDDoklad IS NULL))
GROUP BY tdz.ID,tdz.IDSklad,tdz.RadaDokladu,tdz.PoradoveCislo,tdz.Autor,ISNULL(NULLIF(tcz.LoginId,''),'pochyly')

DECLARE @ID INT;
--první běh za LoginId
DECLARE NotifikaceLoginId CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Notifikace
OPEN NotifikaceLoginId;
FETCH NEXT FROM NotifikaceLoginId INTO @ID;
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN
	SET @loginname=(SELECT LoginId FROM #Notifikace WHERE ID=@ID);
	SET @IdZaznamu=(SELECT IDDoklad FROM #Notifikace WHERE ID=@ID);
	SET @Sklad=(SELECT IDSklad FROM #Notifikace WHERE ID=@ID);
	SET @doc=(SELECT RadaDokladu+PoradoveCislo FROM #Notifikace WHERE ID=@ID);
	SET @TextFull='Zadaný expediční příkaz '+@doc+' na skladu '+@Sklad+' nemá vložený manipulační poplatek. Je to v pořádku?'
	--nadefinujeme systémové proměnné
	EXEC dbo.hp_Notifikace_FormatujSystemovePromenne
	@IdObdobi = @IdObdobi
	,@Sklad = @Sklad
	,@Vystup = @SystemovePromenne OUT;
	--pošleme notifikaci
	EXEC dbo.hp_Notifikace_Zalozeni
	@IdNotif = NULL
	,@Typ = 0
	,@GUIDNotifikator = N'C75A9490-3C43-4EA6-9CC5-46A08AA92348'
	,@TextShort = N'Manipulační poplatek'
	,@TextFull = @TextFull
	,@LoginName = @loginname/*N'zufan'*/
	,@NazevTabulkySys = N'TabDokladyZbozi'
	,@BrowseID_DPSN = 25
	,@SystemovePromenne = @SystemovePromenne
	,@IdZaznamu = @IdZaznamu;
FETCH NEXT FROM NotifikaceLoginId INTO @ID;
END;
CLOSE NotifikaceLoginId;
DEALLOCATE NotifikaceLoginId;

--druhý běh za Autor
DECLARE NotifikaceAutor CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Notifikace
OPEN NotifikaceAutor;
FETCH NEXT FROM NotifikaceAutor INTO @ID;
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN
	SET @loginname=(SELECT Autor FROM #Notifikace WHERE ID=@ID);
	SET @IdZaznamu=(SELECT IDDoklad FROM #Notifikace WHERE ID=@ID);
	SET @Sklad=(SELECT IDSklad FROM #Notifikace WHERE ID=@ID);
	SET @doc=(SELECT RadaDokladu+PoradoveCislo FROM #Notifikace WHERE ID=@ID);
	SET @TextFull='Zadaný expediční příkaz '+@doc+' na skladu '+@Sklad+' nemá vložený manipulační poplatek. Je to v pořádku?'
	--nadefinujeme systémové proměnné
	EXEC dbo.hp_Notifikace_FormatujSystemovePromenne
	@IdObdobi = @IdObdobi
	,@Sklad = @Sklad
	,@Vystup = @SystemovePromenne OUT;
	--pošleme notifikaci
	EXEC dbo.hp_Notifikace_Zalozeni
	@IdNotif = NULL
	,@Typ = 0
	,@GUIDNotifikator = N'C75A9490-3C43-4EA6-9CC5-46A08AA92348'
	,@TextShort = N'Manipulační poplatek'
	,@TextFull = @TextFull
	,@LoginName = @loginname/*N'zufan'*/
	,@NazevTabulkySys = N'TabDokladyZbozi'
	,@BrowseID_DPSN = 25
	,@SystemovePromenne = @SystemovePromenne
	,@IdZaznamu = @IdZaznamu;
	-- konec akce v kurzoru Mail
FETCH NEXT FROM NotifikaceAutor INTO @ID;
END;
CLOSE NotifikaceAutor;
DEALLOCATE NotifikaceAutor;


END;



GO

