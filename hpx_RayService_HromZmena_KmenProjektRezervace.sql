USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_HromZmena_KmenProjektRezervace]    Script Date: 26.06.2025 9:15:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_HromZmena_KmenProjektRezervace]
	@_projrezdil NVARCHAR(10)
	,@ID INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadná změna externích atributů
-- =============================================

MERGE TabKmenZbozi_EXT ET
USING ( 
    VALUES (@ID, @_projrezdil)
) AS V (ID, _projrezdil) 
ON ET.ID = V.ID
WHEN MATCHED THEN
   UPDATE SET _projrezdil = V._projrezdil
WHEN NOT MATCHED BY TARGET THEN
   INSERT (ID, _projrezdil)
   VALUES (V.ID, V._projrezdil);
GO

