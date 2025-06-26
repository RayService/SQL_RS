USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniUpominekRuskeSanceCN_An2]    Script Date: 26.06.2025 15:58:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniUpominekRuskeSanceCN_An2]
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
--sety
SET @Uzivatel=N'zufan'
SET @Popis= N'Odeslání ruských sankcí pro CN Annex 21'
SET @PredmetMailu=N'Declaration of compliance with EU Regulation 833/2014'	--dostanu text
SET @Soubor=N'\\RAYSERVERFS\company\Útvar právní\Všeobecné\02. Procesy\Mezinárodní sankce\Sankce EU proti Rusku\General compliance + Annex 21\Supplier Declaration of Compliance - Sanctions against Russia.pdf'	--dostanu soubor

--nejprve dočasná tabulka pro doklady
--porovnat s číselníkem CN (naše tabulka) a promazat
--pak jedu řádek po řádku a posílám maily.

--tabulka pro select dokladů
IF OBJECT_ID('tempdb..#CNPolozky') IS NOT NULL DROP TABLE #CNPolozky
CREATE TABLE #CNPolozky (ID INT IDENTITY(1,1) NOT NULL,IDOrg INT NOT NULL, CisloOrg INT NOT NULL, CN NVARCHAR(10))

;
WITH CN AS (
SELECT tco.ID AS IDOrg,tco.CisloOrg AS CisloOrg, (SELECT kz.CelniNomenklatura FROM TabStavSkladu ss JOIN TabKmenZbozi kz ON ss.IDKmenZbozi=kz.Id WHERE ss.Id=tpz.IDZboSklad) AS CN
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg=tdz.CisloOrg
  LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
  LEFT OUTER JOIN TabZeme tz ON tco.IdZeme=tz.ISOKod
WHERE
(tdz.IDSklad IN (N'100',N'10000115'))AND(tdz.DruhPohybuZbo=6)
--cvičně
--AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni))) BETWEEN '2022-11-01' AND CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
AND(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,tdz.DatPorizeni)))=CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))
--AND(tz.EU=0)
--AND(tdz.CisloZam IS NOT NULL)	--vyplněný zaměstnanec=VOB je odeslána
--AND(tpz.Mnozstvi-tpz.MnOdebrane)>0	--zbývá dodat je > 0 = nedodaná položka
AND(tcoe._EXT_RS_DatumOdeslaniMailuCN2) IS NULL
AND(tco.ID IS NOT NULL)
)
INSERT INTO #CNPolozky (IDOrg,CisloOrg,CN)
SELECT CN.IDOrg,CN.CisloOrg, CN.CN
FROM CN
WHERE ISNULL(CN.CN,'') <> ''

MERGE #CNPolozky AS TARGET
USING Tabx_RS_CNRuskeSankce2 AS SOURCE
ON TARGET.CN LIKE CONCAT(SOURCE.CN,'%')
WHEN NOT MATCHED BY SOURCE THEN DELETE 
;

--naplníme tabulku pouze s číslem organizace
IF OBJECT_ID('tempdb..#CNOrganizace') IS NOT NULL DROP TABLE #CNOrganizace
CREATE TABLE #CNOrganizace (ID INT IDENTITY(1,1) NOT NULL, IDOrg INT NOT NULL, CisloOrg INT NOT NULL)
INSERT INTO #CNOrganizace (IDOrg,CisloOrg)
SELECT DISTINCT IDOrg,CisloOrg
FROM #CNPolozky


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
		SET @TextMailu=(
N'
Dear Supplier,

In light of the Council Regulation (EU) 833/2014 and its recent updates, we are reaching out to ensure that our suppliers remain fully compliant with applicable EU sanctions, particularly regarding restrictions on goods originating from or exported from Russia.

To confirm compliance with these regulatory requirements, we kindly request that you review, sign, and return the attached Declaration in response to this e-mail within ten (10) business days of its receipt. Should you need any clarification regarding the declaration or require further assistance, feel free to reach out to us directly.

Thank you for your prompt attention to this matter and your continued cooperation in meeting regulatory compliance requirements.

Kind regards,

Purchasing Team
Ray Service, a.s.


'
		)

		SET @Adresati=(
		SELECT TOP 1 tk.Spojeni	--nově podle požadavků MM předěláno na přednastavený mail z kontaktů na organizaci
			FROM TabKontakty tk
			LEFT OUTER JOIN TabCisOrg tco ON tco.ID=tk.IDOrg
			WHERE
			((tk.Prednastaveno=1)AND(tk.Kam=0)AND(tk.Druh=6)AND(tco.CisloOrg=@CisloOrg))
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

		--přidáno uložení informace k organizaci
		IF (SELECT tcoe.ID FROM TabCisOrg_EXT tcoe WHERE tcoe.ID=@IDOrg) IS NULL
		BEGIN
		INSERT INTO TabCisOrg_EXT(ID,_EXT_RS_DatumOdeslaniMailuCN2) VALUES (@IDOrg,GETDATE())
		END;
		ELSE
		BEGIN
		UPDATE TabCisOrg_EXT SET _EXT_RS_DatumOdeslaniMailuCN2=GETDATE() WHERE ID=@IDOrg
		END;
	SET @IDStart=@IDStart+1
END;


GO

