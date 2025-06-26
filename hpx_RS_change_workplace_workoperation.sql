USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_change_workplace_workoperation]    Script Date: 26.06.2025 13:08:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_change_workplace_workoperation] @IDPrac INT, @ID INT
AS
--DECLARE @ID INT/*ID radku*/=2875678
DECLARE @IDPrikaz INT, @Doklad INT, @IDDilec INT, @IDOdch INT, @IDOdchOd INT, @IDPrPNew INT

SELECT @IDPrikaz=tpp.IDPrikaz, @Doklad=tpp.Doklad, @IDDilec=tpp.dilec, @IDOdchOd=tpp.IDOdchylkyOd
FROM TabPrPostup tpp
WHERE tpp.ID=@ID
SELECT @IDOdch=ID
FROM TabCOdchylek
WHERE PermanentniOdchylka=1

SELECT @IDPrikaz, @Doklad, @IDDilec, @IDOdch, @IDOdchOd AS OdchylkaOD

IF @IDOdchOd IS NOT NULL
BEGIN
UPDATE TabPrPostup SET pracoviste = @IDPrac/*ID*/, DatZmeny = GETDATE(), Zmenil = SUSER_SNAME()
WHERE ID = @ID

EXEC hp_PrepocetSkladuPrKVazby_Prikaz @IDPrikaz=@IDprikaz, @JenProDilec=@IDDilec, @JenProDoklad=@Doklad
EXEC hp_PrepocetSkladuPrNVazby_Prikaz @IDPrikaz=@IDprikaz, @JenProDilec=@IDDilec, @JenProDoklad=@Doklad
EXEC hp_PrepocetSkladuPrVPVazby_Prikaz @IDPrikaz=@IDprikaz, @JenProDilec=@IDDilec
END;


IF @IDOdchOd IS NULL
BEGIN
EXEC hp_OdchylkujPrPostup @IDPrikaz=@IDprikaz, @Doklad=@Doklad, @Alt=N'A', @IDOdchNew=@IDOdch
SET @IDPrPNew=IDENT_current('TabPrPostup')
SELECT @IDPrPNew
UPDATE TabPrPostup SET pracoviste = @IDPrac/*ID*/, DatZmeny = GETDATE(), Zmenil = SUSER_SNAME()
WHERE ID=@IDPrPNew--IDPrikaz=@IDPrikaz AND Doklad=@Doklad AND IDOdchylkyOd = @IDOdchOd

EXEC hp_PrepocetSkladuPrKVazby_Prikaz @IDPrikaz=@IDprikaz, @JenProDilec=@IDDilec, @JenProDoklad=@Doklad
EXEC hp_PrepocetSkladuPrNVazby_Prikaz @IDPrikaz=@IDprikaz, @JenProDilec=@IDDilec, @JenProDoklad=@Doklad
EXEC hp_PrepocetSkladuPrVPVazby_Prikaz @IDPrikaz=@IDprikaz, @JenProDilec=@IDDilec
END;

GO

