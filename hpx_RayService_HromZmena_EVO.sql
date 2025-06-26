USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_HromZmena_EVO]    Script Date: 26.06.2025 9:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_HromZmena_EVO]
 @Pricina NVARCHAR(250),
 @Vliv NVARCHAR(5),
 @ID INT
AS
SET NOCOUNT ON

IF NOT EXISTS(SELECT 0 FROM TabPrikazMzdyAZmetky_EXT WHERE ID=@ID)
 INSERT INTO TabPrikazMzdyAZmetky_EXT (ID) VALUES (@ID)

UPDATE TabPrikazMzdyAZmetky_EXT SET _poppric=@Pricina, _vlivnaprod=@Vliv WHERE ID=@ID
GO

