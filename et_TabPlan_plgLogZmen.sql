USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_plgLogZmen]    Script Date: 02.07.2025 15:45:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabPlan_plgLogZmen] on [dbo].[TabPlan] for insert,update,delete
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsDeleted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabPlan',LA.SysNazevAtribut,I.ID,null
          ,left(case LA.SysNazevAtribut 
when N'Autor' then convert(nvarchar(max),I.Autor,121)
when N'DatPorizeni' then convert(nvarchar(max),I.DatPorizeni,121)
when N'datum' then convert(nvarchar(max),I.datum,121)
when N'DatumTPV' then convert(nvarchar(max),I.DatumTPV,121)
when N'DatZmeny' then convert(nvarchar(max),I.DatZmeny,121)
when N'mnozstvi' then convert(nvarchar(max),I.mnozstvi,121)
when N'Rada' then convert(nvarchar(max),I.Rada,121)
when N'SkupinaPlanu' then convert(nvarchar(max),I.SkupinaPlanu,121)
when N'Zmenil' then convert(nvarchar(max),I.Zmenil,121)
when N'TypProvedeneKorekcePozadavku' then convert(nvarchar(max),I.TypProvedeneKorekcePozadavku,121)
when N'BlokovaniEditoru' then convert(nvarchar(max),I.BlokovaniEditoru,121)
                end,255),0
      from inserted I
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPlan' and LA.LogInsert=1
if @existsInserted=1 and @existsDeleted=1
 if
 update(Autor)
or update(DatPorizeni)
or update(datum)
or update(DatumTPV)
or update(DatZmeny)
or update(mnozstvi)
or update(Rada)
or update(SkupinaPlanu)
or update(Zmenil)
or update(TypProvedeneKorekcePozadavku)
or update(BlokovaniEditoru)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabPlan',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Autor' then convert(nvarchar(max),D.Autor,121)
when N'DatPorizeni' then convert(nvarchar(max),D.DatPorizeni,121)
when N'datum' then convert(nvarchar(max),D.datum,121)
when N'DatumTPV' then convert(nvarchar(max),D.DatumTPV,121)
when N'DatZmeny' then convert(nvarchar(max),D.DatZmeny,121)
when N'mnozstvi' then convert(nvarchar(max),D.mnozstvi,121)
when N'Rada' then convert(nvarchar(max),D.Rada,121)
when N'SkupinaPlanu' then convert(nvarchar(max),D.SkupinaPlanu,121)
when N'Zmenil' then convert(nvarchar(max),D.Zmenil,121)
when N'TypProvedeneKorekcePozadavku' then convert(nvarchar(max),D.TypProvedeneKorekcePozadavku,121)
when N'BlokovaniEditoru' then convert(nvarchar(max),D.BlokovaniEditoru,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Autor' then convert(nvarchar(max),I.Autor,121)
when N'DatPorizeni' then convert(nvarchar(max),I.DatPorizeni,121)
when N'datum' then convert(nvarchar(max),I.datum,121)
when N'DatumTPV' then convert(nvarchar(max),I.DatumTPV,121)
when N'DatZmeny' then convert(nvarchar(max),I.DatZmeny,121)
when N'mnozstvi' then convert(nvarchar(max),I.mnozstvi,121)
when N'Rada' then convert(nvarchar(max),I.Rada,121)
when N'SkupinaPlanu' then convert(nvarchar(max),I.SkupinaPlanu,121)
when N'Zmenil' then convert(nvarchar(max),I.Zmenil,121)
when N'TypProvedeneKorekcePozadavku' then convert(nvarchar(max),I.TypProvedeneKorekcePozadavku,121)
when N'BlokovaniEditoru' then convert(nvarchar(max),I.BlokovaniEditoru,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPlan' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'') 
if @existsInserted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabPlan',LA.SysNazevAtribut,D.ID
          ,left(case LA.SysNazevAtribut 
when N'Autor' then convert(nvarchar(max),D.Autor,121)
when N'DatPorizeni' then convert(nvarchar(max),D.DatPorizeni,121)
when N'datum' then convert(nvarchar(max),D.datum,121)
when N'DatumTPV' then convert(nvarchar(max),D.DatumTPV,121)
when N'DatZmeny' then convert(nvarchar(max),D.DatZmeny,121)
when N'mnozstvi' then convert(nvarchar(max),D.mnozstvi,121)
when N'Rada' then convert(nvarchar(max),D.Rada,121)
when N'SkupinaPlanu' then convert(nvarchar(max),D.SkupinaPlanu,121)
when N'Zmenil' then convert(nvarchar(max),D.Zmenil,121)
when N'TypProvedeneKorekcePozadavku' then convert(nvarchar(max),D.TypProvedeneKorekcePozadavku,121)
when N'BlokovaniEditoru' then convert(nvarchar(max),D.BlokovaniEditoru,121)
                end,255),null,2
      from deleted D
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPlan' and LA.LogDelete=1
GO

ALTER TABLE [dbo].[TabPlan] ENABLE TRIGGER [et_TabPlan_plgLogZmen]
GO

