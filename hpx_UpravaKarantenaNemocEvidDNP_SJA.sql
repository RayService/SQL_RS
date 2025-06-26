USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UpravaKarantenaNemocEvidDNP_SJA]    Script Date: 26.06.2025 11:20:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_UpravaKarantenaNemocEvidDNP_SJA] @Karantena BIT
                  ,@Prepsat BIT
	,@ID INT
AS

IF @Prepsat<>1
BEGIN
   RAISERROR(N'Nebyla potvrzena změna položky karanténa', 16, 1) 
   RETURN
END


IF EXISTS (
		SELECT ID
		FROM TabMzEvidenceDNP
		WHERE ID = @ID
			AND TabMzEvidenceDNP.DruhDavky = 1
		)
BEGIN
	UPDATE TabMzEvidenceDNP
	SET NM_Karantena = @Karantena
	WHERE id = @ID
END
ELSE
BEGIN
	RAISERROR (
			N'Označený záznam není dávka nemoci'
			,16
			,1
			)

	RETURN
END
GO

