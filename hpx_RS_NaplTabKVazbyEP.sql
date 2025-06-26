USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NaplTabKVazbyEP]    Script Date: 26.06.2025 15:37:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NaplTabKVazbyEP]
AS
SET NOCOUNT ON

--procedura na vygenerování kusovníkových vazeb nad položkou EP s respektováním množství zbývá dodat
--nejprve pročistit tabulku, je-li tam něco s ID pohybu stejným jako @ID
--naplnit tabulku s uložením ID pohybu

DECLARE @IDZmeny INT
DECLARE @IDDilce INT
DECLARE @IDPohybu INT
DECLARE @MnoPohybu NUMERIC(19,6)

--cvičně - v HEO smazat
--IF OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL DROP TABLE #TabExtKomID
--CREATE TABLE #TabExtKomID (ID INT NOT NULL, Typ TINYINT NULL, Poznamka NVARCHAR(255) NULL)
--INSERT INTO #TabExtKomID (ID)
--SELECT tpz.ID
--FROM TabPohybyZbozi tpz
--WHERE tpz.IDDoklad=1883758

--ostře
IF OBJECT_ID('tempdb..#TabIDDilcu') IS NOT NULL DROP TABLE #TabIDDilcu
CREATE TABLE #TabIDDilcu (ID INT IDENTITY(1,1) NOT NULL, IDPohybu INT NOT NULL, IDDilce INT NULL, MnozstviPohybu NUMERIC(19,3))
INSERT INTO #TabIDDilcu (IDPohybu, IDDilce, MnozstviPohybu)
SELECT tpz.ID,tkz.ID, tpz.Mnozstvi-tpz.MnOdebrane
FROM #TabExtKomID ei
LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.ID=ei.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.Mnozstvi-tpz.MnOdebrane>0

--SELECT * FROM #TabIDDilcu

--definice cyklu
DECLARE @IDStart INT, @IDKonec INT

SELECT @IDStart=MIN(ID), @IDKonec=MAX(ID)
FROM #TabIDDilcu
--nahodíme cyklus
WHILE @IDStart<=@IDKonec
	BEGIN
		
		SET @IDDilce=(SELECT IDDilce FROM #TabIDDilcu WHERE ID=@IDStart)
		SET @IDPohybu=(SELECT IDPohybu FROM #TabIDDilcu WHERE ID=@IDStart)
		SET @MnoPohybu=(SELECT MnozstviPohybu FROM #TabIDDilcu WHERE ID=@IDStart)
		SET @IDZmeny=(SELECT TOP 1 TabCzmeny.ID
		FROM TabCzmeny
		WHERE (TabCZmeny.ID IN  (SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDDilce AND (IDVarianta IS NULL OR IDVarianta=0) AND ZmenaOd IS NOT NULL 
		UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDDilce AND (IDVarianta IS NULL OR IDVarianta=0) AND ZmenaDo IS NOT NULL))
		ORDER BY TabCZmeny.datum DESC)
		--začátek generování kusovníku
			BEGIN
			--vymažeme data pro označený řádek
				DELETE FROM Tabx_RS_TabKvazby WHERE IDPohybu=@IDPohybu
				--vložíme nová
				INSERT INTO Tabx_RS_TabKvazby (IDPohybu,IDVazby,vyssi,IDVarianta,nizsi,ZmenaOd,ZmenaDo,pozice,Operace,mnozstvi,mnoz_zad,ProcZtrat,Prirez,Poznamka,ID1,
				DatPorizeni,Autor,
				mnozstviSeZtratou,IDVzorceSpotMat,PromA,PromB,PromC,PromD,PromE,SpotRozmer,FixniMnozstvi,DavkaTPV
				,RezijniMat,VyraditZKalkulace,IDZakazModif,VychoziSklad)
				SELECT @IDPohybu,tkv.ID,tkv.vyssi,tkv.IDVarianta,tkv.nizsi,tkv.ZmenaOd,tkv.ZmenaDo,tkv.pozice,tkv.Operace,tkv.mnozstvi,tkv.mnozstviSeZtratou*@MnoPohybu,tkv.ProcZtrat,tkv.Prirez,tkv.Poznamka,tkv.ID1,
				GETDATE(),SUSER_SNAME(),
				tkv.mnozstviSeZtratou,tkv.IDVzorceSpotMat,tkv.PromA,tkv.PromB,tkv.PromC,tkv.PromD,tkv.PromE,tkv.SpotRozmer,tkv.FixniMnozstvi,tkv.DavkaTPV
				,tkv.RezijniMat,tkv.VyraditZKalkulace,tkv.IDZakazModif,tkv.VychoziSklad
				FROM TabKvazby tkv
				LEFT OUTER JOIN TabCzmeny czOd ON tkv.ZmenaOd=czOd.ID
				LEFT OUTER JOIN TabCzmeny czDo ON tkv.ZmenaDo=czDo.ID
				WHERE
				(tkv.vyssi=@IDDilce AND((czOd.platnostTPV=1 AND czOd.datum<=GETDATE()))
				AND(((czDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (czDo.platnostTPV=1 AND czDo.datum>GETDATE())) )))
			END;
	SET @IDStart=@IDStart+1
	END; --konec cyklu



--SELECT *
--FROM Tabx_RS_TabKVazby

GO

