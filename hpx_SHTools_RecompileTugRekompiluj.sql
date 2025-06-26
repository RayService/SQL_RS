USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SHTools_RecompileTugRekompiluj]    Script Date: 26.06.2025 15:27:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[hpx_SHTools_RecompileTugRekompiluj]
	@object_id int  /* ID v hvw_SHTools_RecompileTug */
AS
-- =============================================
-- Author: Jiri Dolezal (JiriDolezalSQL@gmail.com)
-- Description: Vynucení rekompilace vybraného objektu
-- Copyright:	Nasazeni v jinych prostredich? Kontaktujte autora! Plagiatorstvi je zalezitost svedomi.
-- =============================================
BEGIN
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @fq_object_name nvarchar(257) = OBJECT_SCHEMA_NAME(@object_id) + N'.' + OBJECT_NAME(@object_id);

		EXEC sys.sp_recompile
			@objname = @fq_object_name;

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;
END;
GO

