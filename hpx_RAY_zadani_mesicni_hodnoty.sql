USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_zadani_mesicni_hodnoty]    Script Date: 26.06.2025 9:55:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_zadani_mesicni_hodnoty]
@Mesic_value NUMERIC(20,6),
@Kumulativ_value NUMERIC(20,6),
@ID INT
AS

UPDATE RAY_Parametry_Values SET
Mesic_value = @Mesic_value,
Kumulativ_value = @Kumulativ_value
WHERE ID = @ID
GO

