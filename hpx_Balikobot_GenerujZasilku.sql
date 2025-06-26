USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_GenerujZasilku]    Script Date: 26.06.2025 14:34:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_GenerujZasilku]
@IdDoklad INT,
@KodDopravce NVARCHAR(20),
@TypSluzby NVARCHAR(50),
@PocetBaliku INT,
@Dobirka BIT,
@CastkaDobirky NUMERIC(19,6),
@MenaDobirky NVARCHAR(3),
@MultiGenerovani BIT = 0
AS
DECLARE @IdKonfigurace INT
SET @IdKonfigurace=dbo.hfx_Balikobot_VratKonfiguraci(@IdDoklad)
DECLARE
@rec_name NVARCHAR(255),
@rec_firm NVARCHAR(255),
@rec_phone NVARCHAR(50),
@rec_email NVARCHAR(100),
@rec_street NVARCHAR(100),
@rec_city NVARCHAR(100),
@rec_zip NVARCHAR(20),
@rec_country NVARCHAR(100),
@rec_region NVARCHAR(100),
@vs NVARCHAR(20),
@branch_id NVARCHAR(100),
@rec_id NVARCHAR(50)
EXEC dbo.hpx_Balikobot_VratKontaktyProZasilku
@IdDoklad=@IdDoklad,
@IdKonfigurace=@IdKonfigurace,
@CisloOrg=NULL,
@rec_firm=@rec_firm OUT,
@rec_name=@rec_name OUT,
@rec_phone=@rec_phone OUT,
@rec_email=@rec_email OUT,
@rec_street=@rec_street OUT,
@rec_city=@rec_city OUT,
@rec_zip=@rec_zip OUT,
@rec_country=@rec_country OUT,
@rec_region=@rec_region OUT
SELECT
  @vs=D.ParovaciZnak
, @branch_id=_Balikobot_branch_id
, @rec_id=_Balikobot_rec_id
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabDokladyZbozi_EXT DE ON DE.ID=D.ID
WHERE D.ID=@IdDoklad
DECLARE @IdZasilky INT, @PoradoveCislo INT
SET @PoradoveCislo=(SELECT MAX(PoradoveCislo)+1 FROM Tabx_BalikobotZasilky)
IF @PoradoveCislo IS NULL
SET @PoradoveCislo=1
INSERT Tabx_BalikobotZasilky(KodDopravce,
service_type,
rec_name,
rec_firm,
rec_phone,
rec_email,
rec_street,
rec_city,
rec_zip,
rec_country,
rec_region,
IdDokladyZbozi,
Dobirka,
IdKonfigurace,
branch_id,
rec_id,
PoradoveCislo)
VALUES(@KodDopravce,
@TypSluzby,
@rec_name,
@rec_firm,
@rec_phone,
@rec_email,
@rec_street,
@rec_city,
@rec_zip,
@rec_country,
@rec_region,
@IdDoklad,
@Dobirka,
@IdKonfigurace,
@branch_id,
@rec_id,
@PoradoveCislo)
SET @IdZasilky=SCOPE_IDENTITY()
DECLARE @Balik INT=1, @IdBaliku INT
DECLARE @UdanaCenaZasilky NUMERIC(19,6), @MenaUdaneCeny NVARCHAR(3)
EXEC hpx_Balikobot_VratUdanouCenuZasilky
  @IdDoklad=@IdDoklad
, @MultiGenerovani=@MultiGenerovani
, @UdanaCenaZasilky=@UdanaCenaZasilky OUT
, @MenaUdaneCeny=@MenaUdaneCeny OUT
WHILE @Balik<=@PocetBaliku
BEGIN
INSERT Tabx_BalikobotBaliky(IdZasilky, OrderNumber)
VALUES(@IdZasilky, @Balik)
SET @IdBaliku=SCOPE_IDENTITY()
IF @Balik=1
UPDATE Tabx_BalikobotBaliky SET
  price=@UdanaCenaZasilky
, ins_currency=@MenaUdaneCeny
WHERE ID=@IdBaliku
IF (@Dobirka=1)AND(@Balik=1)
UPDATE Tabx_BalikobotBaliky SET
cod_price=@CastkaDobirky,
cod_currency=@MenaDobirky
WHERE ID=@IdBaliku
SET @Balik=@Balik+1
END
IF (@Dobirka=1)
UPDATE Tabx_BalikobotBaliky SET vs=@vs WHERE IdZasilky=@IdZasilky
IF @KodDopravce IN('ups', 'pbh', 'dhl') AND @IdDoklad IS NOT NULL
BEGIN
  DECLARE @cod_currency NVARCHAR(3)
  IF ISNULL(@MenaDobirky, '')<>'' SET @cod_currency=@MenaDobirky
  IF @cod_currency IS NULL
    SET @cod_currency=(SELECT Mena FROM TabDokladyZbozi WHERE ID=@IdDoklad)
  IF @cod_currency IS NOT NULL
    UPDATE Tabx_BalikobotBaliky SET cod_currency=@cod_currency WHERE IdZasilky=@IdZasilky
END
INSERT Tabx_BalikobotVZasilkyDoklady(IdZasilky, IdDoklad, MasterDoklad) VALUES(@IdZasilky, @IdDoklad, 1)
IF @MultiGenerovani=1
BEGIN
INSERT INTO Tabx_BalikobotVZasilkyDoklady(IdZasilky, IdDoklad)
SELECT @IdZasilky, IdDOklad
FROM #Tabx_BalikobotMultiGenerovani
END
IF (SELECT ISNULL(RealOrderIdTyp, 0) FROM Tabx_BalikobotKonfigurace WHERE ID=@IdKonfigurace)<>0
  UPDATE Tabx_BalikobotBaliky SET OrderNumber=OrderNumber WHERE IdZasilky=@IdZasilky
IF @IdDoklad IS NOT NULL
  EXEC dbo.hpx_Balikobot_PredvyplneniManipulacnichJednotek @IdZasilky=@IdZasilky, @IdDoklad=@IdDoklad
IF (SELECT GenerovatVychoziHmotnost FROM Tabx_BalikobotKonfigurace WHERE ID=@IdKonfigurace)=1
  EXEC dbo.hpx_Balikobot_GenerovatVychoziHmotnost @IdZasilky=@IdZasilky
IF @IdDoklad IS NOT NULL
BEGIN
DECLARE @IdHlavniBalikZasilky INT
SET @IdHlavniBalikZasilky=(SELECT ID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)
IF (@MultiGenerovani=0)AND(@IdHlavniBalikZasilky IS NOT NULL)
INSERT INTO Tabx_BalikobotVBalikyADRKody(IdBalik, ADR_unit_id, ADR_unit_pieces_count, ADR_unit_weight, ADR_unit_volume)
SELECT @IdHlavniBalikZasilky, KE._Balikobot_ADR_ID, SUM(P.Mnozstvi) AS adr_pieces_count, SUM(P.Hmotnost) AS adr_weight, SUM(K.Objem*P.Mnozstvi) AS adr_volume
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.ID=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
LEFT OUTER JOIN TabKmenZbozi_EXT KE ON KE.ID=K.ID
WHERE ISNULL(KE._Balikobot_ADR_ID, '')<>''
AND D.ID=@IdDoklad
GROUP BY KE._Balikobot_ADR_ID
IF (@MultiGenerovani=1)AND(@IdHlavniBalikZasilky IS NOT NULL)
INSERT INTO Tabx_BalikobotVBalikyADRKody(IdBalik, ADR_unit_id, ADR_unit_pieces_count, ADR_unit_weight, ADR_unit_volume)
SELECT @IdHlavniBalikZasilky, KE._Balikobot_ADR_ID, SUM(P.Mnozstvi) AS adr_pieces_count, SUM(P.Hmotnost) AS adr_weight, SUM(K.Objem*P.Mnozstvi) AS adr_volume
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.ID=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
LEFT OUTER JOIN TabKmenZbozi_EXT KE ON KE.ID=K.ID
WHERE ISNULL(KE._Balikobot_ADR_ID, '')<>''
AND D.ID IN(SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani UNION SELECT @IdDoklad)
GROUP BY KE._Balikobot_ADR_ID
END
IF @MultiGenerovani=1
  EXEC('DELETE FROM #Tabx_BalikobotMultiGenerovani')
IF @KodDopravce='dhl'
BEGIN
DECLARE @IDDokument INT
SET @IDDokument=(
SELECT TOP 1 D.ID
FROM TabDokumenty D
JOIN TabDokumVazba V ON V.IdDok=D.ID
WHERE V.IdentVazby=9
AND V.IdTab=(SELECT TOP 1 IdDoklad FROM Tabx_BalikobotVZasilkyDoklady WHERE IdZasilky=@IdZasilky AND MasterDoklad=1)
AND D.JmenoACesta LIKE '%.pdf'
)
IF @IDDokument IS NOT NULL
  UPDATE Tabx_BalikobotBaliky SET invoice_pdf=@IDDokument WHERE IdZasilky=@IdZasilky AND OrderNumber=1
END
IF OBJECT_ID('dbo.epx_Balikobot_GenerujZasilku', 'P') IS NOT NULL
EXEC dbo.epx_Balikobot_GenerujZasilku
@IdDoklad=@IdDoklad
, @IdZasilky=@IdZasilky
SELECT @IdZasilky
GO

