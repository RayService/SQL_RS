USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_operations_qa]    Script Date: 26.06.2025 15:57:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_operations_qa]
@ID INT
AS
-- ===============================================================================================================================================================================================
-- Author:		MŽ
-- Create date:            18.7.2019
-- Description:	Vložení 3 operací technické výstupní kontroly
-- Change: Vložení nové páté operace TP. Bude vložena na druhé místo. Změna 27.1.2021
-- Change: výpočet času pro operace TK. Suma času běžných operací x 0,06. Pak 55% z tohoto dát na operaci 314, pak 40% z toho dát na operaci 80, pak 5% z toho dát na operaci 155 a 1 hodinu dát na operaci 157
-- Change: vložení nové operace TP. Změna 12.4.2021.
-- Change: vložení další hromady TK operací. U některých dochází k nápočtu časů.
-- ===============================================================================================================================================================================================
--dohledání ID dílce
DECLARE @IDHlavicka INT
SET @IDHlavicka = (SELECT vyssi FROM TabKvazby WHERE TabKVazby.ID = @ID)
--SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
--dohledání ID změny
DECLARE @IDZmena INT
SELECT @IDZmena = (SELECT
TabCzmeny.ID
FROM TabCzmeny
WHERE
((TabCZmeny.Platnost = 0 AND TabCZmeny.ID IN  (SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDHlavicka UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDHlavicka UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabNVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabNVazby WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDHlavicka UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDHlavicka ))))
--dohledání čísla materiálové operace v ext.informacích na technologickém postupu
DECLARE @MaterialOperation INT = (SELECT tpe._EXT_RS_material_operation_postup
		                            FROM TabPostup tp
                                    LEFT OUTER JOIN TabPostup_EXT tpe ON tpe.ID = tp.ID
                                    LEFT OUTER JOIN TabKvazby tkv ON tkv.Operace = tp.Operace AND tkv.vyssi = @IDHlavicka AND tkv.ZmenaOd = @IDZmena
                                    WHERE tkv.ID = @ID AND tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena)--tkv.Operace = @Operace AND tkv.vyssi =@IDHlavicka AND tp.ZmenaOd = @IDZmena)
--dohledání položkového času na kusovníku
DECLARE @ItemTime NUMERIC(19,6) = (SELECT TabKvazby_EXT._EXT_RS_item_time
                                    FROM TabKvazby
                                    LEFT OUTER JOIN  TabKvazby_EXT ON TabKvazby_EXT.ID=TabKvazby.ID
                                    WHERE TabKvazby.ID = @ID)
--dohledání typového označení z materiálové operace v ext.informacích na kartě materiálu
DECLARE @MaterialOperationType NVARCHAR(10) = (SELECT ttp.TypOznaceni
													FROM TabKvazby tkv
													LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
													LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
													LEFT OUTER JOIN TabTypPostup ttp ON ttp.Cislo = tkze._EXT_RS_material_operation
													WHERE tkv.ID = @ID)
-- dohledání sumy času předchozích operací
DECLARE @TotalOperationTime NUMERIC(19,6) = (SELECT SUM(tp.TAC_N)
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON tp.ZmenaOd=VPostupCZmenyOd.ID
  LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON tp.ZmenaDo=VPostupCZmenyDo.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tp.pracoviste=tcp.ID
  LEFT OUTER JOIN TabCPraco_EXT tcpe WITH(NOLOCK) ON tcpe.ID=tcp.ID
WHERE
(tp.dilec=@IDHlavicka AND (@IDZmena>0 AND tp.zmenaOd=@IDZmena OR  @IDZmena=0 AND VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()
AND  (VPostupCZmenyDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) ) AND (tcp.IDTabStrom=N'200' OR (tcp.IDTabStrom LIKE N'2002%' AND (ISNULL(tcpe._EXT_RS_wokplaceQA,0)=0 AND ISNULL(tcpe._EXT_RS_workplaceWH,0)=0)))))
--7.2.2023 na přání BV - přenos generování do VP zrušeno
--22.2.2023 na přání PeZ vráceno zpět
/*--31.10.2024 na přání OM zrušeno - přesunuto do VP
--vložení operací TK 1 na konec (TP - Inspekční prohlídka VP 100)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0950')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0950',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID = 562
END
*/
--vložení operací TK 2 na konec (TP - Výstupní kontrola - vizuální)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0970')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru,JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0970',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID = 154
END
--vložení operací TK 3 na konec (TP - Příprava pracoviště k testování)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0980')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
        SELECT @IDHlavicka,@IDZmena,1,N'0980'/*,N'1300'*/,ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID=625
END
--vložení operací TK 4 na konec (TP - Výstupní kontrola - el.test)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0990')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0990',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID = 155
END
--vložení operací TK 5 na konec (TP - Výstupní kontrola - tvorba dokumentů+odvádění)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'1000')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'1000',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID = 157
END
/*--31.10.2024 na přání OM zrušeno - přesunuto do VP
--vložení operací TK 6 na konec (TP - Učení testovacího programu)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'1100')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'1100'/*N'0980'*/,ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID = 80
END*/
--vložení operací TK 8 na konec (TP - Zapracování podkladů z VP100)
--BEGIN
--    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'1200')
--    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
--		SELECT @IDHlavicka,@IDZmena,1,N'1200'/*N'1100'*/,ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
--		FROM TabTypPostup ttp
--		WHERE ttp.ID = 542
--END

--zjištění SK dílce pro určení kvalifikace dílce a pro výpočet časů
DECLARE @SK NVARCHAR(3)=(SELECT tkz.SkupZbo FROM TabKmenZbozi tkz WHERE tkz.ID=@IDHlavicka)
--zjištění řady VP z dílce
DECLARE @RadaVP NVARCHAR(10)=(SELECT RadaVyrPrikazu FROM TabKmenZbozi WITH(NOLOCK) LEFT OUTER JOIN TabParKmZ VParKmZKmenZbozi WITH(NOLOCK) ON VParKmZKmenZbozi.IDKmenZbozi=TabKmenZbozi.ID WHERE TabKmenZbozi.ID=@IDHlavicka)
--zjištění kmenového střediska pro výpočet času
DECLARE @KmenUtvar NVARCHAR(30)=(SELECT tkz.KmenoveStredisko FROM TabKmenZbozi tkz WHERE tkz.ID=@IDHlavicka)
DECLARE @Hermle BIT=(SELECT ISNULL(tkze._Hermle,0) FROM TabKmenZbozi tkz WITH(NOLOCK) LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID WHERE tkz.ID=@IDHlavicka)
--deklarace pro výpočet časů
DECLARE @TimeVisual NUMERIC(19,6), @TimeElectric NUMERIC(19,6), @TimeDocument NUMERIC(19,6), @TimeMeasure NUMERIC(19,6);

--pro SK 830 nebo (VP=500 nebo VP=050 nebo VP=100)

IF (@SK='830' OR (@RadaVP='500' OR @RadaVP='050' OR @RadaVP='100'))AND(@Hermle=0)
BEGIN
-- zjištění času pro výpočet času pro operace TK
SET @TimeVisual = (SELECT @TotalOperationTime * 0.06 * 0.599)
SET @TimeElectric= (SELECT @TotalOperationTime * 0.06 * 0.40)
SET @TimeDocument = (SELECT @TotalOperationTime * 0.06 * 0.001)

--vložení času do 3 TK operací
BEGIN
UPDATE TabPostup SET TAC_Obsluhy = @TimeVisual, TAC = @TimeVisual, TAC_Obsluhy_J = @TimeVisual, TAC_J = @TimeVisual
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0970')
UPDATE TabPostup SET TAC_Obsluhy = @TimeElectric, TAC = @TimeElectric, TAC_Obsluhy_J = @TimeElectric, TAC_J = @TimeElectric
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0990')
UPDATE TabPostup SET TAC_Obsluhy = @TimeDocument, TAC = @TimeDocument, TAC_Obsluhy_J = @TimeDocument, TAC_J = @TimeDocument
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'1000')
END
END;

--pro SK<>830 a VP<>500

IF ((@SK<>'830') AND ((@RadaVP<>N'500') OR (@RadaVP IS NULL)))AND(@Hermle=0)
BEGIN
-- zjištění času pro výpočet času pro operace TK
SET @TimeElectric = (SELECT @TotalOperationTime * 0.036 * 0.999)
SET @TimeDocument = (SELECT @TotalOperationTime * 0.036 * 0.001)

--vložení času do 2 TK operací
BEGIN
UPDATE TabPostup SET TAC_Obsluhy = @TimeElectric, TAC = @TimeElectric, TAC_Obsluhy_J = @TimeElectric, TAC_J = @TimeElectric
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0990')
UPDATE TabPostup SET TAC_Obsluhy = @TimeDocument, TAC = @TimeDocument, TAC_Obsluhy_J = @TimeDocument, TAC_J = @TimeDocument
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'1000')
END
DELETE FROM TabPostup WHERE dilec = @IDHlavicka AND ZmenaDo IS NULL AND Operace = N'0970'
END;

--nově 19.1.2023
--pro VD s kmenovým střediskem začínajícím na (20022000 nebo 20023000 nebo 20026000) a zároveň (SK<>830 a VP<>500)

IF ((@SK<>'830') AND ((@RadaVP NOT IN ('500','050','100') AND @RadaVP IS NOT NULL)))AND(@Hermle=0)
BEGIN
-- zjištění času pro výpočet času pro operace TK
SET @TimeVisual = (SELECT @TotalOperationTime * 0.030)
SET @TimeElectric = (SELECT @TotalOperationTime * 0.036 * 0.999)
SET @TimeDocument = (SELECT @TotalOperationTime * 0.036 * 0.001)

--vložení času do 3 TK operací
BEGIN
UPDATE TabPostup SET TAC_Obsluhy = @TimeVisual, TAC = @TimeVisual, TAC_Obsluhy_J = @TimeVisual, TAC_J = @TimeVisual
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0970')
UPDATE TabPostup SET TAC_Obsluhy = @TimeElectric, TAC = @TimeElectric, TAC_Obsluhy_J = @TimeElectric, TAC_J = @TimeElectric
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0990')
UPDATE TabPostup SET TAC_Obsluhy = @TimeDocument, TAC = @TimeDocument, TAC_Obsluhy_J = @TimeDocument, TAC_J = @TimeDocument
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'1000')
END
END;

--pro VD s haklíkem "Výroba Hermle"

IF (@Hermle=1)
BEGIN
--nejprve vložíme dvě operace pro Hermle
--vložení operací TK 9 na konec (TP - Výstupní kontrola - měření)
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'1400')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'1400',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID=738
END

--vložení operací TK 10 na konec (TP - Mezioperační kontrola - "kooperace" (zušlechtění))
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'1500')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'1500',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TBC_Obsluhy,ttp.TBC_Obsluhy_T,ttp.TBC,ttp.TBC_T,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
		FROM TabTypPostup ttp
		WHERE ttp.ID=739
END

-- zjištění času pro výpočet času pro operace TK
SET @TimeVisual = (SELECT @TotalOperationTime * 0.045)
SET @TimeMeasure = (SELECT @TotalOperationTime * 0.015)
SET @TimeDocument = (SELECT @TotalOperationTime * 0.001)

--vložení času do 3 TK operací
BEGIN
UPDATE TabPostup SET TAC_Obsluhy = @TimeVisual, TAC = @TimeVisual, TAC_Obsluhy_J = @TimeVisual, TAC_J = @TimeVisual
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0970')
UPDATE TabPostup SET TAC_Obsluhy = @TimeMeasure, TAC = @TimeMeasure, TAC_Obsluhy_J = @TimeMeasure, TAC_J = @TimeMeasure
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'1400')
UPDATE TabPostup SET TAC_Obsluhy = @TimeDocument, TAC = @TimeDocument, TAC_Obsluhy_J = @TimeDocument, TAC_J = @TimeDocument
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'1000')
END
END;
GO

