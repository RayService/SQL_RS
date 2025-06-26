USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UkonceniKooperace]    Script Date: 26.06.2025 13:42:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[hpx_RS_UkonceniKooperace] 
 @GLastIDAkce int,
 @KusyDobre numeric(19,6),
 @KusySpatneOpr numeric(19,6),
 @KusySpatneIO numeric(19,6),
 @KusySpatneNeopr numeric(19,6),
 @KodZavady nvarchar(15),
 @IPTerm nvarchar(15),
 @NazevTerm nvarchar(20) 
AS

--cvičné nastavení
--SET @GLastIDAkce=5179093
--SET @KusyDobre=2
--SELECT @KusySpatneOpr=0, @KusySpatneIO=0,@KusySpatneNeopr=0, @KodZavady=NULL,  @IPTerm='10.0.1.159',  @NazevTerm='iPad 6. Nitara s.r.o'


DECLARE @PauzyS int, @CasOd datetime, @CasDo datetime, @CelkCasS int, @IDMzdy int, @IDStroje int,
        @Platit_TBC int, @IDPrikaz int, @Doklad int, @Alt nvarchar(10), @IDZam int, @NewID int,
        @Evid_KusyDobre numeric(19,6), @Evid_KusySpatneOpr numeric(19,6), @Evid_KusySpatneIO numeric(19,6), @Evid_KusySpatneNeopr numeric(19,6),
        @Evid_CelkCasS_Stroje int, @Evid_CelkCasS_Obsluhy int, @IDPolKoopObj int, @TBCOnlyOne bit=0, @KalendarPreruseni nvarchar(10), @TypEvidMnoz_Kusy bit=1, @SkutecnyPocetSoubeznychOperaci int=1,
 @SkutecnyPocetLidi int=1,@IDSmeny int=NULL
--sety RS:
SET @KalendarPreruseni='ETH_Pauzy'

SELECT @IDZam=IDZam, @CasDo=GETDATE(), @CasOd=T.DatumPor,
       @IDPrikaz=T.IDPrikaz, @Doklad=T.Doklad, @Alt=T.Alt, @IDStroje=T.IDStroje, @PauzyS=0,
       @Platit_TBC=CASE WHEN @TBCOnlyOne=1 THEN 2 ELSE NULL END
  FROM Gatema_TermETH T
  WHERE T.ID=@GLastIDAkce
IF @CasDo<@CasOd SET @CasDo=@CasOd
EXEC @PauzyS=UP_ETH_SumPauzyCasuOdDo @KalendarPreruseni, @CasOd, @CasDo
SET @CelkCasS=DATEDIFF(second,@CasOd,@CasDo) - @PauzyS
SELECT @CelkCasS=@CelkCasS - ISNULL(SUM(CelkCasS),0) FROM Gatema_TermETH WHERE ID>@GLastIDAkce AND IDZam=@IDZam AND IDPrikaz=@IDPrikaz AND Doklad=@Doklad AND Alt=@Alt
IF @CelkCasS<0 SET @CelkCasS=0

SET @IDPolKoopObj=(SELECT TOP 1 polkoob.ID
FROM Gatema_TermETH et
LEFT OUTER JOIN TabPrikaz tp ON tp.ID=et.IDPrikaz
LEFT OUTER JOIN TabPrPostup prp ON prp.IDPrikaz=et.IDPrikaz AND prp.Doklad=et.Doklad AND prp.IDOdchylkyDo IS NULL AND prp.Prednastaveno=1
LEFT OUTER JOIN TabPolKoopObj polkoob ON polkoob.DokladPrPostup=prp.Doklad AND polkoob.IDPrikaz=prp.IDPrikaz AND polkoob.AltPrPostup=prp.Alt
WHERE et.ID=@GLastIDAkce
ORDER BY et.ID DESC)
SET @Evid_KusyDobre=@KusyDobre / @SkutecnyPocetLidi
SET @Evid_KusySpatneOpr=@KusySpatneOpr / @SkutecnyPocetLidi
SET @Evid_KusySpatneIO=@KusySpatneIO / @SkutecnyPocetLidi
SET @Evid_KusySpatneNeopr=@KusySpatneNeopr / @SkutecnyPocetLidi
SET @Evid_CelkCasS_Stroje=@CelkCasS / @SkutecnyPocetLidi
SET @Evid_CelkCasS_Obsluhy=@CelkCasS / @SkutecnyPocetSoubeznychOperaci
BEGIN TRAN 

  BEGIN 
    EXEC @IDMzdy=hp_EvidenceOperace @IDPrikaz=@IDPrikaz, @Doklad=@Doklad, @Alt=@Alt, @Kusy_odv=@Evid_KusyDobre, @kusy_zmet_opr=@Evid_KusySpatneOpr, @kusy_zmet_opr_IO=@Evid_KusySpatneIO,
									@kusy_zmet_neopr=@Evid_KusySpatneNeopr, @IDPolKoopObj=@IDPolKoopObj, @IDZam=@IDZam, @IDSmeny=@IDSmeny, @IDStroje=@IDStroje, @DatumZahajeniOp=@CasOd, @DatumUkonceniOp=@CasDo,
									@Sk_Cas_S=@Evid_CelkCasS_Stroje, @Sk_Cas_Obsluhy_S=@Evid_CelkCasS_Obsluhy, @KodZavady=@KodZavady, @Platit_TBC=@Platit_TBC 
    IF @@error<>0 OR @IDMzdy=0 GOTO CHYBA 
  END 
INSERT INTO Gatema_TermETH(IDKolegy, IPTerm, NazevTerm, Akce, DatumPor, IDZam, IDSmeny, IDPrikaz, Doklad, Alt, IDStroje, KusyDobre, KusySpatne_opr, KusySpatne_IO, KusySpatne_neopr,
							SkutecnyPocetSoubeznychOperaci, SkutecnyPocetLidi, Prostoj_Zavada, CelkCasS, IDMzdy) 
  VALUES(@GLastIDAkce, @IPTerm, @NazevTerm, 11, @CasDo, @IDZam, @IDSmeny, @IDPrikaz, @Doklad, @Alt, @IDStroje, @KusyDobre, @KusySpatneOpr, @KusySpatneIO, @KusySpatneNeopr,
							  @SkutecnyPocetSoubeznychOperaci, @SkutecnyPocetLidi, @KodZavady, @CelkCasS, @IDMzdy) 
IF @@error<>0 GOTO CHYBA 
SET @NewID=SCOPE_IDENTITY() 
UPDATE Gatema_TermETH SET IDKolegy=@NewID WHERE ID=@GLastIDAkce 
UPDATE Gatema_TermETH SET IDKolegy=NULL WHERE IDZam=@IDZam AND IDKolegy=(-1)*@GLastIDAkce 
COMMIT TRAN 
RETURN @IDMzdy 
CHYBA: 
 IF @@trancount>0 ROLLBACK TRAN 
 RETURN 0
GO

