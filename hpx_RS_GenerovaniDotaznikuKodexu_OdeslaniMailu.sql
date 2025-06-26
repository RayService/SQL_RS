USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniDotaznikuKodexu_OdeslaniMailu]    Script Date: 26.06.2025 15:10:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniDotaznikuKodexu_OdeslaniMailu]
@ID INT,	--ID organizace, na níž je akce spouštěna
@Typ INT	--typ dotazníku 0=etický kodex, 1=dodavatelský dotazník, 2=ruské sankce, 3=čínské sankce
AS
SET NOCOUNT ON;
--MŽ, 2.6.2025, přidány čínské sankce
--cvičné deklarace
--DECLARE @ID	INT--ID organizace
--DECLARE @Typ INT
--nastavit datum dnes plus 30 dnů
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
--sety
SET @Uzivatel=N'zufan'
SET @Jazyk=(SELECT ISNULL(Jazyk,'CZ') FROM TabCisOrg WHERE ID=@ID)
SET @DatDo=(SELECT CASE WHEN @Typ=0 THEN CONVERT(NVARCHAR(10), GETDATE()+14, 104) WHEN @Typ=2 THEN CONVERT(NVARCHAR(10), GETDATE()+30, 104) ELSE NULL END
)

SET @Popis=CASE @Typ
WHEN 0 THEN N'Odeslání etického kodexu'
WHEN 1 THEN N'Odeslání dodavatelského dotazníku'
WHEN 2 THEN N'Odeslání ruských sankcí'
WHEN 3 THEN N'Odeslání čínských sankcí'
ELSE NULL END

SET @Soubor=(SELECT CASE
WHEN @Typ=0 AND @Jazyk='CZ' THEN N'\\RAYSERVERFS\Company\Útvar jakosti\Všeobecné\02.Procesy\Řízení dokumentů\Dokumentace do ISH\Popisy procesů\Etický kodex pro obchodní partnery - Ray Service.pdf'  --N'cesta\nazev'+NCHAR(13)+N'cesta2\nazev2' 
WHEN @Typ=0 AND @Jazyk<>'CZ' THEN N'\\RAYSERVERFS\company\Útvar jakosti\Všeobecné\02.Procesy\Řízení dokumentů\Dokumentace do ISH\Popisy procesů\CODE OF CONDUCT FOR BUSINESS PARTNERS - Ray Service_rev2...pdf'
WHEN @Typ=2 THEN N'\\RAYSERVERFS\company\Útvar jakosti\Všeobecné\02.Procesy\Řízení dokumentů\Dokumentace do ISH\Popisy procesů\Sanctions against Russia (11th and 12th package) - Letter of Confirmation.pdf'
WHEN @Typ=3 AND @Jazyk='CZ' THEN N'\\RAYSERVERFS\Company\Útvar jakosti\Všeobecné\02.Procesy\Řízení dokumentů\Dokumentace do ISH\Popisy procesů\Žádost o informace_kontrola exportu z Číny.pdf'  --N'cesta\nazev'+NCHAR(13)+N'cesta2\nazev2' 
WHEN @Typ=3 AND @Jazyk<>'CZ' THEN N'\\RAYSERVERFS\company\Útvar jakosti\Všeobecné\02.Procesy\Řízení dokumentů\Dokumentace do ISH\Popisy procesů\RFI_Supplier_Chinese export control.pdf'
ELSE NULL END)

SET @PredmetMailu=(SELECT CASE 
WHEN @Typ=0 AND @Jazyk='CZ' THEN N'Etický kodex společnosti Ray Service, a.s.'
WHEN @Typ=0 AND @Jazyk<>'CZ' THEN N'Code of Conduct for Business Partners of Ray Service, a.s.'
WHEN @Typ=1 AND @Jazyk='CZ' THEN NULL
WHEN @Typ=1 AND @Jazyk<>'CZ' THEN NULL
WHEN @Typ=2 THEN N'Confirmation on compliance with EU sanctions against Russia'
WHEN @Typ=3 AND @Jazyk='CZ' THEN N'Žádost o informace – kontrola exportu z Číny'
WHEN @Typ=3 AND @Jazyk<>'CZ' THEN N'RFI on Chinese export control'
ELSE NULL END)

SET @TextMailu=(SELECT CASE
WHEN @Typ=0 AND @Jazyk='CZ' THEN 
N'
Vážená paní, vážený pane,

Rádi bychom Vás informovali, že společnost Ray Service, a.s. vydala nový Etický kodex obchodního partnera.

Ray Service, a.s. se zavazuje k vysokým standardům obchodní etiky a k bezvýhradnému dodržování právních předpisů. Společnost od všech svých dodavatelů očekává, že budou v rámci své činnosti dodržovat standardy a zásady, které jsou vyjádřené v přiloženém Etickém kodexu. Vážíme si naší vzájemné spolupráce a pevně věříme, že s principy obsaženými v Etickém kodexu se sami ztotožňujete. Jejich dodržování je základním předpokladem spolupráce s Ray Service, a.s.

Rádi bychom Vás požádali, abyste přiložený Etický kodex prostudovali a jeho přijetí stvrdili podpisem odpovědné osoby. Podepsaný dokument prosím naskenujte a zašlete nám nazpět v odpovědi na tento e-mail nejpozději do '+@DatDo+'.

Děkujeme Vám a těšíme se na další spolupráci.

Ray Service, a.s.
'
WHEN @Typ=0 AND @Jazyk<>'CZ' THEN 
N'
Dear Supplier,

We would like to inform you that Ray Service, a.s. has issued a new Code of Conduct for Business Partners.

Ray Service, a.s. commits to high standards of business ethics and thorough compliance with legal regulations. We expect that all our subcontractors will adhere to the standards and principles laid down in the attached Code of Conduct within their business activities. We highly value our existing cooperation and are convinced that you identify yourselves with the principles contained therein. Compliance with the Code of Conduct is an essential precondition of business cooperation with Ray Service, a.s.

We kindly ask you to carefully read through the attached Code of Conduct and confirm to follow the rules and principles laid therein by the signature of a person entitled to act on behalf of your company. Please, scan the signed document and send it back in response to this e-mail by '+@DatDo+'. at the latest. Thank you.

We are looking forward to our further business cooperation.

Ray Service, a.s.
'
WHEN @Typ=2 THEN
N'
Dear Supplier,

As you are surely aware, the EU is tightening the restrictions on imports of certain materials or goods from Russia by adopting the 11th and 12th package of sanctions against Russia. The Council Regulation (EU) 833/2014 amended per (EU) 2023/1214, 2023/2878 and 2023/2873 now regulates imports of certain raw materials and metal goods even more strictly by requiring importers of such materials or goods that have been processed in a third country to prove that none of these materials come from Russia. Furthermore, the country of origin of the primary goods of such materials must be proven at any time and to any control authorities.

In the context of this, Ray Service is obliged to make sure that you, as a Supplier, are compliant with these regulations and so is the entire supply chain.

Therefore, kindly sign and return this confirmation in response to this e-mail by 30th June 2024.

Thank you for your cooperation.

Kind regards,

Purchasing Team
Ray Service, a.s.
'
WHEN @Typ=3 AND @Jazyk='CZ' THEN 
N'
Vážený dodavateli,

s ohledem na nová pravidla zavedená Čínou pro kontrolu vývozu klíčových prvků vzácných zemin (https://www.reuters.com/world/china-hits-back-us-tariffs-with-rare-earth-export-controls-2025-04-04/) si Vás dovolujeme požádat o důkladné prověření, zda může mít tato nová regulace dopad na naši obchodní spolupráci.

Pokud dojdete k závěru, že by se Vás nebo Vašich dodavatelů mohla nová vývozní pravidla dotýkat, zašlete nám prosím vyjádření dle požadavků uvedených v přiložené žádosti, a to do 10 dnů od jejího obdržení na naši e-mailovou adresu: suppliers@rayservice.com.

Děkujeme vám za včasnou odezvu a za vaši trvalou spolupráci při zajišťování kontinuity a dodržování předpisů v celém dodavatelském řetězci.

S pozdravem

Oddělení nákupu
Ray Service, a.s.
'
WHEN @Typ=3 AND @Jazyk<>'CZ' THEN 
N'
Dear Supplier,

In light of the new export control rules imposed by China on key rare earth materials (https://www.reuters.com/world/china-hits-back-us-tariffs-with-rare-earth-export-controls-2025-04-04/), we kindly ask you to investigate whether the new regulations may have an impact on our business cooperation.

If you find that you or your suppliers might be affected by the new export rules, please send a statement as detailed in the request attached within 10 days from receipt to our email address: suppliers@rayservice.com.

Thank you for your prompt attention to this matter and your continued cooperation in ensuring continuity and compliance across the supply chain.

Best regards,

Purchasing Team
Ray Service, a.s.
'
ELSE NULL END)


S