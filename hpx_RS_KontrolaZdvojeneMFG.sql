USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaZdvojeneMFG]    Script Date: 30.06.2025 8:25:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaZdvojeneMFG]
AS
SET NOCOUNT ON
--kontrolovat, zda ve výrobních příkazech nejsou znásobené hodnoty v poli _APSLogis_MFG_ORDER_ID
IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( ID INT IDENTITY (1,1),
  Pocet NVARCHAR (30),
  MFG NVARCHAR (255)
)

DECLARE @i INT = 0;
DECLARE @pos INT;
DECLARE @s VARCHAR(MAX);
DECLARE @ts VARCHAR(MAX);
DECLARE @xml VARCHAR(MAX);
DECLARE @recipients VARCHAR(7000)-- = 'michal.zufan@rayservice.com'
DECLARE @blind_copy_recipients VARCHAR(7000)='michal.zufan@rayservice.com;'

DECLARE @rec_temp VARCHAR(MAX);

INSERT INTO #Temp (Pocet, MFG)
SELECT 
Pocet=COUNT(RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz)),MFG=P_E._APSLogis_MFG_ORDER_ID
FROM TabPrikaz P 
INNER JOIN TabPrikaz_Ext P_E ON (P_E.ID=P.ID AND P_E._APSLogis_MFG_ORDER_ID IS NOT NULL) 
INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
WHERE P.StavPrikazu IN (20,30,40) AND SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1
GROUP BY P_E._APSLogis_MFG_ORDER_ID
HAVING COUNT(RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz))>1

IF EXISTS (SELECT * FROM #Temp)
BEGIN
	SET @blind_copy_recipients='michal.zufan@rayservice.com;'
	DECLARE @subject varchar(128) ='Vícenásobné MFG ve výrobních příkazech'

	SET @recipients='michal.zufan@rayservice.com;'--'petra.lucna@rayservice.com;hana.svobodova@rayservice.com;patrick.bittner@rayservice.com;'
	-- define CSS inside the HTML head section

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


	--get core xml string
	SET @xml = CAST(( SELECT [Pocet] AS 'td','',[MFG] AS 'td'
	FROM #Temp
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
	<p1>Vážené kolego,<br><br>

	V našich výrobních příkazech evidujeme tyto znásobené údaje MFG a je nutné je opravit.<br>
	</p1>
	<table style="font-family: Calibri;" border=1>
		  <tr style="font-family: Calibri;"><th style="font-family: Calibri;">&nbspPočet příkazů&nbsp</th><th style="font-family: Calibri;">Číslo MFG</th></tr>' 
	+ @s+'</table><br><br>'+
	'<p1>

	Velmi si vážíme Vaší rychlé reakce.<br><br>
	Děkujeme za spolupráci<br><br>

	Váš tým LPP.<br><br>'+

	'(Toto je automaticky generovaná zpráva. Prosím neodpovídejte na tuto emailovou adresu.)</p1>'+

	'</body> </html>';
 

	EXEC msdb.dbo.sp_send_dbmail
	@recipients = @recipients, -- replace with your email address
	@blind_copy_recipients=@blind_copy_recipients,
	@subject = @subject, 
	@body = @bodyCZ,
	@body_format ='HTML';

	DROP TABLE #Temp;

END;
GO

