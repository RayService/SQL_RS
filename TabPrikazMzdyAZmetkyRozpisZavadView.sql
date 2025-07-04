USE [RayService]
GO

/****** Object:  View [dbo].[TabPrikazMzdyAZmetkyRozpisZavadView]    Script Date: 04.07.2025 12:38:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPrikazMzdyAZmetkyRozpisZavadView] AS 
SELECT ID=R.ID, R.IDZmetku, IDRozpisuZavad=R.ID, 
       EvidenceZmetku=convert(bit, CASE WHEN R.kusy_zmet_opr+R.kusy_zmet_opr_IO+R.kusy_zmet_neopr>0 THEN 1 ELSE 0 END), 
       IDVyrCis=ISNULL(R.IDVyrCis,MZ.IDVyrCis), R.kusy_odv, R.Operace_odv, 
       R.IDZavady, R.kusy_zmet_opr, R.kusy_zmet_opr_IO, R.kusy_zmet_neopr, R.Operace_zmet_opr, R.Operace_zmet_opr_IO, R.Operace_zmet_neopr, PlatitMzduZaZmetky=convert(bit,ISNULL(R.PlatitMzduZaZmetky,MZ.PlatitMzduZaZmetky)), MZ.TypMzdy, 
       R.ZbyvaOpravit, R.Kusy_zmet_opravene, R.ZbyvaZajistitNeoprZmet, R.ZajisteneKusyNeoprZmet, R.ZbyvaOdvestNaSkladNeshod, R.Kusy_zmet_OdvedNaSkladNeshod, 
       R.mat_real, R.matA_real, R.matB_real, R.matC_real, R.MatRezie_real, R.koop_real, R.mzda_real, R.rezieS_real, R.rezieP_real, R.ReziePrac_real, R.NakladyPrac_real, R.OPN_real, R.VedProdukt_real, R.naradi_real, R.NespecNakl_real, R.Cena_real, 
       R.Poznamka, R.Autor, R.DatPorizeni, R.Zmenil, R.DatZmeny 
  FROM TabPrikazMzdyAZmetkyRozpisZavad R 
    INNER JOIN TabPrikazMzdyAZmetky MZ ON (MZ.ID=R.IDZmetku) 
UNION ALL 
SELECT ID=ISNULL((-1)*MZ.ID,0), IDZmetku=MZ.ID, IDRozpisuZavad=NULL, 
       EvidenceZmetku=convert(bit, CASE WHEN MZ.kusy_zmet_opr+MZ.kusy_zmet_opr_IO+MZ.kusy_zmet_neopr>0 THEN 1 ELSE 0 END), 
       MZ.IDVyrCis, MZ.kusy_odv, MZ.Operace_odv, 
       IDZavady=MZ.IDZavady, MZ.kusy_zmet_opr, MZ.kusy_zmet_opr_IO, MZ.kusy_zmet_neopr, MZ.Operace_zmet_opr, MZ.Operace_zmet_opr_IO, MZ.Operace_zmet_neopr, MZ.PlatitMzduZaZmetky, MZ.TypMzdy, 
       MZ.ZbyvaOpravit, MZ.Kusy_zmet_opravene, MZ.ZbyvaZajistitNeoprZmet, MZ.ZajisteneKusyNeoprZmet, MZ.ZbyvaOdvestNaSkladNeshod, MZ.Kusy_zmet_OdvedNaSkladNeshod, 
       PKN.mat_real, PKN.matA_real, PKN.matB_real, PKN.matC_real, PKN.MatRezie_real, PKN.koop_real, PKN.mzda_real, PKN.rezieS_real, PKN.rezieP_real, PKN.ReziePrac_real, PKN.NakladyPrac_real, PKN.OPN_real, PKN.VedProdukt_real, PKN.naradi_real, PKN.NespecNakl_real, PKN.Cena_real, 
       MZ.Poznamka, MZ.Autor, MZ.DatPorizeni, MZ.Zmenil, MZ.DatZmeny 
  FROM TabPrikazMzdyAZmetky MZ 
    LEFT OUTER JOIN TabPrikazKalkNaklady PKN ON (PKN.IDZmetku=MZ.ID) 
  WHERE NOT EXISTS(SELECT * FROM TabPrikazMzdyAZmetkyRozpisZavad R WHERE R.IDZmetku=MZ.ID)
GO

