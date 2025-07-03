USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_ITEMMASTER]    Script Date: 03.07.2025 12:58:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_ITEMMASTER] AS SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  CATEGORY=KZ.SKP, 
  ITEM_DESCRIPTION=LEFT(KZ.Nazev1, 200), 
  SAFETY_STOCK=(SELECT ISNULL(SUM(SS.Minimum),0.0) FROM TabStavSkladu SS WHERE SS.IDKmenZbozi=KZ.ID AND SS.IDSklad=N'100'), 
  UNIT_COST= CASE WHEN KZ.Dilec=1 THEN (SELECT ZK.Celkem FROM TabZKalkulace ZK WHERE ZK.Dilec=KZ.ID AND EXISTS(SELECT * FROM TabCZmeny Zod 
                                                                                                                         LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=ZK.zmenaDo) 
		   			                                                    				     											                       WHERE Zod.ID=ZK.zmenaOd AND Zod.platnost=1 AND Zod.datum<=convert(date,GETDATE()) AND 
			   																	                                                                                     (ZK.ZmenaDo IS NULL OR Zdo.platnost=0 OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()))) )) 
	                 WHEN KZ.Material=1 THEN (SELECT ISNULL(SS.Prumer,0.0) FROM TabStavSkladu SS WHERE SS.IDKmenZbozi=KZ.ID AND SS.IDSklad=N'100') 
                  WHEN KZ.VedProdukt=1 THEN (SELECT C.Cena FROM TabVedProduktCena C WHERE C.IDKmenZbozi=KZ.ID AND EXISTS(SELECT * FROM TabCZmeny Zod 
	                                                                                                                                   LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=C.zmenaDo) 
										   																		  	                                                                     WHERE Zod.ID=C.zmenaOd AND Zod.platnost=1 AND Zod.datum<=convert(date,GETDATE()) AND 
											   																		                                                                             (C.ZmenaDo IS NULL OR Zdo.platnost=0 OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()))) )) 
                  ELSE 0.0 
             END, 
  ITEM_TYPE=dbo.GEF_APSLogis_VlozOddelovac(CASE WHEN KZ.dilec=1 THEN (CASE PD.TypDilce WHEN 0 THEN N'FINÁL' ELSE N'POLOTOVAR' END) WHEN KZ.material=1 THEN N'MATERIÁL' END, CASE WHEN KZ.VedProdukt=1 THEN N'VEDLEJŠÍ PRODUKT' ELSE '' END), 
  BASE_UOM=KZ.MJEvidence, 
  MFG_CUMUL_WINDOW=KZ_E._EXT_RS_AccumDays 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=KZ.ID) 
  LEFT OUTER JOIN TabKmenZbozi_Ext KZ_E ON (KZ_E.ID=KZ.ID) 
WHERE KZ.Blokovano=0 AND (KZ.dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0) OR KZ.VedProdukt=1) AND KZ.Sluzba=0 AND 
      SZ_E._EXT_RS_Logis=1 
GO

