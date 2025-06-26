USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_uprava_koeficientu]    Script Date: 26.06.2025 10:04:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_uprava_koeficientu]
@Vyporadani_premioveho_koef NUMERIC(19,6),
@Premiovy_koef_od NUMERIC(19,6),
@Premiovy_koef_do NUMERIC(19,6),
@Koef_1_od NUMERIC(19,6),
@Koef_1_do NUMERIC(19,6),
@Koef_08_od NUMERIC(19,6),
@Koef_08_do NUMERIC(19,6),
@Koef_06_od NUMERIC(19,6),
@Koef_06_do NUMERIC(19,6),
@Koef_0_od NUMERIC(19,6),
@Koef_0_do NUMERIC(19,6),
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
Vyporadani_premioveho_koef = @Vyporadani_premioveho_koef,
Premiovy_koef_od = @Premiovy_koef_od,
Premiovy_koef_do = @Premiovy_koef_do,
Koef_1_od = @Koef_1_od,
Koef_1_do = @Koef_1_do,
Koef_08_od = @Koef_08_od,
Koef_08_do = @Koef_08_do,
Koef_06_od = @Koef_06_od,
Koef_06_do = @Koef_06_do,
Koef_0_od = @Koef_0_od,
Koef_0_do = @Koef_0_do,
Zmenil = SUSER_SNAME(),
DatZmeny = GETDATE()
WHERE ID = @ID
GO

