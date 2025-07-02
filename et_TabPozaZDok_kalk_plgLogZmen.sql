USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPozaZDok_kalk_plgLogZmen]    Script Date: 02.07.2025 16:05:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabPozaZDok_kalk_plgLogZmen] on [dbo].[TabPozaZDok_kalk] for insert,update
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsDeleted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabPozaZDok_kalk',LA.SysNazevAtribut,I.ID,null
          ,left(case LA.SysNazevAtribut 
when N'FAIR' then convert(nvarchar(max),I.FAIR,121)
when N'FORM1' then convert(nvarchar(max),I.FORM1,121)
when N'PPAP' then convert(nvarchar(max),I.PPAP,121)
                end,255),0
      from inserted I
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPozaZDok_kalk' and LA.LogInsert=1
if @existsInserted=1 and @existsDeleted=1
 if
 update(FAIR)
or update(FORM1)
or update(PPAP)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabPozaZDok_kalk',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'FAIR' then convert(nvarchar(max),D.FAIR,121)
when N'FORM1' then convert(nvarchar(max),D.FORM1,121)
when N'PPAP' then convert(nvarchar(max),D.PPAP,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'FAIR' then convert(nvarchar(max),I.FAIR,121)
when N'FORM1' then convert(nvarchar(max),I.FORM1,121)
when N'PPAP' then convert(nvarchar(max),I.PPAP,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPozaZDok_kalk' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'')
GO

ALTER TABLE [dbo].[TabPozaZDok_kalk] ENABLE TRIGGER [et_TabPozaZDok_kalk_plgLogZmen]
GO

