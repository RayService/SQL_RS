USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniZmenyNaDilciPresVP]    Script Date: 26.06.2025 10:58:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniZmenyNaDilciPresVP]
	@IDPrikaz INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		MŽ
-- Description:	Procedura na založení změny na dílci při zadání VP řady 100 daného dílce.
-- Date: 25.6.2021
-- =============================================
DECLARE @IDDilce INT;
DECLARE @CisloAutor INT;
DECLARE @Autor NVARCHAR(128);
DECLARE @CisloZmeny INT;
DECLARE @IDZmeny INT;
DECLARE @IDDavka INT;
BEGIN
SET @IDDilce=(SELECT tp.IdTabKmen FROM TabPrikaz tp WHERE tp.ID=@IDPrikaz);
SET @CisloAutor=(SELECT  tcz.ID FROM TabCisZam tcz LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze._TechnikTPV100=tcz.PrijmeniJmeno WHERE tkze.ID=@IDDilce AND  ((ISNULL((SELECT TabZamMzd.StavES FROM TabZamMzd WITH(NOLOCK) WHERE TabZamMzd.IdObdobi=(SELECT
tabmzdobd.ID FROM TabMzdObd WITH(NOLOCK)
WHERE TabMzdObd.Mes = (SELECT DATEPART(MONTH,GETDATE())) AND TabMzdObd.Rok = (SELECT DATEPART(YEAR,GETDATE()))) AND TabZamMzd.ZamestnanecId=tcz.ID), 10)))=0);
SET @Autor=(SELECT tcz.Jmeno+' '+tcz.Prijmeni FROM TabCisZam tcz WHERE tcz.LoginId=SUSER_SNAME());
SET @CisloZmeny=(SELECT ISNULL(MAX(CASE WHEN ISNUMERIC(LTRIM(RTRIM(CisZmeny))+N'.E0')=1 AND LEN(LTRIM(CisZmeny))<=9 THEN CONVERT(int, CONVERT(numeric(19,6), CisZmeny)) END),0) + 1 
					FROM TabCZmeny
					WHERE ISNUMERIC(LTRIM(RTRIM(CisZmeny))+N'.E0')=1 AND LEN(LTRIM(CisZmeny))<=9  AND Rada=N'X');
--založení změny do číselníku změn
INSERT INTO TabCzmeny (Rada, ciszmeny, navrh, Poznamka, os_cislo, datum, Autor,PermanentniZmena,Running,IntPermanentniZmena)
VALUES ('X',@CisloZmeny,'Zapracování po VP100','',@CisloAutor,GETDATE(),@Autor,0,0,0)
SET @IDZmeny=(SELECT SCOPE_IDENTITY());
EXEC dbo.hp_ZdvojeniKonstrukceATech @IDVyssi=@IDDilce, @IDZmena=@IDZmeny
END;
GO

