USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_nedodane_polozky_odesilani]    Script Date: 26.06.2025 12:01:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_nedodane_polozky_odesilani]
AS
SET NOCOUNT ON
--název 1, kusy objednané, kusy nedodané, požadované datum dodání, prvotně potvrzené datum dodání,  nové datum dodání (to pole by bylo prázdné)
--nedodané položky
--USE RayService
IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDPohybu] [INT],
  [CisloOrg] [INT],
  [NazevOrg] [NVARCHAR](255),
  [ParovaciZnak] [NVARCHAR](30),
  [NazevPolozky] [NVARCHAR](255),
  [MnozstviObjednano] [NUMERIC](19,2),
  [MnozstviZbyvaDodat] [NUMERIC](19,2),
  [PrvotnePotvrzeneDatumDodaniDodavatel] [NVARCHAR](255),
  [PotvrzeneDatumDodani] [NVARCHAR](255),
  [PozadovaneDatumDodani] [NVARCHAR](255),
  [NovyTermin]  [NVARCHAR](255)
)

DECLARE @CisloOrg INT, @OdpOsobaDodavatele NVARCHAR(255), @MailOdpKOs NVARCHAR(255), @Jazyk INT;
--číslo organizace - pro budoucí cursor
--SET @CisloOrg=4414--1490;--6644;--pro AJ je TE connectivity

DECLARE @i INT = 0;
DECLARE @pos INT;
DECLARE @s VARCHAR(MAX);
DECLARE @ts VARCHAR(MAX);
DECLARE @xml VARCHAR(MAX);
--DECLARE @recipients VARCHAR(7000) = 'michal.zufan@rayservice.com;ludmila.mullerova@rayservice.com' -- change to your own
DECLARE @recipients VARCHAR(7000)-- = 'michal.zufan@rayservice.com'
DECLARE @blind_copy_recipients VARCHAR(7000)='michal.zufan@rayservice.com;'--ludmila.mullerova@rayservice.com' -- change to your own*/

DECLARE @rec_temp VARCHAR(MAX);

INSERT INTO #Temp (IDPohybu,CisloOrg,NazevOrg,ParovaciZnak,NazevPolozky,MnozstviObjednano,MnozstviZbyvaDodat,PrvotnePotvrzeneDatumDodaniDodavatel,PotvrzeneDatumDodani,PozadovaneDatumDodani,NovyTermin)
/*SELECT
tpz.ID,tco.CisloOrg,tco.Nazev,/*MŽ 12.5.2023 zpět vrácen pouze párovací znak: tdz.RadaDokladu+'-'+tdz.IDSklad+'-'+CAST(tdz.PoradoveCislo AS NVARCHAR(15))*/tdz.ParovaciZnak,tpz.Nazev1,tpz.Mnozstvi,tpz.Mnozstvi - tpz.MnOdebrane,FORMAT(tpze._dat_dod1,'dd.MM.yyyy') AS 'Prvotně potvrzené datum dodání od dodavatele',FORMAT(tpz.PotvrzDatDod_X,'dd.MM.yyyy'),FORMAT(tpz.PozadDatDod_X,'dd.MM.yyyy'),' '
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg IN(SELECT TabDokladyZbozi.CisloOrg FROM TabDokladyZbozi WHERE TabDokladyZbozi.ID=tpz.IDDoklad)
  LEFT OUTER JOIN TabCisOrg_EXT tco_EXT ON tco_EXT.ID=tco.ID
WHERE
(tdz.Obdobi>=214)AND(tdz.IDSklad IN ('100','10000115'))AND(tdz.DruhPohybuZbo=6)AND
((((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod_X<=DATEADD(DAY,-1,GETDATE()))AND(tdz.Splneno<>1))
OR(((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod IS NULL)AND(tdz.Splneno<>1)AND(tpze._dat_dod1<=DATEADD(DAY,-1,GETDATE()))))
--AND(tco.CisloOrg=@CisloOrg)
--MŽ, 25.8.2023 vyjmuta organizace 0 a 14639
AND(tco.CisloOrg NOT IN (0,14639))
ORDER BY tco.CisloOrg,tdz.ParovaciZnak,tpze._dat_dod1 ASC*/

--původní selec 8.11.2024 na přání MM nahrazen:
SELECT
tpz.ID,tco.CisloOrg,tco.Nazev,/*MŽ 12.5.2023 zpět vrácen pouze párovací znak: tdz.RadaDokladu+'-'+tdz.IDSklad+'-'+CAST(tdz.PoradoveCislo AS NVARCHAR(15))*/tdz.ParovaciZnak,tpz.Nazev1,tpz.Mnozstvi,tpz.Mnozstvi - tpz.MnOdebrane,FORMAT(tpze._dat_dod1,'dd.MM.yyyy') AS 'Prvotně potvrzené datum dodání od dodavatele',FORMAT(tpz.PotvrzDatDod_X,'dd.MM.yyyy'),FORMAT(tpz.PozadDatDod_X,'dd.MM.yyyy'),' '
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg IN(SELECT TabDokladyZbozi.CisloOrg FROM TabDokladyZbozi WHERE TabDokladyZbozi.ID=tpz.IDDoklad)
  LEFT OUTER JOIN TabCisOrg_EXT tco_EXT ON tco_EXT.ID=tco.ID
WHERE
(tdz.Obdobi>=214)AND(tdz.IDSklad=N'100')AND(tdz.DruhPohybuZbo=6)AND(tdz.Splneno<>1)
/*((((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod_X<=DATEADD(DAY,-1,GETDATE()))AND(tdz.Splneno<>1))
OR(((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod IS NULL)AND(tdz.Splneno<>1)AND(tpze._dat_dod1<=DATEADD(DAY,-1,GETDATE()))))		MŽ 8.11.2024 vyřazeno na přání MM*/
--AND(tco.CisloOrg=@CisloOrg)
--MŽ, 25.8.2023 vyjmuta organizace 0 a 14639
AND(tco.CisloOrg NOT IN (0,14639))
AND(ISNULL(tpze._EXT_RS_MovNumber,0)>0)
--MŽ, 22.1.2025 po dohodě s MM vrácena podmínka na zbývá dodat > 0, protože to posílalo i dodané položky
AND((tpz.Mnozstvi - tpz.MnOdebrane)>0)
UNION ALL
SELECT
tpz.ID,tco.CisloOrg,tco.Nazev,/*MŽ 12.5.2023 zpět vrácen pouze párovací znak: tdz.RadaDokladu+'-'+tdz.IDSklad+'-'+CAST(tdz.PoradoveCislo AS NVARCHAR(15))*/tdz.ParovaciZnak,tpz.Nazev1,tpz.Mnozstvi,tpz.Mnozstvi - tpz.MnOdebrane,FORMAT(tpze._dat_dod1,'dd.MM.yyyy') AS 'Prvotně potvrzené datum dodání od dodavatele',FORMAT(tpz.PotvrzDatDod_X,'dd.MM.yyyy'),FORMAT(tpz.PozadDatDod_X,'dd.MM.yyyy'),' '
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg IN(SELECT TabDokladyZbozi.CisloOrg FROM TabDokladyZbozi WHERE TabDokladyZbozi.ID=tpz.IDDoklad)
  LEFT OUTER JOIN TabCisOrg_EXT tco_EXT ON tco_EXT.ID=tco.ID
WHERE
(tdz.Obdobi>=214)AND(tdz.IDSklad=N'10000115')AND(tdz.DruhPohybuZbo=6)AND
((((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod_X<=DATEADD(DAY,-1,GETDATE()))AND(tdz.Splneno<>1))
OR(((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod IS NULL)AND(tdz.Splneno<>1)AND(tpze._dat_dod1<=DATEADD(DAY,-1,GETDATE()))))
--AND(tco.CisloOrg=@CisloOrg)
--MŽ, 25.8.2023 vyjmuta organizace 0 a 14639
AND(tco.CisloOrg NOT IN (0,14639))




--započneme cursor
DECLARE Mail CURSOR LOCAL FAST_FORWARD FOR
SELECT TC.CisloOrg
FROM ((SELECT tco.CisloOrg AS CisloOrg
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg IN(SELECT TabDokladyZbozi.CisloOrg FROM TabDokladyZbozi WHERE TabDokladyZbozi.ID=tpz.IDDoklad)
  LEFT OUTER JOIN TabCisOrg_EXT tco_EXT ON tco_EXT.ID=tco.ID
WHERE
(tdz.Obdobi>=214)AND(tdz.IDSklad=N'100')AND(tdz.DruhPohybuZbo=6)AND(tdz.Splneno<>1)
/*((((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod_X<=DATEADD(DAY,-1,GETDATE()))AND(tdz.Splneno<>1))
OR(((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod IS NULL)AND(tdz.Splneno<>1)AND(tpze._dat_dod1<=DATEADD(DAY,-1,GETDATE()))))		MŽ 8.11.2024 vyřazeno na přání MM*/
--AND(tco.CisloOrg=@CisloOrg)
--MŽ, 25.8.2023 vyjmuta organizace 0 a 14639
AND(tco.CisloOrg NOT IN (0,14639))
AND(ISNULL(tpze._EXT_RS_MovNumber,0)>0)
--MŽ, 22.1.2025 po dohodě s MM vrácena podmínka na zbývá dodat > 0, protože to posílalo i dodané položky
AND((tpz.Mnozstvi - tpz.MnOdebrane)>0))
UNION ALL
(SELECT tco.CisloOrg AS CisloOrg
FROM TabPohybyZbozi tpz
  LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
  LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
  LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg IN(SELECT TabDokladyZbozi.CisloOrg FROM TabDokladyZbozi WHERE TabDokladyZbozi.ID=tpz.IDDoklad)
  LEFT OUTER JOIN TabCisOrg_EXT tco_EXT ON tco_EXT.ID=tco.ID
WHERE
(tdz.Obdobi>=214)AND(tdz.IDSklad=N'10000115')AND(tdz.DruhPohybuZbo=6)AND
((((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod_X<=DATEADD(DAY,-1,GETDATE()))AND(tdz.Splneno<>1))
OR(((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod IS NULL)AND(tdz.Splneno<>1)AND(tpze._dat_dod1<=DATEADD(DAY,-1,GETDATE()))))
--AND(tco.CisloOrg=@CisloOrg)
--MŽ, 25.8.2023 vyjmuta organizace 0 a 14639
AND(tco.CisloOrg NOT IN (0,14639))
)) AS TC
GROUP BY TC.CisloOrg
ORDER BY TC.CisloOrg

OPEN Mail;
	FETCH NEXT FROM Mail INTO @CisloOrg;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

SET @Jazyk=(SELECT CASE WHEN (SELECT tco.IdZeme FROM TabCisOrg tco WHERE tco.CisloOrg=@CisloOrg) LIKE N'%cz%' THEN 0
						WHEN (SELECT tco.IdZeme FROM TabCisOrg tco WHERE tco.CisloOrg=@CisloOrg) IS NULL THEN 1
						ELSE 1 END)
--SELECT @Jazyk
--SELECT * FROM #Temp
--dohledání kont.osoby a mailu
--odpovědná osoba dodavatele se tam již nemá posílat!!
SET @OdpOsobaDodavatele=(SELECT tcoe._odpovednaOsobaOdberatel
						FROM TabCisOrg tco
						LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
						WHERE tco.CisloOrg=@CisloOrg)
SET @MailOdpKOs=(SELECT TOP 1 TabKontakty.Spojeni
				FROM TabKontakty
				LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=TabKontakty.IDCisZam
				LEFT OUTER JOIN TabCisOrg VCisOrgVztahKontakt ON VCisOrgVztahKontakt.ID=TabKontakty.IDOrg
				WHERE ((TabKontakty.Prednastaveno=1)AND(TabKontakty.Druh=6)AND(TabKontakty.Kam=0)AND(tcz.PrijmeniJmeno LIKE (SELECT tcoe._odpovednaOsobaOdberatel
				FROM TabCisOrg tco
				LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
				WHERE tco.CisloOrg=@CisloOrg))))
--21.8.2023 rozšíření kopie o odpovědnou osobu za dodavatele
SET @blind_copy_recipients='michal.zufan@rayservice.com;'+@MailOdpKOs
DECLARE @subject varchar(128) = (CASE WHEN @Jazyk=0 THEN 'Nedodané položky' ELSE 'Undelivered positions' END);
--zjištění, komu by mail odešel:
SET @recipients = (SELECT TOP 1 tk.Spojeni
	FROM TabKontakty tk
	LEFT OUTER JOIN TabVztahOrgKOs tvkos ON tvkos.ID=tk.IDVztahKOsOrg
	LEFT OUTER JOIN TabCisOrg tco ON tco.ID=tk.IDOrg
	LEFT OUTER JOIN TabCisKOs tckos ON tckos.ID=tk.IDCisKOs
	WHERE
	((tk.Prednastaveno=1)AND(tvkos.Prednastaveno=1)AND(tk.Druh=6)AND(tco.CisloOrg=@CisloOrg)))
-- define CSS inside the HTML head section
DECLARE @body NVARCHAR(MAX);
DECLARE @bodyCZ NVARCHAR(MAX)= '
<html>
<head> <style>
 #g {color: green;}
 #r {color: red;}
 #odd {background-color: lightgrey}
 table, th, td {
  border: 1px solid black;
  border-collapse: collapse;}
  th, td {
  text-align: center;}
</style> </head>';

DECLARE @bodyAJ NVARCHAR(MAX)= '
<html>
<head> <style>
 #g {color: green;}
 #r {color: red;}
 #odd {background-color: lightgrey}
 table, th, td {
  border: 1px solid black;
  border-collapse: collapse;}
  th, td {
  text-align: center;}
</style> </head>';

--get core xml string
SET @xml = CAST(( SELECT [ParovaciZnak] AS 'td','',[NazevPolozky] AS 'td','', [MnozstviObjednano] AS 'td',''
,CASE WHEN [MnozstviZbyvaDodat] >=100 THEN 'zr'+cast([MnozstviZbyvaDodat] AS VARCHAR(30))
       WHEN [MnozstviZbyvaDodat] <100 THEN 'zr'+cast([MnozstviZbyvaDodat] AS VARCHAR(30))--bylo dříve 'zg' tedy zelené
   ELSE CAST([MnozstviZbyvaDodat] AS VARCHAR(30)) END AS 'td',''
 ,CASE WHEN [PozadovaneDatumDodani] IS NULL THEN ' '
 ELSE CAST([PozadovaneDatumDodani] AS VARCHAR(30)) END AS 'td',''
 ,CASE WHEN [PrvotnePotvrzeneDatumDodaniDodavatel] IS NULL THEN ' '
 ELSE CAST([PrvotnePotvrzeneDatumDodaniDodavatel] AS VARCHAR(30)) END AS 'td',''
  ,[NovyTermin] AS 'td'
FROM #Temp
--nově vloženo
WHERE CisloOrg=@CisloOrg
ORDER BY ID 
FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX));

SET @xml=replace(@xml, '<td>zg', '<td id="g">'); -- highlight in Green
SET @xml=replace(@xml, '<td>zr', '<td id="r">'); -- highlight in Red

SELECT @s = '', @pos = charindex('<tr>', @xml, 4);

WHILE(@pos > 0)
BEGIN
   SET @i += 1; -- nahrazuje @i = @i + 1
   SET @ts = substring(@xml, 1, @pos-1)
   IF(@i % 2 = 1)
      SET @ts = replace(@ts, '<tr>', '<tr id="odd">');
   set @s += @ts;
   set @xml = substring(@xml, @pos, len(@xml));
   set @pos =  charindex('<tr>', @xml, 4);
END -- while
-- handling the last piece
SET @i +=1;
SET @ts = @xml;
IF(@i % 2 = 1) --lichý řádek
   SET @ts = replace(@ts, '<tr>', '<tr id="odd">');
SET @s += @ts;

SET @bodyCZ +='<body style="font-family: Calibri;"> 
<p1>Vážený obchodní partnere,<br><br>

Evidujeme tyto nedodané položky.<br>
</p1>
<table style="font-family: Calibri;" border=1>
      <tr style="font-family: Calibri;"><th style="font-family: Calibri;">&nbspObjednávka&nbsp</th><th style="font-family: Calibri;">Název položky</th><th style="font-family: Calibri;">&nbspMnožství objednáno&nbsp</th><th style="font-family: Calibri;">&nbspZbývá dodat&nbsp</th><th style="font-family: Calibri;">&nbspPožadované datum dodání&nbsp</th><th style="font-family: Calibri;">&nbspPrvotně potvrzené datum dodání&nbsp</th><th style="font-family: Calibri;">&nbspNávrh nového termínu&nbsp</th></tr>' 
+ @s+'</table><br><br>'+
'<p1>

Tabulku s novými termíny dodání prosím zašlete na e-mail: '+@MailOdpKOs+'<br>
Velmi si vážíme Vaší rychlé zpětné vazby.<br><br>

Děkujeme za spolupráci<br><br>'+

'Ray Service, a.s.<br>
Huštěnovská 2022, 686 03 – Staré Město<br>
Czech Republic<br><br>

(Toto je automaticky generovaná zpráva. Prosím neodpovídejte na tuto emailovou adresu.)</p1>'+

'</body> </html>';
 
SET @bodyAJ +='<body style="font-family: Calibri;"> 
<p1>Dear business partner,<br><br>

We are monitoring these undelivered positions from this order.<br>
</p1>
<table style="font-family: Calibri;" border=1>
      <tr style="font-family: Calibri;"><th style="font-family: Calibri;">&nbspPurchase order&nbsp</th><th style="font-family: Calibri;">&nbspPart number&nbsp</th><th style="font-family: Calibri;">&nbspOrdered QTY&nbsp</th><th style="font-family: Calibri;">&nbspOpen QTY&nbsp</th><th style="font-family: Calibri;">&nbspRequested delivery date&nbsp</th><th style="font-family: Calibri;">&nbspFirst confirmed delivery date&nbsp</th><th style="font-family: Calibri;">&nbspNew delivery date&nbsp</th></tr>' 
+ @s+'</table><br><br>'+
'<p1>

Please send the table with the new delivery dates to the email: '+@MailOdpKOs+'<br>
Your prompt feedback is highly appreciated.<br><br>

Thank you, have a nice day<br><br>'+

'Ray Service, a.s.<br>
Huštěnovská 2022, 686 03 – Staré Město<br>
Czech Republic<br><br>

(This is an automatically generated e-mail. Please do not respond directly to this message.)</p1>'+

'</body> </html>';

--nastavení jazyka
SELECT @body = (CASE WHEN @Jazyk = 0 THEN @bodyCZ ELSE @bodyAJ END)

--SELECT @recipients AS Adresati


--doplnění data urgování do položek dokladů
UPDATE tpze SET tpze._EXT_RS_datum_urgence=GETDATE()
FROM TabPohybyZbozi_EXT tpze
WHERE tpze.ID IN (SELECT IDPohybu FROM #Temp WHERE CisloOrg=@CisloOrg)

EXEC msdb.dbo.sp_send_dbmail
@recipients = @recipients, -- replace with your email address
@blind_copy_recipients=@blind_copy_recipients,
@subject = @subject, 
@body = @body,
@body_format ='HTML';

	-- konec akce v kurzoru Mail
	FETCH NEXT FROM Mail INTO @CisloOrg;
	END;
CLOSE Mail;
DEALLOCATE Mail;


DROP TABLE #Temp;

GO

