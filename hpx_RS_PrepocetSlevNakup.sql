USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PrepocetSlevNakup]    Script Date: 30.06.2025 8:57:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PrepocetSlevNakup] @IDPol INT
AS
SET NOCOUNT ON;

DECLARE @JCbezDaniKC NUMERIC(19,6), @JCbezDaniVal NUMERIC(19,6), @VstupniCena TINYINT, @Kurz NUMERIC(19,6), @Mnozstvi NUMERIC(19,6), --pro Validace
@_EXT_RS_JCPredSlevouKC NUMERIC(19,6), @_EXT_RS_CCPredSlevouKC NUMERIC(19,6), @_EXT_RS_JCPredSlevouVal NUMERIC(19,6), @_EXT_RS_CCPredSlevouVal NUMERIC(19,6), @_EXT_RS_SlevaProcento NUMERIC(19,6) --pro validace_EXT

SELECT @JCbezDaniKC=JCbezDaniKC, @JCbezDaniVal=JCbezDaniVal, @VstupniCena=VstupniCena, @Kurz=Kurz, @Mnozstvi=Mnozstvi
FROM #TempDefForm_Validace
SELECT @_EXT_RS_JCPredSlevouKC=ISNULL(_EXT_RS_JCPredSlevouKC,0), @_EXT_RS_CCPredSlevouKC=ISNULL(_EXT_RS_CCPredSlevouKC,0), @_EXT_RS_JCPredSlevouVal=ISNULL(_EXT_RS_JCPredSlevouVal,0), @_EXT_RS_CCPredSlevouVal=ISNULL(_EXT_RS_CCPredSlevouVal,0), @_EXT_RS_SlevaProcento=ISNULL(_EXT_RS_SlevaProcento,0)
FROM #TempDefForm_Validace_EXT

--začátek výpočtu
--pokud není žádné pole vyplněné, jdeme do pryč
IF @_EXT_RS_JCPredSlevouKC=0 AND @_EXT_RS_CCPredSlevouKC=0 AND @_EXT_RS_JCPredSlevouVal=0 AND @_EXT_RS_CCPredSlevouVal=0 AND @_EXT_RS_SlevaProcento=0
BEGIN
GOTO KONEC
END;
--nejprve zjistíme, zda částka procenta slevy je <>0. Pokud <>0, tak pouze přepočteme naše políčka.
IF @_EXT_RS_SlevaProcento<>0.0
BEGIN
	UPDATE tpze SET tpze._EXT_RS_JCPredSlevouKC=@JCbezDaniKC+(@JCbezDaniKC*@_EXT_RS_SlevaProcento/100), tpze._EXT_RS_CCPredSlevouKC=(@JCbezDaniKC+(@JCbezDaniKC*@_EXT_RS_SlevaProcento/100))*@Mnozstvi, tpze._EXT_RS_JCPredSlevouVal=(@JCbezDaniKC+(@JCbezDaniKC*@_EXT_RS_SlevaProcento/100))/@Kurz, tpze._EXT_RS_CCPredSlevouVal=(@JCbezDaniKC+(@JCbezDaniKC*@_EXT_RS_SlevaProcento/100))*@Mnozstvi/@Kurz
	FROM TabPohybyZbozi_EXT tpze
	WHERE tpze.ID=@IDPol
END;
--Pokud = 0, tak musíme zjistit, zda je položka valutová, zda je JC nebo CC a podle toho vezmeme vstupní cenu a dopočítáme všechny výstupní ceny včetně slev a procent
--0=JC bez daní, 2=CC bez daní, 4=JC bez daní valuty, 6=CC bez daní valuty
IF @_EXT_RS_SlevaProcento=0.0 AND (@_EXT_RS_JCPredSlevouKC<>0 OR @_EXT_RS_CCPredSlevouKC<>0 OR @_EXT_RS_JCPredSlevouVal<>0 OR @_EXT_RS_CCPredSlevouVal<>0)
BEGIN
	--teď nastoupí sada výpočtů podle toho, jaký je druh vstupní ceny
	--0=JC bez daní
	IF @VstupniCena=0 AND @_EXT_RS_JCPredSlevouKC<>0
	BEGIN
		UPDATE tpze SET tpze._EXT_RS_CCPredSlevouKC=@_EXT_RS_JCPredSlevouKC*@Mnozstvi, tpze._EXT_RS_JCPredSlevouVal=@_EXT_RS_JCPredSlevouKC/@Kurz, tpze._EXT_RS_CCPredSlevouVal=@_EXT_RS_JCPredSlevouKC/@Kurz*@Mnozstvi, tpze._EXT_RS_SlevaProcento=(ROUND((@_EXT_RS_JCPredSlevouKC/@JCbezDaniKC),2)-1)*100
		FROM TabPohybyZbozi_EXT tpze
		WHERE tpze.ID=@IDPol
	END;
	IF @VstupniCena=0 AND @_EXT_RS_JCPredSlevouKC=0
	BEGIN
		RAISERROR('Nesprávná kombinace zadání ceny před slevou (JC CZK), nelze přepočítat.',16,1)
		RETURN;
	END;

	--2=CC bez daní
	IF @VstupniCena=2
	BEGIN
		UPDATE tpze SET tpze._EXT_RS_JCPredSlevouKC=@_EXT_RS_CCPredSlevouKC/@Mnozstvi, tpze._EXT_RS_JCPredSlevouVal=@_EXT_RS_CCPredSlevouKC/@Mnozstvi/@Kurz, tpze._EXT_RS_CCPredSlevouVal=@_EXT_RS_CCPredSlevouKC*@Kurz, tpze._EXT_RS_SlevaProcento=(ROUND((@_EXT_RS_JCPredSlevouKC/@JCbezDaniKC),2)-1)*100
		FROM TabPohybyZbozi_EXT tpze
		WHERE tpze.ID=@IDPol
	END;
	IF @VstupniCena=2 AND @_EXT_RS_CCPredSlevouKC=0
	BEGIN
		RAISERROR('Nesprávná kombinace zadání ceny před slevou (CC CZK), nelze přepočítat.',16,1)
		RETURN;
	END;

	--4=JC bez daní valuty
	IF @VstupniCena=4
	BEGIN
		UPDATE tpze SET tpze._EXT_RS_JCPredSlevouKC=@_EXT_RS_JCPredSlevouVal*@Kurz, tpze._EXT_RS_CCPredSlevouKC=@_EXT_RS_JCPredSlevouVal*@Mnozstvi*@Kurz, tpze._EXT_RS_CCPredSlevouVal=@_EXT_RS_JCPredSlevouVal*@Mnozstvi, tpze._EXT_RS_SlevaProcento=(ROUND((@_EXT_RS_JCPredSlevouVal/@JCbezDaniVal),2)-1)*100
		FROM TabPohybyZbozi_EXT tpze
		WHERE tpze.ID=@IDPol
	END;
	IF @VstupniCena=4 AND @_EXT_RS_JCPredSlevouVal=0
	BEGIN
		RAISERROR('Nesprávná kombinace zadání ceny před slevou (JC valuty), nelze přepočítat.',16,1)
		RETURN;
	END;

	--6=CC bez daní valuty
	IF @VstupniCena=6
	BEGIN
		UPDATE tpze SET tpze._EXT_RS_JCPredSlevouKC=@_EXT_RS_CCPredSlevouVal*@Kurz/@Mnozstvi, tpze._EXT_RS_CCPredSlevouKC=@_EXT_RS_CCPredSlevouVal*@Kurz, tpze._EXT_RS_JCPredSlevouVal=@_EXT_RS_CCPredSlevouVal/@Mnozstvi, tpze._EXT_RS_SlevaProcento=(ROUND((@_EXT_RS_JCPredSlevouVal/@JCbezDaniVal),2)-1)*100
		FROM TabPohybyZbozi_EXT tpze
		WHERE tpze.ID=@IDPol
	END;
	IF @VstupniCena=6 AND @_EXT_RS_CCPredSlevouVal=0
	BEGIN
		RAISERROR('Nesprávná kombinace zadání ceny před slevou (CC valuty), nelze přepočítat.',16,1)
		RETURN;
	END;

	KONEC:

	--SELECT @_EXT_RS_JCPredSlevouKC AS JCKC, @_EXT_RS_CCPredSlevouKC AS CCKC, @_EXT_RS_JCPredSlevouVal AS JCVal, @_EXT_RS_CCPredSlevouVal AS CCVal, @_EXT_RS_SlevaProcento AS Procento
	--SELECT _EXT_RS_JCPredSlevouKC,_EXT_RS_CCPredSlevouKC,_EXT_RS_JCPredSlevouVal,_EXT_RS_CCPredSlevouVal,_EXT_RS_SlevaProcento
	--FROM TabPohybyZbozi_EXT tpze
	--WHERE tpze.ID=8634615
END;
GO

