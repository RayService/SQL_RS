USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikaz_EXT_plgLogZmen]    Script Date: 02.07.2025 16:11:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabPrikaz_EXT_plgLogZmen] on [dbo].[TabPrikaz_EXT] for insert,update,delete
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsDeleted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabPrikaz_EXT',LA.SysNazevAtribut,I.ID,null
          ,left(case LA.SysNazevAtribut 
when N'_popistatvu4' then convert(nvarchar(max),I._popistatvu4,121)
when N'_vPriprave' then convert(nvarchar(max),I._vPriprave,121)
when N'_popistavu5_zad' then convert(nvarchar(max),I._popistavu5_zad,121)
                end,255),0
      from inserted I
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPrikaz_EXT' and LA.LogInsert=1
if @existsInserted=1 and @existsDeleted=1
 if
 update(_popistatvu4)
or update(_zodpovednyMechanik)
or update(_vPriprave)
or update(_popistavu5_zad)
or update(_Popisstavu)
or update(_Popisstavu2)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabPrikaz_EXT',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'_popistatvu4' then convert(nvarchar(max),D._popistatvu4,121)
when N'_zodpovednyMechanik' then convert(nvarchar(max),D._zodpovednyMechanik,121)
when N'_vPriprave' then convert(nvarchar(max),D._vPriprave,121)
when N'_popistavu5_zad' then convert(nvarchar(max),D._popistavu5_zad,121)
when N'_Popisstavu' then convert(nvarchar(max),D._Popisstavu,121)
when N'_Popisstavu2' then convert(nvarchar(max),D._Popisstavu2,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'_popistatvu4' then convert(nvarchar(max),I._popistatvu4,121)
when N'_zodpovednyMechanik' then convert(nvarchar(max),I._zodpovednyMechanik,121)
when N'_vPriprave' then convert(nvarchar(max),I._vPriprave,121)
when N'_popistavu5_zad' then convert(nvarchar(max),I._popistavu5_zad,121)
when N'_Popisstavu' then convert(nvarchar(max),I._Popisstavu,121)
when N'_Popisstavu2' then convert(nvarchar(max),I._Popisstavu2,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPrikaz_EXT' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'') 
if @existsInserted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabPrikaz_EXT',LA.SysNazevAtribut,D.ID
          ,left(case LA.SysNazevAtribut 
when N'_zodpovednyMechanik' then convert(nvarchar(max),D._zodpovednyMechanik,121)
when N'_vPriprave' then convert(nvarchar(max),D._vPriprave,121)
when N'_popistavu5_zad' then convert(nvarchar(max),D._popistavu5_zad,121)
                end,255),null,2
      from deleted D
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPrikaz_EXT' and LA.LogDelete=1
GO

ALTER TABLE [dbo].[TabPrikaz_EXT] ENABLE TRIGGER [et_TabPrikaz_EXT_plgLogZmen]
GO

