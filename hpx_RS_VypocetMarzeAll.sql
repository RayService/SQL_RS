USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VypocetMarzeAll]    Script Date: 26.06.2025 13:49:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VypocetMarzeAll]
@Year INT,
@Volba1 BIT,
@Volba2 BIT,
@Volba3 BIT,
@ID INT
AS

IF NOT EXISTS (SELECT Nazev FROM TabObdobi WHERE Nazev=@Year)
BEGIN
RAISERROR( 'Pro zadané období neexistuje záznam v číselníku období.',16,1)
RETURN
END;

IF @Volba1 = 1
BEGIN
EXEC dbo.hpx_RS_VypocetMarzeDistr @Year, @ID
END;
IF @Volba1 = 1
BEGIN
EXEC dbo.hpx_RS_VypocetMarzeKabely @Year, @ID
END;
IF @Volba1 = 1
BEGIN
EXEC dbo.hpx_RS_VypocetMarzeBoxy @Year, @ID
END;
IF @Volba1=0 AND @Volba2=0 AND @Volba3=0
BEGIN
RAISERROR('Výpočet neproběhne, není zatržena žádná volba.',16,1)
RETURN
END;
GO

