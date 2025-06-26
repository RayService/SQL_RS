USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VlozeniPersonalniSlozky]    Script Date: 26.06.2025 15:26:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_VlozeniPersonalniSlozky] @Cislo INT, @CisloZam INT
AS

SET NOCOUNT ON
BEGIN
--cvičně
--SET @Cislo=24
--SET @CisloZam=600

DECLARE @PorCislo INT
DECLARE @IdObdobi INT
SET @PorCislo=(SELECT MAX(PorCislo) FROM TabPerSlozZam)+1
SET @IdObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE (Stav = 1))

INSERT INTO TabPerSlozZam (IdObdobi, PorCislo, Cislo, CisloZam)
VALUES (@IdObdobi,@PorCislo,@Cislo,@CisloZam)

END;

GO

