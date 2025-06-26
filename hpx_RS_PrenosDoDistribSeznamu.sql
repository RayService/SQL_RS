USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PrenosDoDistribSeznamu]    Script Date: 26.06.2025 14:25:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PrenosDoDistribSeznamu]
@IDDoc INT
AS
--cvičná deklarace
--DECLARE @IDDoc INT=791284
--ostrá deklarace
DECLARE @StartID INT;
DECLARE @StopID INT;
DECLARE @IDKonJed INT;
DECLARE @IDZam INT;
DECLARE @IDZmdObd INT
SET @IDZmdObd=(
SELECT ID
FROM TabMzdObd
WHERE Rok=DATEPART(YEAR,GETDATE()) AND Mes=DATEPART(MONTH,GETDATE())
)
--dočasná tabule pro import do distribučního seznamu, vytvořená z kombinací volných uživatelů a uživatelů v rolí z práv k aktuálního dokumentu
IF OBJECT_ID('tempdb..#TabUsers') IS NOT NULL DROP TABLE #TabUsers
CREATE TABLE #TabUsers (
ID INT IDENTITY(1,1) NOT NULL,
IDDoc INT NOT NULL,
LoginName NVARCHAR(128),
IDZam INT NOT NULL
)
INSERT INTO #TabUsers (LoginName,IDZam,IDDoc)
SELECT DISTINCT ISNULL(tpd.LoginName,uv.LoginName),tcz.ID, @IDDoc
FROM TabPravaDokum tpd
LEFT OUTER JOIN TabRole tr ON tr.ID=tpd.IDRole
LEFT OUTER JOIN TabRoleUzivView uv ON uv.IDRole=tr.ID
LEFT OUTER JOIN TabCisZam tcz ON tcz.LoginId=ISNULL(tpd.LoginName,uv.LoginName)
WHERE (tpd.IDDokum=@IDDoc)AND(tcz.ID IS NOT NULL)
--přidána podmínka na zaměstnance, kteří nejsou PP archivován ani PP ukončen ani vyňat z ES
AND(
((((CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecId=tcz.ID)
THEN
CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WHERE IdObdobi=@IDZmdObd AND ZamestnanecId=tcz.ID)
THEN (SELECT StavES FROM TabZamMzd WHERE IdObdobi=@IDZmdObd AND ZamestnanecId=tcz.ID)
WHEN EXISTS(SELECT m.*
FROM TabZamMzd m
JOIN TabMzdObd o1 ON o1.IdObdobi=m.IdObdobi
LEFT OUTER JOIN TabMzdObd o2 ON o2.IdObdobi=@IDZmdObd
WHERE ((o1.Rok<o2.Rok) OR ((o1.Rok=o2.Rok) AND (o1.Mesic<o2.Mesic))) AND m.ZamestnanecId=tcz.ID)
THEN 4
ELSE 10
END
ELSE
CASE
WHEN EXISTS(SELECT * FROM TabMzNastupPP WHERE ZamestnanecId=tcz.ID)
THEN 5
ELSE 6
END
END))<>4)AND(((CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecId=tcz.ID)
THEN
CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WHERE IdObdobi=@IDZmdObd AND ZamestnanecId=tcz.ID)
THEN (SELECT StavES FROM TabZamMzd WHERE IdObdobi=@IDZmdObd AND ZamestnanecId=tcz.ID)
WHEN EXISTS(SELECT m.*
FROM TabZamMzd m
JOIN TabMzdObd o1 ON o1.IdObdobi=m.IdObdobi
LEFT OUTER JOIN TabMzdObd o2 ON o2.IdObdobi=@IDZmdObd
WHERE ((o1.Rok<o2.Rok) OR ((o1.Rok=o2.Rok) AND (o1.Mesic<o2.Mesic))) AND m.ZamestnanecId=tcz.ID)
THEN 4
ELSE 10
END
ELSE
CASE
WHEN EXISTS(SELECT * FROM TabMzNastupPP WHERE ZamestnanecId=tcz.ID)
THEN 5
ELSE 6
END
END))<>3)AND(((CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecId=tcz.ID)
THEN
CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WHERE IdObdobi=@IDZmdObd AND ZamestnanecId=tcz.ID)
THEN (SELECT StavES FROM TabZamMzd WHERE IdObdobi=@IDZmdObd AND ZamestnanecId=tcz.ID)
WHEN EXISTS(SELECT m.*
FROM TabZamMzd m
JOIN TabMzdObd o1 ON o1.IdObdobi=m.IdObdobi
LEFT OUTER JOIN TabMzdObd o2 ON o2.IdObdobi=@IDZmdObd
WHERE ((o1.Rok<o2.Rok) OR ((o1.Rok=o2.Rok) AND (o1.Mesic<o2.Mesic))) AND m.ZamestnanecId=tcz.ID)
THEN 4
ELSE 10
END
ELSE
CASE
WHEN EXISTS(SELECT * FROM TabMzNastupPP WHERE ZamestnanecId=tcz.ID)
THEN 5
ELSE 6
END
END))<>1))
)
--teď spustíme loop za řádky #TabUsers
SELECT @StartID=MIN(ID), @StopID=MAX(ID)
FROM #TabUsers

WHILE @StartID<=@StopID
BEGIN
SET @IDKonJed=(SELECT tkj.ID
FROM TabDokumenty td
  LEFT OUTER JOIN TabKontaktJednani tkj ON EXISTS(SELECT*FROM TabDokumVazba V JOIN TabKontaktJednani KJ ON KJ.ID=V.IDTab AND KJ.ID=tkj.ID JOIN TabKategKontJed KK ON KK.Cislo=KJ.Kategorie WHERE V.IDDok=td.ID AND V.IdentVazby=1 AND KK.QMSAgenda=8)
WHERE td.ID=@IDDoc)
SET @IDZam=(SELECT IDZam FROM #TabUsers WHERE ID=@StartID)

INSERT TabQMSDokumLogAkci (IDKonJed, IDDokum, IDZam, Akce)
SELECT @IDKonJed, @IDDoc, @IDZam, 0
FROM #TabUsers U
WHERE U.ID=@StartID AND NOT EXISTS(SELECT*FROM TabQMSDokumLogAkci WHERE IDKonJed=@IDKonJed AND IDDokum=@IDDoc AND IDZam=@IDZam AND Akce=0)

INSERT TabKJUcastZam (IDKJ,IDZam)
SELECT @IDKonJed, IDZam
FROM #TabUsers
WHERE ID=@StartID AND NOT EXISTS(SELECT * FROM TabKJUcastZam WHERE IDKJ=@IDKonJed AND IDZam=@IDZam)

SET @StartID=@StartID+1
END;


GO

