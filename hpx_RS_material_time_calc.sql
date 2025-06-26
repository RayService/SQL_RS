USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_material_time_calc]    Script Date: 26.06.2025 10:04:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_material_time_calc] @ID INT

AS

DECLARE @_EXT_RS_item_time NUMERIC(19,6)

-- =============================================
-- Author:		MŽ
-- Create date:            25.2.2019
-- Description:	Výpočet materiálového času do položky kusovníku dle: Toto pole se bude plnit hromadně externí akcí – výpočtem. Definice je („Materiálový čas“ * TabKvazby.mnozstvi)/60. Toto pole bude také ručně editovatelné/vyplnitelné.
-- Nově: nedělit 60, ale ponechat v minutové stopáži
-- =============================================

SELECT @_EXT_RS_item_time = ROUND((
(SELECT _EXT_RS_material_time FROM TabKVazby
  LEFT OUTER JOIN TabKmenZbozi tkz ON TabKvazby.nizsi=tkz.ID
  LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID= tkz.ID
  WHERE	TabKVazby.ID = @ID) * (SELECT mnozstviSeZtratou FROM TabKVazby WHERE TabKVazby.ID = @ID)), 3)


IF NOT EXISTS (SELECT * FROM TabKVazby_EXT as tkv WHERE tkv.ID =@ID )
     BEGIN
           INSERT INTO TabKVazby_EXT (ID,_EXT_RS_item_time) 
           VALUES (@ID, @_EXT_RS_item_time)
     END
ELSE
     BEGIN
           UPDATE TabKvazby_EXT  SET _EXT_RS_item_time =@_EXT_RS_item_time  WHERE ID =@ID
     END
GO

