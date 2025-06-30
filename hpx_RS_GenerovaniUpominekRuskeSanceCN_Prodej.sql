USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniUpominekRuskeSanceCN_Prodej]    Script Date: 30.06.2025 9:04:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniUpominekRuskeSanceCN_Prodej]
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
DECLARE @CisloOrg INT;
DECLARE @IDOrg INT;
DECLARE @IDStart INT;
DECLARE @IDEnd INT;
DECLARE @Jazyk NVARCHAR(15);

--sety
SET @Uzivatel=N'zufan'
SET @Popis= N'Odeslání ruských sankcí pro CN Prodej'
SET @PredmetMailu=NULL
SET @Soubor=NULL

--nejprve dočasná tabulka pro doklady
--porovnat s číselníkem CN (naše tabulka) a promazat
--pak jedu řádek po řádku a posílám maily.

--tabulka pro select dokladů
IF OBJECT_ID('tempdb..#CNPolozky') IS NOT NULL DROP TABLE #CNPolozky
CREATE TABLE #CNPolozky (ID INT IDENTITY(1,1) NOT NULL,IDDoklad INT NOT NULL, Sklad NVARCHAR(30) NULL, ParovaciZnak NVARCHAR(20) NOT NULL,CN NVARCHAR(10),IDOrg INT, CisloOrg INT)
;
WITH CN AS (
SELECT tdz.ID AS ID, tdz.IDSklad AS IDSklad, tdz.ParovaciZnak AS ParovaciZnak,
(SELECT kz.CelniNomenklatura FROM TabStavSkladu ss JOIN TabKmenZbozi kz ON ss.IDKmenZbozi=kz.Id WHERE ss.Id=tpz.IDZboSklad) AS CN,
tco.ID AS IDOrg, tco.CisloOrg AS CisloOrg
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg=tdz.CisloOrg
WHERE
(tdz.DruhPohybuZbo=2)AND
((tdz.IDSklad IN (N'100',N'10000115') AND tdz.RadaDokladu IN ('601','602','616','603'))OR
(tdz.IDSklad IN (N'200') AND tdz.RadaDokladu IN ('655','656','674'))
)
--cvičně
--AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni))) BETWEEN '2023-01-01' AND '2025-01-31') --CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
--AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni)))=CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni))) BETWEEN (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()-30)))) AND (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()-1)))))
)
INSERT INTO #CNPolozky (IDDoklad,Sklad,ParovaciZnak,CN,IDOrg,CisloOrg)
SELECT CN.ID, CN.IDSklad, CN.ParovaciZnak, CN.CN, CN.IDOrg, CN.CisloOrg
FROM CN
WHERE ISNULL(CN.CN,'') <> ''

--SELECT *
--FROM #CNPolozky

--promažeme tabulku, aby zůstaly pouze řádky s CN, které se mají hlídat
MERGE #CNPolozky AS TARGET
USING Tabx_RS_CNRuskeSankce3 AS SOURCE
ON TARGET.CN LIKE CONCAT(SOURCE.CN,'%')
WHEN NOT MATCHED BY SOURCE THEN DELETE 
;

--naplníme tabulku pouze s číslem organizace
IF OBJECT_ID('tempdb..#CNOrganizace') IS NOT NULL DROP TABLE #CNOrganizace
CREATE TABLE #CNOrganizace (ID INT IDENTITY(1,1) NOT NULL, IDOrg INT NOT NULL, CisloOrg INT NOT NULL)
INSERT INTO #CNOrganizace (IDOrg,CisloOrg)
SELECT DISTINCT IDOrg,CisloOrg
FROM #CNPolozky

--SELECT *
--FROM #CNOrganizace

--SELECT tco.CisloOrg,tco.Nazev,tco.DruhyNazev
--FROM #CNOrganizace
--LEFT OUTER JOIN TabCisOrg tco ON tco.ID=#CNOrganizace.IDOrg
--LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
--ORDER BY tco.CisloOrg ASC

--nahodíme smyčku za doklady, aby se odeslal mail
SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
FROM #CNOrganizace

WHILE @IDStart<=@IDEnd
	BEGIN
		SET @IDOrg=(SELECT IDOrg FROM #CNOrganizace WHERE ID=@IDStart)
		SET @CisloOrg=(SELECT CisloOrg FROM #CNOrganizace WHERE ID=@IDStart)
		--SET @Jazyk=(SELECT ISNULL(Jazyk,'CZ') FROM TabCisOrg WHERE ID=@IDOrg)

		--tady toto musíme přidat:
		SET @Soubor=N'\\RAYSERVERFS\Company\Útvar jakosti\Všeobecné\02.Procesy\Řízení dokumentů\Dokumentace do ISH\Popisy procesů\Declaration of Compliance - Sanctions against Russia - sales_general.pdf'  --N'cesta\nazev'+NCHAR(13)+N'cesta2\nazev2' 

		SET @PredmetMailu=N'Customer’s declaration of compliance with EU Regulation 833/2014'

		SET @TextMailu=
		N'
Dear Sir or Madam,

In light of the Council Regulation (EU) 833/2014 and its recent updates, we are reaching out to ensure that our business partners remain fully compliant with applicable EU sanctions, particularly regarding restrictions on sales of goods or technologies to Russia or for use in Russia.

To confirm compliance with these regulatory requirements, we kindly request that you review, sign, and return the attached Declaration in response to this e-mail within ten (10) business days of its receipt. Should you need any clarification regarding the Declaration or require further assistance, feel free to reach out to us directly.

Thank you for your prompt attention to this matter and your continued cooperation in meeting regulatory compliance requirements.

Kind regards,

Sales Team
Ray Service, a.s.
		'

		SET @Adresati=(
		SELECT TOP 1 tk.Spojeni	--nově podle požadavků MM předěláno na přednastavený mail z kontaktů na organizaci
			FROM TabKontakty tk
			LEFT OUTER JOIN TabCisOrg tco ON tco.ID=tk.IDOrg
			WHERE
			((tk.Prednastaveno=1)AND(tk.Kam=0)AND(tk.Druh=6)AND(tco.CisloOrg=@CisloOrg))
		)

		--SET @Adresati=N'michal.zufan@rayservice.com'+NCHAR(13)+N'hana.dovrtelova@rayservice.com'  --N'xx@xxx.xx'+NCHAR(13)+N'yy@yyy.yy'
		IF @Adresati IS NULL
		BEGIN
		SET @PredmetMailu='Neodeslané sankce CN prodej'
		SET @TextMailu='Nenalezen kontakt pro odeslání sankcí CN prodej pro organizaci č.'+CONVERT(NVARCHAR(10),@CisloOrg)
		  EXEC RayService.dbo.GEP_RP_NewPozadavekNaMail 
		    @Uzivatel=@Uzivatel, 
		    @Popis='Chybi_kontakt_sankce_CN_prodej', 
		    @Soubor=NULL,
		    @Adresati='customers@rayservice.com',
		    @AdresatiKopie=NULL,
		    @AdresatiSkryty=NULL,
		    @PredmetMailu=@PredmetMailu, 
		    @TextMailu=@TextMailu, 
		    @HTMLTextMailu=NULL, 
		    @Priorita=0, --<0,10> 
		    @MailProfil='P2_CN'
		GOTO NEXT;
		END;

		

		SET @AdresatiSkryty=N'michal.zufan@rayservice.com'--;hana.dovrtelova@rayservice.com;ivana.dolezalova@rayservice.com;magda.mostkova@rayservice.com'
		SET @AdresatiKopie=N'customers@rayservice.com'

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

		--přidáno uložení informace k organizaci
		IF (SELECT tcoe.ID FROM TabCisOrg_EXT tcoe WHERE tcoe.ID=@IDOrg) IS NULL
		BEGIN
		INSERT INTO TabCisOrg_EXT(ID,_EXT_RS_DatumOdeslaniMailuCNProdej) VALUES (@IDOrg,GETDATE())
		END;
		ELSE
		BEGIN
		UPDATE TabCisOrg_EXT SET _EXT_RS_DatumOdeslaniMailuCNProdej=GETDATE() WHERE ID=@IDOrg
		END;
	NEXT:
	SET @IDStart=@IDStart+1
END;


GO

