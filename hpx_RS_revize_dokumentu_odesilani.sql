USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_revize_dokumentu_odesilani]    Script Date: 26.06.2025 12:05:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_revize_dokumentu_odesilani]
AS
SET NOCOUNT ON

IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDDok] [INT],
  [Popis] [NVARCHAR](255),
  [DatVydano] [NVARCHAR](255),
  [DatPlatnostOd] [NVARCHAR](255),
  [Garant] [NVARCHAR](255),
  [emailGarant] [VARCHAR](7000),
  [Vydal] [NVARCHAR](255),
  [emailVydal] [VARCHAR](7000),
)

DECLARE @Mail INT;
DECLARE @i INT = 0;
DECLARE @pos INT;
DECLARE @s VARCHAR(MAX);
DECLARE @ts VARCHAR(MAX);
DECLARE @xml VARCHAR(MAX);
DECLARE @recipients VARCHAR(7000)
DECLARE @copy_recipients VARCHAR(7000)
--DECLARE @blind_copy_recipients VARCHAR(7000) = 'michal.zufan@rayservice.com'--ludmila.mullerova@rayservice.com' -- change to your own*/
DECLARE @subject varchar(128) = 'Termín revize dokumentu';

INSERT INTO #Temp (IDDok,Popis,DatVydano,DatPlatnostOd,Garant,emailGarant,Vydal,emailVydal)
SELECT
D.ID,D.Popis,FORMAT(D.DatVydano,'dd.MM.yyyy'),FORMAT(D.DatPlatnostOd,'dd.MM.yyyy'),tczG.PrijmeniJmeno AS Garant,tkg.Spojeni AS MailGarant,tczV.PrijmeniJmeno AS Vydal,tkv.Spojeni AS MailVydal
FROM TabDokumenty D
LEFT OUTER JOIN TabKategKontJed tkj ON tkj.ID = (SELECT  tkkj.ID  FROM TabDokumenty td WITH(NOLOCK)  LEFT OUTER JOIN TabKontaktJednani tkj WITH(NOLOCK) ON EXISTS(SELECT*FROM TabDokumVazba V WITH(NOLOCK) JOIN TabKontaktJednani KJ WITH(NOLOCK) ON KJ.ID=V.IDTab AND KJ.ID=tkj.ID JOIN TabKategKontJed KK WITH(NOLOCK) ON KK.Cislo=KJ.Kategorie WHERE V.IDDok=td.ID AND V.IdentVazby=1 AND KK.QMSAgenda=8)  LEFT OUTER JOIN TabKategKontJed tkkj WITH(NOLOCK) ON tkj.Kategorie=tkkj.Cislo  WHERE  (EXISTS(SELECT * FROM TabKontaktJednani KJ WITH(NOLOCK) JOIN TabDokumVazba V WITH(NOLOCK) ON V.IDDok=td.ID AND V.IdentVazby=1 AND V.IDTab=KJ.ID JOIN TabKategKontJed KTG WITH(NOLOCK) ON KJ.Kategorie=KTG.Cislo WHERE KTG.QMSAgenda=8)AND td.ID = D.ID))  
LEFT OUTER JOIN TabKontaktJednani rizdok ON EXISTS(SELECT*FROM TabDokumVazba V JOIN TabKontaktJednani KJ ON KJ.ID=V.IDTab AND KJ.ID=rizdok.ID JOIN TabKategKontJed KK ON KK.Cislo=KJ.Kategorie WHERE V.IDDok=D.ID AND V.IdentVazby=1 AND KK.QMSAgenda=8)
LEFT OUTER JOIN TabCisZam tczG ON tczG.Cislo=rizdok.CisloZam
LEFT OUTER JOIN TabKontakty tkG ON tkg.IDCisZam=tczG.ID AND(tkG.Prednastaveno=1)AND(tkG.Druh=6)AND(tkG.Kam=0)
LEFT OUTER JOIN TabCisZam tczV ON tczV.ID=D.IDZamVydal
LEFT OUTER JOIN TabKontakty tkV ON tkV.IDCisZam=tczV.ID AND(tkV.Prednastaveno=1)AND(tkV.Druh=6)AND(tkv.Kam=0)
WHERE
((EXISTS(SELECT * FROM TabKontaktJednani KJ JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IdentVazby=1 AND V.IDTab=KJ.ID JOIN TabKategKontJed KTG ON KJ.Kategorie=KTG.Cislo WHERE KTG.QMSAgenda=8 AND KJ.Ukonceni IS NULL 
AND ((D.DatPlatnostOd<=GETDATE()) 
AND (D.DatPlatnostDo IS NULL OR D.DatPlatnostDo>=GETDATE())))))
AND(((tkj.Popis LIKE N'%Příručka%')OR(tkj.Popis LIKE N'%Organizační směrnice%')OR(tkj.Popis LIKE N'%Popisy procesů%')
OR(tkj.Popis LIKE N'%Pracovní pokyny%')OR(tkj.Popis LIKE N'%Předpisy%')
OR(tkj.Popis LIKE N'%Směrnice%')OR(tkj.Popis LIKE N'%Výklad organizace výroby%'))AND(D.DatVydano=DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))-730))
ORDER BY D.DatVydano DESC

SELECT * FROM #Temp

--započneme cursor
DECLARE Mail CURSOR LOCAL FAST_FORWARD FOR
SELECT ID
FROM #Temp

OPEN Mail;
	FETCH NEXT FROM Mail INTO @Mail;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

--zjištění, komu by mail odešel:
--MŽ 23.11.2022 na přání J.Hodulíkové zadána adresa natvrdo
SET @recipients = 'jana.hodulikova@rayservice.com'--(SELECT emailGarant FROM #temp WHERE ID=@Mail)
SET @copy_recipients=(SELECT emailVydal FROM #temp WHERE ID=@Mail)

-- define CSS inside the HTML head section
DECLARE @body NVARCHAR(MAX)= '
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
SET @xml = CAST(( SELECT ' ',[Popis] AS 'td',' '
 ,CASE WHEN [DatVydano] IS NULL THEN ' '
 ELSE CAST([DatVydano] AS VARCHAR(30)) END AS 'td',' '
 ,CASE WHEN [DatPlatnostOd] IS NULL THEN ' '
 ELSE CAST([DatPlatnostOd] AS VARCHAR(30)) END AS 'td',' '
  ,[Garant] AS 'td',' '
  ,[Vydal] AS 'td',' '
FROM #Temp
WHERE ID=@Mail
FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX));

SET @xml=replace(@xml, '<td>zg', '<td id="g">'); -- highlight in Green
SET @xml=replace(@xml, '<td>zr', '<td id="r">'); -- highlight in Red

SELECT @s = '', @pos = charindex('<tr>', @xml, 4);

WHILE(@pos > 0)
BEGIN
   SET @i += 1; -- nahrazuje @i = @i + 1
   SET @ts = substring(@xml, 1, @pos-1)
   /*IF(@i % 2 = 1)
      SET @ts = replace(@ts, '<tr>', '<tr id="odd">');*/
   set @s += @ts;
   set @xml = substring(@xml, @pos, len(@xml));
   set @pos =  charindex('<tr>', @xml, 4);
END -- while
-- handling the last piece
SET @i +=1;
SET @ts = @xml;
/*IF(@i % 2 = 1) --lichý řádek
   SET @ts = replace(@ts, '<tr>', '<tr id="odd">');*/
SET @s += @ts;

SET @body +='<body style="font-family: Calibri;"> 
<p1>Dobrý den,<br><br>

Níže uvedenému dokumentu, u kterého jste uveden(a) jako zpracovatel, bylo přiřazeno datum revize na dnešní den.<br>
Prosím o revizi dokumentu. V případě , že aktuální revize zůstává i nadále platná, zašlete informaci do 10 pracovních dnů J. Hodulíkové.<br><br>
</p1>
<table style="font-family: Calibri;" border=1>
      <tr style="font-family: Calibri;"><th style="font-family: Calibri;">&nbspPopis&nbsp</th><th style="font-family: Calibri;">&nbspVydáno&nbsp</th><th style="font-family: Calibri;">&nbspPlatný Od&nbsp</th><th style="font-family: Calibri;">&nbspGarant&nbsp</th><th style="font-family: Calibri;">&nbspVydal&nbsp</th></tr>' 
+ @s+'</table><br><br>'+
'<p1>

Ray Service, a.s.<br><br>

(Toto je automaticky generovaná zpráva. Prosím neodpovídejte na ni.)</p1>'+

'</body> </html>';

EXEC msdb.dbo.sp_send_dbmail
@recipients = @recipients,
@copy_recipients=@copy_recipients,
--@blind_copy_recipients=@blind_copy_recipients,
@subject = @subject, 
@body = @body,
@body_format ='HTML';

	-- konec akce v kurzoru Mail
	FETCH NEXT FROM Mail INTO @Mail;
	END;
CLOSE Mail;
DEALLOCATE Mail;


DROP TABLE #Temp;

GO

