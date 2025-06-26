USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_time_edit_duplicite]    Script Date: 26.06.2025 10:27:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_time_edit_duplicite]
@_EXT_RS_material_time_duplicite NUMERIC (19,6),
@ID INT
AS

-- =============================================
-- Author:		MŽ
-- Create date:            14.2.2020
-- Description:	Hromadné změna materiálového času duplicitního na kmenové kartě
-- =============================================


IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT as KZE WHERE   KZE.ID =@ID )
     BEGIN 
           INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_material_time_duplicite) 
           VALUES (@ID, @_EXT_RS_material_time_duplicite)
     END
ELSE
     BEGIN
           UPDATE TabKmenZbozi_EXT  SET _EXT_RS_material_time_duplicite =@_EXT_RS_material_time_duplicite  WHERE ID =@ID
     END
GO

