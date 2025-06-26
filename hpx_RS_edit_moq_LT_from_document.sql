USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_edit_moq_LT_from_document]    Script Date: 26.06.2025 12:45:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_edit_moq_LT_from_document]
@_poptMOQ NUMERIC(19,6),
@kontrola1 BIT,
@_poptLT NUMERIC(19,6),
@kontrola2 BIT,
@ID INT
AS
SET NOCOUNT ON

IF @kontrola1 = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Dokl_poptMOQ=@_poptMOQ FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END;
IF @kontrola2 = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Dokl_poptLT=@_poptLT FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END;
IF @kontrola1=0 AND @kontrola2=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN;
END;
GO

