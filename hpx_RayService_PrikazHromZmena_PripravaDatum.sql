USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_PrikazHromZmena_PripravaDatum]    Script Date: 26.06.2025 9:13:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_PrikazHromZmena_PripravaDatum]
	@_pocet_opraveno DATETIME
	,@ID INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadná změna příznaku - Datum zadání do přípravy
-- =============================================

MERGE TabPrikaz_EXT ET
USING ( 
    VALUES (@ID, @_pocet_opraveno)
) AS V (ID, _pocet_opraveno) 
ON ET.ID = V.ID
WHEN MATCHED THEN
   UPDATE SET _pocet_opraveno = V._pocet_opraveno
WHEN NOT MATCHED BY TARGET THEN
   INSERT (ID, _pocet_opraveno)
   VALUES (V.ID, V._pocet_opraveno);
GO

