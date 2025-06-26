USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayServiceUctDokladZCestPrikaz]    Script Date: 26.06.2025 8:37:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[hpx_RayServiceUctDokladZCestPrikaz] 
	@uctSbornik nvarchar(3),
	@cestPrikazId int
as 
begin
	set nocount on
	declare @uctDokladDatumPripadu datetime,
			@uctCisloZam int,
			@uctCisloZakazky nvarchar(15),
			@uctCisloNakladovyOkruh nvarchar(15),
			@uctCisloStredisko nvarchar(30),
			@uctCisloOrg int,
			@uctIdObdobi int,
			@uctIdVozidlo int,
			@uctPrednastavenyUcetDAL nvarchar(30),
			@uctPrednastavenyZaknihovano tinyint,
			@uctPrednastavenyStav tinyint,
			@uctPrednastavenyPlnitMedzery bit,
			@uctPrednastavenyDruhData tinyint,
			@uctCisloDokladu int,
			@uctParovaciZnak nvarchar(20),
			@uctObdobiStavu int,
			@uctSumaDALCastka numeric(19,6),
			@uctSumaDALCastkaMena numeric(19,6)
			
	-- Konstantne udaje
	set @uctPrednastavenyUcetDAL = null
	set @uctPrednastavenyZaknihovano = null
	set @uctPrednastavenyStav = null
	select @uctPrednastavenyUcetDAL = s.UcetDAL,
		   @uctPrednastavenyZaknihovano = s.Zaknihovano,
		   @uctPrednastavenyStav = s.Stav,
		   @uctPrednastavenyPlnitMedzery = s.PlnitMezery,
		   @uctPrednastavenyDruhData = s.DruhData
	from dbo.TabSbornik s
	where s.Cislo = @uctSbornik
			
	-- Dotiahni spolocne udaje			
	select @uctDokladDatumPripadu = cest.DatCasKonec,
		   @uctCisloZam = cest.CisloZamestnance,
		   @uctCisloZakazky = cest.CisloZakazky,
		   @uctCisloNakladovyOkruh = cest.NOkruh,
		   @uctCisloStredisko = cest.Stredisko,
		   @uctCisloOrg = cest.CisOrg,
		   @uctIdVozidlo = cest.idVozidlo
	from dbo.TabICestak cest
	where cest.id = @cestPrikazId
	
	set @uctIdObdobi = (select o.Id
						from dbo.TabObdobi o
						where @uctDokladDatumPripadu between o.DatumOd and o.DatumDo)
	if (@uctIdObdobi is null) 
	begin
		declare @ErrStr nvarchar(2047)
		set @ErrStr = dbo.hf_FormatError(50000, N'Period not found')
		raiserror(@ErrStr, 16, 1)
	end
	exec dbo.hp_testuj_obdobi @uctIdObdobi
	
	-- Cislo dokladu
	declare @idObdobiStr varchar(3),
			@where nvarchar(50)
	set @idObdobiStr = CAST(@uctIdObdobi as nvarchar)
	set @where = N'IdObdobi= ' + @idObdobiStr + ' AND Sbornik= N' + CHAR(39) + @uctSbornik + CHAR(39)
	exec @uctCisloDokladu = dbo.hp_NajdiPrvniVolnyDistinct 
		@Tabulka = N'TabDenik',
		@Atribut = N'CisloDokladu',
		@Odkud = 1,
		@Kam = 999999,
		@Where = @where,
		@Returnem = 1,
		@PlnitMezery = @uctPrednastavenyPlnitMedzery
	
	-- Vygeneruj riadky dokladu
	declare @cestNaklPopis nvarchar(50),
			@cestNaklUcetMD nvarchar(30),
			@cestNaklCenaKc numeric(19,6),
			@cestNaklCenaVal numeric(19,6),
			@cestNaklKurz numeric(19,6),
			@cestNaklMena nvarchar(3),
			@lastMena nvarchar(3),
			@lastMenaKurz numeric(19,6)
			
	declare riadky_cur cursor for 
		select cestNakl.Popis,
			   cestNaklKod.UcetMD,
			   ISNULL(cestNakl.CenaKc, 0),
			   ISNULL(cestNakl.CenaVal, 0),
			   cestNakl.Kurz,
			   cestNakl.Mena
        from dbo.TabICestaNakl cestNakl
	     	 left join dbo.TabINaklKod cestNaklKod On cestNakl.idNaklKod = cestNaklKod.id
  	    where cestNakl.idCestak = @cestPrikazId
  	    order by cestNakl.Mena asc
  	    
  	open riadky_cur
  	declare @cisloRiadku int,
  			@dokladId int
  	set @cisloRiadku = 1
  	set @uctSumaDALCastka = 0
	set @uctSumaDALCastkaMena = 0
	set @lastMena = null
	set @uctParovaciZnak = right('000' + @uctSbornik,3) + right('000000' + convert(nvarchar, @uctCisloDokladu),6)
	set @uctObdobiStavu = (select os.Id
						   from dbo.TabObdobiStavu os
						   where @uctDokladDatumPripadu between os.DatumOd and os.DatumDo)
  	while 1 = 1
  	begin	
  		fetch next from riadky_cur into @cestNaklPopis, @cestNaklUcetMD, @cestNaklCenaKc, @cestNaklCenaVal, @cestNaklKurz, @cestNaklMena
  		if @@FETCH_STATUS <> 0
  			break
  	
  		if @lastMena is null 
  			set @lastMena = @cestNaklMena
  	
  		if @lastMena <> @cestNaklMena
  		begin
  			-- Vytvorenie DAL za danu menu a vypocet kurzu
  			set @lastMenaKurz = case 
  									when @uctSumaDALCastkaMena = 0 then 1
  									else round(@uctSumaDALCastka / @uctSumaDALCastkaMena,3)
  								end
  			-- DAL
			insert into dbo.TabDenik (Zaknihovano, Stav, Sbornik, CisloDokladu, CisloRadku, Utvar, IdObdobi, DruhData, DatumPripad, Popis, Strana, CisloUcet, CisloZam, CisloZakazky, CisloNakladovyOkruh, CisloOrg, Mena, Kurz, Castka, CastkaMena, IdVozidlo, ParovaciZnak, IdObdobiStavu)
			values(@uctPrednastavenyZaknihovano, 0, @uctSbornik, @uctCisloDokladu, @cisloRiadku, @uctCisloStredisko, @uctIdObdobi, @uctPrednastavenyDruhData, @uctDokladDatumPripadu, '', 1, @uctPrednastavenyUcetDAL, @uctCisloZam, @uctCisloZakazky, @uctCisloNakladovyOkruh, @uctCisloOrg, @lastMena, @lastMenaKurz, @uctSumaDALCastka, @uctSumaDALCastkaMena, @uctIdVozidlo, @uctParovaciZnak, @uctObdobiStavu)
			-- Vydrazdenie triggera
			set @dokladId = SCOPE_IDENTITY()
			update dbo.TabDenik 
			set BlokovaniEditoru = null
			where Id = @dokladId 
			
			-- Vynulovanie
			set @uctSumaDALCastka = 0
			set @uctSumaDALCastkaMena = 0
			
			-- Pocitadla
			set @cisloRiadku = @cisloRiadku + 1
			set @lastMena = @cestNaklMena
  		end
  	
  		-- MD
  		insert into dbo.TabDenik (Zaknihovano, Stav, Sbornik, CisloDokladu, CisloRadku, Utvar, IdObdobi, DruhData, DatumPripad, Popis, Strana, CisloUcet, CisloZam, CisloZakazky, CisloNakladovyOkruh, CisloOrg, Mena, Kurz, Castka, CastkaMena, IdVozidlo, ParovaciZnak, IdObdobiStavu)
  		values(@uctPrednastavenyZaknihovano, @uctPrednastavenyStav, @uctSbornik, @uctCisloDokladu, @cisloRiadku, @uctCisloStredisko, @uctIdObdobi, @uctPrednastavenyDruhData, @uctDokladDatumPripadu, @cestNaklPopis, 0, @cestNaklUcetMD, @uctCisloZam, @uctCisloZakazky, @uctCisloNakladovyOkruh, @uctCisloOrg, @lastMena, @cestNaklKurz, @cestNaklCenaKc, @cestNaklCenaVal, @uctIdVozidlo, @uctParovaciZnak, @uctObdobiStavu)
  		set @dokladId = SCOPE_IDENTITY()
  		-- Vydrazdenie triggera
  		update dbo.TabDenik 
  		set BlokovaniEditoru = null
  		where Id = @dokladId
  		
  		-- Nascitavanie strany DAL
  		set @uctSumaDALCastka = @uctSumaDALCastka + isnull(@cestNaklCenaKc, 0)
		set @uctSumaDALCastkaMena = @uctSumaDALCastkaMena + isnull(@cestNaklCenaVal, 0)
		
  		set @cisloRiadku = @cisloRiadku + 1
  	end
  	close riadky_cur
	deallocate riadky_cur
	
	-- Vytvorenie posledneho DAL za danu menu a vypocet kurzu
	set @lastMenaKurz = case 
							when @uctSumaDALCastkaMena = 0 then 1
							else round(@uctSumaDALCastka / @uctSumaDALCastkaMena,3)
						end
	-- DAL
	insert into dbo.TabDenik (Zaknihovano, Stav, Sbornik, CisloDokladu, CisloRadku, Utvar, IdObdobi, DruhData, DatumPripad, Popis, Strana, CisloUcet, CisloZam, CisloZakazky, CisloNakladovyOkruh, CisloOrg, Mena, Kurz, Castka, CastkaMena, IdVozidlo, ParovaciZnak, IdObdobiStavu)
	values(@uctPrednastavenyZaknihovano, 0, @uctSbornik, @uctCisloDokladu, @cisloRiadku, @uctCisloStredisko, @uctIdObdobi, @uctPrednastavenyDruhData, @uctDokladDatumPripadu, '', 1, @uctPrednastavenyUcetDAL, @uctCisloZam, @uctCisloZakazky, @uctCisloNakladovyOkruh, @uctCisloOrg, @cestNaklMena, @lastMenaKurz, @uctSumaDALCastka, @uctSumaDALCastkaMena, @uctIdVozidlo, @uctParovaciZnak, @uctObdobiStavu)
	-- Vydrazdenie triggera
	set @dokladId = SCOPE_IDENTITY()
	update dbo.TabDenik 
	set BlokovaniEditoru = null
	where Id = @dokladId 
	
	-- Nastavenie externeho atributu
	if not exists (select 1
				   from dbo.TabICestak_Ext cest_e 
				   where cest_e.id = @cestPrikazId)
	begin
		insert into dbo.TabICestak_Ext (ID) values(@cestPrikazId)
	end
	update dbo.TabICestak_Ext
	set _RayServiceCisloUctDokladu = @uctCisloDokladu
	where Id = @cestPrikazId
	
	set nocount off
end
GO

