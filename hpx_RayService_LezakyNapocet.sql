USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_LezakyNapocet]    Script Date: 26.06.2025 8:43:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Create date: 19.6.2012
-- Description:	Ležáky - Nápočet
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_LezakyNapocet]
	@Datum DATETIME				-- Datum do
	,@PocetMesicu SMALLINT		-- Počet měšíců 
	,@ProcentoVydej NUMERIC(5,2)-- výdej v daném období < @ProcentoVydej z celkového množství
	,@Podminky BIT				-- Uplatnit / Neuplatnit podmínky
	,@ID INT					-- ID v hvw_RayService_LezakyUser
WITH EXECUTE AS N'automat'
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @IDSklad NVARCHAR(30);
DECLARE @DatumPS DATETIME;

SET @Datum = (@Datum + '23:59:59.960');
SET @DatumPS = DATEADD(MONTH,-@PocetMesicu,@Datum)+1;

/* kontroly */

-- ID Skladu (buď z řádku nebo z uživatelských konstant)
SELECT @IDSklad = IDSklad FROM hvw_RayService_LezakyUser WHERE ID = @ID;
IF @IDSklad IS NULL
	SELECT @IDSklad = PrednastavenySklad FROM TabUziv WHERE LoginName = SUSER_SNAME();
	
IF @IDSklad IS NULL
	OR NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo = @IDSklad)
	BEGIN
		RAISERROR (N'Neznámý identifikátor skladu! Akci pravděpodobně spouštíte v prázdném přehledu 
a není přednstaven sklad v uživatelských konstantách.',16,1);
		RETURN;
	END;
	
-- nulový / záporný počet měsíců
IF @PocetMesicu <= 0
	BEGIN
		RAISERROR (N'Neplatná hodnota pro Počet měsíců! Musí být > 0.',16,1);
		RETURN;
	END;
	
-- nulový / záporný procento výdeje
IF @ProcentoVydej <= 0
	BEGIN
		RAISERROR (N'Neplatná hodnota pro Procento výdeje ležáku! Musí být > 0.',16,1);
		RETURN;
	END;

/* funkčí tělo procedury */

-- Nejprve smazat fajfku Ležák u položek, které nemají vyplněno pole Důvod ležáku 
UPDATE tkze SET _lezaky=0
FROM TabKmenZbozi_EXT tkze
WHERE tkze._EXT_RS_duvod_lezak IS NULL

-- smažeme záznamy pro daného Usera
DELETE FROM Tabx_RayService_LezakyUser
WHERE LoginName = SUSER_SNAME();

-- pracovní tabulka
IF OBJECT_ID('tempdb..#Lezaky') IS NOT NULL
	DROP TABLE #Lezaky;
CREATE TABLE [#Lezaky](
 	[IDStavSkladu] [int] NOT NULL PRIMARY KEY CLUSTERED
 	,[M] [numeric](19,6) NOT NULL
 	,[S] [numeric](19,6) NOT NULL
 	,[M_PS] [numeric](19,6) NOT NULL
 	,[M_Vydej] [numeric](19,6) NOT NULL);

-- naplnění pracovní tabulky
INSERT INTO #Lezaky(
IDStavSkladu
,M
,S
,M_PS
,M_Vydej)
SELECT
S.ID
,M = ISNULL(MIN(S.Mnozstvi), 0) - SUM(CASE WHEN(D.DatRealizace > @Datum) AND (D.DruhPohybuZbo BETWEEN 0 AND 4)
	THEN CASE WHEN D.DruhPohybuZbo IN (0,3) THEN ISNULL(P.MnozstviReal, 0) ELSE ISNULL(-P.MnozstviReal, 0) END ELSE 0 END)
,S = ISNULL(MIN(S.StavSkladu), 0) - SUM(CASE WHEN(D.DatRealizace > @Datum) AND (D.DruhPohybuZbo BETWEEN 0 AND 4)
	THEN CASE WHEN D.DruhPohybuZbo IN (0,3) THEN ISNULL(P.CCEvid, 0) ELSE ISNULL(-P.CCEvid, 0) END ELSE 0 END)
,M_PS = ISNULL(MIN(S.Mnozstvi), 0) - SUM(CASE WHEN(D.DatRealizace > @DatumPS) AND (D.DruhPohybuZbo BETWEEN 0 AND 4)
	THEN CASE WHEN D.DruhPohybuZbo IN (0,3) THEN ISNULL(P.MnozstviReal, 0) ELSE ISNULL(-P.MnozstviReal, 0) END ELSE 0 END)
,M_Vydej = SUM(CASE WHEN(D.DatRealizace > @DatumPS AND D.DatRealizace <= @Datum) AND (D.DruhPohybuZbo BETWEEN 2 AND 4) AND D.RadaDokladu <> N'622' 
	THEN CASE WHEN D.DruhPohybuZbo = 3 THEN ISNULL(-P.MnozstviReal, 0) ELSE ISNULL(P.MnozstviReal, 0) END ELSE 0 END)
FROM TabStavSkladu AS S
	INNER JOIN TabKmenZbozi KM ON S.IDKmenZbozi = KM.ID
	INNER JOIN TabPohybyZbozi P ON S.ID = P.IDZboSklad
	LEFT OUTER JOIN TabDokladyZbozi D ON P.IDDoklad = D.ID AND D.DatRealizace > @DatumPS
	LEFT OUTER JOIN TabParametryKmeneZbozi PKM ON S.IDKmenZbozi = PKM.IDKmenZbozi
	INNER JOIN TabKmenZbozi_EXT KME ON KME.ID = KM.ID	--nově zařazený join pro položky, které nemají vyplněno pole Důvod není ležák
WHERE KM.Sluzba = 0
	AND S.IDSklad = @IDSklad
	AND (@Podminky = 0 OR (PKM.BlokovanoProVyrobu = 0 AND ISNULL(KME._EXT_RS_MnozstviPlanovanaVyrobaLPP,0)=0 AND S.Rezervace = 0 AND S.MnozstviKVydeji = 0))	--MŽ, 20.3.2024 přidána podmínka na množství plánovaná výroba=0, MŽ, 30.1.2025 na přání MO zaměněn atribut _EXT_RAY_MnozPlan za _EXT_RS_MnozstviPlanovanaVyrobaLPP
	AND (KME._EXT_RS_duvod_lezak_neni IS NULL)	--nově zařazená podmínka pro položky, které nemají vyplněno pole Důvod není ležák
GROUP BY S.ID;

-- naplneni ostre tabulky
INSERT INTO Tabx_RayService_LezakyUser(
IDStavSkladu
,M
,S
,A
,M_PS
,M_Vydej
,DatumDo
,PocetMesicu
,ProcentoVydej
,Podminky)
SELECT
IDStavSkladu
,M
,S
,(CASE WHEN M = M_PS THEN 1
	WHEN M < M_PS THEN 2
	WHEN M > M_PS THEN 3
	WHEN M = 0 THEN 4 END) as A
,M_PS
,M_Vydej
,@Datum
,@PocetMesicu
,@ProcentoVydej
,@Podminky
FROM #Lezaky
WHERE ((CASE WHEN (M_PS + M_Vydej) = 0 THEN 0 ELSE (M_Vydej/((M_PS + M_Vydej))) END)*100) < @ProcentoVydej
	AND M_PS > 0
	AND M > 0;

-- žádný ležák
IF @@ROWCOUNT = 0
	BEGIN
		RAISERROR(N'Pro zvolené údaje nesplňuje žádná položka parametry ležáku!',16,1)
	END


-- označit kmenové karty, že jsou ležák (_lezaky=1)
MERGE TabKmenZbozi_EXT AS TARGET
USING Tabx_RayService_LezakyUser AS SOURCE
ON TARGET.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WITH(NOLOCK) WHERE tss.ID = SOURCE.IDStavSkladu) AND SOURCE.LoginName=SUSER_SNAME()
WHEN MATCHED THEN
UPDATE SET TARGET._lezaky=1
;
GO

