USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaCenyOdvolavek]    Script Date: 26.06.2025 15:54:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaCenyOdvolavek] @ID INT
AS
SET NOCOUNT ON;

--Vytvořit funkci, která by automaticky změnila ceny ve všech odvolávkách, pokud se změní cena v rámcové smlouvě.
--Odvolávky vnikají převodem položek z rámcové smlouvy.
--Mají se změnit skutečně ceny všech odvolávek? I do minulosti? I do vykrytých odvolávek? Jak poznám odvolávky (řady, sklady…)?
--Pokud pouze v nevykrytých – jak poznám ne/vykryté? = POUZE NEVYKRYTÉ, POZNÁŠ PODLE SLOUCE „ZBÝVÁ DODAT“ = TO JE ŽIVÁ POLOŽKA - položka EP: podmínka Zbývá dodat > 0
--Jak poznám rámcovku (řady, sklady…)?= NO, TEORETICKY BY TO ŠLO I NA NABÍDKY? RÁMCOVÉ SMLOUVY MÁME V MODULU NABÍDKY,
--TAK KDYBY SE TO VŠEOBECNĚ POUŽILO I ZDE, TAK BY TO UŠETŘILO I PRÁCI S PŘÍP. ZMĚNOU PŘI NABÍDKOVÉM ŘÍZENÍ , 
--SKLAD 200, ŘADY 320,330,383,384
--Přidat do poznámky položek EP, že došlo ke změně ceny a datum.
--zřejmě těch položek EP může být více z jedné položky NAB, které mají zbývá dodat > 0

DECLARE @VstupniCena TINYINT, @PriceNew NUMERIC(19,6), @IDPolEp INT, @IDDokladEP INT, @IDStart INT, @IDEnd INT, @ParovaciZnak NVARCHAR(20), @Poznamka NVARCHAR(MAX)
--cvičně
--DECLARE @ID INT		--označený řádek
--SET @ID=8111233

IF OBJECT_ID('tempdb..#PolEP') IS NOT NULL DROP TABLE #PolEP
CREATE TABLE #PolEP (ID INT IDENTITY(1,1) NOT NULL, IDPolEP INT NOT NULL, IDDokladEP INT NOT NULL, ParovaciZnak NVARCHAR(20))

INSERT INTO #PolEP (IDPolEP, IDDokladEP, ParovaciZnak)
SELECT tpzEP.ID, tpzEP.IDDoklad, tdz.RadaDokladu+'/'+CONVERT(NVARCHAR(10),tdz.PoradoveCislo)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabPohybyZbozi tpzEP ON tpzEP.IDOldPolozka=tpz.ID
WHERE tpz.ID=@ID AND (tpzEP.Mnozstvi-tpzEP.MnOdebrane)>0-- AND (tpz.)

--SELECT *
--FROM #PolEP

--spustíme cyklus za každou položku EP
SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #PolEP
WHILE @IDStart<=@IDEnd
BEGIN
	SET @VstupniCena=NULL;
	SET @PriceNew=NULL;
	SET @IDPolEP=NULL;
	SET @IDDokladEP=NULL;
	SET @Poznamka=NULL;
	SET @ParovaciZnak=NULL
	SET @VstupniCena=(SELECT VstupniCena FROM TabPohybyZbozi WHERE ID=@ID);
	SET @PriceNew=(SELECT CASE @VstupniCena WHEN 0 THEN JCbezDaniKC WHEN 4 THEN JCbezDaniVal END FROM TabPohybyZbozi WHERE ID=@ID);
	SET @IDPolEp=(SELECT IDPolEP FROM #PolEP WHERE ID=@IDStart);
	SET @IDDokladEP=(SELECT IDDokladEP FROM #PolEP WHERE ID=@IDStart);
	SET @ParovaciZnak=(SELECT ParovaciZnak FROM #PolEP WHERE ID=@IDStart);
	SET @Poznamka=(SELECT ISNULL(Poznamka,'')+'
Provedena změna ceny dle předchozí rámcové obj./nabídky č. '+@ParovaciZnak+', dne: '+CONVERT(NVARCHAR(MAX),SYSDATETIMEOFFSET())+'.' FROM TabPohybyZbozi WHERE ID=@IDPolEp)

	IF @VstupniCena=0	--JC bez daní
		BEGIN
			-- aktualizace JC + prepocet dle vstupni ceny po sleve
			UPDATE TabPohybyZbozi SET JCbezDaniKC=@PriceNew, Poznamka=@Poznamka WHERE ID=@IDPolEp
			EXEC dbo.hp_VypCenOZPolozek_IDPolozky @IDPolozky=@IDPolEp, @AktualizaceSlev=0, @Pozice=NULL, @Hranice=NULL, @VstupniCena=0
			EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDokladEP, @AktualizaceSlev=1
		END;

	IF @VstupniCena=4	--JC bez daní valuty
		BEGIN
			-- aktualizace JC + prepocet dle vstupni ceny po sleve
			UPDATE TabPohybyZbozi SET JCbezDaniVal=@PriceNew, Poznamka=@Poznamka WHERE ID=@IDPolEp
			EXEC dbo.hp_VypCenOZPolozek_IDPolozky @IDPolozky=@IDPolEp, @AktualizaceSlev=0, @Pozice=NULL, @Hranice=NULL, @VstupniCena=4
			EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDokladEP, @AktualizaceSlev=1
		END;

	SET @IDStart=@IDStart+1
END;
GO

