USE [RayService]
GO

/****** Object:  View [dbo].[hvw_778834519D104A5AB8F06D491A970757]    Script Date: 03.07.2025 11:22:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_778834519D104A5AB8F06D491A970757] AS select SAPERTA_TAB_TRIGGER.ID, SAPERTA_TAB_TRIGGER.NAZEV, SAPERTA_TAB_TRIGGER.DEFINICE,SAPERTA_TAB_TRIGGER.systemovy, SAPERTA_TAB_TRIGGER.skupina,
(SUBSTRING(REPLACE(SUBSTRING(cast(SAPERTA_TAB_TRIGGER.DEFINICE as nvarchar(255)),1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) as DEFINICE_255,
SAPERTA_TAB_TRIGGER.AKTIVNI, SAPERTA_TAB_TRIGGER.AUTOR, SAPERTA_TAB_TRIGGER.DATPORIZENI, SAPERTA_TAB_TRIGGER.ZMENIL, 
SAPERTA_TAB_TRIGGER.DATZMENY, SAPERTA_TAB_TRIGGER.BlokovaniEditoru, (case when  tr.name is null and trigfunkce is null then 1 when SAPERTA_TAB_TRIGGER.trigfunkce is not  null and object_id( SAPERTA_TAB_TRIGGER.nazev,'FN') is null then 1 
when SAPERTA_TAB_TRIGGER.trigfunkce is not  null and object_id( SAPERTA_TAB_TRIGGER.nazev,'FN') is not null then 3 when tr.is_disabled=1 then 2 else 3 end) as StavVDatabazi, 
SAPERTA_TAB_TRIGGER.TrigFunkce,
left(  (case when  SAPERTA_TAB_TRIGGER.TrigFunkce is not null then null else substring(replace(cast(definice as nvarchar(1000)),'  ',' '),charindex(nazev,replace(definice,'  ',' '))+len(nazev)+12,130) end) ,
charindex(']',(case when  SAPERTA_TAB_TRIGGER.TrigFunkce is not null then null else substring(replace(cast(definice as nvarchar(1000)),'  ',' '),charindex(nazev,replace(definice,'  ',' '))+len(nazev)+12,130) end))-1
)  as Tabulka 
from SAPERTA_TAB_TRIGGER
left outer join sys.triggers tr on tr.name=SAPERTA_TAB_TRIGGER.Nazev
GO

