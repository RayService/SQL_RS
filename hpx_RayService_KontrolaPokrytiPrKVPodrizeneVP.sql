USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_KontrolaPokrytiPrKVPodrizeneVP]    Script Date: 26.06.2025 9:52:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_KontrolaPokrytiPrKVPodrizeneVP]
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Kontrola pokrytí materiálů a polotovarů pro výrobu s respektovanim podsestav
-- =============================================

-- kontrola existence temptable #TabPrikazKontrPokrytiPrKV, #TabKontrPokrytiPrKV - jinak neni spustena kontrola pokryti
IF OBJECT_ID('tempdb..#TabPrikazKontrPokrytiPrKV') IS NULL
	OR OBJECT_ID('tempdb..#TabKontrPokrytiPrKV ') IS NULL
	BEGIN
		RAISERROR (N'Akci lze spustit pouze za existence nápočtu Kontroly pokrytí materiálů a polotovarů pro výrobu!',16,1);
		RETURN;
	END;

-- odecet
WITH D as 
	(
		SELECT
			IDPrikazVyssi = PV.IDPrikaz
			,P.IDTabKmen
			,Pokryto = P.kusy_ciste
		FROM TabVazbyPrikazu V
			INNER JOIN #TabPrikazKontrPokrytiPrKV PV ON V.IDPrikazVyssi = PV.IDPrikaz
			INNER JOIN TabPrikaz P ON V.IDPrikaz = P.ID
	)
UPDATE C SET
	NepokrytyPozadavek = CASE WHEN (C.NepokrytyPozadavek - D.Pokryto) < 0. THEN 0. ELSE (C.NepokrytyPozadavek - D.Pokryto) END
FROM #TabKontrPokrytiPrKV C
	INNER JOIN TabPrKVazby KV ON KV.IDPrikaz = C.IDPrikaz AND KV.Doklad = C.Doklad
	INNER JOIN D ON KV.IDPrikaz = D.IDPrikazVyssi AND KV.nizsi = D.IDTabKmen
WHERE C.Upozorneni = 1;

UPDATE #TabKontrPokrytiPrKV SET Upozorneni = 0 WHERE NepokrytyPozadavek = 0. AND Upozorneni = 1;
GO

