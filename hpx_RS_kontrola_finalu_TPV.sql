USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kontrola_finalu_TPV]    Script Date: 26.06.2025 12:06:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kontrola_finalu_TPV]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

DECLARE @Final INT
SET @Final=(SELECT tkz.ID
			FROM #TempDefForm_Validace
			LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=#TempDefForm_Validace.nizsi
			LEFT OUTER JOIN TabParKmZ pkm ON pkm.IDKmenZbozi = tkz.ID
			WHERE (pkm.TypDilce=0))
IF (@Final IS NOT NULL)
BEGIN
  RAISERROR(N'Pokoušíte se vložit finál do kusovníku a není to dobrý nápad!', 16, 1)
  RETURN
END;

DECLARE @rezpol BIT
SET @rezpol=(SELECT RezijniMat
			FROM #TempDefForm_Validace)
IF (@rezpol=1)
BEGIN
  SELECT 2, N'Je zatrženo pole Režijní položka.'
  RETURN
END;

--rozšíření funkce o doplnění fajfky ESD výroba 2.NPNB, pokud vyšší dílec má v kvalifikaci dílce "E" nebo "L"
DECLARE @Polozka INT;
DECLARE @KvalDil NVARCHAR(1);
DECLARE @SKN NVARCHAR(3);
SELECT @Polozka=tkzN.ID, @KvalDil=tkzVe._KvalDil, @SKN=ISNULL(tsze._EXT_RS_OznacovatESD,0)
FROM #TempDefForm_Validace
LEFT OUTER JOIN TabKmenZbozi tkzN WITH(NOLOCK) ON tkzN.ID=#TempDefForm_Validace.nizsi
LEFT OUTER JOIN TabKmenZbozi_EXT tkzNe WITH(NOLOCK) ON tkzNe.ID=tkzN.ID
LEFT OUTER JOIN TabSkupinyZbozi tsz WITH(NOLOCK) ON tsz.SkupZbo=tkzN.SkupZbo
LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze WITH(NOLOCK) ON tsze.ID=tsz.ID
LEFT OUTER JOIN TabKmenZbozi tkzV WITH(NOLOCK) ON tkzV.ID=#TempDefForm_Validace.vyssi
LEFT OUTER JOIN TabKmenZbozi_EXT tkzVe WITH(NOLOCK) ON tkzVe.ID=tkzV.ID
IF ((@KvalDil=N'e' OR @KvalDil=N'l')AND
--((@SKN IN ('830','840','850','678','679','681','690','695')OR(@SKN BETWEEN '671' AND '676')))
@SKN=1
)
BEGIN
UPDATE TabKmenZbozi_EXT SET _2NP=1 WHERE ID=@Polozka
END;


--MŽ, 13.5.2024, rozšíření funkce o kontrolu, že je vyplněno pole Fixní množství
DECLARE @FixniMnozstvi NUMERIC(19,6)
SET @FixniMnozstvi=(SELECT FixniMnozstvi
FROM #TempDefForm_Validace)
IF @FixniMnozstvi>0
BEGIN
  SELECT 2, N'Chcete skutečně použít fixní množství?', N'FixniMnozstvi'
  RETURN
END;
GO

