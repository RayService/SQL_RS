USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UzavreniVP909]    Script Date: 26.06.2025 11:12:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UzavreniVP909]
AS
SET NOCOUNT ON;
--uzavírání procesních VP řady 909, pokud jsou splněny (uzavřena) všechny operace, které mají vyplněno Odpovědná osoba úkolu (_OdpOsOp)
--deklarace
DECLARE @IDPrikaz INT;
DECLARE @Min INT;
DECLARE @Max INT;
DECLARE @KonecneOdvedeniNatvrdo BIT;
DECLARE @Dilec INT;
DECLARE @DatPripadu DATETIME;
DECLARE @IDPrikazZdroj INT;
DECLARE @IDPrikazCil INT;
DECLARE @Doklad INT;
DECLARE @IDDilec INT
DECLARE @mnozstvi NUMERIC(19,6);

BEGIN
--pomocná tabule
IF (OBJECT_ID('tempdb..#Tabx_RS_UzavritVP909') IS NOT NULL)
BEGIN
DROP TABLE #Tabx_RS_UzavritVP909
END;
CREATE TABLE #Tabx_RS_UzavritVP909 
( [ID] [INT] IDENTITY(1,1),
  [IDPrikaz] [INT]
)

--zjistíme si VP k uzavření a vložení seznamu VP do dočasné tabule
INSERT INTO #Tabx_RS_UzavritVP909 (IDPrikaz)
SELECT tp.ID
FROM TabPrikaz tp WITH(NOLOCK)
LEFT OUTER JOIN TabPrPostup tpp WITH(NOLOCK) ON tpp.IDPrikaz=tp.ID AND tpp.IDOdchylkyDo IS NULL
LEFT OUTER JOIN TabPrPostup_EXT tppe WITH(NOLOCK) ON tppe.ID=tpp.ID
WHERE tp.ID NOT IN (SELECT tp.ID
					FROM TabPrPostup tpp
					LEFT OUTER JOIN TabPrPostup_EXT tppe WITH(NOLOCK) ON tppe.ID=tpp.ID
					LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=tpp.IDPrikaz
					WHERE ((tpp.IDOdchylkyDo IS NULL)AND(tpp.Splneno=0)AND(tppe._OdpOsOp IS NOT NULL)AND(tp.Rada=N'909')AND(tp.StavPrikazu<=40))
					GROUP BY tp.ID)
AND tp.ID NOT IN (SELECT tp.ID
					FROM Gatema_TermETH G
					JOIN TabPrikaz tp ON tp.ID=G.IDPrikaz
					WHERE (convert(bit,CASE WHEN ISNULL(G.IDKolegy,-1)<0 THEN 0 ELSE 1 END))=0 AND (tp.Rada=N'909')
					GROUP BY tp.ID)
AND(tp.Rada=N'909')AND(tp.StavPrikazu<=40)AND(tppe._OdpOsOp IS NOT NULL)AND(tp.ID NOT IN (156219,156220,156088,132951,17725,132438,28324,170898))
GROUP BY tp.ID

SELECT /*TOP 10 */tp.ID,tp.RadaPrikaz,T.IDPrikaz,T.ID,tp.Rada,tp.Prikaz,tz.CisloZakazky
FROM #Tabx_RS_UzavritVP909 T
JOIN TabPrikaz tp ON tp.ID=T.IDPrikaz
LEFT OUTER JOIN TabZakazka tz ON tz.ID=tp.IDZakazka
ORDER BY T.ID

DECLARE CurCloseVP CURSOR LOCAL FAST_FORWARD FOR
SELECT /*TOP 10*/ IDPrikaz FROM #Tabx_RS_UzavritVP909
OPEN CurCloseVP;
FETCH NEXT FROM CurCloseVP INTO @IDPrikaz;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	SET @DatPripadu=GETDATE();
	SET @Dilec=(SELECT tp.IDTabKmen FROM TabPrikaz tp WHERE tp.ID=@IDPrikaz);
	EXEC hp_OdvedeniPrikazuPrevodem @DatPripadu=@DatPripadu,@KonecneOdvedeniNatvrdo=1,@IDPrikazZdroj=@IDPrikaz,@IDPrikazCil=NULL,@Doklad=NULL,@IDDilec=@Dilec,@mnozstvi=0
	--SELECT 'Zavíráme příkaz '+CONVERT(NVARCHAR(10),@IDPrikaz) +'.'

	FETCH NEXT FROM CurCloseVP INTO @IDPrikaz;
	END;
CLOSE CurCloseVP;
DEALLOCATE CurCloseVP;

END;









/*
--původně bylo:
ALTER PROCEDURE [dbo].[hpx_RS_UzavreniVP909]
	@IDMzdy INT
AS
SET NOCOUNT ON;
-- ==============================================================================================================
-- Author:		MŽ
-- Description:	Při evidenci práce na VP řady 909 a zároveň na poslední nesplněné operaci, kde je vyplněno Odpovědná osoba úkolu
-- Date: 30.6.2021
-- ==============================================================================================================
--DECLARE @IDMzdy INT=xxxxxxxxxxxxxxxxxxx;
DECLARE @IDPrikaz INT;
DECLARE @IDOperation INT;
DECLARE @IDControl INT;
DECLARE @KonecneOdvedeniNatvrdo BIT;
DECLARE @Dilec INT, @DatPripadu datetime, @IDPrikazZdroj int, @IDPrikazCil int, @Doklad int, @IDDilec int, @mnozstvi numeric(19,6);
SET @IDOperation=(SELECT tpp.ID
					FROM TabPrPostup tpp
					LEFT OUTER JOIN TabPrikazMzdyAZmetky tpmz WITH(NOLOCK) ON tpmz.IDPrikaz=tpp.IDPrikaz AND tpmz.DokladPrPostup=tpp.Doklad
					WHERE tpmz.ID=@IDMzdy AND tpp.IDOdchylkyDo IS NULL AND tpp.Prednastaveno=1);
SET @IDPrikaz=(SELECT TOP 1 IDPrikaz FROM TabPrPostup WHERE ID=@IDOperation);
SET @Dilec=(SELECT TOP 1 tp.IDTabKmen FROM TabPrikaz tp WHERE tp.ID=@IDPrikaz);
SET @DatPripadu=GETDATE();

IF (SELECT Uzavrit FROM Tabx_RS_UzavritVP909)=1
BEGIN
EXEC hp_OdvedeniPrikazuPrevodem @DatPripadu=@DatPripadu,@KonecneOdvedeniNatvrdo=1,@IDPrikazZdroj=@IDPrikaz,@IDPrikazCil=NULL,@Doklad=NULL,@IDDilec=@Dilec,@mnozstvi=0
--Print 'Existuje poslední operace a právě na ní evidujete čas.'
END
*/
GO

