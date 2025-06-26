USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_LezakyUlozHistorie]    Script Date: 26.06.2025 9:08:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 19.6.2012
-- Description:	Ležáky - Uložení do historie
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_LezakyUlozHistorie]
	@ID INT					-- ID v hvw_RayService_LezakyUser
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @Obdobi NCHAR(6)
DECLARE @IDSklad NVARCHAR(30);
DECLARE @DatumDo DATETIME;
DECLARE @DatumDo_X DATETIME;
DECLARE @PocetMesicu SMALLINT;
DECLARE @ProcentoVydej NUMERIC(5,2);
DECLARE @Podminky BIT;
DECLARE @DatumAktualizace DATETIME;
DECLARE @ExecSQL NVARCHAR(4000)
DECLARE @CRLF CHAR(2);

DECLARE @Rok SMALLINT;
DECLARE @Mesic TINYINT;

DECLARE @TranCountPred INT;

SET @CRLF=CHAR(13)+CHAR(10);

SELECT 
	@IDSklad = IDSklad
	,@DatumDo = DatumDo
	,@PocetMesicu = PocetMesicu
	,@ProcentoVydej = ProcentoVydej
	,@Podminky = Podminky
	,@DatumAktualizace = Datum
FROM hvw_RayService_LezakyUser
WHERE ID = @ID;

-- nenačetlo se, protože bylo spuštěno na řádkem z historii, který není v user
IF @DatumDo IS NULL
	SELECT TOP 1
		@IDSklad = IDSklad
		,@DatumDo = DatumDo
		,@PocetMesicu = PocetMesicu
		,@ProcentoVydej = ProcentoVydej
		,@Podminky = Podminky
		,@DatumAktualizace = Datum
	FROM hvw_RayService_LezakyUser
	WHERE DatumDo IS NOT NULL
	ORDER BY Datum DESC;

SET @DatumDo_X = (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,@DatumDo))))

/* kontroly */

-- nenačetlo se
IF @DatumDo IS NULL
	BEGIN
		RAISERROR(N'Nenačetly se vstupní parametry pro historii! %s
Možné důvody:
- nebyl proveden žádný nápočet
- ve zvoleném období pravděpodobně nesplňuje žádná položka parametry ležáku',16,1,@CRLF);
		RETURN;
	END;

-- datum nesmí být větší než 2030
IF YEAR(@DatumDo) > 2030
	BEGIN
		RAISERROR(N'Maximální datum pro uložení do historie je 31.12.2030!',16,1);
		RETURN
	END;

-- datum musí být na konci měsíce / roku (do 2011)
IF YEAR(@DatumDo) < 2012
	BEGIN
		IF @DatumDo_X <> (SELECT DATEADD(YEAR,DATEDIFF(YEAR,'20001231',@DatumDo),'20001231'))
			BEGIN
				RAISERROR(N'Datum pro uložení do historie před rokem 2012 musí být poslední den v roce!',16,1);
				RETURN
			END;
	END;
ELSE
	BEGIN
		IF @DatumDo_X <> (SELECT DATEADD(MONTH,DATEDIFF(MONTH,'20001231',@DatumDo),'20001231'))
			BEGIN
				RAISERROR(N'Datum pro uložení do historie musí být poslední den v měsíci!',16,1);
				RETURN
			END;
	END;
	
-- * kontroly na log
SET @Obdobi = CAST(YEAR(@DatumDo) as NCHAR(4)) + RIGHT((N'00' + CAST(MONTH(@DatumDo) as NVARCHAR(2))),2);
SET @Rok = YEAR(@DatumDo);
SET @Mesic = MONTH(@DatumDo);

-- již uloženo
IF EXISTS(SELECT * FROM Tabx_RayService_LezakyLog
			WHERE Obdobi = @Obdobi
				AND IDSklad = @IDSklad)
	BEGIN
		RAISERROR(N'Pro toto období a sklad již byla historie uložena!',16,1);
		RETURN;
	END;
	
-- nesoulad parametrů
IF EXISTS(SELECT * FROM Tabx_RayService_LezakyLog
			WHERE IDSklad = @IDSklad
				AND (PocetMesicu <> @PocetMesicu OR Podminky <> @Podminky OR ProcentoVydej <> @ProcentoVydej))
	BEGIN
		RAISERROR(N'Parametry aktuálního nápočtu nejsou shodné s parametry historie (Počet měsíců, Procento výdeje, Uplatnit podmínky)!',16,1);
		RETURN;
	END;


/* funkční tělo procedury */
BEGIN TRY

	SET @TranCountPred = @@TRANCOUNT;
	IF @TranCountPred = 0 BEGIN TRAN;

		-- vložíme dosud nezaložené
		INSERT INTO Tabx_RayService_Lezaky(ID)
		SELECT U.IDStavSkladu
		FROM Tabx_RayService_LezakyUser U
			INNER JOIN TabStavSkladu S ON U.IDStavSkladu = S.ID
		WHERE S.IDSklad = @IDSklad
			AND U.LoginName = SUSER_SNAME()
			AND NOT EXISTS(SELECT * FROM Tabx_RayService_Lezaky WHERE ID = U.IDStavSkladu);

		-- aktualizujeme
		SET @ExecSQL = N'UPDATE C SET' + @CRLF +
		'	C.M_' + @Obdobi + ' = Z.M' + @CRLF +
		'	,C.S_' + @Obdobi + ' = Z.S' + @CRLF +
		'	,C.A_' + @Obdobi + ' = Z.A' + @CRLF +
		'FROM Tabx_RayService_Lezaky C' + @CRLF +
		'	INNER JOIN Tabx_RayService_LezakyUser Z ON C.ID = Z.IDStavSkladu AND Z.LoginName = SUSER_SNAME()' + @CRLF +
		'	INNER JOIN TabStavSkladu S ON Z.IDStavSkladu = S.ID AND S.IDSklad = @IDSklad;'

		EXEC sp_executesql
			@ExecSQL
			,N'@IDSklad NVARCHAR(30)'
			,@IDSklad;

		-- aktualizujeme - řádky
		DELETE FROM Tabx_RayService_LezakyRadky
		WHERE Rok = @Rok AND Mesic = @Mesic;

		INSERT INTO Tabx_RayService_LezakyRadky(
			ID
			,Mesic
			,Rok
			,M
			,S
			,A)
		SELECT 
			U.IDStavSkladu
			,@Mesic
			,@Rok
			,U.M
			,U.S
			,U.A
		FROM Tabx_RayService_LezakyUser U
			INNER JOIN TabStavSkladu S ON U.IDStavSkladu = S.ID
		WHERE S.IDSklad = @IDSklad
			AND U.LoginName = SUSER_SNAME();

		-- zapíšeme do logu
		INSERT INTO Tabx_RayService_LezakyLog(
			Obdobi
			,IDSklad
			,DatumDo
			,PocetMesicu
			,ProcentoVydej
			,Podminky
			,Datum)
		VALUES(
			@Obdobi
			,@IDSklad
			,@DatumDo
			,@PocetMesicu
			,@ProcentoVydej
			,@Podminky
			,@DatumAktualizace);
			
		-- aktualizujeme příznak Ležák na Kmenové kartě
		WITH D as (
			SELECT
				S.IDKmenZbozi
				,CAST(CASE WHEN U.A IS NULL THEN 0 ELSE 1 END as BIT) as Lezak
			FROM TabStavSkladu S
				LEFT OUTER JOIN Tabx_RayService_LezakyUser U ON S.ID = U.IDStavSkladu AND U.LoginName = SUSER_SNAME()
			WHERE S.IDSklad = @IDSklad
			)
		MERGE TabKmenZbozi_EXT as E
		USING D ON E.ID = D.IDKmenZbozi
		WHEN MATCHED THEN
			UPDATE SET _lezaky = D.Lezak
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ID, _lezaky)
			VALUES(D.IDKmenZbozi,D.Lezak);

	IF @TranCountPred = 0 COMMIT;

END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	RAISERROR (@ErrorMessage,16,1);
	RETURN;
END CATCH;
GO

