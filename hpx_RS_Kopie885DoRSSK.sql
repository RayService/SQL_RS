USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_Kopie885DoRSSK]    Script Date: 26.06.2025 14:23:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_Kopie885DoRSSK]
@IDOrig INT
AS
--cvičná deklarace
--DECLARE @IDOrig INT=210599
--ostrá deklarace
--MŽ 21.3.2025 přidána možnost ještě i pro 886 a 887

DECLARE @SkupZbo NVARCHAR(3);
DECLARE @RegCis  NVARCHAR(30);
DECLARE @AutoCislovani BIT;
DECLARE @Nazev1 NVARCHAR(100);
DECLARE @Nazev2 NVARCHAR(100);
DECLARE @Nazev3 NVARCHAR(100);
DECLARE @Nazev4 NVARCHAR(100);
DECLARE @MJEv NVARCHAR(10);
DECLARE @IDDilce INT;
DECLARE @ID INT;	--návratové ID dílce v RS SK
--úpravy kvůli odlišné délce reg.čísla oproti konfiguraci
DECLARE @DelkaSK TINYINT
DECLARE @DelkaRC TINYINT

SET @SkupZbo=(SELECT SkupZbo FROM TabKmenZbozi WHERE ID=@IDOrig)

IF @SkupZbo IN (N'850',N'885',N'886',N'887')
BEGIN
	SELECT @SkupZbo=SkupZbo, @RegCis=RegCis, @AutoCislovani=1, @Nazev1=Nazev1, @Nazev2=Nazev2, @Nazev3=Nazev3, @Nazev4=Nazev4, @MJEv=MJEvidence, @DelkaRC=LEN(tkz.RegCis)
	FROM TabKmenZbozi tkz
	WHERE tkz.ID=@IDOrig
	--uložíme aktuální délku reg.čísla a upravíme dle označené karty
	SET @DelkaSK=(SELECT DelkaRegCislaZbozi FROM RayService5.dbo.TabHGlob)
	UPDATE RayService5.dbo.TabHGlob SET DelkaRegCislaZbozi=@DelkaRC

	EXEC @ID=RayService5.dbo.hp_VytvorPolozkuKmeneZbozi @SZ=@SkupZbo,@RegCis=@RegCis, @Nazev1=@Nazev1,@Nazev2=@Nazev2 ,@Nazev3=@Nazev3, @Nazev4=@Nazev4, @MJEv=@MJEv, @Dilec=0, @Material=1
	--SET @IDDilce=(SELECT IDENT_CURRENT('TabKmenZbozi'))
	--vložení do Stavu skladu
	SELECT @ID
	EXEC RayService5.dbo.hp_InsertStavSkladu @IDKmen=@ID/*@IDDilce*/, @IDSklad=N'100'
	--vložení ext.tabulky a napojení orig.dílce na nově založený
	INSERT INTO RayService5.dbo.TabKmenZbozi_EXT (ID,_EXT_RS_IDKmenRS) VALUES (@ID, @IDOrig)
	--nastavíme výchozí sklad pro výdej do výroby
	--EXEC hp_PridaniPolozkyKZDoVyroby @ID=@ID, @SetDilec=0, @SetMaterial=1, @SetNaradi=0
	--INSERT INTO RayService5.dbo.TabParametryKmeneZbozi (IDKmenZbozi, 
	--vrátíme délku reg.čísla
	UPDATE RayService5.dbo.TabHGlob SET DelkaRegCislaZbozi=@DelkaSK

	--SELECT *
	--FROM RayService5.dbo.TabKmenZbozi_EXT
	--WHERE ID=3356
END;
GO

