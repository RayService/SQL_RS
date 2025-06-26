USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_locking_vp]    Script Date: 26.06.2025 9:53:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_locking_vp] @ID INT

As
begin

	if not exists (Select 0 From dbo.TabPrikaz_EXT WHERE ID = @ID)
	begin
		insert into dbo.TabPrikaz_EXT (ID) Values (@ID)
	end

	Update dbo.TabPrikaz_EXT
	Set _EXT_locked = 1, _EXT_locking_user = SUSER_NAME()
	Where ID = @ID
end
GO

