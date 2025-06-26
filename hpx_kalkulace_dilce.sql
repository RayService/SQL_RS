USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_kalkulace_dilce]    Script Date: 26.06.2025 15:28:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--nová definice
CREATE PROCEDURE [dbo].[hpx_kalkulace_dilce]
@kontrola BIT,
@ID INT
AS
SET NOCOUNT ON
-- ===================================================================================
-- Author:		MŽ
-- Create date:            10.3.2022
-- Description:	Uložení spočtené kalkulace do Kalkulace dílců po zakázkách
-- Desc.: Výpočet kalkulace uložen do externí tabulky Tabx_RS_ZKalkulace.
-- 22.6.2022 MŽ přidáno logování změnil a datum změny
--19.7.2022 MŽ přidány podmínky pro dotažení cen: mat/pol pouze pro Patro=1 a ostatní pouze pro Patro=0
-- ===================================================================================

DECLARE @Zakazka_vypocet NVARCHAR(15) = (SELECT CisloZakazky FROM TabZakazka LEFT OUTER JOIN TabPozaZDok_kalk ON TabPozaZDok_kalk.IDZakazka = TabZakazka.ID WHERE TabPozaZDok_kalk.ID = @ID);
--množství z požadavku dám do parametrů výpočtu
DECLARE @Mnozstvi_vypocet NUMERIC(19,6) = (SELECT Pozadavek FROM TabZakazka LEFT OUTER JOIN TabPozaZDok_kalk ON TabPozaZDok_kalk.IDZakazka = TabZakazka.ID WHERE TabPozaZDok_kalk.ID = @ID);
--dohledání ID vyráběného dílce pro kalkulaci
DECLARE @IDPol INT = (SELECT IDKmenZbozi FROM TabPozaZDok_kalk WHERE ID = @ID);
--dohledání ID zakázky dle navoleného čísla
DECLARE @IDZakazka_vypocet INT = (SELECT ID FROM TabZakazka WHERE CisloZakazky = @Zakazka_vypocet);
--vymazání případných předchozích uložených kalkulací pro daný výrobek a zakázku
DELETE FROM Tabx_RS_ZKalkulace WHERE Dilec = @IDPol AND CisloZakazky = @Zakazka_vypocet;
--množství pro uložení do kalkulace
DECLARE @mnf_kalkulace NUMERIC(19,6)
SET @mnf_kalkulace=(SELECT tdkk.mnf
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (0) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME())
--dohledání způsobu výpočtu kalkulace
DECLARE @Davka TINYINT = (SELECT Davka FROM TabPozaZDok_kalk WHERE ID = @ID);

IF @kontrola=1
BEGIN
INSERT dbo.Tabx_RS_ZKalkulace(Dilec,CisloZakazky,mat,TAC_KC,TBC_KC,TEC_KC,rezieS,rezieP,ReziePrac,OPN,NakladyPrac,VedProdukt,naradi,koop,TAC,TBC,TEC,TAC_T,TBC_T,TEC_T,Davka) 
  SELECT @IDPol, @Zakazka_vypocet,
	ISNULL((SELECT SUM(tdkk.JNmat)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (10,20) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=1),0),
	ISNULL((SELECT SUM(tdkk.JNTAC_KC)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNTBC_KC)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNTEC_KC)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNrezieS)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNrezieP)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNReziePrac)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNOPN)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (60) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNNakladyPrac)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNVedProdukt)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (70) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNnaradi)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (50) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.JNkoop)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (40) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.TAC)/@mnf_kalkulace
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.TBC)/@mnf_kalkulace
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT SUM(tdkk.TEC)/@mnf_kalkulace
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT MIN(tdkk.TAC_T)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT MIN(tdkk.TBC_T)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	ISNULL((SELECT MIN(tdkk.TEC_T)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
	@Davka
  WHERE NOT EXISTS
  (
    SELECT 1 FROM dbo.Tabx_RS_ZKalkulace WITH (UPDLOCK, SERIALIZABLE)
      WHERE Dilec = @IDPol AND CisloZakazky = @Zakazka_vypocet
  );
IF @@ROWCOUNT = 0
BEGIN
UPDATE dbo.Tabx_RS_ZKalkulace SET
mat= ISNULL((SELECT SUM(tdkk.JNmat)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (10,20) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=1),0),
TAC_KC=ISNULL((SELECT SUM(tdkk.JNTAC_KC)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TBC_KC=ISNULL((SELECT SUM(tdkk.JNTBC_KC)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TEC_KC=ISNULL((SELECT SUM(tdkk.JNTEC_KC)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
rezieS=ISNULL((SELECT SUM(tdkk.JNrezieS)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
rezieP=ISNULL((SELECT SUM(tdkk.JNrezieP)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
ReziePrac=ISNULL((SELECT SUM(tdkk.JNReziePrac)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
OPN=ISNULL((SELECT SUM(tdkk.JNOPN)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (60) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
NakladyPrac=ISNULL((SELECT SUM(tdkk.JNNakladyPrac)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
VedProdukt=ISNULL((SELECT SUM(tdkk.JNVedProdukt)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (70) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
naradi=ISNULL((SELECT SUM(tdkk.JNnaradi)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (50) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
koop=ISNULL((SELECT SUM(tdkk.JNkoop)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (40) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TAC=ISNULL((SELECT SUM(tdkk.TAC)/@mnf_kalkulace
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TBC=ISNULL((SELECT SUM(tdkk.TBC)/@mnf_kalkulace
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TEC=ISNULL((SELECT SUM(tdkk.TEC)/@mnf_kalkulace
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TAC_T=ISNULL((SELECT MIN(tdkk.TAC_T)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TBC_T=ISNULL((SELECT MIN(tdkk.TBC_T)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
TEC_T=ISNULL((SELECT MIN(tdkk.TEC_T)
                     FROM TabDetailniKalkulace_kalk tdkk 
                     WHERE tdkk.TypRadku IN (30) AND tdkk.IDFinal = @IDPol AND tdkk.IDZakazka = @IDZakazka_vypocet AND tdkk.Autor=SUSER_SNAME() AND tdkk.Patro=0),0),
Zmenil=SUSER_SNAME(),
DatZmeny=GETDATE(),
Davka=@Davka
WHERE Dilec = @IDPol AND CisloZakazky = @Zakazka_vypocet;
END
END
ELSE
RETURN;
GO

