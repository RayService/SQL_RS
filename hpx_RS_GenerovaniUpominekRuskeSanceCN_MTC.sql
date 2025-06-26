USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniUpominekRuskeSanceCN_MTC]    Script Date: 26.06.2025 15:48:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniUpominekRuskeSanceCN_MTC]
AS
SET NOCOUNT ON;

DECLARE @Uzivatel NVARCHAR(100);
DECLARE @Popis NVARCHAR(100);
DECLARE @Soubor NVARCHAR(max)=NULL;
DECLARE @Adresati NVARCHAR(max);
DECLARE @AdresatiKopie NVARCHAR(max)=NULL;
DECLARE @AdresatiSkryty NVARCHAR(max)=NULL;
DECLARE @PredmetMailu NVARCHAR(200);
DECLARE @TextMailu NVARCHAR(max)=NULL;
DECLARE @HTMLTextMailu NVARCHAR(max)=NULL;
DECLARE @MailProfil NVARCHAR(20);
DECLARE @Jazyk NVARCHAR(15);
DECLARE @DatDo NVARCHAR(30);
DECLARE @ParovaciZnak NVARCHAR(20);
DECLARE @IDDoklad INT;
DECLARE @IDStart INT;
DECLARE @IDEnd INT;
--sety
SET @Uzivatel=N'zufan'
SET @Popis= N'Odeslání ruských sankcí pro CN'
SET @PredmetMailu=N'Mill Test Certificate (MTC) Request'
SET @Soubor=N'\\RAYSERVERFS\company\Útvar právní\Všeobecné\02. Procesy\Mezinárodní sankce\Sankce EU proti Rusku\MTC\MTC Request_form.pdf'

--nejprve dočasná tabulka pro doklady
--porovnat s číselníkem CN (naše tabulka) a promazat
--pak jedu řádek po řádku a posílám maily.

--tabulka pro select dokladů
IF OBJECT_ID('tempdb..#CNPolozky') IS NOT NULL DROP TABLE #CNPolozky
CREATE TABLE #CNPolozky (ID INT IDENTITY(1,1) NOT NULL,IDDoklad INT NOT NULL,ParovaciZnak NVARCHAR(20) NOT NULL,CN NVARCHAR(10))

;
WITH CN AS (
SELECT tdz.ID, tdz.ParovaciZnak,(SELECT kz.CelniNomenklatura FROM TabStavSkladu ss JOIN TabKmenZbozi kz ON ss.IDKmenZbozi=kz.Id WHERE ss.Id=tpz.IDZboSklad) AS CN
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg=tdz.CisloOrg
  LEFT OUTER JOIN TabZeme tz ON tco.IdZeme=tz.ISOKod
WHERE
(tdz.IDSklad IN (N'100',N'10000115'))AND(tdz.DruhPohybuZbo=6)
--cvičně
--AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni))) BETWEEN '2023-10-01' AND CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni)))=CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
AND(tz.EU=0)
AND(tdz.CisloZam IS NOT NULL)	--vyplněný zaměstnanec=VOB je odeslána
AND(tpz.Mnozstvi-tpz.MnOdebrane)>0	--zbývá dodat je > 0 = nedodaná položka
)
INSERT INTO #CNPolozky (IDDoklad,ParovaciZnak,CN)
SELECT CN.ID, CN.ParovaciZnak, CN.CN
FROM CN
WHERE ISNULL(CN.CN,'') <> ''

MERGE #CNPolozky AS TARGET
USING Tabx_RS_CNRuskeSankce AS SOURCE
ON TARGET.CN LIKE CONCAT(SOURCE.CN,'%')
WHEN NOT MATCHED BY SOURCE THEN DELETE 
;

--naplníme tabulku pouze s IDDoklady
IF OBJECT_ID('tempdb..#CNDoklady') IS NOT NULL DROP TABLE #CNDoklady
CREATE TABLE #CNDoklady (ID INT IDENTITY(1,1) NOT NULL,IDDoklad INT NOT NULL,ParovaciZnak NVARCHAR(20) NOT NULL)
INSERT INTO #CNDoklady (IDDoklad, ParovaciZnak)
SELECT DISTINCT IDDoklad, ParovaciZnak
FROM #CNPolozky

--nahodíme smyčku za doklady, aby se doplnilo číslo VOB
SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #CNDoklady

WHILE @IDStart<=@IDEnd
	BEGIN
		SET @ParovaciZnak=(SELECT ParovaciZnak FROM #CNDoklady WHERE ID=@IDStart)
		SET @IDDoklad=(SELECT IDDoklad FROM #CNDoklady WHERE ID=@IDStart)
		SET @TextMailu=(
N'
Dear Sir or Madam,

To ensure compliance with Council Regulation (EU) No 833/2014, we require that the products to be delivered under the Purchase Order No. '+@ParovaciZnak+', which are covered by Annex XVII of the abovementioned Council Regulation, are accompanied by a Mill Test Certificate (MTC) containing information regarding the country of origin. This data is essential for us to verify that the products imported into EU do not originate from or have not been processed in Russia.

Please fill in all the required information in the attached form, or alternatively, issue your own document covering the required information, and attach it to the products delivered under the respective Purchase Order.


Thank you for cooperation.


Kind regards,

Purchasing Team
Ray Service, a.s.

'
		)

		SET @Adresati=(
		SELECT TOP 1 tk.Spojeni	--nově podle požadavků MM předěláno na přednastavený mail z kontaktů na organizaci
			FROM TabKontakty tk
			LEFT OUTER JOIN TabCisOrg tco ON tco.ID=tk.IDOrg
			LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.CisloOrg=tco.CisloOrg
			WHERE
			((tk.Prednastaveno=1)AND(tk.Kam=0)AND(tk.Druh=6)AND(tdz.ID=@IDDoklad))
		)

		--SET @Adresati=N'michal.zufan@rayservice.com'--;hana.dovrtelova@rayservice.com'--+NCHAR(13)+N'hana.dovrtelova@rayservice.com'  --N'xx@xxx.xx'+NCHAR(13)+N'yy@yyy.yy'

		SET @AdresatiSkryty=N'michal.zufan@rayservice.com'--;hana.dovrtelova@rayservice.com;ivana.dolezalova@rayservice.com;magda.mostkova@rayservice.com'
		SET @AdresatiKopie=N'suppliers@rayservice.com'

		SET @MailProfil='P2_CN'  --kód mailového profilu
		--odeslání mailu
		  EXEC RayService.dbo.GEP_RP_NewPozadavekNaMail 
		    @Uzivatel=@Uzivatel, 
		    @Popis=@Popis, 
		    @Soubor=@Soubor,
		    @Adresati=@Adresati,
		    @AdresatiKopie=@AdresatiKopie,
		    @AdresatiSkryty=@AdresatiSkryty,
		    @PredmetMailu=@PredmetMailu, 
		    @TextMailu=@TextMailu, 
		    @HTMLTextMailu=NULL, 
		    @Priorita=0, --<0,10> 
		    @MailProfil=@MailProfil

		UPDATE TabDokladyZbozi_EXT SET _EXT_RS_DatumOdeslaniMailuCN=GETDATE() WHERE ID=@IDDoklad--přidáno uložení informace k VOB

	SET @IDStart=@IDStart+1
END;


GO

