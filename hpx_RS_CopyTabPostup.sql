USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CopyTabPostup]    Script Date: 26.06.2025 13:35:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_CopyTabPostup]
@Pomer NUMERIC(19,6),
@CisOper NVARCHAR(4),
@Pracoviste INT,
@ID INT
AS
--vložení kopie operace do TPV
--poměr nesmí být větší než 1 a hodnota platí pro novou operaci. Na původní operaci se dá čas 1-@Pomer
--pracoviště vybírat z číselníku nových pracovišť (20002%)
--číslo operace předgenerovat standardním selectem v HEO
--cvičné deklarace
/*
DECLARE @Pomer NUMERIC(19,6)=0.7  --poměr nesmí být větší než 1 a hodnota platí pro novou operaci. Na původní operaci se dá čas 1-@Pomer
DECLARE @CisOper NVARCHAR(4)='19'
DECLARE @Pracoviste INT=76  --pracoviště vybírat z číselníku
DECLARE @ID INT=7532929*/
--ostrá deklarace
DECLARE @IDDilce INT, @IDZmena INT, @Operace NCHAR(4), @IDPostup_INS INT
DECLARE @TACOrig NUMERIC(19,6), @TBCOrig NUMERIC(19,6), @TECOrig NUMERIC(19,6), @TACUpr NUMERIC(19,6), @TBCUpr NUMERIC(19,6), @TECUpr NUMERIC(19,6), @TACNew NUMERIC(19,6), @TBCNew NUMERIC(19,6), @TECNew NUMERIC(19,6);
SET @Operace = (SELECT RIGHT(RTRIM('0000'+ISNULL(@CisOper,'')),4))
SELECT @IDZmena=ZmenaOd, @IDDilce=dilec, @TACOrig=TAC, @TBCOrig=TBC, @TECOrig=TEC
FROM TabPostup
WHERE ID=@ID
--kontrola na hodnotu poměru
IF @Pomer>=1
BEGIN
RAISERROR('Hodnota poměru musí být menší než 1, nelze vložit.',16,1)
RETURN
END;
--kontrola na existující operaci
IF @Operace IN (SELECT Operace FROM TabPostup tp WHERE tp.ZmenaOd=@IDZmena AND tp.dilec=@IDDilce)
BEGIN
RAISERROR('Číslo operace je již na dílci použito, nelze vložit.',16,1)
RETURN
END;
SELECT @IDZmena, @Operace

INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
SELECT @IDDilce,@IDZmena,tp.DavkaTPV,@Operace,tp.nazev+'-2',@Pracoviste,tp.tarif,tp.TAC_Obsluhy,tp.TAC_Obsluhy_T,tp.TAC,tp.TAC_T,tp.NasobekTAC,tp.TAC_J,tp.TAC_Obsluhy_J,tp.TAC_J_T,tp.TAC_Obsluhy_J_T,tp.MeziOperCas,tp.MeziOperCas_T,tp.Poznamka,tp.TypOznaceni,tp.typ
FROM TabPostup tp
WHERE tp.ID = @ID
SET @IDPostup_INS=(SELECT SCOPE_IDENTITY())
--úprava času
SET @TACUpr=@TACOrig*(1-@Pomer)
SET @TBCUpr=@TBCOrig*(1-@Pomer)
SET @TECUpr=@TECOrig*(1-@Pomer)
SET @TACNew=@TACOrig*@Pomer
SET @TBCNew=@TBCOrig*@Pomer
SET @TECNew=@TECOrig*@Pomer
UPDATE TabPostup SET 
TAC_Obsluhy=@TACUpr, TAC=@TACUpr, TAC_Obsluhy_J=@TACUpr, TAC_J=@TACUpr,
TBC_Obsluhy=@TBCUpr, TBC=@TBCUpr,
TEC_Obsluhy=@TECUpr, TEC=@TECUpr
WHERE TabPostup.ID=@ID

UPDATE TabPostup SET
TAC_Obsluhy=@TACNew, TAC=@TACNew, TAC_Obsluhy_J=@TACNew, TAC_J=@TACNew,
TBC_Obsluhy=@TBCNew, TBC=@TBCNew,
TEC_Obsluhy=@TECNew, TEC=@TECNew
WHERE TabPostup.ID=@IDPostup_INS

--vložení profesí do nově vložené operace z profesí na materiálové typové operaci
BEGIN
	INSERT INTO TabPostupVyrProfese (IDPostup, IDVyrProfese, Mnozstvi, ParKP_PocetSoucaneObsluhStroju, ID1)
	SELECT @IDPostup_INS,pvp.IDVyrProfese,pvp.Mnozstvi,pvp.ParKP_PocetSoucaneObsluhStroju,pvp.ID1
	FROM TabPostupVyrProfese pvp
	WHERE pvp.IDPostup=@ID
END
--úprava názvu původní operace
UPDATE TabPostup SET nazev=nazev+'-1' WHERE ID=@ID

GO

