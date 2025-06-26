USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_vypocet_ceniku_kalkulace]    Script Date: 26.06.2025 10:10:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_vypocet_ceniku_kalkulace]
@IDZakazka_cislo NVARCHAR(15),
@ID INT
AS
SET NOCOUNT ON
-- =============================================
-- Author:		MŽ
-- Create date:            3.6.2019
-- Description:	Vygenerování ceníku - souhrnného/strukturního kusovníku dle položek pro kalkulaci.
-- =============================================

DECLARE @IDPol INT
SELECT @IDPol = (SELECT IDKmenZbozi FROM TabPozaZDok_kalk WHERE ID = @ID)
DECLARE @IDZakazka INT
SELECT @IDZakazka = (SELECT ID FROM TabZakazka WHERE CisloZakazky = @IDZakazka_cislo)

DELETE TabStrukKusovnik_kalk FROM TabStrukKusovnik_kalk
--JOIN TabPozaZDok_kalk ON TabPozaZDok_kalk.IDKmenZbozi = TabStrukKusovnik_kalk.IDFinal
WHERE TabStrukKusovnik_kalk.IDZakazka = @IDZakazka

--naplnění tabulky kusovníku
INSERT INTO TabStrukKusovnik_kalk (IDZakazka,IDNizsi,IDVyssi,mnf,Autor,Dat_vypoctu,dilec,material,Vypocteny_prumer,Cena_2,Cena_dilec,Cena_vypoctena)  
SELECT tpzdk.IDZakazka,tkv.nizsi, tkv.vyssi, SUM(tkv.mnozstviSeZtratou), SUSER_SNAME(),GETDATE(),KZ.Dilec,KZ.Material,0,0,0,0
FROM TabPozaZDok_kalk tpzdk
LEFT OUTER JOIN TabKvazby tkv ON tpzdk.IDKmenZbozi = tkv.vyssi
LEFT OUTER JOIN TabKmenZbozi KZ ON KZ.ID = tkv.nizsi AND tkv.ZmenaDo IS NULL
WHERE tkv.ZmenaDo IS NULL
GROUP BY tpzdk.IDZakazka,tkv.nizsi, tkv.vyssi,KZ.Dilec,KZ.Material
GO

