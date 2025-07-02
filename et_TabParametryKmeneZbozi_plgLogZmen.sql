USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabParametryKmeneZbozi_plgLogZmen]    Script Date: 02.07.2025 15:27:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabParametryKmeneZbozi_plgLogZmen] on [dbo].[TabParametryKmeneZbozi] for update,delete
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(VychoziSklad)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabParametryKmeneZbozi',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'VychoziSklad' then convert(nvarchar(max),D.VychoziSklad,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'VychoziSklad' then convert(nvarchar(max),I.VychoziSklad,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabParametryKmeneZbozi' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'') 
if @existsInserted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabParametryKmeneZbozi',LA.SysNazevAtribut,D.ID
          ,left(case LA.SysNazevAtribut 
when N'VychoziSklad' then convert(nvarchar(max),D.VychoziSklad,121)
                end,255),null,2
      from deleted D
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabParametryKmeneZbozi' and LA.LogDelete=1
GO

ALTER TABLE [dbo].[TabParametryKmeneZbozi] ENABLE TRIGGER [et_TabParametryKmeneZbozi_plgLogZmen]
GO

