USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_DenikZmenaDatumPorizeno]    Script Date: 26.06.2025 8:42:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Create date: 21.5.2012
-- Description:	Změna data pořízení dokladu
-- =============================================
CREATE PROCEDURE [dbo].[hpx_ReseniHeO_DenikZmenaDatumPorizeno]
	@NoveDatum DATETIME			-- nové datum
	,@ID INT					-- ID v TabDenik
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @PuvodniDatum_Cas DATETIME;

/* kontroly */
IF @NoveDatum IS NULL
	BEGIN
		RAISERROR (N'Nové datum pořízení dokladu nezadáno!',16,1)
		RETURN
	END

/* funkční tělo procedury */
-- vytrhneme casovou slozku z puvodniho data
SELECT @PuvodniDatum_Cas = DATEADD(DAY,-DATEDIFF(DAY,0,DatumPorizeno),DatumPorizeno)
FROM TabDenik
WHERE ID = @ID;

-- nastavime nove datum vc. puvodni casove slozky
SET @NoveDatum = (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,@NoveDatum)))) + @PuvodniDatum_Cas;

-- aktualizujeme
UPDATE TabDenik SET
	DatumPorizeno = @NoveDatum
	,Zmenil = SUSER_SNAME()
	,DatZmeny = GETDATE()
WHERE ID = @ID;
GO

