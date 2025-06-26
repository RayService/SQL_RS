USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_OdhadZvyseniNC]    Script Date: 26.06.2025 8:54:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		OZE
-- Create date: 27.8.2013
-- Description:	Hromadná změna nad Zboží a služby - položka "Odhadované zvýšení nákupní ceny"
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_OdhadZvyseniNC]
	@Hodnota NUMERIC(19,6)
	,@ID INT
	
AS
SET NOCOUNT ON;

UPDATE TabKmenZbozi SET 
OdhadZvysNakupniCeny = @Hodnota
WHERE ID = @ID
GO

