USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generate_stock_taking]    Script Date: 26.06.2025 14:11:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_generate_stock_taking] @DatumGen DATETIME2, @RadaPrijem NVARCHAR(3), @RadaVydej NVARCHAR(3), @ID INT
AS

--cvičná deklarace
--DECLARE @ID INT;
--SET @ID=100803;
DECLARE @Kod NVARCHAR(15);
DECLARE @NKod NVARCHAR(15);
DECLARE @IDSklad NVARCHAR(30);
SET @Kod=(SELECT Kod FROM TabUmisteni WHERE ID=@ID)
SET @NKod=@Kod+'%'
SELECT @Kod, @NKod
SET @IDSklad=(SELECT IdSklad FROM TabUmisteni WHERE ID=@ID)

--inventura
--založení hlavičky - otevření editoru
DECLARE @IDInvHead INT;
DECLARE @IDObdobi INT;
SET @IDObdobi=(SELECT O.ID FROM TabObdobi O WHERE O.Nazev LIKE DATEPART(YEAR,GETDATE()))
INSERT INTO TabInvHead (IDSklad, IDObdobi, BlokovaniEditoru, EvNulaStavVC, EvNulaStavSkladu,MnozPredvypl,JeNovaVetaEditor)
VALUES (@IDSklad/*N'100'*/,@IDObdobi,0,0,0,1,0)
SET @IDInvHead=(SELECT SCOPE_IDENTITY());
--uložení hlavičky
UPDATE TabInvHead SET DatumGenerovani=@DatumGen/*'20221120 00:00:00:000'*/,dPrijem=0,dVydej=4,DokladPrijem=@RadaPrijem/*'530'*/,DokladVydej=@RadaVydej/*'694'*/,Popis=N'Inventura umístění '+@Kod,BlokovaniEditoru=NULL,VC=1
WHERE ID=@IDInvHead
--spuštění generování položek
--výběr položek a přenos
IF OBJECT_ID(N'tempdb..#TmpOZSezIDInventura')IS NULL
CREATE TABLE #TmpOZSezIDInventura(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TmpOZSezIDInventura

--naplnění položek přenosové tabulky
--vložit ID označených položek, neboli položek, které budou v rámci jednoho umístění. Musím si tedy zjistit ID skladových karet, které jsou součástí jednoho umístění.
INSERT #TmpOZSezIDInventura(ID)--VALUES(@ID)
SELECT ID
FROM TabStavSkladu tss
WHERE tss.ID IN (SELECT GSU.IDStavSkladu
				FROM Gatema_StavUmisteni GSU
				WHERE GSU.IDUmisteni IN (SELECT	TabUmisteni.ID
						FROM TabUmisteni
						LEFT OUTER JOIN  TabUmisteni_EXT ON TabUmisteni_EXT.ID=TabUmisteni.ID
						WHERE ((TabUmisteni.Kod LIKE @Kod+'%')AND(TabUmisteni.Kod<>@Kod)AND(TabUmisteni.IdSklad=@IDSklad)))
						)
--SELECT * FROM #TmpOZSezIDInventura
BEGIN TRANSACTION
EXEC dbo.hp_SkladInventura 1, @IDInvHead, NULL, 1, 0, 0, 0, 0, 1
COMMIT TRANSACTION

--přes spuštěním gatema umístění
IF OBJECT_ID(N'tempdb..#TabTempUziv','U')IS NOT NULL
BEGIN
INSERT #TabTempUziv(Tabulka, SCOPE_IDENTITY, Datum, Typ)
VALUES(N'Gatema_InvItemUmisteni',1,GETDATE(),1)
END--po spuštění gatema umístění
DECLARE @Predvyplnit bit, @TypGenerMnoz int 
SELECT @Predvyplnit=0, @TypGenerMnoz=0 
INSERT INTO Gatema_InvItemUmisteni(IDInvItem, IDUmisteni, MnozstviStav, MnozstviInv, MnozstviInvMJ, MJ, PrepMnozstvi) 
  SELECT I.ID, SU.IDUmisteni, SU.Mnozstvi,
         SU.Mnozstvi,/*CASE WHEN @Predvyplnit=1 AND SU.Mnozstvi>0.0 THEN SU.Mnozstvi ELSE 0.0 END,*/
         SU.Mnozstvi/I.PrepMnozstvi,/*CASE WHEN @Predvyplnit=1 AND SU.Mnozstvi>0.0 THEN SU.Mnozstvi/I.PrepMnozstvi ELSE 0.0 END,*/
         I.MJ, I.PrepMnozstvi
    FROM TabInvItem I
      INNER JOIN TabInvHead H ON (H.ID=I.IDDoklad AND H.TypInv=0 AND H.DleUmisteni=0 AND (H.DatumClose IS NULL OR @Predvyplnit=0))
      INNER JOIN Gatema_StavUmisteni SU ON (SU.IDStavSkladu=I.IDSklad AND ISNULL(SU.IDVyrCis,0)=ISNULL(I.IDVyrCS,0))
    WHERE I.Uzav=0 AND I.IDUmisteni IS NULL AND
          NOT EXISTS(SELECT * FROM Gatema_InvItemUmisteni IU WHERE IU.IDInvItem=I.ID AND IU.IDUmisteni=SU.IDUmisteni) AND
          (@TypGenerMnoz=0 OR SU.Mnozstvi<>0.0) AND
          I.IdDoklad=@IDInvHead
		  --nově vložená podmínka
		  AND SU.IDUmisteni IN (SELECT TabUmisteni.ID
													  FROM TabUmisteni WITH(NOLOCK)
													  WHERE((TabUmisteni.IdSklad=@IDSklad)AND(TabUmisteni.Kod LIKE @NKod)AND(TabUmisteni.Kod<>@Kod)))
--vymazání zbytečných položek
DECLARE @IDItem INT
DECLARE CurSmazPol CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM TabInvItem tii
	WHERE (tii.IdDoklad=@IDInvHead);
OPEN CurSmazPol;
FETCH NEXT FROM CurSmazPol INTO 
	@IDItem;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		-- zacatek akce v kurzoru CurSmazPol
		IF NOT EXISTS (SELECT hvw_Gatema_InvItemUmisteni.ID
			FROM hvw_Gatema_InvItemUmisteni
			WHERE (hvw_Gatema_InvItemUmisteni.IDInvItem=@IDItem))-- IS NULL
			BEGIN
			DELETE FROM TabInvItem WHERE TabInvItem.ID = @IDItem;
			END;
		-- konec akce v kurzoru CurSmazPol
	FETCH NEXT FROM CurSmazPol INTO 
		@IDItem;
	END;
CLOSE CurSmazPol;
DEALLOCATE CurSmazPol;
--znovu doplnění data inventury
UPDATE TabInvHead SET DatumGenerovani=@DatumGen
WHERE ID=@IDInvHead

--
GO

