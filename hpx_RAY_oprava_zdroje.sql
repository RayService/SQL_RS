USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_oprava_zdroje]    Script Date: 26.06.2025 9:58:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_oprava_zdroje]
@Zdroje nvarchar(100),
@Poznamka ntext,
@ID INT
AS

UPDATE RAY_Personalistika_Zdroje SET
Zdroje = @Zdroje,
Poznamka = @Poznamka,
Zmenil = SUSER_SNAME(),
DatZmeny = GETDATE()
WHERE ID = @ID
GO

