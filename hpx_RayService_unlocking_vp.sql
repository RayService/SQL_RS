USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_unlocking_vp]    Script Date: 26.06.2025 9:53:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_unlocking_vp] @ID INT

As

begin

if (exists(
		SELECT * 
		FROM TabPrikaz a 
		INNER JOIN TabPrikaz_EXT b ON a.ID = b.ID 
		WHERE (SUSER_SNAME() IN (b._EXT_locking_user,'sa','velecky') AND a.ID = @ID)
		)) begin
	       Update TabPrikaz_EXT
	       Set TabPrikaz_EXT._EXT_locked = 0, TabPrikaz_EXT._EXT_locking_user = ''
	       Where ID = @ID
         end
		 ELSE
		 BEGIN
         ROLLBACK
         RAISERROR('Odemknutí není povoleno.', 16, 1);
      END
end
GO

