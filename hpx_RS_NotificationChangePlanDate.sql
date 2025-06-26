USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NotificationChangePlanDate]    Script Date: 26.06.2025 13:31:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NotificationChangePlanDate]
AS

DECLARE @loginname NVARCHAR(255);
DECLARE @IdZaznamu INT;
DECLARE @IdObdobi INT = (SELECT TabObdobi.ID FROM TabObdobi WHERE (TabObdobi.Nazev LIKE (SELECT DATEPART(YEAR,GETDATE()))));
DECLARE @CisloZakazky NVARCHAR(15);
DECLARE @SystemovePromenne NVARCHAR(MAX);
DECLARE @doc NVARCHAR(30);
DECLARE @TextFull NVARCHAR(255);

BEGIN

IF OBJECT_ID('tempdb..#Notifikace') IS NOT NULL
DROP TABLE #Notifikace
CREATE TABLE #Notifikace (ID INT IDENTITY(1,1) NOT NULL,IDPlan INT NOT NULL,SkupZbo NVARCHAR(3),RegCis NVARCHAR(10),Autor NVARCHAR(128),CisloZakazky NVARCHAR(15))
INSERT INTO #Notifikace (Autor,IDPlan,SkupZbo,RegCis,CisloZakazky)
SELECT T.Autor,T.IDvTab,tkz.SkupZbo,tkz.RegCis,tz.CisloZakazky
FROM (SELECT tz.Autor,tzl.IDvTab
FROM TabZmenovyLOG tzl WITH(NOLOCK)
LEFT OUTER JOIN TabZurnal tz WITH(NOLOCK) ON tzl.IdZurnal=tz.ID
WHERE (
(NOT EXISTS(SELECT*FROM TabPravaAtrView A WITH(NOLOCK) WHERE (A.NazevTabulkySys=tzl.Tabulka OR A.NazevTabulkySys + N'_EXT'=tzl.Tabulka) AND A.NazevAtrSys=tzl.Sloupec))
AND(tzl.Tabulka=N'TabPlan')
AND(tzl.LogAkce LIKE N'u%')AND(tzl.Sloupec=N'datum')
AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tzl.Datum)))=CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE())))))
GROUP BY tz.Autor,tzl.IDvTab) AS T
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=T.IDvTab
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tpl.IDTabKmen
LEFT OUTER JOIN TabZakazka tz  WITH(NOLOCK) ON tz.ID=tpl.IDZakazka
WHERE EXISTS (SELECT plprkv.IDPlan
			FROM TabPlanPrKVazby plprkv
			LEFT OUTER JOIN TabKmenZbozi tkzn ON plprkv.nizsi=tkzn.ID
			WHERE((plprkv.IDPlan=tpl.ID))AND(tkzn.Dilec=1)AND(tkzn.SkupZbo NOT IN ('150','930','931','932','934','666','720'))
			AND tpl.Rada IN ('P_blokace','P_GEN','P_RO','P_RO_povrz','Plan_fix','Plan_quick','VVPK')
)

DECLARE @ID INT;
--druhý běh za Autor
DECLARE NotifikaceAutor CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Notifikace
OPEN NotifikaceAutor;
FETCH NEXT FROM NotifikaceAutor INTO @ID;
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN
	SET @loginname=(SELECT Autor FROM #Notifikace WHERE ID=@ID);
	SET @IdZaznamu=(SELECT IDPlan FROM #Notifikace WHERE ID=@ID);
	SET @CisloZakazky=(SELECT ISNULL(CisloZakazky,'PRÁZDNÁ ZAKÁZKA') FROM #Notifikace WHERE ID=@ID);
	SET @doc=(SELECT SkupZbo+RegCis FROM #Notifikace WHERE ID=@ID);
	SET @TextFull='Na výrobním plánu č. '+CONVERT(NVARCHAR(30),@IdZaznamu)+' na dílci '+@doc+' se zakázkou '+@CisloZakazky+' bylo změněno Datum.'
	--nadefinujeme systémové proměnné
	EXEC dbo.hp_Notifikace_FormatujSystemovePromenne
	@IdObdobi = @IdObdobi
	--,@Sklad = @Sklad
	,@Vystup = @SystemovePromenne OUT;
	--pošleme notifikaci
	EXEC dbo.hp_Notifikace_Zalozeni
	@IdNotif = NULL
	,@Typ = 0
	,@GUIDNotifikator = N'AC44BE25-06B9-4EAA-979E-74AD71BB0C74'
	,@TextShort = N'Posun data plánu'
	,@TextFull = @TextFull
	,@LoginName = @loginname/*N'zufan'*/
	,@NazevTabulkySys = N'TabPlan'
	,@BrowseID_DPSN = 11010
	,@SystemovePromenne = @SystemovePromenne
	,@IdZaznamu = @IdZaznamu;
	-- konec akce v kurzoru Mail
FETCH NEXT FROM NotifikaceAutor INTO @ID;
END;
CLOSE NotifikaceAutor;
DEALLOCATE NotifikaceAutor;
END;
GO

