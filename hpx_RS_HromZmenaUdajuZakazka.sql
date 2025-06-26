USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmenaUdajuZakazka]    Script Date: 26.06.2025 15:24:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmenaUdajuZakazka]
@Stredisko NVARCHAR(30),
@kontrola1 bit,
@Zadavatel INT,
@kontrola2 bit,
@NavaznaZak NVARCHAR(15),
@kontrola3 bit,
@NadrizenaZak NVARCHAR(15),
@kontrola4 bit,
@_EXT_RS_puvodni_zakazka NVARCHAR(15),
@kontrola5 bit,
@DruhyNazev NVARCHAR(100),
@kontrola6 bit,
@Stav NVARCHAR(15),
@kontrola7 bit,

@ID INT
AS

IF @kontrola1 = 1
BEGIN
UPDATE TabZakazka SET Stredisko=@Stredisko WHERE ID = @ID
END

IF @kontrola2 = 1
BEGIN
UPDATE TabZakazka SET Zadavatel=@Zadavatel WHERE ID = @ID
END

IF @kontrola3 = 1
BEGIN
UPDATE TabZakazka SET NavaznaZak=@NavaznaZak WHERE ID = @ID
END

IF @kontrola4 = 1
BEGIN
UPDATE TabZakazka SET NadrizenaZak=@NadrizenaZak WHERE ID = @ID
END

IF @kontrola5 = 1
BEGIN
--UPDATE TabZakazka_EXT SET _EXT_RS_puvodni_zakazka=@_EXT_RS_puvodni_zakazka WHERE ID = @ID
--END
IF (SELECT tze.ID  FROM TabZakazka_EXT as tze WHERE tze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabZakazka_EXT (ID,_EXT_RS_puvodni_zakazka)
    VALUES (@ID,@_EXT_RS_puvodni_zakazka)
 END
ELSE
UPDATE TabZakazka_EXT SET _EXT_RS_puvodni_zakazka=@_EXT_RS_puvodni_zakazka WHERE ID = @ID
END

IF @kontrola6 = 1
BEGIN
UPDATE TabZakazka SET DruhyNazev=@DruhyNazev WHERE ID = @ID
END

IF @kontrola7 = 1
BEGIN
UPDATE TabZakazka SET Stav=@Stav WHERE ID = @ID
END

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0 AND @kontrola6=0 AND @kontrola7=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

