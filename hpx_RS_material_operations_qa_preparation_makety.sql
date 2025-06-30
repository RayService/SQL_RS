USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_operations_qa_preparation_makety]    Script Date: 30.06.2025 8:55:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_material_operations_qa_preparation_makety]
@ID INT
AS
-- ============================================================================================
-- Author:		MŽ
-- Create date:            28.5.2025
-- Description:	Vložení 5 operací technické kontroly pro dílce typu makety
-- ============================================================================================
/*Nové generování operací pro makety
Po napočítání materiálového času spustit funkci, která si převezme operace z dílce: 899/02079.
Do druhé operace dá součet materiálového času.
Do třetí operace dá 6% z výše uvedeného součtu.
Zároveň 3. operaci nastavit jako odváděcí.*/
--dohledání ID dílce
/*DECLARE @IDHlavicka INT
SET @IDHlavicka = (SELECT vyssi FROM TabKvazby WHERE TabKVazby.ID = @ID)*/
--dohledání ID dílce
DECLARE @IDHlavicka INT
SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
--dohledání ID změny
DECLARE @IDZmena INT
SELECT @IDZmena = (SELECT
TabCzmeny.ID
FROM TabCzmeny
WHERE
((TabCZmeny.Platnost = 0 AND TabCZmeny.ID IN  (SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDHlavicka UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDHlavicka UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabNVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabNVazby WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION   SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDHlavicka UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDHlavicka ))))
-- dohledání sumy času předchozích operací
DECLARE @TotalOperationTime NUMERIC(19,6) = (SELECT SUM(TabKvazby_EXT._EXT_RS_item_time)
                                            FROM TabKvazby
                                            LEFT OUTER JOIN  TabKvazby_EXT ON TabKvazby_EXT.ID=TabKvazby.ID
                                            WHERE TabKvazby.vyssi = @IDHlavicka AND TabKvazby.ZmenaOd = @IDZmena)
-- zjištění času pro výpočet času pro operace TK
DECLARE @TimeThird NUMERIC(19,6) = (SELECT @TotalOperationTime * 0.06)
-- dohledání ID vzorové operace číslo 1
SELECT x.ID, x.Operace, x.rn
FROM (SELECT tp.ID,tp.Operace,ROW_NUMBER() OVER (ORDER BY tp.Operace) AS rn
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny tcOd WITH(NOLOCK) ON tp.ZmenaOd=tcOd.ID
  LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON tp.ZmenaDo=tcDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON tp.pracoviste=VPostupCPraco.ID
  WHERE ((tp.dilec=@IDHlavicka))AND((tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE()))AND(((tcDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))
) x
WHERE x.rn=1;
-- vzorový dílec
DECLARE @IDHlavickaOrig INT=253247;
-- dohledání ID vzorové operace číslo 1
DECLARE @IDOperace1 INT
SET @IDOperace1=(SELECT x.ID
FROM (SELECT tp.ID,tp.Operace,ROW_NUMBER() OVER (ORDER BY tp.Operace) AS rn
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny tcOd WITH(NOLOCK) ON tp.ZmenaOd=tcOd.ID
  LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON tp.ZmenaDo=tcDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON tp.pracoviste=VPostupCPraco.ID
  WHERE ((tp.dilec=@IDHlavickaOrig))AND((tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE()))AND(((tcDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))
) x
WHERE x.rn=1)
-- dohledání ID vzorové operace číslo 1
DECLARE @IDOperace2 INT
SET @IDOperace2=(SELECT x.ID
FROM (SELECT tp.ID,tp.Operace,ROW_NUMBER() OVER (ORDER BY tp.Operace) AS rn
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny tcOd WITH(NOLOCK) ON tp.ZmenaOd=tcOd.ID
  LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON tp.ZmenaDo=tcDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON tp.pracoviste=VPostupCPraco.ID
  WHERE ((tp.dilec=@IDHlavickaOrig))AND((tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE()))AND(((tcDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))
) x
WHERE x.rn=2)
DECLARE @IDOperace3 INT
SET @IDOperace3=(SELECT x.ID
FROM (SELECT tp.ID,tp.Operace,ROW_NUMBER() OVER (ORDER BY tp.Operace) AS rn
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny tcOd WITH(NOLOCK) ON tp.ZmenaOd=tcOd.ID
  LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON tp.ZmenaDo=tcDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON tp.pracoviste=VPostupCPraco.ID
  WHERE ((tp.dilec=@IDHlavickaOrig))AND((tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE()))AND(((tcDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))
) x
WHERE x.rn=3)

DECLARE @IDOperace4 INT
SET @IDOperace4=(SELECT x.ID
FROM (SELECT tp.ID,tp.Operace,ROW_NUMBER() OVER (ORDER BY tp.Operace) AS rn
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny tcOd WITH(NOLOCK) ON tp.ZmenaOd=tcOd.ID
  LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON tp.ZmenaDo=tcDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON tp.pracoviste=VPostupCPraco.ID
  WHERE ((tp.dilec=@IDHlavickaOrig))AND((tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE()))AND(((tcDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))
) x
WHERE x.rn=4)

DECLARE @IDOperace5 INT
SET @IDOperace5=(SELECT x.ID
FROM (SELECT tp.ID,tp.Operace,ROW_NUMBER() OVER (ORDER BY tp.Operace) AS rn
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny tcOd WITH(NOLOCK) ON tp.ZmenaOd=tcOd.ID
  LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON tp.ZmenaDo=tcDo.ID
  LEFT OUTER JOIN TabCPraco VPostupCPraco WITH(NOLOCK) ON tp.pracoviste=VPostupCPraco.ID
  WHERE ((tp.dilec=@IDHlavickaOrig))AND((tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE()))AND(((tcDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))
) x
WHERE x.rn=5)

--vložení operací TK 1
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0010')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0010',tp.BlokovaniEditoru,0,tp.nazev,tp.pracoviste,tp.tarif,tp.TBC_Obsluhy,tp.TBC_Obsluhy_T,tp.TBC,tp.TBC_T,tp.TAC_Obsluhy,tp.TAC_Obsluhy_T,tp.TAC,tp.TAC_T,1,tp.TAC,tp.TAC_Obsluhy,tp.TAC_T,tp.TAC_Obsluhy_T,tp.MeziOperCas,tp.MeziOperCas_T,tp.Poznamka,tp.TypOznaceni,tp.typ
		FROM TabPostup tp
		WHERE tp.ID=@IDOperace1
END
--vložení operací TK 2
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0020')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0020',tp.BlokovaniEditoru,0,tp.nazev,tp.pracoviste,tp.tarif,tp.TBC_Obsluhy,tp.TBC_Obsluhy_T,tp.TBC,tp.TBC_T,tp.TAC_Obsluhy,tp.TAC_Obsluhy_T,tp.TAC,tp.TAC_T,1,tp.TAC,tp.TAC_Obsluhy,tp.TAC_T,tp.TAC_Obsluhy_T,tp.MeziOperCas,tp.MeziOperCas_T,tp.Poznamka,tp.TypOznaceni,tp.typ
		FROM TabPostup tp
		WHERE tp.ID=@IDOperace2
END
--vložení operací TK 3
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0030')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru,JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0030',tp.BlokovaniEditoru,0,tp.nazev,tp.pracoviste,tp.tarif,tp.TBC_Obsluhy,tp.TBC_Obsluhy_T,tp.TBC,tp.TBC_T,tp.TAC_Obsluhy,tp.TAC_Obsluhy_T,tp.TAC,tp.TAC_T,1,tp.TAC,tp.TAC_Obsluhy,tp.TAC_T,tp.TAC_Obsluhy_T,tp.MeziOperCas,tp.MeziOperCas_T,tp.Poznamka,tp.TypOznaceni,tp.typ
		FROM TabPostup tp
		WHERE tp.ID=@IDOperace3
END

--vložení operací TK 4
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0040')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru,JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
		SELECT @IDHlavicka,@IDZmena,1,N'0040',tp.BlokovaniEditoru,0,tp.nazev,tp.pracoviste,tp.tarif,tp.TBC_Obsluhy,tp.TBC_Obsluhy_T,tp.TBC,tp.TBC_T,tp.TAC_Obsluhy,tp.TAC_Obsluhy_T,tp.TAC,tp.TAC_T,1,tp.TAC,tp.TAC_Obsluhy,tp.TAC_T,tp.TAC_Obsluhy_T,tp.MeziOperCas,tp.MeziOperCas_T,tp.Poznamka,tp.TypOznaceni,tp.typ
		FROM TabPostup tp
		WHERE tp.ID=@IDOperace4
END

--vložení operací TK 5
BEGIN
    IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0050')
    INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru,JeNovaVetaEditor,nazev,pracoviste,tarif,TBC_Obsluhy,TBC_Obsluhy_T,TBC,TBC_T,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ,Odvadeci)
		SELECT @IDHlavicka,@IDZmena,1,N'0050',tp.BlokovaniEditoru,0,tp.nazev,tp.pracoviste,tp.tarif,tp.TBC_Obsluhy,tp.TBC_Obsluhy_T,tp.TBC,tp.TBC_T,tp.TAC_Obsluhy,tp.TAC_Obsluhy_T,tp.TAC,tp.TAC_T,1,tp.TAC,tp.TAC_Obsluhy,tp.TAC_T,tp.TAC_Obsluhy_T,tp.MeziOperCas,tp.MeziOperCas_T,tp.Poznamka,tp.TypOznaceni,tp.typ,1
		FROM TabPostup tp
		WHERE tp.ID=@IDOperace5
END


--vložení času do 3 TK operací
BEGIN
--1.operace
/*
UPDATE TabPostup SET TAC_Obsluhy = @TimeVisual, TAC = @TimeVisual, TAC_Obsluhy_J = @TimeVisual, TAC_J = @TimeVisual
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0010')
*/
--3.operace
UPDATE TabPostup SET TAC_Obsluhy = @TotalOperationTime, TAC = @TotalOperationTime, TAC_Obsluhy_J = @TotalOperationTime, TAC_J = @TotalOperationTime
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0030')
--4.operace
UPDATE TabPostup SET TAC_Obsluhy = @TimeThird, TAC = @TimeThird, TAC_Obsluhy_J = @TimeThird, TAC_J = @TimeThird
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0040')
END
GO

