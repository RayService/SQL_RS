USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kalk_dilce_zakazky_new]    Script Date: 26.06.2025 11:39:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kalk_dilce_zakazky_new] 
@Dilec INT
, @CisloZakazky NVARCHAR(15)
, @mat NUMERIC(19,6)
,@koop NUMERIC(19,6)
,@TAC_KC NUMERIC(19,6)
,@TBC_KC NUMERIC(19,6)
,@TEC_KC NUMERIC(19,6)
--,@rezieS NUMERIC(19,6)
,@naradi NUMERIC(19,6)
,@OPN NUMERIC(19,6)
,@VedProdukt NUMERIC(19,6)
,@mat_P NUMERIC(19,6)
,@koop_P NUMERIC(19,6)
,@TAC_KC_P NUMERIC(19,6)
,@TBC_KC_P NUMERIC(19,6)
,@TEC_KC_P NUMERIC(19,6)
--,@rezieS_P NUMERIC(19,6)
,@OPN_P NUMERIC(19,6)
,@VedProdukt_P NUMERIC(19,6)
,@naradi_P NUMERIC(19,6)
,@matA NUMERIC(19,6)
,@matB NUMERIC(19,6)
,@matC NUMERIC(19,6)
,@matA_P NUMERIC(19,6)
,@matB_P NUMERIC(19,6)
,@matC_P NUMERIC(19,6)
,@TAC NUMERIC(19,6)
,@TAC_T INT
,@TBC  NUMERIC(19,6)
,@TBC_T INT
,@TEC NUMERIC(19,6)
,@TEC_T INT
AS
IF NOT EXISTS (SELECT * FROM Tabx_RS_ZKalkulace WHERE CisloZakazky=@CisloZakazky AND Dilec=@Dilec)
BEGIN
INSERT INTO Tabx_RS_ZKalkulace (Dilec,mat,koop,TAC_KC,TBC_KC,TEC_KC,rezieS,naradi,OPN,VedProdukt,mat_P,koop_P,TAC_KC_P,TBC_KC_P,TEC_KC_P,rezieS_P,OPN_P,VedProdukt_P,naradi_P,matA
,matB,matC,matA_P,matB_P,matC_P,CisloZakazky,TAC,TAC_T,TBC,TBC_T,TEC,TEC_T)
SELECT @Dilec,@mat,@koop,@TAC_KC,@TBC_KC,@TEC_KC,/*@rezieS*/(@TAC_KC+@TBC_KC+@TEC_KC)*4,@naradi,@OPN,@VedProdukt,@mat_P,@koop_P,@TAC_KC_P,@TBC_KC_P,@TEC_KC_P,/*@rezieS_P*/(@TAC_KC_P+@TBC_KC_P+@TEC_KC_P)*4,@OPN_P,@VedProdukt_P,@naradi_P,@matA
,@matB,@matC,@matA_P,@matB_P,@matC_P,@CisloZakazky,@TAC,@TAC_T,@TBC,@TBC_T,@TEC,@TEC_T
END
ELSE
BEGIN
RAISERROR('Nelze vložit duplicitní kombinaci dílec + zakázka',16,1)
RETURN
END;
GO

