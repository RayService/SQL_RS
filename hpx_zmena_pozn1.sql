USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_zmena_pozn1]    Script Date: 26.06.2025 10:27:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_zmena_pozn1]
@zmena VARCHAR (255),
@ID INT
AS

UPDATE TabDokladyZbozi  SET Poznamka = @zmena WHERE ID = @ID
GO

