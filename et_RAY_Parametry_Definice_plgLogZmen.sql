USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_RAY_Parametry_Definice_plgLogZmen]    Script Date: 02.07.2025 14:40:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_RAY_Parametry_Definice_plgLogZmen] on [dbo].[RAY_Parametry_Definice] for update
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(Koef_0_do)
or update(Koef_0_od)
or update(Koef_06_do)
or update(Koef_06_od)
or update(Koef_08_do)
or update(Koef_08_od)
or update(Koef_1_do)
or update(Koef_1_od)
or update(Premiovy_koef_do)
or update(Premiovy_koef_od)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'RAY_Parametry_Definice',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Koef_0_do' then convert(nvarchar(max),D.Koef_0_do,121)
when N'Koef_0_od' then convert(nvarchar(max),D.Koef_0_od,121)
when N'Koef_06_do' then convert(nvarchar(max),D.Koef_06_do,121)
when N'Koef_06_od' then convert(nvarchar(max),D.Koef_06_od,121)
when N'Koef_08_do' then convert(nvarchar(max),D.Koef_08_do,121)
when N'Koef_08_od' then convert(nvarchar(max),D.Koef_08_od,121)
when N'Koef_1_do' then convert(nvarchar(max),D.Koef_1_do,121)
when N'Koef_1_od' then convert(nvarchar(max),D.Koef_1_od,121)
when N'Premiovy_koef_do' then convert(nvarchar(max),D.Premiovy_koef_do,121)
when N'Premiovy_koef_od' then convert(nvarchar(max),D.Premiovy_koef_od,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Koef_0_do' then convert(nvarchar(max),I.Koef_0_do,121)
when N'Koef_0_od' then convert(nvarchar(max),I.Koef_0_od,121)
when N'Koef_06_do' then convert(nvarchar(max),I.Koef_06_do,121)
when N'Koef_06_od' then convert(nvarchar(max),I.Koef_06_od,121)
when N'Koef_08_do' then convert(nvarchar(max),I.Koef_08_do,121)
when N'Koef_08_od' then convert(nvarchar(max),I.Koef_08_od,121)
when N'Koef_1_do' then convert(nvarchar(max),I.Koef_1_do,121)
when N'Koef_1_od' then convert(nvarchar(max),I.Koef_1_od,121)
when N'Premiovy_koef_do' then convert(nvarchar(max),I.Premiovy_koef_do,121)
when N'Premiovy_koef_od' then convert(nvarchar(max),I.Premiovy_koef_od,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'RAY_Parametry_Definice' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'')
GO

ALTER TABLE [dbo].[RAY_Parametry_Definice] ENABLE TRIGGER [et_RAY_Parametry_Definice_plgLogZmen]
GO

