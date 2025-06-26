USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ImportOutJagging]    Script Date: 26.06.2025 15:46:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ImportOutJagging]
AS

INSERT INTO RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERJAGGING
(Cislo_VP
,ID_Vyrobku
,Obj_Mnozstvi
,PST
,PET
,LPST
,EPST
,ID_Zakazek
,ID_Zakazky
,Rada_VP
,Pokryto
,Typ_Dodavky
,ID_Dodavky
,ID_Materialu
,Alokovano
,Doporuceni
,Zpozdeni
,T_Dodani
,T_Potreby
,Mn_Objednane
,Mn_Nevyuzite
,Suma_Potreb
,Suma_NO
,Suma_NNO
,T_VystaveniPP
,T_PotrebyPP
,Mn_ObjednanePP
)

SELECT mo.MFG_ORDER_ID AS 'Číslo_VP', mo.ITEM_ID AS 'ID_Výrobku', mo.QTY_ORDERED AS 'Obj_Množství', mo.PLANNED_START_TIME AS 'PST', mo.PLANNED_END_TIME AS 'PET', mo.LPST AS 'LPST', mo.EPST AS 'EPST'
, mopDOS.STRING_VALUE AS 'ID_Zakázek'
, mopDO.STRING_VALUE AS 'ID_Zakázky'
, mopRVP.STRING_VALUE AS 'Řada_VP'
, mopPKR.BOOL_VALUE AS 'Pokryto'
, pg.SUPPLY_TYPE AS 'Typ_Dodávky', pg.SUPPLY_ID AS 'ID_Dodávky', pg.ITEM_ID AS 'ID_Materiálu', pg.QTY_ALLOCATED AS 'Alokováno'
, pmp.PROPOSAL_TEXT AS 'Doporučení', pmp.LATENESS AS 'Zpoždění', pmp.AVAILABILITY_DATE AS 'T_Dodání', pmp.REQUIRED_DATE AS 'T_Potřeby', pmp.QTY_OPEN AS 'Mn_Objednané', pmp.QTY_UNALLOCATED AS 'Mn_Nevyužité'
, isnull(popTC.NUMERIC_VALUE,ppTC.NUMERIC_VALUE) AS 'Suma_Potřeb'
, isnull(popTPO.NUMERIC_VALUE,ppTPO.NUMERIC_VALUE) AS 'Suma_NO'
, isnull(popTPOP.NUMERIC_VALUE,ppTPOP.NUMERIC_VALUE) AS 'Suma_NNO'
, pp.ORDER_BY_DATE AS 'T_VystaveníPP', pp.REQUIRED_DATE AS 'T_PotřebyPP'
, pp.QTY_ORDERED AS 'Mn_ObjednanéPP'
FROM OUT_MANUFACTURINGORDER mo --58,467
LEFT JOIN OUT_MANUFACTURINGORDERPROPERTY mopDO WITH(NOLOCK) ON (mo.MFG_ORDER_ID=mopDO.MFG_ORDER_ID and mopDO.ATTRIBUTE_NAME = 'RAY_Zakazka' )                                        -- 58,467
LEFT JOIN OUT_MANUFACTURINGORDERPROPERTY mopDOS WITH(NOLOCK) ON (mo.MFG_ORDER_ID=mopDOS.MFG_ORDER_ID and mopDOS.ATTRIBUTE_NAME = 'DEMAND_ORDER_IDS' )                -- 58,467
LEFT JOIN OUT_MANUFACTURINGORDERPROPERTY mopRVP WITH(NOLOCK) ON (mo.MFG_ORDER_ID=mopRVP.MFG_ORDER_ID and mopRVP.ATTRIBUTE_NAME = 'RAY_RadaVP' )                                 -- 58,467
LEFT JOIN OUT_MANUFACTURINGORDERPROPERTY mopPKR WITH(NOLOCK) ON (mo.MFG_ORDER_ID=mopPKR.MFG_ORDER_ID and mopPKR.ATTRIBUTE_NAME = 'RAY_Potvrzeno' )                           -- 58,467
LEFT JOIN OUT_MFGORDERPEGGING pg WITH(NOLOCK) ON (pg.DEMAND_ID=mo.MFG_ORDER_ID)                                                                                                                                                                                                                                                                                                         -- 54,963 inner VP v 984,622 pegging
LEFT JOIN OUT_PURCHASEMODIFPROPOSAL pmp WITH(NOLOCK) ON (pg.SUPPLY_ID=pmp.PURCHASE_ORDER_ID and pg.SUPPLY_TYPE='PO')
LEFT JOIN OUT_PURCHASEORDERPROPERTY popTC WITH(NOLOCK) ON (pg.SUPPLY_ID=popTC.PURCHASE_ORDER_ID and pg.SUPPLY_TYPE='PO' and popTC.ATTRIBUTE_NAME='RAY_IM_TotalConsumptions')
LEFT JOIN OUT_PURCHASEORDERPROPERTY popTPO WITH(NOLOCK) ON (pg.SUPPLY_ID=popTPO.PURCHASE_ORDER_ID and pg.SUPPLY_TYPE='PO' and popTPO.ATTRIBUTE_NAME='RAY_IM_TotalPOSupplies')
LEFT JOIN OUT_PURCHASEORDERPROPERTY popTPOP WITH(NOLOCK) ON (pg.SUPPLY_ID=popTPOP.PURCHASE_ORDER_ID and pg.SUPPLY_TYPE='PO' and popTPOP.ATTRIBUTE_NAME='RAY_IM_TotalPOPSupplies')
LEFT JOIN OUT_PURCHASEORDERPROPOSAL pp WITH(NOLOCK) ON (pg.SUPPLY_ID=pp.PROPOSAL_ID and pg.SUPPLY_TYPE='PP')
LEFT JOIN OUT_PURCHASEORDERPROPOSALPROP ppTC WITH(NOLOCK) ON (pg.SUPPLY_ID=ppTC.PROPOSAL_ID and pg.SUPPLY_TYPE='PP' and ppTC.ATTRIBUTE_NAME='RAY_IM_TotalConsumptions')
LEFT JOIN OUT_PURCHASEORDERPROPOSALPROP ppTPO WITH(NOLOCK) ON (pg.SUPPLY_ID=ppTPO.PROPOSAL_ID and pg.SUPPLY_TYPE='PP' and ppTPO.ATTRIBUTE_NAME='RAY_IM_TotalPOSupplies')
LEFT JOIN OUT_PURCHASEORDERPROPOSALPROP ppTPOP WITH(NOLOCK) ON (pg.SUPPLY_ID=ppTPOP.PROPOSAL_ID and pg.SUPPLY_TYPE='PP' and ppTPOP.ATTRIBUTE_NAME='RAY_IM_TotalPOPSupplies')
--where mopDOS.STRING_VALUE like '%20244305|8017997%'
GO

