USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniVP_RSSKURC]    Script Date: 30.06.2025 8:45:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniVP_RSSKURC]
@IDPrikaz INT
AS

DECLARE @TypDilce NVARCHAR(2);
DECLARE @IDTypOperace INT;
DECLARE @IDZakazky INT;
DECLARE @IDDilce INT;
DECLARE @IDDilceNewVP INT;
DECLARE @TerminVPRS DATETIME;
DECLARE @MnoPrikazRS NUMERIC(19,6);
DECLARE @IDOper INT;
DECLARE @DatumOper DATETIME;
DECLARE @NewIDPrikaz INT;
DECLARE @NewIDOper INT;
DECLARE @retmaznapojeni INT;
DECLARE @retmazoper INT;
DECLARE @Odchylka INT;
DECLARE @SumTBC NUMERIC(19,6);
DECLARE @SumTAC NUMERIC(19,6);
DECLARE @SumTEC NUMERIC(19,6);
DECLARE @KoefDilce NUMERIC(19,6);

--cvičná deklarace
--DECLARE @IDPrikaz INT=174011;
SET @TerminVPRS=(SELECT Plan_ukonceni FROM TabPrikaz WHERE ID=@IDPrikaz)
SET @IDDilce=(SELECT IDTabKmen FROM TabPrikaz WHERE ID=@IDPrikaz)
SET @IDDilceNewVP=(SELECT tkz.ID FROM RayService5.dbo.TabKmenZbozi tkz LEFT OUTER JOIN TabKmenZbozi tkzRS ON tkzRS.SkupZbo=tkz.SkupZbo AND tkzRS.RegCis=tkz.RegCis WHERE tkzRS.ID=@IDDilce)
SET @MnoPrikazRS=(SELECT kusy_zive FROM TabPrikaz WHERE ID=@IDPrikaz)
SET @KoefDilce=(SELECT ISNULL(tkze._KoefSK,1) FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDDilce)

--SELECT @IDDilce AS dilecRS, @IDDilceNewVP AS dilecRSSK, @TerminVPRS AS Plan_ukonceni

--založení VP
IF NOT EXISTS (SELECT tpsk.ID FROM RayService5.dbo.TabPrikaz_EXT tpsk WHERE tpsk._EXT_RS_IDPrikazRS=@IDPrikaz)
BEGIN
	EXEC @NewIDPrikaz=RayService5.dbo.hp_NewVyrobniPrikaz @IDDilce=@IDDilceNewVP, @kusy_zad=@MnoPrikazRS, @kusy_ciste=@MnoPrikazRS, @Rada='208', /*@IDZakazka=@IDZakazky,*/ @Plan_ukonceni=@TerminVPRS
	--zadání nového VP
	EXEC RayService5.dbo.hp_ZadaniPrikazuDoVyroby @IDPrikaz=@NewIDPrikaz, @OnlyPredzpracovani=0
	UPDATE RayService5.dbo.TabPrikaz_EXT SET _EXT_RS_IDPrikazRS=@IDPrikaz WHERE RayService5.dbo.TabPrikaz_EXT.ID=@NewIDPrikaz
END;

--vložení operace
BEGIN
	--vložení nové operace ceník(vd)
	SELECT @IDTypOperace = 3--CASE WHEN @TypDilce = 'M' THEN 381 WHEN @TypDilce = 'D' THEN 383 ELSE NULL END
	EXEC @NewIDOper=RayService5.dbo.hp_NewPozadavek_TabPrPostup @IDPrikaz=@NewIDPrikaz, @IDTypoveOperace=@IDTypOperace
	UPDATE RayService5.dbo.TabPrPostup SET Plan_ukonceni=@TerminVPRS WHERE ID=@NewIDOper
	SELECT @SumTBC=SUM(prp.TBC)*ISNULL(@KoefDilce,1), @SumTAC=SUM(prp.TAC)*ISNULL(@KoefDilce,1), @SumTEC=SUM(prp.TEC)*ISNULL(@KoefDilce,1)
	FROM TabPrPostup prp
	WHERE prp.IDOdchylkyDo IS NULL AND prp.Prednastaveno=1 AND prp.IDPrikaz=@IDPrikaz
	--aktualizujeme plánované časy
	UPDATE RayService5.dbo.TabPrPostup SET
	TAC_T=1,
	TAC_J_T=1,
	TAC_Obsluhy_J_T=1, 
	TAC=@SumTAC,-- CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END,
	TAC_J=@SumTAC, --CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END,
	TAC_Obsluhy=@SumTAC, --CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END,
	TAC_Obsluhy_J=@SumTAC, --CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END
	TBC_T=1,
	TBC=@SumTBC,
	TBC_Obsluhy=@SumTBC,
	TEC_T=1,
	TEC=@SumTEC,
	TEC_Obsluhy=@SumTEC
	WHERE ID=@NewIDOper
END;

GO

