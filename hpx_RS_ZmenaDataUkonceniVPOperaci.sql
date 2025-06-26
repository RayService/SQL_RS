USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaDataUkonceniVPOperaci]    Script Date: 26.06.2025 15:12:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaDataUkonceniVPOperaci] @DateDo DATETIME, @kontrola BIT, @ID INT
AS
SET NOCOUNT ON

--cvičná deklarace
--DECLARE @ID INT=174043
--DECLARE @kontrola BIT=1
--DECLARE @DateDo DATETIME
--ostrá deklarace
DECLARE @DateOd DATETIME
DECLARE @ErrMsg NVarChar(2000) 

IF @kontrola=1
BEGIN
	SET @DateOd=(SELECT tp.Plan_zadani FROM TabPrikaz tp WHERE tp.ID=@ID)

	IF @DateDo>=@DateOd
	BEGIN
		--změna na VP
		UPDATE TabPrikaz SET Plan_ukonceni=@DateDo, DatZmeny = GETDATE(), Zmenil=SUSER_SNAME() WHERE ID = @ID

		--změna na operacích
		IF OBJECT_ID(N'tempdb..#TabCEAOznacID')IS NULL
		CREATE TABLE #TabCEAOznacID(ID INT NOT NULL PRIMARY KEY)
		ELSE
		TRUNCATE TABLE #TabCEAOznacID

		INSERT #TabCEAOznacID(ID)
		SELECT TabPrPostup.ID
		FROM TabPrPostup
		WHERE (TabPrPostup.IDOdchylkyDo IS NULL)AND(TabPrPostup.IDPrikaz=@ID)

			BEGIN TRAN 
			UPDATE PrP SET Plan_ukonceni=@DateDo
			FROM TabPrPostup PrP 
			INNER JOIN TabPrikaz P ON (P.ID=PrP.IDPrikaz AND P.StavPrikazu<60) 
			WHERE PrP.ID1 IN (SELECT PrP2.ID1 FROM #TabCEAOznacID T INNER JOIN TabPrPostup PrP2 ON (PrP2.ID=T.ID)) AND 
					 PrP.Uzavreno=0 
			 IF @@error<>0 GOTO CHYBA 
			KONEC: 
			 COMMIT TRAN 
			 RETURN 
			CHYBA: 
			 IF @@trancount>0 ROLLBACK TRAN

		IF OBJECT_ID(N'tempdb..#TabCEAOznacID') IS NOT NULL DROP TABLE #TabCEAOznacID

	END
	ELSE
	BEGIN
		RAISERROR('Požadované datum je menší než datum zahájení, nelze provést.',16,1)
		RETURN
	END;

END;
ELSE
BEGIN
	RAISERROR('Nic neproběhne, není zatrženo Provést.',16,1)
	RETURN
END;
GO

