USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UkladaniObchodnichDokumentu]    Script Date: 26.06.2025 16:08:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UkladaniObchodnichDokumentu] @IDFormulare INT, @IDZaznamu INT, @BID INT, @RadaDokladu NVARCHAR(3)
AS
SET NOCOUNT ON;

--Technicky jsem to totiž navrhl tak, že se v okamžiku Tisku (odeslání na tiskárnu) nebo e-mailu (odeslání do Outlooku), uloží pdf s daným formulářem někam na disk a k dokladu se udělá link na tento soubor. Dále se do externí tabulky zapíše datum, autor, číslo formuláře.
--z vyšší procedury přijde IDFormulare a IDZaznamu
--cvičně
--DECLARE @IDFormulare INT;
--DECLARE @IDZaznamu INT;
--DECLARE @BID INT;
--DECLARE @RadaDokladu NVARCHAR(3)

--přidám si dočasnou podmínku
IF (@BID=25 AND @IDZaznamu=1992283) OR (@BID=22 AND @IDZaznamu=1622810) OR (@BID=11143 AND @IDZaznamu=6723)
--konec dočasné podmínky
BEGIN
DECLARE @IDDoklad INT;--ID výdejky, zřejmě brané z dočasné tabulky
DECLARE @Uzivatel nvarchar(100);
DECLARE @Popis nvarchar(100);
DECLARE @BrowseID int;
DECLARE @TiskID int;
DECLARE @Filtr nvarchar(max)=NULL; 
DECLARE @NazevSouboru nvarchar(255); --bez přípony
DECLARE @UmisteniSouboru nvarchar(255)=NULL; --pokud je zadáno, tak je dokument uložen na disk; extení úložiště se zapisuje "<kod>"
DECLARE @IdentVazby int=NULL; --pokud je vyplněno včetně @IDTabVazby, tak je založen dokument v systému HeiN.
DECLARE @IDTabVazby int=NULL; 
DECLARE @Sklad nvarchar(30)=NULL;
DECLARE @IDObdobi int=NULL;
DECLARE @DatumTPV datetime=NULL;
DECLARE @Priorita int=3; --<0,10> 
DECLARE @ParovaciZnak NVARCHAR(20);
DECLARE @Smer INT;	--0=Nákup, 1= Prodej
DECLARE @NazevFormulare NVARCHAR(100)

IF OBJECT_ID('tempdb..#TempDLAutomat') IS NOT NULL DROP TABLE #TempDLAutomat
CREATE TABLE #TempDLAutomat (ID INT IDENTITY(1,1),IDDoklad INT NOT NULL)
INSERT INTO #TempDLAutomat (IDDoklad)
SELECT
tdz.ID
FROM TabDokladyZbozi tdz
WHERE tdz.ID=@IDZaznamu

DECLARE Ukladani CURSOR LOCAL FAST_FORWARD FOR
	SELECT IDDoklad
	FROM #TempDLAutomat
OPEN Ukladani;
FETCH NEXT FROM Ukladani INTO @IDDoklad;
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN

	SET @ParovaciZnak=(SELECT ParovaciZnak FROM TabDokladyZbozi WHERE ID=@IDDoklad)
	SET @Smer=(SELECT CASE WHEN @BID=22 AND @RadaDokladu IN ('800','801','810','811','820','822','850','851','880','870','861') THEN 0
	WHEN @BID=27 AND @RadaDokladu IN ('340','350','381','380') THEN 0
	WHEN @BID=27 AND @RadaDokladu IN('300','310','311','320','330','374','382','383','384','385') THEN 1
	WHEN @BID=25 AND @RadaDokladu IN ('400','410','411','420','430','474') THEN 1
	WHEN @BID=11143 THEN 0
	END)
	SET @Sklad=(SELECT IDSklad FROM TabDokladyZbozi WHERE ID=@IDDoklad)
	SET @IDObdobi=(SELECT Obdobi FROM TabDokladyZbozi WHERE ID=@IDDoklad)
	SET @Uzivatel=N'zufan'
	SET @Popis='Obchodní dokument č.'+@ParovaciZnak
	SET @IdentVazby=(SELECT CASE @BID WHEN 11143 THEN 41 ELSE 9 END)
	SET @Filtr=(SELECT CASE @BID WHEN 11143 THEN 'TabKoopObj.ID='+CONVERT(NVARCHAR(255),@IDDoklad) ELSE 'TabDokladyZbozi.ID='+CONVERT(NVARCHAR(255),@IDDoklad) END)
	SET @NazevSouboru=@ParovaciZnak--'Dodací list č. '+@ParovaciZnak
	SET @UmisteniSouboru=(SELECT CASE @Smer WHEN 0 THEN N'\\RAYSERVERFS\company\Útvar nákup\Interní\sentfromheo - záloha aut. ukládaných dokumentů\'
	WHEN 1 THEN N'\\RAYSERVERFS\company\Útvar prodej\Všeobecné\27.Sentfromheo_záloha aut. ukládaných dokumentů'
	END)
		
	-- požadavek na vytvoření dokumentu z tisku systému Helios 
	  EXEC RayService.dbo.GEP_RP_NewPozadavekNaTisk_Dokument 
		@Uzivatel=@Uzivatel,
		@Popis=@Popis,
		@BrowseID=18,
		@TiskID=@IDFormulare, 
		@Filtr=@Filtr,
		@NazevSouboru=@NazevSouboru, --bez přípony
		@UmisteniSouboru=@UmisteniSouboru, --pokud je zadáno, tak je dokument uložen na disk; extení úložiště se zapisuje "<kod>"
		@IdentVazby=@IdentVazby, --pokud je vyplněno včetně @IDTabVazby, tak je založen dokument v systému HeiN.
		@IDTabVazby=@IDDoklad, 
		@Sklad=@Sklad, 
		@IDObdobi=@IDObdobi, 
		@DatumTPV=NULL, 
		@Priorita=3 --<0,10> 

		SET @NazevFormulare=(SELECT Nazev FROM TabFormDef WHERE ID=@IDFormulare)
		--uložení informací do externí tabulky
		INSERT INTO Tabx_RS_UkladaniObchodnichDokumentu (IDDoklad,SystCisloFormulare,Nazev,Smer)
		VALUES (@IDZaznamu,@IDFormulare,@NazevFormulare,@Smer)


FETCH NEXT FROM Ukladani INTO @IDDoklad;
END;
CLOSE Ukladani;
DEALLOCATE Ukladani;
END;
GO

