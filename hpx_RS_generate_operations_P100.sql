USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generate_operations_P100]    Script Date: 26.06.2025 13:11:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_generate_operations_P100] @IDPrikaz INT
AS

DECLARE @TypDilce NVARCHAR(2), @IDTypOperace INT, @IDZakazky INT;
DECLARE @IDDilceVP INT;
DECLARE @IDOper INT;
DECLARE @Operace NVARCHAR(4);
DECLARE @DatumOper DATETIME;
DECLARE @NewIDPrikaz INT;
DECLARE @NewIDOper INT;
DECLARE @retmaznapojeni INT;
DECLARE @retmazoper INT;
DECLARE @Odchylka INT;

BEGIN
	SET @Operace=(SELECT RIGHT(RTRIM('0000'+CAST(ISNULL(MIN(tpr.Operace)-10,'') AS NVARCHAR(4))),4)
	FROM TabPrPostup tpr WITH (NOLOCK)
	WHERE tpr.IDPrikaz=@IDPrikaz AND tpr.IDOdchylkyDo IS NULL
	AND tpr.Operace LIKE '09%')
	SELECT @Operace
	SET @Odchylka=(SELECT TOP 1 ID FROM TabCOdchylek WHERE PermanentniOdchylka=1)

	IF @IDPrikaz IS NOT NULL AND @Operace IS NOT NULL
	BEGIN
		--1.Dogenerovat před první 09xx operaci novou operaci „TP - Informace z výroby VP 000 a 100“. Typové operace číslo 236.
		SELECT @IDTypOperace = 314
		EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @Operace=@Operace, @IDTypoveOperace=@IDTypOperace
	END;
	--31.10.2024 MŽ, na přání OM přidány další dvě operace, původně v generátoru v TPV
	IF NOT EXISTS (SELECT prp.ID FROM TabPrPostup prp WHERE prp.IDPrikaz=@IDPrikaz AND prp.Operace='0971')
	BEGIN
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @Operace='0971', @IDTypoveOperace=562
	END;
	IF NOT EXISTS (SELECT prp.ID FROM TabPrPostup prp WHERE prp.IDPrikaz=@IDPrikaz AND prp.Operace='0981')
	BEGIN
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @Operace='0981', @IDTypoveOperace=80
	END;
	--2.Dogenerovat za poslední operaci operace: 
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=804;		--změna MŽ, 19.9.2024 na přání OR přidat operaci TP - Konzultace VP100
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=839;		--změna MŽ, 7.4.2025 na přání OM přidat operaci TP - Kontrola podkladů z VP 100 (Technologie)
	BEGIN
	DECLARE @NewID INT
	EXEC @NewID=hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=542;		--změna MŽ, 19.6.2025 na přání OM přidat operaci TP - Zapracování podkladů z VP100
	--MŽ 25.6.2025 na přání OM přidat generování odpovědné osoby a ID dle dílce z příkazu pouze pro 542
		DECLARE @_EXT_B2ADIMARS_IdAssignedEmployee INT, @_OdpOsOp NVARCHAR(20)
		SELECT @_EXT_B2ADIMARS_IdAssignedEmployee=tkze.ID, @_OdpOsOp=tkze._TechnikTPV100
		FROM TabPrikaz tp
		LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tp.IDTabKmen
		WHERE tp.ID=@IDPrikaz
		IF NOT EXISTS (SELECT * FROM TabPrPostup_EXT WHERE ID=@NewID)
		BEGIN
			INSERT INTO TabPrPostup_EXT (ID, _EXT_B2ADIMARS_IdAssignedEmployee, _OdpOsOp)
			VALUES (@NewID, @_EXT_B2ADIMARS_IdAssignedEmployee, @_OdpOsOp)
		END;
		ELSE
		BEGIN
			UPDATE TabPrPostup_EXT SET _EXT_B2ADIMARS_IdAssignedEmployee=@_EXT_B2ADIMARS_IdAssignedEmployee, _OdpOsOp=@_OdpOsOp WHERE ID=@NewID
		END
	END;
	
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=543;		--TP - Validace podkladů pro VP200/500 (TO 1200), 
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=611;		--FAIR - TK - včetně foto (TO 9936),
	--EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=612;		 -- FAIR – TPV (TO 9937) 31.10.2024 na přání OM zrušeno
	EXEC hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=613;		-- a FAIR - TK - ukládání + odvádění (TO 9938).
	--3.Na všech operacích, kromě skladu a TK změnit středisko na 20021000 (TabStrom.ID=261) a pracoviště KUSOVÁ V. (ID prac=247), MŽ, 26.4.2023 změna ID na 250*/
	UPDATE tprp SET pracoviste=250
	FROM TabPrPostup tprp
	LEFT OUTER JOIN TabCPraco tcpo ON tprp.Pracoviste=tcpo.ID
	LEFT OUTER JOIN TabCPraco_EXT tcpoe ON tcpoe.ID=tcpo.ID
	WHERE (tprp.IDOdchylkyDo IS NULL AND tprp.IDPrikaz=@IDPrikaz AND ISNULL(tcpoe._EXT_RS_wokplaceQA,0)<>1 AND ISNULL(tcpoe._EXT_RS_workplaceWH,0)<>1)
END;

GO

