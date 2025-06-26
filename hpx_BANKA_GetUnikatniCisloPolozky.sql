USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_BANKA_GetUnikatniCisloPolozky]    Script Date: 26.06.2025 10:09:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PluginBanka0100.ExportImport*/CREATE PROCEDURE [dbo].[hpx_BANKA_GetUnikatniCisloPolozky]
@TypPP SMALLINT,
@Format NVARCHAR(64)
AS
SET NOCOUNT ON
DECLARE @CISLO INT
IF NOT EXISTS(SELECT 1 FROM TabBankaPluginUPC WHERE(Format=@Format))
BEGIN
INSERT INTO TabBankaPluginUPC(TypPP,Poradi,DolniMez,HorniMez,Format)VALUES(0,1,1,49999,@Format)
INSERT INTO TabBankaPluginUPC(TypPP,Poradi,DolniMez,HorniMez,Format)VALUES(1,50001,50001,99999,@Format)
END
UPDATE TabBankaPluginUPC SET Autor=suser_id() WHERE(Format=@Format)AND(TypPP=@TypPP)AND(Autor IS NULL)
IF EXISTS(SELECT 1 FROM TabBankaPluginUPC WHERE(Autor=suser_id())AND(Format=@Format)AND(TypPP=@TypPP))
BEGIN
SELECT @CISLO=Poradi FROM TabBankaPluginUPC WHERE(Autor=suser_id())AND(Format=@Format)AND(TypPP=@TypPP)
UPDATE TabBankaPluginUPC SET Poradi=
CASE WHEN Poradi<HorniMez THEN Poradi+1 ELSE DolniMez END
WHERE(Autor=suser_id())AND(Format=@Format)AND(TypPP=@TypPP)
UPDATE TabBankaPluginUPC SET Autor=NULL WHERE(Autor=suser_id())AND(Format=@Format)AND(TypPP=@TypPP)
END
SELECT ISNULL(@Cislo,-1)
GO

