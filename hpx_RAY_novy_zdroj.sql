USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_novy_zdroj]    Script Date: 26.06.2025 9:58:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_novy_zdroj]
@Zdroje nvarchar(100),
@Poznamka ntext
AS

INSERT INTO RAY_Personalistika_Zdroje (Zdroje, Poznamka, Autor, DatPorizeni) VALUES (@Zdroje, @Poznamka, SUSER_SNAME(), GETDATE())
GO

