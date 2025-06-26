USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VPGenerujVyrCislaDleMaskyDilec]    Script Date: 26.06.2025 9:51:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_VPGenerujVyrCislaDleMaskyDilec]
	@IDPrikaz int
	,@mnozDo numeric(19,6)
AS 
SET NOCOUNT ON;

IF (EXISTS(SELECT * FROM TabVyrCisPrikaz WHERE IDPrikaz = @IDPrikaz))
BEGIN
   RAISERROR('Nelze provést - na příkaze jsou VČ', 16, 1)
   RETURN
END
DECLARE @mnozOd NUMERIC(19,6);
DECLARE @Mnoz numeric(19,6);
DECLARE @SkupZbo nvarchar(3);
DECLARE @RegCis nvarchar(30);
DECLARE @IndexZmeny1 nvarchar(15);
DECLARE @IndexZmeny2 nvarchar(15);
DECLARE @KodModifikace nvarchar(20);
DECLARE @maska nvarchar(500);
DECLARE @zakazka nvarchar(100);
DECLARE @ix int;
DECLARE @PocetCifer int;
DECLARE @Nasobek numeric(19,6);
DECLARE @DelkaKodu int;
DECLARE @vyrCislo nvarchar(100);
DECLARE @PopisVC nvarchar(100);
DECLARE @DatExpirace datetime;
DECLARE @pomS nvarchar(100);
DECLARE @CisloDavky int;
DECLARE @DavkaOd int;
DECLARE @DavkaDo int;
DECLARE @MnozstviDavky numeric(19,6);
DECLARE @Rada nvarchar(20)
DECLARE @Prikaz int;
DECLARE @IDTabKmen int;
DECLARE @IDZakazka int;
DECLARE @EvidJed numeric(19,6);
DECLARE @TranDavka numeric(19,6);
DECLARE @SkupinaPlanu nvarchar(20);
DECLARE @NavaznaObjednavka nvarchar(30);
DECLARE @DatumZadani datetime;
DECLARE @DatumPlanZadani datetime;
DECLARE @DatumTPV datetime;
DECLARE @IDZakazModif int;
DECLARE @RespPosledni BIT;
DECLARE @PosledniCislo INT;

DECLARE @DavkaEXP SMALLINT;

--DECLARE @mnozDo numeric(19,6)
--SELECT @mnozDo = kusy_ciste FROM TabPrikaz
SELECT 
	@Maska=N''
	, @Zakazka=N''
	, @SkupZbo=N''
	, @RegCis=N''
	, @IndexZmeny1=N''
	, @IndexZmeny2=N'';
	
SELECT 
	@Rada=P.Rada
	, @Prikaz=P.Prikaz 
FROM TabPrikaz P 
WHERE P.ID=@IDPrikaz;

SELECT 
	@SkupinaPlanu=ISNULL(P.SkupinaPlanu,'')
	, @NavaznaObjednavka=P.NavaznaObjednavka
	, @DatumZadani=P.zadani
	, @DatumPlanZadani=P.Plan_Zadani
	, @IDZakazka=P.IDZakazka
	, @IDTabKmen=P.IDTabKmen
	, @DatumTPV=P.DatumTPVOrDnes
	, @IDZakazModif=P.IDZakazModif
	, @EvidJed=P.EvidJednotka
	, @TranDavka=P.TranDavka 
FROM TabPrikaz P 
WHERE P.ID=@IDPrikaz;

SELECT 
	@maska=LTRIM(RTRIM(_RayService_GenVC_Maska))
	,@RespPosledni = ISNULL(_RayService_GenVC_RespPosledni,0)
	,@PosledniCislo = ISNULL(_RayService_GenVC_PosledniCislo,0)
FROM TabKmenZbozi_EXT
WHERE ID = @IDTabKmen;

-- není maska - jdeme pryč (ale nemělo by nastat)
IF ISNULL(@maska,'')=''
	RETURN;
	
SELECT 
	@zakazka=Z.CisloZakazky
	, @SkupZbo=KZ.SkupZbo
	, @RegCis=KZ.RegCis
	, @IndexZmeny1=D.IndexZmeny1
	, @IndexZmeny2=D.IndexZmeny2
	, @KodModifikace=ZM.Kod
	, @TranDavka=ISNULL(ISNULL(@TranDavka,ParD.TranDavka),0.0) 
FROM TabKmenZbozi KZ 
LEFT OUTER JOIN TabParKmZ ParD ON (ParD.IDKmenZbozi=KZ.ID) 
LEFT OUTER JOIN TabZakazModif ZM ON (ZM.ID=@IDZakazModif) 
LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=@IDZakazModif AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
LEFT OUTER JOIN TabZakazka Z ON (Z.ID=@IDZakazka) 
LEFT OUTER JOIN TabDavka D ON ((D.IDDilce=KZ.IDKusovnik OR D.IDDilce=KZ.ID) AND 
                               D.IDDilce=CASE WHEN ZMD.ID IS NULL THEN KZ.IDKusovnik ELSE KZ.ID END AND 
                                (D.IDZakazModif=ZMD.IDZakazModif OR 
                                 ZMD.ID IS NULL AND D.IDZakazModif IS NULL AND 
                                   EXISTS(SELECT * FROM tabczmeny ZodD 
                                     LEFT OUTER JOIN tabczmeny ZdoD ON (ZDoD.ID=D.zmenaDo) 
                                    WHERE ZodD.ID=D.zmenaOd AND ZodD.platnost=1 AND @DatumTPV>=ZodD.datum AND 
                                          (D.ZmenaDo IS NULL OR ZdoD.platnost=0 OR (ZdoD.platnost=1 AND @DatumTPV<ZDoD.datum)) 
                                         ) ) ) 
WHERE KZ.ID=@IDTabKmen;

SET @maska=REPLACE(@maska, N'#PZR2', RIGHT(convert(nvarchar(20),100+DATEPART(yy,@DatumPlanZadani)),2)); 
SET @maska=REPLACE(@maska, N'#PZR4', RIGHT(convert(nvarchar(20),10000+DATEPART(yyyy,@DatumPlanZadani)),4));
SET @maska=REPLACE(@maska, N'#PZM', RIGHT(convert(nvarchar(20),100+DATEPART(mm,@DatumPlanZadani)),2)); 
SET @maska=REPLACE(@maska, N'#PZT', RIGHT(convert(nvarchar(20),100+DATEPART(ww,@DatumPlanZadani)),2)); 
SET @maska=REPLACE(@maska, N'#PZD', RIGHT(convert(nvarchar(20),100+DATEPART(dd,@DatumPlanZadani)),2));
SET @maska=REPLACE(@maska, N'#ZR2', RIGHT(convert(nvarchar(20),100+DATEPART(yy,@DatumZadani)),2));
SET @maska=REPLACE(@maska, N'#ZR4', RIGHT(convert(nvarchar(20),10000+DATEPART(yyyy,@DatumZadani)),4));
SET @maska=REPLACE(@maska, N'#ZM', RIGHT(convert(nvarchar(20),100+DATEPART(mm,@DatumZadani)),2));
SET @maska=REPLACE(@maska, N'#ZT', RIGHT(convert(nvarchar(20),100+DATEPART(ww,@DatumZadani)),2));
SET @maska=REPLACE(@maska, N'#ZD', RIGHT(convert(nvarchar(20),100+DATEPART(dd,@DatumZadani)),2));
SET @maska=REPLACE(@maska, N'#DSZ', ISNULL(@SkupZbo,''));
SET @maska=REPLACE(@maska, N'#DRC', ISNULL(@RegCis,''));
SET @maska=REPLACE(@maska, N'#IZ1', ISNULL(@IndexZmeny1,''));
SET @maska=REPLACE(@maska, N'#IZ2', ISNULL(@IndexZmeny2,''));
SET @maska=REPLACE(@maska, N'#Z', ISNULL(@zakazka,''));
SET @maska=REPLACE(@maska, N'#R', RTRIM(@rada));
SET @maska=REPLACE(@maska, N'#OB', ISNULL(@NavaznaObjednavka,''));
SET @maska=REPLACE(@maska, N'#KM', ISNULL(@KodModifikace,''));
--naše nová maska
SET @maska=REPLACE(@maska, N'#DDD', RIGHT(convert(nvarchar(20),1000+DATEPART(DAYOFYEAR,GETDATE())),3));

-- číslo výrobního příkazu na n míst 
SET @maska=REPLACE(@maska, N'#P', CONVERT(nvarchar(20),@prikaz));
SET @ix=PATINDEX(N'%#[0-9]P%',@maska); 
IF @ix>0 
	BEGIN 
		SET @PocetCifer=CONVERT(int,SUBSTRING(@maska,@ix+1,1));
		SET @maska=SUBSTRING(@maska,1,@ix-1)+ISNULL(REPLICATE(N'0',@PocetCifer-LEN(@prikaz)),'')+CONVERT(nvarchar(20),@prikaz)+SUBSTRING(@maska,@ix+3,500);
    END;

-- skupina plánu z výrobního příkazu na n míst 
SET @maska=REPLACE(@maska, N'#SP', @SkupinaPlanu);
SET @ix=PATINDEX(N'%#[0-9]SP%',@maska);
IF @ix>0 
	BEGIN 
		SET @PocetCifer=CONVERT(int,SUBSTRING(@maska,@ix+1,1));
		SET @maska=SUBSTRING(@maska,1,@ix-1)+ISNULL(REPLICATE(N'0',@PocetCifer-LEN(@SkupinaPlanu)),'')+@SkupinaPlanu+SUBSTRING(@maska,@ix+4,500);
	END

-- číslo dávky položky exp. prikazu
IF ISNULL(NULLIF(PATINDEX(N'%#[0-9]DEXP%',@maska),0),PATINDEX(N'%#DEXP%',@maska)) > 0
	BEGIN
		
		IF NOT EXISTS(SELECT * FROM TabPrikaz Pr
					INNER JOIN TabPohybyZbozi P ON Pr.IDRezervace = P.ID
					WHERE Pr.ID = @IDPrikaz
						AND P.DruhPohybuZbo = 9)
			BEGIN
				RAISERROR (N'Maska pro generování VČ vyžaduje vazbu na položku expedičního příkazu, která chybí!',16,1);
				RETURN;
			END;
		
		SELECT @DavkaEXP = ISNULL(PE._RayService_GenVC_Davka,0) + 1
		FROM TabPrikaz Pr
		INNER JOIN TabPohybyZbozi P ON Pr.IDRezervace = P.ID
		LEFT OUTER JOIN TabPohybyZbozi_EXT PE ON P.ID = PE.ID
		WHERE Pr.ID = @IDPrikaz
			AND P.DruhPohybuZbo = 9;
		
		SET @maska=REPLACE(@maska, N'#DEXP', CONVERT(nvarchar(20),@DavkaEXP));
		SET @ix=PATINDEX(N'%#[0-9]DEXP%',@maska); 
		IF @ix>0 
			BEGIN 
				SET @PocetCifer=CONVERT(int,SUBSTRING(@maska,@ix+1,1));
				SET @maska=SUBSTRING(@maska,1,@ix-1)+ISNULL(REPLICATE(N'0',@PocetCifer-LEN(@DavkaEXP)),'')+CONVERT(nvarchar(20),@DavkaEXP)+SUBSTRING(@maska,@ix+6,500);
			END;
			
		WITH D AS (
			SELECT 
				P.ID
				,@DavkaEXP as DavkaEXP
			FROM TabPrikaz Pr
			INNER JOIN TabPohybyZbozi P ON Pr.IDRezervace = P.ID
			LEFT OUTER JOIN TabPohybyZbozi_EXT PE ON P.ID = PE.ID
			WHERE Pr.ID = @IDPrikaz
				AND P.DruhPohybuZbo = 9
			)
		MERGE TabPohybyZbozi_EXT ET
		USING D ON ET.ID = D.ID
		WHEN MATCHED THEN
			UPDATE SET _RayService_GenVC_Davka = D.DavkaEXP
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ID,_RayService_GenVC_Davka)
			VALUES(D.ID,D.DavkaEXP);
	
	END;

-- počítadlo
SELECT 
	@ix=PATINDEX(N'%#[0-9]C%',@maska)
	, @Nasobek=@EvidJed
	, @DelkaKodu=1; 

IF @ix=0 
	SELECT 
		@ix=PATINDEX(N'%#[0-9]TD%',@maska)
		, @Nasobek=@TranDavka
		, @DelkaKodu=2;
		
IF @ix>0 AND @Nasobek<=0.0 
	BEGIN 
		SELECT 
			@PocetCifer=CONVERT(int,SUBSTRING(@maska,@ix+1,1))
			, @pomS= CASE WHEN @RespPosledni = 1 THEN CAST((@PosledniCislo + 1) as NVARCHAR) ELSE N'1' END;
		SET @Maska=SUBSTRING(@maska,1,@ix-1) + ISNULL(REPLICATE(N'0',@PocetCifer-LEN(@pomS)),'') + @pomS + SUBSTRING(@maska,@ix+2+@DelkaKodu,500);
		SET @ix=0;
	END;
	
SET @mnozOd = 0.;

IF @ix=0 
	BEGIN 
		SET @vyrCislo=LEFT(LTRIM(@maska),100); 
		UPDATE TabVyrCisPrikaz SET mnozstvi=mnozstvi+(@mnozDo-@mnozOd) WHERE IDPrikaz=@IDPrikaz AND VyrCislo=@vyrCislo;
		IF @@rowcount=0 AND LEN(@vyrCislo)>0 
			INSERT INTO TabVyrCisPrikaz (VyrCislo, Popis, Mnozstvi, IDPrikaz) VALUES(@vyrCislo, '', @mnozDo-@mnozOd, @IDPrikaz);
		SET @PosledniCislo = @PosledniCislo + 1;
	END
ELSE 
	BEGIN
		
		SET @mnozOd = CASE WHEN @RespPosledni = 1 THEN @PosledniCislo ELSE 0. END;
		SET @PocetCifer=CONVERT(int,SUBSTRING(@maska,@ix+1,1));
		SET @DavkaOd=@mnozOd+1;
		SET @DavkaDo=@mnozOd + CEILING(ROUND(@mnozDo/@Nasobek,5));
		SET @CisloDavky=@DavkaOd;
		
		WHILE @CisloDavky<=@DavkaDo 
			BEGIN 
				SET @pomS=CONVERT(nvarchar(20), @CisloDavky);
				SET @vyrCislo=LEFT(LTRIM( SUBSTRING(@maska,1,@ix-1)+ISNULL(REPLICATE(N'0',@PocetCifer-LEN(@pomS)),'')+@pomS+SUBSTRING(@maska,@ix+2+@DelkaKodu,500) ),100);
				
				SET @MnozstviDavky=@Nasobek;
						
				IF @MnozstviDavky>0.0 
					BEGIN
						UPDATE TabVyrCisPrikaz SET mnozstvi=mnozstvi+@MnozstviDavky WHERE IDPrikaz=@IDPrikaz AND VyrCislo=@vyrCislo;
						IF @@rowcount=0 AND LEN(@vyrCislo)>0 
							INSERT INTO TabVyrCisPrikaz (VyrCislo, Popis, Mnozstvi, IDPrikaz) VALUES(@vyrCislo, '', @MnozstviDavky, @IDPrikaz);
					END;
					
				SET @CisloDavky=@CisloDavky + 1;
			END
			
		SET @PosledniCislo = @CisloDavky - 1;
		
	END 

-- uložíme poslední číslo (nehledě na stav @RespPosledni)
IF NOT EXISTS(SELECT * FROM TabKmenZbozi_EXT WHERE ID = @IDTabKmen)
	INSERT INTO TabKmenZbozi_EXT(ID) VALUES(@IDTabKmen);
UPDATE TabKmenZbozi_EXT SET _RayService_GenVC_PosledniCislo = @PosledniCislo
WHERE ID = @IDTabKmen;


--Vezmu všechna VČ výrobního příkazu, zkopíruji VyrCislo do Popisu a do VyrCisla naplním Skupina zboží + Registrační číslo +
--			Řada příkazu + Pořadové číslo příkazu + Pořadové číslo kusu (4 místa)
DECLARE @IDVCP int, @PoradoveCislo int, @IDModif int, @IDKZ int, @Dilec bit
SET @PoradoveCislo = 0
DECLARE crVCPrikaz CURSOR FOR  
SELECT VCP.ID, KZ.SkupZbo, KZ.RegCis, P.Rada, P.Prikaz, P.IDZakazModif, KZ.ID, VCP.VyrCislo, KZ.Dilec 
	FROM TabVyrCisPrikaz VCP
		INNER JOIN TabPrikaz P ON P.ID = VCP.IDPrikaz
		LEFT OUTER JOIN TabKmenZbozi KZ ON KZ.ID = P.IDTabKmen
WHERE IDPrikaz = @IDPrikaz
ORDER BY VCP.ID ASC

OPEN crVCPrikaz
WHILE 1=1
BEGIN  
	FETCH NEXT FROM crVCPrikaz INTO @IDVCP, @SkupZbo, @RegCis, @Rada, @Prikaz, @IDModif, @IDKZ, @PopisVC, @Dilec
	IF @@FETCH_STATUS <> 0 BREAK
	SET @PoradoveCislo = @PoradoveCislo + 1

	SET @vyrCislo = @SkupZbo + @RegCis + LTRIM(RTRIM(@Rada)) + CONVERT(nvarchar(30), @Prikaz) + 
					ISNULL(REPLICATE(N'0', 4 - LEN(@PoradoveCislo)), '') + CONVERT(nvarchar(4), @PoradoveCislo)
					/*@SkupZbo + @RegCis + @Rada + ISNULL(REPLICATE(N'0', 30 - LEN(@Prikaz)), '') + CONVERT(nvarchar(30), @Prikaz) + 
					ISNULL(REPLICATE(N'0', 4 - LEN(@PoradoveCislo)), '') + CONVERT(nvarchar(4), @PoradoveCislo)*/
	/*if (@Dilec = 1) 
		UPDATE TabVyrCisPrikaz 
			SET Poznamka = @PopisVC, VyrCislo = @vyrCislo
		WHERE ID = @IDVCP
	else*/
		UPDATE TabVyrCisPrikaz 
			SET Popis = @PopisVC, VyrCislo = @vyrCislo
		WHERE ID = @IDVCP
	SELECT @IndexZmeny2 = IndexZmeny2 FROM TabDavka WHERE IDDilce = @IDKZ AND IDZakazModif = @IDModif AND ZmenaDo IS NULL
	IF (NOT EXISTS(SELECT * FROM TabVyrCisPrikaz_EXT WHERE ID = @IDVCP))
		INSERT INTO TabVyrCisPrikaz_EXT (ID, _IndexZmeny) VALUES (@IDVCP, @IndexZmeny2)
	ELSE
		UPDATE TabVyrCisPrikaz_EXT SET _IndexZmeny = @IndexZmeny2 WHERE ID = @IDVCP
END  
CLOSE crVCPrikaz
DEALLOCATE crVCPrikaz


GO

