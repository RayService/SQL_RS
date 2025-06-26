USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_HromZmenaCofC]    Script Date: 26.06.2025 8:41:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Create date: 15.5.2012
-- Description:	Hromadná změna - CofC požadováno
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_HromZmenaCofC]
	@ID INT			-- ID v TabKmenZbozi
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @IDKusovnik INT;
DECLARE @IDVarianta INT;
DECLARE @nizsi INT;

SELECT
	@IDKusovnik = IdKusovnik
	,@IDVarianta = IdVarianta
FROM TabKmenZbozi
WHERE ID = @ID;

/* fuknčí tělo procedury */
DECLARE CurKVazby CURSOR LOCAL FAST_FORWARD FOR
	SELECT
		nizsi
	FROM TabKvazby
	  LEFT OUTER JOIN TabCzmeny VZmenaOd ON TabKvazby.ZmenaOd = VZmenaOd.ID
	  LEFT OUTER JOIN TabCzmeny VZmenaDo ON TabKvazby.ZmenaDo = VZmenaDo.ID
	WHERE TabKVazby.vyssi = @IDKusovnik
		AND (TabKVazby.IDVarianta IS NULL OR TabKVazby.IDVarianta = @IDVarianta) 
		AND	(VZmenaOd.platnostTPV=1 AND VZmenaOd.datum <= GETDATE())
		AND	(VZmenaDo.platnostTPV=0 
				OR TabKVazby.ZmenaDo IS NULL 
				OR (VZmenaDo.platnostTPV=1 AND VZmenaDo.datum > GETDATE()))
OPEN CurKVazby;
FETCH NEXT FROM CurKVazby INTO @nizsi;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		-- zacatek akce v kurzoru CurKVazby
		
		-- neexistuje řádek v EXT
		IF NOT EXISTS(SELECT * FROM TabKmenZbozi_EXT WHERE ID = @ID)
			INSERT INTO TabKmenZbozi_EXT(ID) VALUES(@nizsi);
			
		-- aktualizujeme
		UPDATE TabKmenZbozi_EXT SET
			_Cofc_en10204 = 1
		WHERE ID = @nizsi;
		
		-- konec akce v kurzoru CurKVazby
	FETCH NEXT FROM CurKVazby INTO @nizsi;
	END;
CLOSE CurKVazby;
DEALLOCATE CurKVazby;



	



GO

