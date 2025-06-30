USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaCostDriver]    Script Date: 30.06.2025 8:57:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaCostDriver]
@CostDriver BIT,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
UPDATE TabStrukKusovnik_kalk_cenik SET CostDriver=@CostDriver WHERE ID=@ID;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

