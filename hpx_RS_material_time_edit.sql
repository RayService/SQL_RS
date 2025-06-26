USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_time_edit]    Script Date: 26.06.2025 10:01:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_time_edit]
@_EXT_RS_material_time NUMERIC (19,6),
@ID INT
AS

-- =============================================
-- Author:		MŽ
-- Create date:            17.2.2019
-- Description:	Hromadné změna materiálového času na kmenové kartě
-- =============================================


IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT as KZE WHERE   KZE.ID =@ID )
     BEGIN 
           INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_material_time) 
           VALUES (@ID, @_EXT_RS_material_time)
     END
ELSE
     BEGIN
           UPDATE TabKmenZbozi_EXT  SET _EXT_RS_material_time =@_EXT_RS_material_time  WHERE ID =@ID
     END
GO

