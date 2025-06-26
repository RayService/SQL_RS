USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_ValidaceSpusteniAkce]    Script Date: 26.06.2025 15:03:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_ValidaceSpusteniAkce]
@IdZasilky INT
, @Akce TINYINT
AS
SET NOCOUNT ON
DECLARE @AktualniStav INT, @PozadovanyStav INT
DECLARE @Hlaska NVARCHAR(MAX), @JazykVerze INT
SET @JazykVerze=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
IF @JazykVerze IS NULL SET @JazykVerze=1
DELETE FROM #TabExtKom
IF (SELECT ISNULL(D.Distribucni, 0)
FROM Tabx_BalikobotZasilky Z
JOIN Tabx_BalikobotDopravci D ON D.KodDopravce=Z.KodDopravce
WHERE Z.ID=@IdZasilky)=0
AND OBJECT_ID('dbo.epx_Balikobot_ValidaceSpusteniAkce', 'P') IS NOT NULL
BEGIN
EXEC dbo.epx_Balikobot_ValidaceSpusteniAkce
@IdZasilky=@IdZasilky
, @Akce=@Akce
IF EXISTS(SELECT * FROM #TabExtKom WHERE Poznamka LIKE '*%')
RETURN
END
SET @AktualniStav=(SELECT Stav FROM hvw_BalikobotZasilky WHERE ID=@IdZasilky)
IF @Akce=0 --metoda ADD
SET @PozadovanyStav=1
IF @Akce=1 --metoda DROP
SET @PozadovanyStav=0
IF @Akce=2 --metoda ORDER
SET @PozadovanyStav=2
IF @Akce=3 --metoda PREDANO DOPRAVCI
SET @PozadovanyStav=3
IF @AktualniStav=99
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='269D8AC8-71B0-42E4-BA13-EE5BB852FB59' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='269D8AC8-71B0-42E4-BA13-EE5BB852FB59' AND Jazyk=1)
INSERT #TabExtKom(Poznamka) VALUES('*' + @Hlaska)
RETURN
END
IF (@AktualniStav=100)AND(@PozadovanyStav<>0)
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='269D8AC8-71B0-42E4-BA13-EE5BB852FB59' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='269D8AC8-71B0-42E4-BA13-EE5BB852FB59' AND Jazyk=1)
INSERT #TabExtKom(Poznamka) VALUES('*' + @Hlaska)
RETURN
END
IF (@PozadovanyStav=0)AND(@AktualniStav<>1)AND(@AktualniStav<>100)
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='E9710B34-BB1A-4537-AA70-9072C7F13580' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='E9710B34-BB1A-4537-AA70-9072C7F13580' AND Jazyk=1)
INSERT #TabExtKom(Poznamka) VALUES('*' + @Hlaska)
RETURN
END
IF (@PozadovanyStav<>0)
IF (@PozadovanyStav-@AktualniStav)<>1
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='5259F73E-59EC-49E3-976B-CBD251787F94' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='5259F73E-59EC-49E3-976B-CBD251787F94' AND Jazyk=1)
INSERT #TabExtKom(Poznamka) VALUES('*' + @Hlaska)
END
GO

