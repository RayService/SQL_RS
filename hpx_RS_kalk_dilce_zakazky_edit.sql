USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kalk_dilce_zakazky_edit]    Script Date: 26.06.2025 11:40:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kalk_dilce_zakazky_edit]
@mat NUMERIC(19,6)
,@koop NUMERIC(19,6)
,@TAC_KC NUMERIC(19,6)
,@TBC_KC NUMERIC(19,6)
,@TEC_KC NUMERIC(19,6)
,@naradi NUMERIC(19,6)
,@OPN NUMERIC(19,6)
,@VedProdukt NUMERIC(19,6)
,@mat_P NUMERIC(19,6)
,@koop_P NUMERIC(19,6)
,@TAC_KC_P NUMERIC(19,6)
,@TBC_KC_P NUMERIC(19,6)
,@TEC_KC_P NUMERIC(19,6)
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
,@TEC_T INT,
@ID INT
AS
BEGIN
UPDATE tzkk SET
mat=@mat
,koop=@koop
,TAC_KC=@TAC_KC
,TBC_KC=@TBC_KC
,TEC_KC=@TEC_KC
,rezieS=(@TAC_KC+@TBC_KC+@TEC_KC)*4
,naradi=@naradi
,OPN=@OPN
,VedProdukt=@VedProdukt
,mat_P=@mat_P
,koop_P=@koop_P
,TAC_KC_P=@TAC_KC_P
,TBC_KC_P=@TBC_KC_P
,TEC_KC_P=@TEC_KC_P
,rezieS_P=(@TAC_KC_P+@TBC_KC_P+@TEC_KC_P)*4
,OPN_P=@OPN_P
,VedProdukt_P=@VedProdukt_P
,naradi_P=@naradi_P
,matA=@matA
,matB=@matB
,matC=@matC
,matA_P=@matA_P
,matB_P=@matB_P
,matC_P=@matC_P
,TAC=@TAC
,TAC_T=@TAC_T
,TBC=@TBC
,TBC_T=@TBC_T
,TEC=@TEC
,TEC_T=@TEC_T
FROM Tabx_RS_ZKalkulace tzkk
WHERE ID=@ID
END
GO

