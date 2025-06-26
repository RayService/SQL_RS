USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZjistiUzavreniVP909]    Script Date: 26.06.2025 11:16:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZjistiUzavreniVP909]
	@IDMzdy INT
AS
SET NOCOUNT ON;

-- ==============================================================================================================
-- Author:		MŽ
-- Description:	Při evidenci práce na VP řady 909 a zároveň na poslední nesplněné operaci, kde je vyplněno Odpovědná osoba úkolu. Tato procedura předplní údaj, zda uzavřít.
-- Date: 30.6.2021
-- ==============================================================================================================
--DECLARE @IDMzdy INT=xxxxxxxxxxxxxxxxxxx;
DECLARE @IDPrikaz INT;
DECLARE @IDOperation INT;
DECLARE @IDControl INT;
DECLARE @KonecneOdvedeniNatvrdo BIT;
DECLARE @Dilec INT, @DatPripadu datetime, @IDPrikazZdroj int, @IDPrikazCil int, @Doklad int, @IDDilec int, @mnozstvi numeric(19,6);

SET @IDOperation=(SELECT tpp.ID
					FROM TabPrPostup tpp
					LEFT OUTER JOIN TabPrikazMzdyAZmetky tpmz WITH(NOLOCK) ON tpmz.IDPrikaz=tpp.IDPrikaz AND tpmz.DokladPrPostup=tpp.Doklad
					WHERE tpmz.ID=@IDMzdy AND tpp.IDOdchylkyDo IS NULL AND tpp.Prednastaveno=1);
SET @IDPrikaz=(SELECT TOP 1 IDPrikaz FROM TabPrPostup WHERE ID=@IDOperation);

IF (EXISTS(
SELECT tpp.ID
FROM TabPrPostup tpp WITH(NOLOCK)
  LEFT OUTER JOIN TabPrPostup_EXT tpp_EXT WITH(NOLOCK) ON tpp_EXT.ID=tpp.ID
  LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tpp.IDPrikaz=tp.ID
WHERE
((tpp.IDOdchylkyDo IS NULL)AND((tpp.IDPrikaz=@IDPrikaz))AND(tpp.Splneno=0)AND(tpp_EXT._OdpOsOp IS NOT NULL)AND(tpp.ID=@IDOperation)))
AND(
SELECT
COUNT(tpp.ID)
FROM TabPrPostup tpp WITH(NOLOCK)
  LEFT OUTER JOIN TabPrPostup_EXT tpp_EXT WITH(NOLOCK) ON tpp_EXT.ID=tpp.ID
  LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tpp.IDPrikaz=tp.ID
WHERE
((tpp.IDOdchylkyDo IS NULL)AND((tpp.IDPrikaz=@IDPrikaz))AND(tpp.Splneno=0)AND(tpp_EXT._OdpOsOp IS NOT NULL)))=1)
BEGIN
IF EXISTS(SELECT * FROM Tabx_RS_UzavritVP909)
DELETE FROM Tabx_RS_UzavritVP909
ELSE
BEGIN
	INSERT INTO Tabx_RS_UzavritVP909 (IDPrikaz,Uzavrit)
	VALUES (@IDPrikaz,1)
END
END;
GO

