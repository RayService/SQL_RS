USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_PrikazHromZmena_DoprednaPriprava]    Script Date: 26.06.2025 9:13:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_PrikazHromZmena_DoprednaPriprava]
	@_rizene_suseni BIT
	,@ID INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadná změna příznaku - Dopředná příprava výroby
-- =============================================

MERGE TabPrikaz_EXT ET
USING ( 
    VALUES (@ID, @_rizene_suseni)
) AS V (ID, _rizene_suseni) 
ON ET.ID = V.ID
WHEN MATCHED THEN
   UPDATE SET _rizene_suseni = V._rizene_suseni
WHEN NOT MATCHED BY TARGET THEN
   INSERT (ID, _rizene_suseni)
   VALUES (V.ID, V._rizene_suseni);
GO

