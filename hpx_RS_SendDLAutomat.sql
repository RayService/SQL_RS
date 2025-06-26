USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_SendDLAutomat]    Script Date: 26.06.2025 13:20:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_SendDLAutomat]
AS

--zrelizované výdejky na skladu 200
--zatím firma 6956, jinak firmy, které mají TabCisOrg_EXT._EXT_RS_SendDeliveryNoteMail=1
--formulář 209
--akce spouštět každý pátek v 15:00
--gatema procedury pro uložení formuláře na disk a odeslání mailem

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
DECLARE @Adresati NVARCHAR(MAX);
DECLARE @NavaznaObjednavka NVARCHAR(50);


IF OBJECT_ID('tempdb..#TempDLAutomat') IS NOT NULL DROP TABLE #TempDLAutomat
CREATE TABLE #TempDLAutomat (ID INT IDENTITY(1,1),IDDoklad INT NOT NULL)
INSERT INTO #TempDLAutomat (IDDoklad)
SELECT
tdz.ID
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDDoklad=tdz.ID
WHERE
(tdz.IDSklad=N'200')AND(tdz.DruhPohybuZbo>=2)AND(tdz.DruhPohybuZbo<=4)AND(tdz.Realizovano=1)AND(ISNULL(tcoe._EXT_RS_SendDeliveryNoteMail,0)=1)
AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tpz.SkutecneDatReal)))=CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))--MŽ 18.10.2023 změněno z původního na GETDATE()-1
AND(ISNULL(tdze._EXT_RS_DatumOdeslaniMailuDL,0)=0)
GROUP BY tdz.ID

DECLARE PosilaniDLCur CURSOR LOCAL FAST_FORWARD FOR
	SELECT IDDoklad
	FROM #TempDLAutomat
OPEN PosilaniDLCur;
FETCH NEXT FROM PosilaniDLCur INTO @IDDoklad;
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN

	SET @ParovaciZnak=(SELECT ParovaciZnak FROM TabDokladyZbozi WHERE ID=@IDDoklad)
	SET @Sklad=(SELECT IDSklad FROM TabDokladyZbozi WHERE ID=@IDDoklad)
	SET @IDObdobi=(SELECT Obdobi FROM TabDokladyZbozi WHERE ID=@IDDoklad)
	SET @NavaznaObjednavka=(SELECT ' PO '+NavaznaObjednavka FROM TabDokladyZbozi WHERE ID=@IDDoklad)	--MŽ, 5.3.2024 přidáno pro zobrazení v předmětu mailu
	SET @Uzivatel=N'zufan'
	SET @Popis='Dodací list č.'+@ParovaciZnak+'/'+CONVERT(NVARCHAR(4),DATEPART(YEAR,GETDATE()))
	SET @Filtr='TabDokladyZbozi.ID='+CONVERT(NVARCHAR(255),@IDDoklad)
	SET @NazevSouboru=@ParovaciZnak--'Dodací list č. '+@ParovaciZnak
	SET @UmisteniSouboru=N'\\RAYSERVERFS\Company\Útvar prodej\Všeobecné\25. Dodací listy\'
	--doplnění 23.2.2023 úprava tiskového formuláře
	SET @TiskID=(SELECT ISNULL(NULLIF(tcoe._DL_Syst_C,''),209)
				FROM TabDokladyZbozi tdz
				LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
				LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
				WHERE tdz.ID=@IDDoklad)

	-- požadavek na vytvoření dokumentu z tisku systému Helios 
	  EXEC dbo.GEP_RP_NewPozadavekNaTisk_Dokument 
		@Uzivatel=@Uzivatel,
		@Popis=@Popis,
		@BrowseID=18,
		@TiskID=@TiskID, 
		@Filtr=@Filtr,
		@NazevSouboru=@NazevSouboru, --bez přípony
		@UmisteniSouboru=@UmisteniSouboru, --pokud je zadáno, tak je dokument uložen na disk; extení úložiště se zapisuje "<kod>"
		@IdentVazby=9, --pokud je vyplněno včetně @IDTabVazby, tak je založen dokument v systému HeiN.
		@IDTabVazby=@IDDoklad, 
		@Sklad=@Sklad, 
		@IDObdobi=@IDObdobi, 
		@DatumTPV=NULL, 
		@Priorita=3 --<0,10> 

	--odeslání mailem procedurou Gatema - nutno definovat v konfiguraci pluginu SMTP profil pro mail
	DECLARE @PredmetMailu nvarchar(200);
	DECLARE @TextMailu nvarchar(max)=NULL;
	DECLARE @HTMLTextMailu nvarchar(max)=NULL;

	SET @Adresati=(
	SELECT REPLACE(tk.Spojeni,';',NCHAR(13))
	FROM TabDokladyZbozi tdz WITH(NOLOCK)
	LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg=tdz.CisloOrg
	LEFT OUTER JOIN TabKontakty tk WITH(NOLOCK) ON tk.IDOrg=tco.ID AND tk.Prednastaveno=1 AND tk.Druh=0
	WHERE tdz.ID=@IDDoklad)--N'michal.zufan@rayservice.com'+NCHAR(13)+N'miki.zufan@centrum.cz'

	SET @PredmetMailu='RayService; O.N. '+@ParovaciZnak+'/'+CONVERT(NVARCHAR(4),DATEPART(YEAR,GETDATE()))+'; Delivery note/Lieferschein'+@NavaznaObjednavka	--'Delivery note/Lieferschein'+@NavaznaObjednavka
	SET @TextMailu=
'Dear Sir or Madam,
Enclosed you can find delivery note to the package we just dispatched to you.

This e-mail is automatically generated and is only a confirmation of receipt of your order. Please do not reply.


Sehr geehrte Damen und Herren,
Anbei finden Sie den Lieferschein zu dem Paket, das wir gerade an Sie versendet haben.

Diese E-Mail wird automatisch generiert und ist nur eine Eingangsbestätigung Ihrer Bestellung. Bitte nicht antworten.



Ray Service,a.s.
'
	-- požadavek na odeslání tisku ze systému Helios e-mailem 
	  EXEC dbo.GEP_RP_NewPozadavekNaTisk_Mail 
		@Uzivatel=@Uzivatel, 
		@Popis=@Popis, 
		@BrowseID=18, 
		@TiskID=@TiskID, 
		@Filtr=@Filtr, 
		@Adresati=@Adresati, --N'xx@xxx.xx'+NCHAR(13)+N'yy@yyy.yy' 
		@AdresatiKopie=NULL, 
		@AdresatiSkryty=NULL, 
		@PredmetMailu=@PredmetMailu, 
		@TextMailu=@TextMailu, 
		@Sklad=@Sklad, 
		@IDObdobi=@IDObdobi, 
		@DatumTPV=NULL, 
		@HTMLTextMailu=NULL, 
		@Priorita=0, --<0,10> 
		@MailProfil='P1_DL'--3 --kód mailového profilu

	UPDATE TabDokladyZbozi_EXT SET _EXT_RS_DatumOdeslaniMailuDL=GETDATE() WHERE ID=@IDDoklad--přidáno uložení informace k DL

-- konec akce v kurzoru Mail
FETCH NEXT FROM PosilaniDLCur INTO @IDDoklad;
END;
CLOSE PosilaniDLCur;
DEALLOCATE PosilaniDLCur;

GO

