USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_GenerujZasilku_BezEditace]    Script Date: 26.06.2025 14:35:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_GenerujZasilku_BezEditace]
@IdDoklad INT,
@MultiGenerovani BIT = 0
AS
DECLARE @Hlaska NVARCHAR(MAX), @JazykVerze INT
SET @JazykVerze=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
IF @JazykVerze IS NULL SET @JazykVerze=1
DECLARE @KodDopravce NVARCHAR(20), @TypSluzby NVARCHAR(50), @PocetBaliku INT, @Dobirka BIT, @CastkaDobirky NUMERIC(19,6), @MenaDobirky NVARCHAR(3), @ParovaciZnak NVARCHAR(20)
SELECT @KodDopravce=ISNULL(FDE._Balikobot_KodDopravce, ''),
@TypSluzby=FDE._Balikobot_TypSluzby,
@MenaDobirky=ISNULL(D.Mena, (SELECT Kod FROM TabKodMen WHERE HlavniMena=1)),
@PocetBaliku=ISNULL(DE._Balikobot_PocetBaliku, 1),
@ParovaciZnak=D.ParovaciZnak
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabDokladyZbozi_EXT DE ON DE.ID=D.ID
LEFT OUTER JOIN TabFormaUhrady FU ON FU.FormaUhrady=D.FormaUhrady
LEFT OUTER JOIN TabFormaUhrady_EXT FUE ON FUE.ID=FU.ID
LEFT OUTER JOIN TabFormaDopravy FD ON FD.FormaDopravy=D.FormaDopravy
LEFT OUTER JOIN TabFormaDopravy_EXT FDE ON FDE.ID=FD.ID
WHERE D.ID=@IdDoklad
EXEC dbo.hpx_Balikobot_JeToDobirka
  @IdDoklad=@IdDoklad
, @MultiGenerovani=@MultiGenerovani
, @JeToDobirka=@Dobirka OUT
IF @Dobirka=1
EXEC dbo.hpx_Balikobot_VratCastkuDobirky
@IdDoklad=@IdDoklad
, @MultiGenerovani=@MultiGenerovani
, @CastkaDobirky=@CastkaDobirky OUT
ELSE
SET @CastkaDobirky=0
DECLARE @PodleCehoHledatMenuACastku TINYINT
SET @PodleCehoHledatMenuACastku=dbo.hfx_Balikobot_VratZpusobHledaniMeny(@IdDoklad)
IF ISNULL(@PodleCehoHledatMenuACastku, 0)=1
BEGIN
  SET @MenaDobirky=(SELECT Kod FROM TabKodMen WHERE HlavniMena=1)
END
IF @MultiGenerovani=0
IF EXISTS(SELECT * FROM Tabx_BalikobotVZasilkyDoklady WHERE IdDoklad=@IdDoklad)
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='EF799A2B-C2F3-4097-B0BB-54E10AE5E0C6' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='EF799A2B-C2F3-4097-B0BB-54E10AE5E0C6' AND Jazyk=1)
SET @Hlaska=REPLACE(@Hlaska, '%s', @ParovaciZnak)
INSERT #TabExtKom(Poznamka) VALUES(@Hlaska)
GOTO END_PROC
END
IF @MultiGenerovani=1
IF EXISTS(SELECT * FROM Tabx_BalikobotVZasilkyDoklady WHERE IdDoklad=@IdDoklad)
OR EXISTS(SELECT * FROM Tabx_BalikobotVZasilkyDoklady WHERE IdDoklad IN(SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani))
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='EF799A2B-C2F3-4097-B0BB-54E10AE5E0C6' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='EF799A2B-C2F3-4097-B0BB-54E10AE5E0C6' AND Jazyk=1)
SET @Hlaska=REPLACE(@Hlaska, '%s', @ParovaciZnak)
INSERT INTO #TabExtKom(Poznamka)
SELECT REPLACE(@Hlaska, '%s', ParovaciZnak)
FROM TabDokladyZbozi
WHERE ID IN(SELECT IdDoklad FROM Tabx_BalikobotVZasilkyDoklady WHERE IdDoklad IN(SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani UNION SELECT @IdDoklad))
GOTO END_PROC
END
IF (@KodDopravce='')OR(@TypSluzby='')
BEGIN
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='4968E3F8-9390-4F72-B0F3-B4CB8AC9EE22' AND Jazyk=@JazykVerze)
IF @Hlaska IS NULL
SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='4968E3F8-9390-4F72-B0F3-B4CB8AC9EE22' AND Jazyk=1)
SET @Hlaska=REPLACE(@Hlaska, '%s', @ParovaciZnak)
INSERT #TabExtKom(Poznamka) VALUES(@Hlaska)
GOTO END_PROC
END
EXEC dbo.hpx_Balikobot_GenerujZasilku
@IdDoklad=@IdDoklad
, @KodDopravce=@KodDopravce
, @TypSluzby=@TypSluzby
, @PocetBaliku=@PocetBaliku
, @Dobirka=@Dobirka
, @CastkaDobirky=@CastkaDobirky
, @MenaDobirky=@MenaDobirky
, @MultiGenerovani=@MultiGenerovani
END_PROC:
GO

