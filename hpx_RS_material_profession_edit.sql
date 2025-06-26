USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_profession_edit]    Script Date: 26.06.2025 10:02:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_profession_edit]
@_EXT_RS_material_profession INT,
@ID INT
AS

-- =============================================
-- Author:		MŽ
-- Create date:            20.2.2019
-- Description:	Hromadné změna materiálové profese na kmenové kartě
-- =============================================


IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT as KZE WHERE KZE.ID = @ID )
     BEGIN 
           INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_material_time) 
           VALUES (@ID, @_EXT_RS_material_profession)
     END
ELSE
     BEGIN
           UPDATE TabKmenZbozi_EXT SET _EXT_RS_material_profession = @_EXT_RS_material_profession WHERE ID = @ID
     END
GO

