USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_nedodane_faktury_odesilani]    Script Date: 26.06.2025 12:05:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_nedodane_faktury_odesilani]
AS
SET NOCOUNT ON
/*Výstup:
* Dle země původu na organizaci se pošle český nebo anglický text s urgencí faktury.
* Jako cílový adresát bude použita přednastavená kontaktní osoba z organizace.
* Na poznámku 1 na příjemku se připíše na 1. řádek poznámka: xx.xx.xxxx Urgováno dodání faktury. SQL   (ty křížky, to je datum odeslání urgence)
* Automatický email odejde 1x týdně – ve středu*/
IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDDokladu] [INT],
  [CisloOrg] [INT],
  [IDZeme] [NVARCHAR](3),
  [Poznamka] [NTEXT],
  [CisloDL] [NVARCHAR](60)
)

DECLARE @IDDokladu INT, @OdpOsobaDodavatele NVARCHAR(255), @MailOdpKOs NVARCHAR(255), @Jazyk INT, @Poznamka NVARCHAR(255), @DodList NVARCHAR(60);

DECLARE @i INT = 0;
DECLARE @pos INT;
DECLARE @s VARCHAR(MAX);
DECLARE @ts VARCHAR(MAX);
DECLARE @xml VARCHAR(MAX);
DECLARE @recipients VARCHAR(7000)-- = 'michal.zufan@rayservice.com;ludmila.mullerova@rayservice.com' -- change to your own
--DECLARE @recipients VARCHAR(7000) = 'michal.zufan@rayservice.com'
DECLARE @blind_copy_recipients VARCHAR(7000) = 'michal.zufan@rayservice.com'--ludmila.mullerova@rayservice.com' -- change to your own*/

INSERT INTO #Temp (IDDokladu,CisloOrg,IDZeme,Poznamka,CisloDL)
SELECT
tdz.ID,tdz.CisloOrg,tco.IdZeme,tdz.Poznamka,tdze._cislodl
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
WHERE
((tdz.DruhPohybuZbo<=1)AND(tdz.PoradoveCislo>=0))AND((tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'500')OR(tdz.RadaDokladu=N'501')OR(tdz.RadaDokladu=N'502')OR(tdz.RadaDokladu=N'526'))
AND(tdz.DatPovinnostiFa>'2022-05-01')AND(tdz.DatPovinnostiFa_X<DATEADD(DAY,-7,DATEDIFF(DAY,0,GETDATE()))))
AND(tdz.DodFak='')

--započneme cursor
DECLARE Mail CURSOR LOCAL FAST_FORWARD FOR
SELECT
tdz.ID--,tdz.CisloOrg,tco.IdZeme,tdz.Poznamka,tdze._cislodl
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID
LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
WHERE
((tdz.DruhPohybuZbo<=1)AND(tdz.PoradoveCislo>=0))AND((tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'500')OR(tdz.RadaDokladu=N'501')OR(tdz.RadaDokladu=N'502')OR(tdz.RadaDokladu=N'526'))
AND(tdz.DatPovinnostiFa>'2022-05-01')AND(tdz.DatPovinnostiFa_X<DATEADD(DAY,-7,DATEDIFF(DAY,0,GETDATE()))))
AND(tdz.DodFak='')
OPEN Mail;
	FETCH NEXT FROM Mail INTO @IDDokladu;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		SET @recipients=NULL
		SET @Jazyk=(SELECT CASE WHEN (SELECT t.IdZeme FROM #Temp t WHERE t.IDDokladu=@IDDokladu) LIKE N'%cz%' THEN 0
								WHEN (SELECT t.IdZeme FROM #Temp t WHERE t.IDDokladu=@IDDokladu) IS NULL THEN 1
								ELSE 1 END)
		SET @Poznamka=(SELECT CASE WHEN (SELECT t.CisloDL FROM #Temp t WHERE t.IDDokladu=@IDDokladu) IS NULL THEN FORMAT(GETDATE(),'dd.MM.yyyy')+' Faktura neurgována, není vyplněno číslo DL. SQL'
								ELSE FORMAT(GETDATE(),'dd.MM.yyyy')+' Urgováno dodání faktury. SQL' END)
		--zjištění, komu by mail odešel:
		--původně:
		/*SET @recipients = (SELECT TOP 1 tk.Spojeni
			FROM TabKontakty tk
			LEFT OUTER JOIN TabVztahOrgKOs tvkos ON tvkos.ID=tk.IDVztahKOsOrg
			LEFT OUTER JOIN TabCisOrg tco ON tco.ID=tk.IDOrg
			LEFT OUTER JOIN TabCisKOs tckos ON tckos.ID=tk.IDCisKOs
			LEFT OUTER JOIN #Temp t ON t.CisloOrg=tco.CisloOrg
			WHERE
			((tk.Prednastaveno=1)AND(tvkos.Prednastaveno=1)AND(tk.Druh=6)AND(t.IDDokladu=@IDDokladu)))*/
		--nově:
		SET @recipients=(SELECT TOP 1 tk.Spojeni
		FROM TabDokladyZbozi tdz
		  LEFT OUTER JOIN TabCisOrg tco ON tdz.CisloOrg=tco.CisloOrg
		  LEFT OUTER JOIN TabCisKOs tkos ON tdz.KontaktOsoba=tkos.ID
		  LEFT OUTER JOIN TabKontakty tk ON tdz.KontaktOsoba = (SELECT TOP 1  TabCisKOs.ID FROM TabCisKOs WITH(NOLOCK) INNER JOIN TabKontakty WITH(NOLOCK) ON TabCisKOs.ID = tk.IDCisKOs WHERE tk.Druh=6)
		WHERE
		(tdz.ID=@IDDokladu)AND(tk.Druh=6))

		IF @recipients IS NOT NULL
			BEGIN
			SET @DodList=(SELECT t.CisloDL FROM #Temp t WHERE t.IDDokladu=@IDDokladu)
			--SELECT @DodList AS Dodak
			IF @DodList IS NULL
			GOTO Dodak

			--dohledání kont.osoby a mailu
			--odpovědná osoba dodavatele se tam již nemá posílat!!
			SET @OdpOsobaDodavatele=(SELECT tcoe._odpovednaOsobaOdberatel
									FROM TabCisOrg tco
									LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
									LEFT OUTER JOIN #Temp t ON t.CisloOrg=tco.CisloOrg
									WHERE t.IDDokladu=@IDDokladu)
			SET @MailOdpKOs=(SELECT TOP 1 TabKontakty.Spojeni
							FROM TabKontakty
							LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=TabKontakty.IDCisZam
							LEFT OUTER JOIN TabCisOrg VCisOrgVztahKontakt ON VCisOrgVztahKontakt.ID=TabKontakty.IDOrg
							WHERE ((TabKontakty.Prednastaveno=1)AND(TabKontakty.Druh=6)AND(TabKontakty.Kam=0)AND(tcz.PrijmeniJmeno LIKE (SELECT tcoe._odpovednaOsobaOdberatel
							FROM TabCisOrg tco
							LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
							LEFT OUTER JOIN #Temp t ON t.CisloOrg=tco.CisloOrg
							WHERE t.IDDokladu=@IDDokladu))))
			DECLARE @subject varchar(128) = (CASE WHEN @Jazyk=0 THEN 'Žádost o fakturu' ELSE 'Request for invoice' END);

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
			SET @bodyCZ +='<body style="font-family: Calibri;"> 
			<p1>Vážení obchodní přátelé,<br><br>

			Prosíme Vás o zaslání faktury k dodacímu listu č.: '+@DodList +'<br>

			Fakturu prosím zašlete na email: fakturace@rayservice.com<br><br>

			Ray Service, a.s.<br>
			Huštěnovská 2022, 686 03 – Staré Město<br>
			Czech Republic<br><br>

			(Toto je automaticky generovaná zpráva. Prosím neodpovídejte na tuto emailovou adresu. Pokud jste již fakturu zaslali, prosím ignorujte tento e-mail.)</p1>'+

			'</body> </html>';
 
			SET @bodyAJ +='<body style="font-family: Calibri;"> 
			<p1>Dear business partner,<br><br>

			We kindly ask you to send an invoice for the delivery note: '+@DodList +' <br>

			Please send the invoice to the email: invoice@rayservice.com<br><br>

			Ray Service, a.s.<br>
			Huštěnovská 2022, 686 03 – Staré Město<br>
			Czech Republic<br><br>

			(This is an automatically generated e-mail. Please do not respond directly to this message. If you have already sent the invoice, please ignore this email.)</p1>'+

			'</body> </html>';

			--nastavení textu dle jazyka
			SELECT @body = (CASE WHEN @Jazyk = 0 THEN @bodyCZ ELSE @bodyAJ END)

			EXEC msdb.dbo.sp_send_dbmail
			@recipients = @recipients, -- replace with your email address
			@blind_copy_recipients=@blind_copy_recipients,
			@subject = @subject, 
			@body = @body,
			@body_format ='HTML';

			Dodak:
			--doplnění data urgování do položek dokladů
			UPDATE tdz SET tdz.Poznamka=CAST((@Poznamka +'
			'+ ISNULL(CAST(tdz.Poznamka AS NVARCHAR(MAX)),'')) AS NTEXT)
			FROM TabDokladyZbozi tdz
			WHERE tdz.ID = @IDDokladu

			END;
	-- konec akce v kurzoru Mail
	FETCH NEXT FROM Mail INTO @IDDokladu;
	END;
CLOSE Mail;
DEALLOCATE Mail;

DROP TABLE #Temp;

GO

