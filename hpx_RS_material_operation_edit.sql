USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_operation_edit]    Script Date: 26.06.2025 10:05:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_material_operation_edit]
@_EXT_RS_material_operation INT,
@ID INT
AS

-- =============================================
-- Author:		MŽ
-- Create date:            11.4.2019
-- Description:	Hromadná změna materiálové operace na kmenové kartě
-- =============================================


IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT as KZE WHERE   KZE.ID =@ID )
     BEGIN 
           INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_material_operation) 
           VALUES (@ID, @_EXT_RS_material_operation)
     END
ELSE
     BEGIN
           UPDATE TabKmenZbozi_EXT  SET _EXT_RS_material_operation =@_EXT_RS_material_operation  WHERE ID =@ID
     END
GO

