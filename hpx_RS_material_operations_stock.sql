USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_operations_stock]    Script Date: 26.06.2025 13:43:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_material_operations_stock]
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
GO

