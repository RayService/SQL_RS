USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_edit_CalculatedPrice]    Script Date: 26.06.2025 13:45:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_edit_CalculatedPrice]
@Cena_vypoctena1 NUMERIC(19,6),
@kontrola1 BIT,
@Koef NUMERIC(19,6),
@kontrola2 BIT,
@ID INT
AS
SET NOCOUNT ON

IF @kontrola1 = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena=@Cena_vypoctena1 FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END;
IF @kontrola2 = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena=Cena_vypoctena*@Koef FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END;
IF @kontrola1=0 AND @kontrola2=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN;
END;
IF @kontrola1=1 AND @kontrola2=1
BEGIN
RAISERROR('Nic neproběhne, je zatržena nepovolená kombinace.',16,1)
RETURN;
END;
GO

