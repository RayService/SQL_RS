USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenVydTensileTest]    Script Date: 26.06.2025 14:12:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenVydTensileTest]
AS

DECLARE @NewID INT, @IDGen INT, @IDGenPrikaz INT, @IDKmenZboziGen INT, @MnoGen NUMERIC(19,6), @Sklad NVARCHAR(15), @Rada NVARCHAR(3);

IF (OBJECT_ID('tempdb..#TempGenPol') IS NOT NULL)
BEGIN
DROP TABLE #TempGenPol
END;
CREATE TABLE #TempGenPol 
( [ID] [INT],
  [IDPolozky] [INT],
  [Mnozstvi] [NUMERIC](19,6),
  [IDPrikaz] [INT],
  [IDCombination] [INT],
  [AutomatGenVC] [BIT],
  [Autor] [NVARCHAR](128),
  [DatPorizeni] [DATETIME],
  [IDRequest] [INT]
)
--beru pouze položky, které jsou skladem
INSERT INTO #TempGenPol (IDPolozky,Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,ID,Autor,DatPorizeni,IDRequest)
SELECT T.IDPolozky, T.Mnozstvi, T.IDPrikaz, T.IDCombination, T.AutomatGenVC, ROW_NUMBER() OVER(ORDER BY T.ID) AS ID,SUSER_SNAME(),GETDATE(),T.IDZadosti
FROM (SELECT wb.ID,wb.IDPolozky,wb.Mnozstvi,wb.IDPrikaz,wb.IDCombination,wb.AutomatGenVC,wb.IDZadosti
		FROM Tabx_RS_TDMWire_Before wb
		LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=(SELECT tss.ID
													FROM TabKmenZbozi tkz WITH(NOLOCK)
													LEFT OUTER JOIN TabParametryKmeneZbozi parkmz WITH(NOLOCK) ON parkmz.IDKmenZbozi=tkz.ID
													LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=parkmz.VychoziSklad
													WHERE tkz.ID=wb.IDPolozky)
		WHERE (tss.Mnozstvi>0)
		UNION SELECT cb.ID,cb.IDPolozky,cb.Mnozstvi,cb.IDPrikaz,cb.IDCombination,cb.AutomatGenVC,cb.IDZadosti
		FROM Tabx_RS_TDMContacts_Before cb
		LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=(SELECT tss.ID
													FROM TabKmenZbozi tkz WITH(NOLOCK)
													LEFT OUTER JOIN TabParametryKmeneZbozi parkmz WITH(NOLOCK) ON parkmz.IDKmenZbozi=tkz.ID
													LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=parkmz.VychoziSklad
													WHERE tkz.ID=cb.IDPolozky)
		WHERE (tss.Mnozstvi>0)
		) AS T

--tabulka pro položky, které se vezmou do výdejky
IF (OBJECT_ID('tempdb..#TabPrKVazbyGen') IS NOT NULL)
BEGIN
DROP TABLE #TabPrKVazbyGen
END;
CREATE TABLE #TabPrKVazbyGen(
ID int IDENTITY(1,1) NOT NULL, 
Generuj bit NOT NULL, --1=tento záznam zahrň do generování
IDPrKV int NOT NULL, --ID z TabPrKVazby
Sklad nvarchar(30) COLLATE database_default NOT NULL, 
MnozstviPoz numeric(19,6) NOT NULL, 
Dodavatel int NULL, --ID organizace pro generování objednávek
IDPohZbo int NULL, --zde uloženka zapíše IDčko nového záznamu z TabPohybyZbozi
PRIMARY KEY (ID)) 

--zjistíme ID příkazu, kam nasypeme materiál
SET @IDGenPrikaz=(SELECT tp.ID FROM TabPrikaz tp LEFT OUTER JOIN TabPrikaz_EXT tpe ON tpe.ID=tp.ID WHERE (ISNULL(tpe._EXT_RS_GenVydTensTest,0)=1) AND tp.StavPrikazu=30)

DECLARE CurGenPrKV CURSOR LOCAL FAST_FORWARD FOR
SELECT ID FROM #TempGenPol
OPEN CurGenPrKV;
FETCH NEXT FROM CurGenPrKV INTO @IDGen;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	SELECT @IDKmenZboziGen=IDPolozky, @MnoGen=Mnozstvi
	FROM #TempGenPol WHERE ID=@IDGen;
	
	EXEC @NewID=hp_NewPozadavek_TabPrKVazby @IDPrikaz=@IDGenPrikaz, @IDKmenZbozi=@IDKmenZboziGen, @Mnozstvi=@MnoGen
	
	--nasypeme do #TabPrKVazbyGen položku
	INSERT INTO #TabPrKVazbyGen(Generuj, IDPrKV, Sklad, MnozstviPoz)
	SELECT 1, PrKV.ID, PrKV.Sklad, PrKV.mnoz_zad * 1.0 / P.kusy_zad
	FROM TabPrKVazby PrKV
	INNER JOIN TabPrikaz P ON (P.ID=PrKV.IDPrikaz)
	WHERE PrKV.IDPrikaz=@IDGenPrikaz AND PrKV.prednastaveno=1 AND PrKV.IDOdchylkyDo IS NULL AND PrKV.Sklad IS NOT NULL AND PrKV.Splneno=0 AND Prkv.ID=@NewID

	FETCH NEXT FROM CurGenPrKV INTO @IDGen;
	END;
CLOSE CurGenPrKV;
DEALLOCATE CurGenPrKV;

--generování výdejky cursorem dle skladu

DECLARE CurGenVyd CURSOR LOCAL FAST_FORWARD FOR
SELECT Sklad FROM #TabPrKVazbyGen
GROUP BY Sklad
OPEN CurGenVyd;
FETCH NEXT FROM CurGenVyd INTO @Sklad;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	
	--tabulka, kam se zapíšou ID výdejek, které vzniknou
	IF (OBJECT_ID('tempdb..#TabGenRezVyd') IS NOT NULL)
	BEGIN
	DROP TABLE #TabGenRezVyd
	END;
	
	CREATE TABLE #TabGenRezVyd(
	ID int) --zde uloženka zapíše IDčka nového záznamu z TabDokladyZbozi

	SET @Rada = (SELECT CASE @Sklad WHEN '100' THEN '631' WHEN '20000280' THEN '640' END)
	EXEC hp_generujRezVyd @RadaDokladu=@Rada, @DruhPohybuZbo=4, @DatPorizeni=NULL, @SekejZakazky=0, @SekejPrikazy=0

	UPDATE TabDokladyZbozi_EXT SET _EXT_DocCreatedByB2aDima=1
	FROM TabDokladyZbozi_EXT tdze
	WHERE tdze.ID=(SELECT ID FROM #TabGenRezVyd)
	IF @@ROWCOUNT = 0
	BEGIN
	INSERT INTO TabDokladyZbozi_EXT (ID, _EXT_DocCreatedByB2aDima)
	SELECT ID, 1
	FROM #TabGenRezVyd
	END;
	--zápis ID výdejky do žádostí
	MERGE B2A_TDM_TensileTest_Request AS TARGET
	USING (SELECT IDRequest FROM #TempGenPol GROUP BY IDRequest) AS SOURCE
                  ON TARGET.ID=SOURCE.IDRequest
	WHEN MATCHED THEN
	UPDATE SET TARGET.IDVydejky=(SELECT ID FROM #TabGenRezVyd)
	;

	FETCH NEXT FROM CurGenVyd INTO @Sklad;
	END;
CLOSE CurGenVyd;
DEALLOCATE CurGenVyd;

--označení žádostí, že se na nich generovaly výdejky
MERGE B2A_TDM_TensileTest_Request AS TARGET
USING (SELECT IDRequest FROM #TempGenPol GROUP BY IDRequest) AS SOURCE
                  ON TARGET.ID=SOURCE.IDRequest
WHEN MATCHED THEN
UPDATE SET TARGET.GenerovanyVydejky=1
;

--smazání seznamu generovaných položek, které jsou skladem, ostatní ponechat
DELETE wb FROM Tabx_RS_TDMWire_Before wb
		LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=(SELECT tss.ID
													FROM TabKmenZbozi tkz WITH(NOLOCK)
													LEFT OUTER JOIN TabParametryKmeneZbozi parkmz WITH(NOLOCK) ON parkmz.IDKmenZbozi=tkz.ID
													LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=parkmz.VychoziSklad
													WHERE tkz.ID=wb.IDPolozky)
		WHERE (tss.Mnozstvi>0)
DELETE cb FROM Tabx_RS_TDMContacts_Before cb
		LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=(SELECT tss.ID
													FROM TabKmenZbozi tkz WITH(NOLOCK)
													LEFT OUTER JOIN TabParametryKmeneZbozi parkmz WITH(NOLOCK) ON parkmz.IDKmenZbozi=tkz.ID
													LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=parkmz.VychoziSklad
													WHERE tkz.ID=cb.IDPolozky)
		WHERE (tss.Mnozstvi>0)
GO

