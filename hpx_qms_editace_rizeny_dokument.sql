USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_qms_editace_rizeny_dokument]    Script Date: 26.06.2025 11:56:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_qms_editace_rizeny_dokument]
@Predmet NVARCHAR(255),
@ID INT
AS
-- =============================================
-- Author:		MŽ
-- Create date:            1.11.2019
-- Description:	Editace pole Řízený dokument v QMS
-- =============================================

BEGIN
           UPDATE TabKontaktJednani SET Predmet =@Predmet  WHERE ID =@ID
END
GO

