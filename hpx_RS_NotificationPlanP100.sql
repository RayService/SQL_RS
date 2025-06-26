USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NotificationPlanP100]    Script Date: 26.06.2025 13:17:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NotificationPlanP100]
AS

/*Upozornění při přeplánování skupiny plánu P100 a série (série nesmí předběhnout P100) – prio 1.
Projdou se všechny plány se skupinou plánu P100. U každého se podle kmenové karty dílce dohledají všechny plány, které mají Datum dříve než Datum na plánu P100.
Najdou-li se nějaké, pošle se notifikace o tomto plánu.
Adresát: Monika Kolářová.Filtr pro oba výběry ještě bude takový, že beru pouze plány Uzavřeno=0, Množství > Zaplánované množství.
Posílat 1x denně*/

--browseID=11010

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
CREATE TABLE #Notifikace (ID INT IDENTITY(1,1),IDPlan INT,IDSklad INT,Autor NVARCHAR(128),LoginId NVARCHAR(128))
;WITH CTE_Plan AS (
SELECT tp.ID,tp.IDTabKmen AS IDTabKmen,tp.datum AS Datum
FROM TabPlan tp WITH (NOLOCK)
WHERE tp.SkupinaPlanu=N'P100' AND tp.Rada IN (N'Plan_fix',N'Plan_quick',N'P_GEN') AND tp.uzavreno=0 AND tp.mnozstvi>tp.mnozPrev)
INSERT INTO #Notifikace (IDPlan,IDSklad,Autor,LoginId)
SELECT tpl.ID, N'100',tpl.Autor,'Kolarova'
FROM CTE_Plan cte
LEFT OUTER JOIN TabPlan tpl ON tpl.IDTabKmen=cte.IDTabKmen AND tpl.uzavreno=0 AND tpl.mnozstvi>tpl.mnozPrev AND tpl.Rada IN (N'Plan_fix',N'Plan_quick',N'P_GEN')
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=cte.IDTabKmen
WHERE tpl.datum<cte.Datum

SELECT * FROM #Notifikace

DECLARE @ID INT;

DECLARE NotifikacePlanP100 CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Notifikace
OPEN NotifikacePlanP100;
FETCH NEXT FROM NotifikacePlanP100 INTO @ID;
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN
	SET @loginname=(SELECT LoginId FROM #Notifikace WHERE ID=@ID);
	SET @IdZaznamu=(SELECT IDPlan FROM #Notifikace WHERE ID=@ID);
	SET @Sklad=(SELECT IDSklad FROM #Notifikace WHERE ID=@ID);
	SET @doc=(SELECT IDPlan FROM #Notifikace WHERE ID=@ID);
	SET @TextFull='Pozor - sériový plán č. '+@doc+' předbíhá P100'
	--nadefinujeme systémové proměnné
	EXEC dbo.hp_Notifikace_FormatujSystemovePromenne
	@IdObdobi = @IdObdobi
	,@Sklad = @Sklad
	,@Vystup = @SystemovePromenne OUT;
	--pošleme notifikaci
	EXEC dbo.hp_Notifikace_Zalozeni
	@IdNotif = NULL
	,@Typ = 0
	,@GUIDNotifikator = N'AC44BE25-06B9-4EAA-979E-74AD71BB0C74'
	,@TextShort = N'P100'
	,@TextFull = @TextFull
	,@LoginName = @loginname/*N'zufan'*/
	,@NazevTabulkySys = N'TabPlan'
	,@BrowseID_DPSN = 11010
	,@SystemovePromenne = @SystemovePromenne
	,@IdZaznamu = @IdZaznamu;
	-- konec akce v kurzoru Mail
FETCH NEXT FROM NotifikacePlanP100 INTO @ID;
END;
CLOSE NotifikacePlanP100;
DEALLOCATE NotifikacePlanP100;



END;



GO

