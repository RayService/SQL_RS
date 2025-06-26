USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_TxtPol_OpravaII]    Script Date: 26.06.2025 11:25:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_TxtPol_OpravaII]
@_EXT_B2A_NutnostInvestice NVARCHAR(10),
@_EXT_B2A_ZpusobRealizace NVARCHAR(15),
--@IDZakazka INT,
--@Poznamka NTEXT,
@ID INT
AS

BEGIN
UPDATE  TabOZTxtPol_EXT SET
_EXT_B2A_NutnostInvestice = @_EXT_B2A_NutnostInvestice,
_EXT_B2A_ZpusobRealizace= @_EXT_B2A_ZpusobRealizace
FROM TabOZTxtPol_EXT
WHERE ID = @ID
/*
UPDATE txt SET
txt.IDZakazka = @IDZakazka
--,txt.Poznamka = @Poznamka
FROM TabOZTxtPol txt
WHERE txt.ID = @ID
*/
END
GO

