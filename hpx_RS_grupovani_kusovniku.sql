USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_grupovani_kusovniku]    Script Date: 26.06.2025 10:31:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_grupovani_kusovniku]
@ID INT
AS
--=============================
--Change: 11.6.2020 Přidán import znaku S do Spotřební rozměr u položek, které byly založeny seskupením
--=============================
DECLARE @Oznacenych SMALLINT, @Aktualni SMALLINT, @IDPrikaz INT, @Doklad INT, @nizsi INT, @IDOdchylka INT;
DECLARE @Sklad NVARCHAR(30);
DECLARE @VyrStredisko NVARCHAR(30);
DECLARE @IDPracoviste INT;
DECLARE @Uzavreno INT;
DECLARE @AutorUzavreni NVARCHAR(128);
DECLARE @IDOdchylkyOd INT;
DECLARE @IDOdchylkyDo INT;
DECLARE @priorita INT;
DECLARE @vyssi INT;
SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM'
SELECT @Aktualni = MAX(Cislo) FROM #TabExtKomPar WHERE Popis = 'PRECHOD'
IF @Aktualni = 1 OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
   DELETE FROM Tabx_RS_TabPrKVazby-- WHERE Ident = @@SPID
SET @IDPrikaz = (SELECT IDPrikaz
				FROM TabPrKVazby PrKV
				LEFT OUTER JOIN TabKmenZbozi tkz ON PrKV.nizsi=tkz.ID
				LEFT OUTER JOIN TabPrikaz tp ON PrKV.IDPrikaz=tp.ID
				WHERE ((tkz.SkupZbo like N'1%')AND(tkz.MJEvidence=N'm'))AND PrKV.ID = @ID);
SET @Doklad = (SELECT Doklad
				FROM TabPrKVazby PrKV
				LEFT OUTER JOIN TabKmenZbozi tkz ON PrKV.nizsi=tkz.ID
				LEFT OUTER JOIN TabPrikaz tp ON PrKV.IDPrikaz=tp.ID
				WHERE ((tkz.SkupZbo like N'1%')AND(tkz.MJEvidence=N'm'))AND PrKV.ID = @ID);
SET @nizsi = (SELECT nizsi
				FROM TabPrKVazby PrKV
				LEFT OUTER JOIN TabKmenZbozi tkz ON PrKV.nizsi=tkz.ID
				LEFT OUTER JOIN TabPrikaz tp ON PrKV.IDPrikaz=tp.ID
				WHERE ((tkz.SkupZbo like N'1%')AND(tkz.MJEvidence=N'm'))AND PrKV.ID = @ID);
SET @IDOdchylka = (SELECT TOP 1 ID FROM TabCOdchylek WHERE PermanentniOdchylka=1)
INSERT INTO Tabx_RS_TabPrKVazby
	(ID
	,Doklad
	,IDPrikaz
	,Prednastaveno
	,predzpracovano
	,Sklad
	,VyrStredisko
	,IDPracoviste
	,mnoz_zad
	,Mnoz_nepotrebne
	,Mnoz_skut_realizovane
	,Mnoz_odv
	,Uzavreno
	,AutorUzavreni
	,IDOdchylkyOd
	,IDOdchylkyDo
	,priorita
	,vyssi
	,nizsi
	,pozice
	,Operace
	,mnozstvi
	,ProcZtrat
	,Prirez
	,Poznamka
	,DatPorizeni
	,Autor
	,Zmenil
	,DatZmeny
	,BlokovaniEditoru
	,ID1
	,RefMnoz
	,VydanoRefMnoz
	,mnozstviSeZtratou
	,IDVzorceSpotMat
	,PromA
	,PromB
	,PromC
	,PromD
	,PromE
	,SpotRozmer
	,mat_real
	,mat_odv
	,MatRezie_real
	,koop_real
	,mzda_real
	,rezieS_real
	,rezieP_real
	,ReziePrac_real
	,NakladyPrac_real
	,OPN_real
	,VedProdukt_real
	,naradi_real
	,NespecNakl_real
	,MatRezie_odv
	,koop_odv
	,mzda_odv
	,rezieS_odv
	,rezieP_odv
	,ReziePrac_odv
	,NakladyPrac_odv
	,OPN_odv
	,VedProdukt_odv
	,naradi_odv
	,NespecNakl_odv
	,FixniMnozstvi
	,AutorTisku
	,DatumTisku
	,DavkaTPV
	,RezijniMat
	,VyraditZKalkulace
	,matA_real
	,matB_real
	,matC_real
	,matA_odv
	,matB_odv
	,matC_odv
	,VychoziSklad
	,UzivNastSklad
	,Ident
	,CPrirez)
	SELECT
	@ID
	,PrKV.Doklad
	,PrKV.IDPrikaz
	,PrKV.Prednastaveno
	,PrKV.predzpracovano
	,PrKV.Sklad
	,PrKV.VyrStredisko
	,PrKV.IDPracoviste
	,PrKV.mnoz_zad
	,PrKV.Mnoz_nepotrebne
	,PrKV.Mnoz_skut_realizovane
	,PrKV.Mnoz_odv
	,PrKV.Uzavreno
	,PrKV.AutorUzavreni
	,PrKV.IDOdchylkyOd
	,PrKV.IDOdchylkyDo
	,PrKV.priorita
	,PrKV.vyssi
	,PrKV.nizsi
	,PrKV.pozice
	,PrKV.Operace
	,PrKV.mnozstvi
	,PrKV.ProcZtrat
	,PrKV.Prirez
	,PrKV.Poznamka
	,PrKV.DatPorizeni
	,PrKV.Autor
	,PrKV.Zmenil
	,PrKV.DatZmeny
	,PrKV.BlokovaniEditoru
	,PrKV.ID1
	,PrKV.RefMnoz
	,PrKV.VydanoRefMnoz
	,PrKV.mnozstviSeZtratou
	,PrKV.IDVzorceSpotMat
	,PrKV.PromA
	,PrKV.PromB
	,PrKV.PromC
	,PrKV.PromD
	,PrKV.PromE
	,PrKV.SpotRozmer
	,PrKV.mat_real
	,PrKV.mat_odv
	,PrKV.MatRezie_real
	,PrKV.koop_real
	,PrKV.mzda_real
	,PrKV.rezieS_real
	,PrKV.rezieP_real
	,PrKV.ReziePrac_real
	,PrKV.NakladyPrac_real
	,PrKV.OPN_real
	,PrKV.VedProdukt_real
	,PrKV.naradi_real
	,PrKV.NespecNakl_real
	,PrKV.MatRezie_odv
	,PrKV.koop_odv
	,PrKV.mzda_odv
	,PrKV.rezieS_odv
	,PrKV.rezieP_odv
	,PrKV.ReziePrac_odv
	,PrKV.NakladyPrac_odv
	,PrKV.OPN_odv
	,PrKV.VedProdukt_odv
	,PrKV.naradi_odv
	,PrKV.NespecNakl_odv
	,PrKV.FixniMnozstvi
	,PrKV.AutorTisku
	,PrKV.DatumTisku
	,PrKV.DavkaTPV
	,PrKV.RezijniMat
	,PrKV.VyraditZKalkulace
	,PrKV.matA_real
	,PrKV.matB_real
	,PrKV.matC_real
	,PrKV.matA_odv
	,PrKV.matB_odv
	,PrKV.matC_odv
	,PrKV.VychoziSklad
	,PrKV.UzivNastSklad
	,@@SPID
	,CONVERT(numeric(19,6), (SELECT CASE WHEN PrKV.mnozstvi=0.0 THEN PrKV.prirez
	ELSE PP.Mnoz_Zad*PrKV.prirez/PrKV.DavkaTPV END
	FROM TabPrikazP PP
	WHERE PP.IDPrikaz=PrKV.IDPrikaz AND PP.IDTabKmen=PrKV.vyssi AND PP.Mnoz_Zad>0.0))
FROM TabPrKVazby PrKV
LEFT OUTER JOIN TabKmenZbozi tkz ON PrKV.nizsi=tkz.ID
LEFT OUTER JOIN TabPrikaz tp ON PrKV.IDPrikaz=tp.ID
WHERE ((tkz.SkupZbo like N'1%')AND(tkz.MJEvidence=N'm'))AND PrKV.ID = @ID;
DECLARE @ret integer;
EXEC @ret=hp_TabPrKVazby_Delete @IDPrikaz, @Doklad, @nizsi, @IDOdchylka
--SELECT @ret
IF @Aktualni = @Oznacenych OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
BEGIN
    DECLARE DK_cur CURSOR LOCAL FAST_FORWARD FOR
		SELECT PrKV.IDPrikaz, PrKV.Sklad, PrKV.VyrStredisko, PrKV.IDPracoviste, PrKV.Uzavreno, PrKV.AutorUzavreni, PrKV.IDOdchylkyOd, PrKV.IDOdchylkyDo, PrKV.priorita, PrKV.vyssi, PrKV.nizsi
		FROM Tabx_RS_TabPrKVazby PrKV
		GROUP BY PrKV.IDPrikaz, PrKV.nizsi, PrKV.Sklad, PrKV.VyrStredisko, PrKV.IDPracoviste, PrKV.Uzavreno, PrKV.AutorUzavreni, PrKV.IDOdchylkyOd, PrKV.IDOdchylkyDo, PrKV.priorita, PrKV.vyssi
		ORDER BY IDPrikaz, nizsi
	OPEN DK_cur
	WHILE 1=1
	  BEGIN
	    FETCH NEXT FROM DK_cur INTO
		@IDPrikaz
		,@Sklad
		,@VyrStredisko
		,@IDPracoviste
		,@Uzavreno
		,@AutorUzavreni
		,@IDOdchylkyOd
		,@IDOdchylkyDo
		,@priorita
		,@vyssi
		,@nizsi;
		IF @@FETCH_STATUS <> 0 BREAK
		INSERT INTO TabPrKVazby
		(Doklad
		,IDPrikaz
		,Prednastaveno
		,predzpracovano
		,Sklad
		,VyrStredisko
		,IDPracoviste
		,mnoz_zad
		,Mnoz_nepotrebne
		,Mnoz_skut_realizovane
		,Mnoz_odv
		,Uzavreno
		,AutorUzavreni
		,IDOdchylkyOd
		,IDOdchylkyDo
		,priorita
		,vyssi
		,nizsi
		,pozice
		,Operace
		,mnozstvi
		,ProcZtrat
		,Prirez
		/*,Poznamka*/
		,DatPorizeni
		,Autor
		,Zmenil
		,DatZmeny
		,BlokovaniEditoru
		,ID1
		,RefMnoz
		,VydanoRefMnoz
		,mnozstviSeZtratou
		,IDVzorceSpotMat
		,PromA
		,PromB
		,PromC
		,PromD
		,PromE
		,SpotRozmer
		,mat_real
		,mat_odv
		,MatRezie_real
		,koop_real
		,mzda_real
		,rezieS_real
		,rezieP_real
		,ReziePrac_real
		,NakladyPrac_real
		,OPN_real
		,VedProdukt_real
		,naradi_real
		,NespecNakl_real
		,MatRezie_odv
		,koop_odv
		,mzda_odv
		,rezieS_odv
		,rezieP_odv
		,ReziePrac_odv
		,NakladyPrac_odv
		,OPN_odv
		,VedProdukt_odv
		,naradi_odv
		,NespecNakl_odv
		,FixniMnozstvi
		,AutorTisku
		,DatumTisku
		,DavkaTPV
		,RezijniMat
		,VyraditZKalkulace
		,matA_real
		,matB_real
		,matC_real
		,matA_odv
		,matB_odv
		,matC_odv
		,VychoziSklad
		,UzivNastSklad)
		SELECT
		/*(SELECT ISNULL(MAX(Doklad),0) + 1 FROM TabPrKVazby WHERE Doklad<=999999999 AND IDPrikaz=@IDPrikaz)*/MAX(PrKV.Doklad)
		,PrKV.IDPrikaz
		,PrKV.Prednastaveno /*1*/
		,0
		,PrKV.Sklad
		,PrKV.VyrStredisko
		,PrKV.IDPracoviste
		,SUM(PrKV.mnoz_zad)
		,SUM(PrKV.Mnoz_nepotrebne)
		,SUM(PrKV.Mnoz_skut_realizovane)
		,SUM(PrKV.Mnoz_odv)
		,PrKV.Uzavreno
		,PrKV.AutorUzavreni
		,@IdOdchylka
		,NULL/*PrKV.IDOdchylkyDo*/
		,PrKV.priorita
		,PrKV.vyssi
		,PrKV.nizsi/*konec Groupy*/
		,MAX(PrKV.pozice)
		,MIN(PrKV.Operace)
		,SUM(PrKV.mnozstvi)
		,SUM(PrKV.ProcZtrat)
		,MAX(PrKV.Prirez)
		/*, CAST(PrKV.Poznamka AS NVARCHAR(255))*/
		,MAX(PrKV.DatPorizeni)
		,MAX(PrKV.Autor)
		,MAX(PrKV.Zmenil)
		,MAX(PrKV.DatZmeny)
		,MAX(PrKV.BlokovaniEditoru)
		,MAX(PrKV.ID1)
		,SUM(PrKV.RefMnoz)
		,SUM(PrKV.VydanoRefMnoz)
		,SUM(PrKV.mnozstviSeZtratou)
		,2 /*IDVzorceSpotMat*/
		,1 /*PromA*/
		,SUM(mnozstvi)*PrKv.CPrirez*1000 /*PromB*/
		,NULL /*PromC*/
		,NULL /*PromD*/
		,NULL /*PromE*/
		,'S'/*NULL*//*SpotRozmer*/
		,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		,MAX(PrKV.AutorTisku)
		,MAX(PrKV.DatumTisku)
		,MAX(PrKV.DavkaTPV)
		,0/*RezijniMat*/
		,0 /*vyraditzkalkulace*/
		,0,0,0,0,0,0
		, NULL /*VychoziSklad*/
		,0 /*UzivNastSklad*/
		FROM Tabx_RS_TabPrKVazby PrKV
		GROUP BY PrKV.IDPrikaz, PrKV.nizsi, PrKV.Prednastaveno, PrKV.Sklad, PrKV.VyrStredisko, PrKV.IDPracoviste, PrKV.Uzavreno, PrKV.AutorUzavreni, PrKV.IDOdchylkyOd, PrKV.IDOdchylkyDo, PrKV.priorita, PrKV.vyssi, PrKV.CPrirez--, CAST(PrKV.Poznamka AS NVARCHAR(255))
		ORDER BY IDPrikaz, nizsi
	  END
	CLOSE DK_cur
	DEALLOCATE DK_cur   
END;
GO

