USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_PredvyplneniManipulacnichJednotek]    Script Date: 26.06.2025 14:37:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_PredvyplneniManipulacnichJednotek]
@IdZasilky INT,
@IdDoklad INT
AS
DECLARE @MU_type_one NVARCHAR(50), @Pieces_count_one INT
SELECT @MU_type_one=FDE._Balikobot_mu_type_one
, @Pieces_count_one=FDE._Balikobot_pieces_count_one
FROM TabFormaDopravy FD
LEFT OUTER JOIN TabFormaDopravy_EXT FDE ON FDE.ID=FD.ID
WHERE FD.FormaDopravy=(SELECT FormaDopravy FROM TabDokladyZbozi WHERE ID=@IdDoklad)
UPDATE Tabx_BalikobotBaliky SET
mu_type=@MU_type_one
, pieces_count=@Pieces_count_one
WHERE IdZasilky=@IdZasilky
GO

