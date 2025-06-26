USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVPoradiOperaceEdit]    Script Date: 26.06.2025 9:00:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RayService_TPVPoradiOperaceEdit]
	@Operace NVARCHAR(4)	-- zadaná hodnota
	,@ID INT					-- ID v TabTypPostup
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Editace sloupce Poradi operace typovych operaci
-- =============================================

IF @Operace = N''
	SET @Operace = NULL;
ELSE
	SET @Operace = RIGHT((REPLICATE(CHAR(32),4) + @Operace),4);

/* kontroly */
IF @Operace IS NOT NULL
	BEGIN
	
		IF EXISTS(SELECT * FROM TabTypPostup_EXT
					WHERE _RayService_Operace = @Operace
						AND ID <> @ID)
			BEGIN
				RAISERROR (N'Duplicitní hodnota Pořadí operace: Nepovoleno!',16,1);
				RETURN;
			END;
		
		IF LEN(RTRIM(LTRIM(@Operace))) < 3
			BEGIN
				RAISERROR (N'Pořadí operace má méně jak 3 znaky (mezeru nepočítaje): Nepovoleno!',16,1);
				RETURN;
			END;
			
		IF RTRIM(LTRIM(@Operace)) LIKE N'%[^0-9]%'
			BEGIN
				RAISERROR (N'Pořadí operace obsahuje nečíselné znaky (mezeru nepočítaje): Nepovoleno!',16,1);
				RETURN;
			END;
			
	END
	

	
/* funkcni telo procedury */
IF @Operace IS NOT NULL
	AND NOT EXISTS(SELECT * FROM TabTypPostup_EXT WHERE ID = @ID)
	INSERT INTO TabTypPostup_EXT(ID)
	VALUES(@ID);
UPDATE TabTypPostup_EXT SET
	_RayService_Operace = @Operace
WHERE ID = @ID;
GO

