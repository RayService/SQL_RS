USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVPostupHromZmena]    Script Date: 26.06.2025 8:59:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Hromědná změna technologických postupů
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_TPVPostupHromZmena]
	@TypOznaceni NVARCHAR(10)	-- typové označení
	,@TypOznaceniPrepsat BIT	-- přepsat typové označení
	,@ID INT
AS
SET NOCOUNT ON;

SET @TypOznaceni = NULLIF(@TypOznaceni,N'');

UPDATE TabPostup SET
	TypOznaceni = CASE WHEN ISNULL(TypOznaceni,N'') = N'' OR @TypOznaceniPrepsat = 1 THEN @TypOznaceni ELSE TypOznaceni END
WHERE ID = @ID;
GO

