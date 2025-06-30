USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaZdvojeneMS922]    Script Date: 30.06.2025 8:55:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaZdvojeneMS922]
AS
SET NOCOUNT ON
--kontrolovat, zda ve mzdových paušálech za předchozí mzdové období není někdo se znásobenými řádky s MS=922
IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( ID INT IDENTITY (1,1),
  PocetMS NVARCHAR (30),
  IDZam INT,
  CisloZam INT,
  PrijmeniJmeno NVARCHAR(255)
)

DECLARE @i INT = 0;
DECLARE @pos INT;
DECLARE @s VARCHAR(MAX);
DECLARE @ts VARCHAR(MAX);
DECLARE @xml VARCHAR(MAX);
DECLARE @recipients VARCHAR(7000)-- = 'michal.zufan@rayservice.com'
DECLARE @blind_copy_recipients VARCHAR(7000)='michal.zufan@rayservice.com;'
DECLARE @rec_temp VARCHAR(MAX);
DECLARE @IDObdobi INT
SET @IDObdobi=(SELECT ID FROM TabMzdObd WHERE Rok=CASE DATEPART(MONTH,GETDATE()) WHEN 1 THEN DATEPART(YEAR,GETDATE())-1 ELSE DATEPART(YEAR,GETDATE()) END AND Mesic=CASE DATEPART(MONTH,GETDATE()) WHEN 1 THEN 12 ELSE DATEPART(MONTH,GETDATE())-1 END)


INSERT INTO #Temp (CisloZam, PrijmeniJmeno, PocetMS)
SELECT tcz.Cislo,tcz.PrijmeniJmeno,COUNT(pau.CisloMS) AS PocetMS
FROM TabMzPaus pau
LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=pau.ZamestnanecId
LEFT OUTER JOIN TabZamMzd mzd ON mzd.ZamestnanecId=pau.ZamestnanecId
WHERE
(pau.IdObdobi=@IDObdobi)AND
(mzd.IdObdobi=@IDObdobi)AND
(pau.CisloMS=922)AND
(mzd.StavES=0)
GROUP BY pau.ZamestnanecId,tcz.Cislo,tcz.PrijmeniJmeno
HAVING COUNT(pau.CisloMS)>1

SELECT *
FROM #Temp

IF EXISTS (SELECT * FROM #Temp)
BEGIN
	SET @blind_copy_recipients='michal.zufan@rayservice.com;'
	DECLARE @subject varchar(128) ='Vícenásobné MS 922 v předchozím mzdovém období'

	SET @recipients='mzdy@rayservice.com;'
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
	SET @xml = CAST(( SELECT [CisloZam] AS 'td','',[PrijmeniJmeno] AS 'td','',[PocetMS] AS 'td'
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
	<p1>Dobrý den,<br><br>

	Ve mzdových paušálech v předchozím období jsou tito zaměstnanci, kteří mají znásobené řádky s MS 922 a to bude problém pro aplikaci Hodnocení. Prosím o opravu.<br>
	</p1>
	<table style="font-family: Calibri;" border=1>
		  <tr style="font-family: Calibri;"><th style="font-family: Calibri;">&nbspČíslo zaměstnance&nbsp</th><th style="font-family: Calibri;">Příjmení Jméno</th><th style="font-family: Calibri;">Počet řádků 922</th></tr>' 
	+ @s+'</table><br><br>'+
	'<p1>

	Velmi si vážíme Vaší rychlé reakce.<br><br>
	Děkujeme za spolupráci<br><br>

	Váš tým HEO.<br><br>'+

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

