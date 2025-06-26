USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_operations]    Script Date: 26.06.2025 15:56:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_operations]
@ID INT
AS
-- ============================================================================================
-- Author:		MŽ
-- Create date:            10.4.2019
-- Description:	Hromadný import operací z externího pole na materiálu do technologického  postupu
-- ============================================================================================
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
--vložení první operace
/*toto je po zadání od PaM z 24.4.2023 změněno
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0010')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0010',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 15
END*/
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0009')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0009',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 732
END
--vložení druhé operace
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0010')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0010',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 677
END


/*7.2.2023 na přání BV - přenos generování do VP zrušeno
--vložení druhé operace (přidáno 23.3.2022 PaM)
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0013')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0013',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 651
END
*/

--15.7.2024 na přání BV vloženo
--vložení třetí operace
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0015')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0015',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 796
END


--vložení čtvrté operace
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0020')
         BEGIN
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0020',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 312
--vložení _EXT_RS_evidence_jedenkrat do TabPostup_EXT do třetí operace
          DECLARE @ID_radku INT = (SELECT SCOPE_IDENTITY())
          INSERT INTO TabPostup_EXT (ID, _EXT_RS_evidence_jedenkrat)
          SELECT @ID_radku, 1;
          END;
END
/*7.2.2023 na přání BV - přenos generování do VP zrušeno
--vložení čtvrté operace
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0030')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0030',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 558
END
*/
/*31.10.2024 na přání OM zrušeno
--vložení páté operace
BEGIN
         IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDHlavicka AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0040')
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
                          SELECT @IDHlavicka,@IDZmena,1,N'0040',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,ttp.MeziOperCas,ttp.MeziOperCas_T,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
                          FROM TabTypPostup ttp
                          WHERE ttp.ID = 324
END
*/
--nastavení čísla operace
DECLARE @Operace_bef NCHAR(4) = (SELECT ISNULL(MAX(CASE WHEN ISNUMERIC(LTRIM(RTRIM(Operace))+N'.E0')=1 AND LEN(LTRIM(Operace))<=9 THEN CONVERT(int, CONVERT(numeric(19,6), Operace)) END),0) + 10 
                                                             FROM TabPostup 
                                                             WHERE ISNUMERIC(LTRIM(RTRIM(Operace))+N'.E0')=1 AND LEN(LTRIM(Operace))<=9  AND dilec=@IDHlavicka AND (IDVarianta IS NULL OR IDVarianta=0) AND ZmenaOd=@IDZmena)
DECLARE @Operace NCHAR(4) = (SELECT RIGHT(RTRIM('0000'+ISNULL(@Operace_bef,'')),4))

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
--dohledání profese z materiálové operace v ext.informacích na kartě materiálu
DECLARE @MaterialOperationProfession NVARCHAR(30) = (SELECT tvp.ID
                                                                                                         FROM TabKvazby tkv
                                                                                                         LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
                                                                                                         LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
                                                                                                         LEFT OUTER JOIN TabTypPostup ttp ON ttp.Cislo = tkze._EXT_RS_material_operation
                                                                                                         LEFT OUTER JOIN TabTypPostupVyrProfese ttpvp ON ttpvp.IDPostup = ttp.ID
                                                                                                         LEFT OUTER JOIN TabVyrProfese tvp ON tvp.ID=ttpvp.IDVyrProfese
                                                                                                         WHERE tkv.ID = @ID)
BEGIN
--podmínka na existenci postupu k aktuálnímu řádku kusovníku
IF EXISTS
(SELECT *
FROM TabKVazby tkv
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
LEFT OUTER JOIN TabPostup tp ON tp.dilec = tkv.vyssi AND tp.ZmenaOd = @IDZmena
LEFT OUTER JOIN TabPostup_EXT tpe ON tpe.ID = tp.ID
WHERE tkv.ID = @ID AND tpe._EXT_RS_material_operation_postup = tkze._EXT_RS_material_operation)

BEGIN
   BEGIN
      UPDATE TabPostup SET TAC_Obsluhy = TAC_Obsluhy+@ItemTime, TAC = TAC+@ItemTime, TAC_Obsluhy_J = TAC_Obsluhy_J+@ItemTime, TAC_J = TAC_J+@ItemTime
                                   WHERE TabPostup.ID = (SELECT tp.ID
                                                                              FROM TabPostup tp
                                                                              JOIN TabPostup_EXT tpe ON tpe.ID = tp.ID
                                                                              JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                                                                              JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
                                                                              JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
                                                                              WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tkze._EXT_RS_material_operation = tpe._EXT_RS_material_operation_postup AND tp.ZmenaDo IS NULL)
   END
   BEGIN
         UPDATE TabKvazby SET Operace = (SELECT tp.Operace FROM TabKVazby tkv
         LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
         LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
         LEFT OUTER JOIN TabPostup tp ON tp.dilec = tkv.vyssi AND tp.ZmenaOd = @IDZmena
         LEFT OUTER JOIN TabPostup_EXT tpe ON tpe.ID = tp.ID
         WHERE tkv.ID = @ID AND tpe._EXT_RS_material_operation_postup = tkze._EXT_RS_material_operation)
         WHERE TabKVazby.ID = @ID
   END
--přičtení přípravného času operace do operace TP - příprava pracoviště krát 0,4
    BEGIN
		UPDATE TabPostup SET TBC_Obsluhy = TBC_Obsluhy+(@ItemTime*0.4), TBC = TBC+(@ItemTime*0.4)
                                   WHERE (TabPostup.ID = (SELECT tp.ID
                                                                        FROM TabPostup tp
                                                                        JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                                                                        WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.nazev LIKE N'TP - Příprava pracoviště%')
			      AND TabPostup.nazev LIKE N'TP - Příprava pracoviště%')
   END
END
ELSE
--pokud neexistuje postup k aktuálnímu řádku kusovníku, generuje se nová operace
BEGIN
   BEGIN
         INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni)
                          SELECT @IDHlavicka,@IDZmena,1,@Operace,ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,tkve._EXT_RS_item_time,1,tkve._EXT_RS_item_time,1,1,tkve._EXT_RS_item_time,tkve._EXT_RS_item_time,1,1,ISNULL(ttp.MeziOperCas,0),ISNULL(ttp.MeziOperCas_T,2),ttp.Poznamka,@MaterialOperationType
                          FROM TabKvazby tkv
                          LEFT OUTER JOIN TabKvazby_EXT tkve ON tkve.ID = tkv.ID
                          LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
                          LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
                          LEFT OUTER JOIN TabTypPostup ttp ON ttp.Cislo = tkze._EXT_RS_material_operation
                          WHERE tkv.ID = @ID
   END
   BEGIN
         UPDATE TabKvazby SET Operace = @Operace WHERE TabKvazby.ID = @ID
   END
--zjištění ID právě vložené operace   
   DECLARE @IDPostup_INS INT = (SELECT SCOPE_IDENTITY())
--přičtení přípravného času operace do operace TP - příprava pracoviště krát 0,4
   BEGIN
		UPDATE TabPostup SET TBC_Obsluhy = TBC_Obsluhy+(@ItemTime*0.4), TBC = TBC+(@ItemTime*0.4)
                                   WHERE (TabPostup.ID = (SELECT tp.ID
                                                                        FROM TabPostup tp
                                                                        JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                                                                        WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.nazev LIKE N'TP - Příprava pracoviště%')
			      AND TabPostup.nazev LIKE N'TP - Příprava pracoviště%')
   END
--vložení čísla materiálové operace do ext.pole v technol.postupu   
   BEGIN
         INSERT INTO TabPostup_EXT (ID,_EXT_RS_material_operation_postup)
		   SELECT tp.ID, tkze._EXT_RS_material_operation
		   FROM TabPostup tp
                                        JOIN TabKvazby tkv ON tkv.Operace = tp.Operace AND tkv.vyssi = @IDHlavicka AND tkv.ZmenaOd = @IDZmena
                                        JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkv.nizsi AND tkv.ZmenaOd = @IDZmena
                                        WHERE tp.dilec = @IDHlavicka AND tkv.Operace = @Operace AND tkv.vyssi =@IDHlavicka AND tp.ZmenaOd = @IDZmena
   END
--vložení profesí do nově vložené operace z profesí na materiálové typové operaci
   BEGIN
         INSERT INTO TabPostupVyrProfese (IDPostup, IDVyrProfese, Mnozstvi, ParKP_PocetSoucaneObsluhStroju, ID1)
                          SELECT @IDPostup_INS,@MaterialOperationProfession,1,1,0
   END
END
END

--MŽ 14.11.2022
--dodatečné násobení časů TAC  1+(celkový čas/500)
DECLARE @Oznacenych SMALLINT, @Aktualni SMALLINT
-- Počet řádků a aktuálně zpracovávaný řádek načteme do proměnných
SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM'
SELECT @Aktualni = MAX(Cislo) FROM #TabExtKomPar WHERE Popis = 'PRECHOD'
-- Smažeme při prvním průchodu možná existující původní vybrané záznamy
IF @Aktualni = 1 OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
   DELETE FROM OznaceneRadky WHERE Ident = @@SPID
-- Při každém průchodu vložíme do tabulky pro označené řádky potřebné atributy
INSERT INTO OznaceneRadky(ID,Ident) VALUES(@ID,@@SPID)
-- Samotné tělo procedury při průchodu posledním záznamem
IF @Aktualni = @Oznacenych OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
BEGIN
DECLARE @TotalOperationTime NUMERIC(19,6),@Koef NUMERIC(19,6)
SELECT @TotalOperationTime=(SELECT SUM(tp.TAC_H)
FROM TabPostup tp WITH(NOLOCK)
  LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON tp.ZmenaOd=VPostupCZmenyOd.ID
  LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON tp.ZmenaDo=VPostupCZmenyDo.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tp.pracoviste=tcp.ID
  LEFT OUTER JOIN TabCPraco_EXT tcpe WITH(NOLOCK) ON tcpe.ID=tcp.ID
WHERE
(tp.dilec=@IDHlavicka AND (@IDZmena>0 AND tp.zmenaOd=@IDZmena OR  @IDZmena=0 AND VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()
AND  (VPostupCZmenyDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) ) AND (tcp.IDTabStrom=N'200' OR (tcp.IDTabStrom LIKE N'2002%' AND (ISNULL(tcpe._EXT_RS_wokplaceQA,0)=0 AND ISNULL(tcpe._EXT_RS_workplaceWH,0)=0)))))
SELECT @Koef=(1+(@TotalOperationTime/500))

  BEGIN
      UPDATE TabPostup SET TAC_Obsluhy = TAC_Obsluhy*@Koef, TAC = TAC*@Koef, TAC_Obsluhy_J = TAC_Obsluhy_J*@Koef, TAC_J = TAC_J*@Koef
						   WHERE TabPostup.ID IN (SELECT tp.ID
								   FROM TabPostup tp
								   LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON tp.ZmenaOd=VPostupCZmenyOd.ID
								   LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON tp.ZmenaDo=VPostupCZmenyDo.ID
								   LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tp.pracoviste=tcp.ID
								   LEFT OUTER JOIN TabCPraco_EXT tcpe WITH(NOLOCK) ON tcpe.ID=tcp.ID
								   WHERE (tp.dilec=@IDHlavicka AND (@IDZmena>0 AND tp.zmenaOd=@IDZmena OR  @IDZmena=0 AND VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()
								   AND  (VPostupCZmenyDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) ) AND (tcp.IDTabStrom=N'200' OR (tcp.IDTabStrom LIKE N'2002%' AND (ISNULL(tcpe._EXT_RS_wokplaceQA,0)=0 AND ISNULL(tcpe._EXT_RS_workplaceWH,0)=0)))))
   END

--nakonec ještě obligátní:
--přičtení přípravného času operace do operace TP - příprava pracoviště krát 0,4
    BEGIN
		UPDATE TabPostup SET TBC_Obsluhy = TBC_Obsluhy*@Koef, TBC = TBC*@Koef
                                   WHERE (TabPostup.ID = (SELECT tp.ID
														 FROM TabPostup tp
                                                         LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON tp.ZmenaOd=VPostupCZmenyOd.ID
														 LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON tp.ZmenaDo=VPostupCZmenyDo.ID
														 LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tp.pracoviste=tcp.ID
														 LEFT OUTER JOIN TabCPraco_EXT tcpe WITH(NOLOCK) ON tcpe.ID=tcp.ID
														 WHERE (tp.dilec=@IDHlavicka AND (@IDZmena>0 AND tp.zmenaOd=@IDZmena OR  @IDZmena=0 AND VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()
								   AND  (VPostupCZmenyDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) ) AND tp.nazev LIKE N'TP - Příprava pracoviště%')
			      AND TabPostup.nazev LIKE N'TP - Příprava pracoviště%'))
   END
--nově vložený výpočet času operací 09 a 10. 
--09: čas = celková metráže x 0.6666, tj. sečtu mnozstviseztratou, kde MJ=m a vynasobím
--10: čas = celkové ks x 0.4545, tj. sečtu mnozstviseztratou, kde MJ<>m a vynásobím
DECLARE @CasMetraz NUMERIC(19,6), @CasKusy NUMERIC(19,6)
SELECT @CasMetraz=(SELECT ISNULL(SUM(tkv.mnozstviSeZtratou),0)
FROM TabKvazby tkv WITH(NOLOCK)
LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON tkv.ZmenaOd=VPostupCZmenyOd.ID
LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON tkv.ZmenaDo=VPostupCZmenyDo.ID
LEFT OUTER JOIN TabKmenZbozi tkzn WITH(NOLOCK) ON tkv.nizsi=tkzn.ID
WHERE
(tkv.vyssi=@IDHlavicka AND (@IDZmena>0 AND tkv.zmenaOd=@IDZmena OR  @IDZmena=0 AND VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()
AND  (VPostupCZmenyDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) ) AND (tkzn.MJEvidence=N'm')))
SELECT @CasKusy=(SELECT ISNULL(SUM(tkv.mnozstviSeZtratou),0)
FROM TabKvazby tkv WITH(NOLOCK)
LEFT OUTER JOIN TabCzmeny VPostupCZmenyOd WITH(NOLOCK) ON tkv.ZmenaOd=VPostupCZmenyOd.ID
LEFT OUTER JOIN TabCzmeny VPostupCZmenyDo WITH(NOLOCK) ON tkv.ZmenaDo=VPostupCZmenyDo.ID
LEFT OUTER JOIN TabKmenZbozi tkzn WITH(NOLOCK) ON tkv.nizsi=tkzn.ID
WHERE
(tkv.vyssi=@IDHlavicka AND (@IDZmena>0 AND tkv.zmenaOd=@IDZmena OR  @IDZmena=0 AND VPostupCZmenyOd.platnostTPV=1 AND VPostupCZmenyOd.datum<=GETDATE()
AND  (VPostupCZmenyDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (VPostupCZmenyDo.platnostTPV=1 AND VPostupCZmenyDo.datum>GETDATE())) ) AND (tkzn.MJEvidence<>N'm')))
--uložení času do operací
UPDATE TabPostup SET TAC_Obsluhy = @CasMetraz*0.6666, TAC = @CasMetraz*0.6666, TAC_Obsluhy_J = @CasMetraz*0.6666, TAC_J = @CasMetraz*0.6666
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0009')
UPDATE TabPostup SET TAC_Obsluhy = @CasKusy*0.4545, TAC = @CasKusy*0.4545, TAC_Obsluhy_J = @CasKusy*0.4545, TAC_J = @CasKusy*0.4545
WHERE TabPostup.ID = (SELECT tp.ID
                            FROM TabPostup tp
                            JOIN TabKvazby tkv ON tkv.vyssi = tp.dilec
                            WHERE tkv.vyssi = @IDHlavicka AND tkv.ID = @ID AND tp.ZmenaDo IS NULL AND tp.Operace = N'0010')
END;
GO

