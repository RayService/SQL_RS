USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ValidaceDatKmenZbozi]    Script Date: 26.06.2025 15:36:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_ValidaceDatKmenZbozi]
@ValidaceOK BIT,
@NovaVeta BIT,
@NovaVetaExt BIT
AS
IF EXISTS (SELECT*FROM #TempDefForm_Validace INNER JOIN TabSortiment ON TabSortiment.ID=#TempDefForm_Validace.IdSortiment
WHERE TabSortiment.K1 like N'%VD%' AND ISNULL(#TempDefForm_Validace.BaleniTXT,N'') = N'')
BEGIN 
      RAISERROR (N'Pole Pomocný text musí být vyplněno!', 16, 1)
      RETURN
END
--generování skladové karty na výchozím skladu pro odvádění
DECLARE @IDSkladOdv NVARCHAR(30)
DECLARE @IDKmen INT=(SELECT ID FROM #TempDefForm_Validace)
SET @IDSkladOdv=(SELECT parkm.VychoziSklad
FROM #TempDefForm_Validace val
LEFT OUTER JOIN TabParametryKmeneZbozi parkm ON parkm.IDKmenZbozi=val.ID)
IF @IDSkladOdv IS NOT NULL
BEGIN
EXEC hp_InsertStavSkladu @IDKmen=@IDKmen, @IDSklad=@IDSkladOdv
END;
--generování skladové karty na výchozím skladu pro výdej do výroby
DECLARE @IDSkladVyd NVARCHAR(30)
SET @IDSkladVyd=(SELECT parkm.VychoziSklad
FROM #TempDefForm_Validace val
LEFT OUTER JOIN TabParKmZ parkm ON parkm.IDKmenZbozi=val.ID)
IF @IDSkladVyd IS NOT NULL
BEGIN
EXEC hp_InsertStavSkladu @IDKmen=@IDKmen, @IDSklad=@IDSkladVyd
END;
GO

